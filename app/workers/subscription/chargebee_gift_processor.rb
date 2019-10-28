require 'chargebee'
require 'resque/plugins/lock'

# Ensure 1 claimed gift always results in the promotional credits being applied

module Subscription
  class ChargeBeeGiftProcessor
    extend Resque::Plugins::Lock

    @queue = 'ChargeBeeGiftProcessor'

    def self.lock(params)
      "ChargeBeeGiftProcessor-#{params[:gift_id]}"
    end

    # Params
    # {
    #   :gift_id => 123,
    #   :user_id => 456,
    #   :plan_amount => 6900,
    #   :currency_code => 'USD'
    # }
    def self.perform(params)
      Rails.logger.info("ChargeBeeGiftProcessor starting perform with params=#{params.inspect}")

      if already_completed?(params[:gift_id])
        Rails.logger.info("ChargeBeeGiftProcessor already completed, skipping processing")
      else
        process(params)
      end

      Librato.increment('ChargeBeeGiftProcessor.success', sporadic: true)
      Librato.tracker.flush
    end

    def self.process(params)
      mark_started(params[:gift_id])
      claim_gift(params[:gift_id])
      add_promotional_credit(params[:gift_id], params[:user_id], params[:plan_amount], params[:currency_code])
      mark_completed(params[:gift_id])
    end

    def self.mark_started(gift_id)
      ChargebeeGiftRedemptions.create!(:gift_id => gift_id)
    end

    def self.mark_completed(gift_id)
      gift_redemption = ChargebeeGiftRedemptions.find_by_gift_id!(gift_id)
      gift_redemption.complete = true
      gift_redemption.save!
    end

    def self.already_completed?(gift_id)
      ChargebeeGiftRedemptions.where(:gift_id => gift_id).where(:complete => true).exists?
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
                                                      :description => gift_code
                                                  })
      else
        Rails.logger.info("ChargeBeeGiftProcessor - promotional credit already redeemed")
      end
    end
  end
end

