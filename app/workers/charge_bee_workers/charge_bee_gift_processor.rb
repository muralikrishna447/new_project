require 'chargebee'
require 'resque/plugins/lock'

# This class in conjunction with ChargeBeeGiftWorker are responsible for ensuring
# that 1 claimed gift always results in the promotional credit being applied to the customer's account
#
# This is necessary because (due to the way we are using ChargeBee) there are two steps necessary to redeem a gift:
#  1) Claim the gift - this can only be done for unclaimed gifts so is a one time process
#  2) Add the promotional credits to the user's account
#
# Both steps are done via an API call to ChargeBee.  It is therefore possible for #1 to succeed but for #2 to fail or not happen.
#
# ChargeBeeGiftProcessor does the following
#   a) Mark this redemption as started in a sql table
#   b) Claim the Gift with Chargebee
#   c) Add the promotion credit
#   d) Mark this redemption as complete in a sql table
#
# All of these steps can be re-tried without harm.
# But, it is NOT safe to have multiple concurrent executions of this job for the same gift_id.
# Step c (add the promotional credit) has a race condition and could result in multiple promotional credits being added for one gift
# Because of this, we use the Resque Lock to ensure that only one of these processor jobs can be queued per gift_id at a time

module ChargeBeeWorkers
class ChargeBeeGiftProcessor
  extend Resque::Plugins::Lock

  @queue = 'ChargeBeeGiftProcessor'

  def self.lock(params)
    "ChargeBeeGiftProcessor-#{params[:gift_id]}"
  end

  # Params
  # {
  #   :gift_id => '123',
  #   :user_id => 456,
  #   :plan_amount => 6900,
  #   :currency_code => 'USD'
  # }
  def self.perform(params)
    symbolized_params = params.deep_symbolize_keys

    Rails.logger.info("ChargeBeeGiftProcessor starting perform with params=#{symbolized_params.inspect}")

    if already_completed?(symbolized_params[:gift_id])
      Rails.logger.info("ChargeBeeGiftProcessor already completed, skipping processing")
    else
      process(symbolized_params)
    end

    Librato.increment('ChargeBeeGiftProcessor.success', sporadic: true)
    Librato.tracker.flush
  end

  def self.process(params)
    Rails.logger.info('ChargeBeeGiftProcessor.process - started')
    mark_started(params)
    Rails.logger.info('ChargeBeeGiftProcessor.process - before claim')
    claim_gift(params[:gift_id])
    Rails.logger.info('ChargeBeeGiftProcessor.process - before promotional credit')
    add_promotional_credit(params[:gift_id], params[:user_id], params[:plan_amount], params[:currency_code])
    Rails.logger.info('ChargeBeeGiftProcessor.process - before mark complete')
    mark_completed(params[:gift_id])
    Rails.logger.info('ChargeBeeGiftProcessor.process - completed')
  end

  def self.mark_started(params)
    ChargebeeGiftRedemptions.first_or_create(:gift_id => params[:gift_id], :user_id => params[:user_id], :plan_amount => params[:plan_amount], :currency_code => params[:currency_code])
  end

  def self.mark_completed(gift_id)
    gift_redemption = ChargebeeGiftRedemptions.where(:gift_id => gift_id).first
    gift_redemption.complete = true
    gift_redemption.save!
  end

  def self.already_completed?(gift_id)
    ChargebeeGiftRedemptions.complete.where(:gift_id => gift_id).exists?
  end

  def self.claim_gift(gift_id)
    begin
      ChargeBee::Gift.claim(gift_id)
    rescue ChargeBee::InvalidRequestError => e
      Rails.logger.info('ChargeBeeGiftProcessor - gift already claimed')
    end
  end

  def self.add_promotional_credit(gift_id, user_id, plan_amount, currency_code)
    result = ChargeBee::PromotionalCredit.list({
                                                             "customer_id[is]" => user_id,
                                                             "type[is]" => "increment",
                                                             :limit => 100
                                                         })

    if result.next_offset.present?
      raise StandardError.new("ChargeBeeGiftProcessor - promotional credit list returned more than 100 promotional credits - gift_id=#{gift_id} user_id=#{user_id}")
    end

    # We are using the "description" field to identify the Gift Redemption
    # This is the only field we can control to uniquely identify the promotional code
    # which is also returned by the list call.  Unfortunately, the API does not allow us to control the ID
    credit_code = "Gift Redemption #{gift_id}"
    already_added = result.list.any? do |credit|
      credit.description == credit_code
    end

    unless already_added
      Rails.logger.info("ChargeBeeGiftProcessor - creating promotional credit")
      ChargeBee::PromotionalCredit.add({
                                                    :customer_id => user_id,
                                                    :amount => plan_amount,
                                                    :currency_code => currency_code,
                                                    :description => credit_code
                                                })
    else
      Rails.logger.info("ChargeBeeGiftProcessor - promotional credit already redeemed")
    end
  end
end
end
