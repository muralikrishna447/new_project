require 'resque/plugins/lock'

# ChargeBeeGiftWorker picks up any failed gift redemptions and puts them on the ChargebeeGiftProcessor queue

module Subscription
  class ChargeBeeGiftWorker
    extend Resque::Plugins::Lock

    @queue = 'ChargeBeeGiftWorker'

    def self.lock(params)
      'ChargeBeeGiftWorker'
    end

    def self.perform
      Rails.logger.info('ChargeBeeGiftWorker starting')

      pending_count = ChargebeeGiftRedemptions.incomplete.count
      pending_redemptions = ChargebeeGiftRedemptions.incomplete.limit(limit)

      Rails.logger.info("ChargeBeeGiftWorker found #{pending_count} pending gift redemptions")

      pending_redemptions.each do |redemption|
        Resque.enqueue(Subscription::ChargeBeeGiftProcessor, {
            :gift_id => redemption.gift_id,
            :user_id => redemption.user_id,
            :plan_amount => redemption.plan_amount,
            :currency_code => redemption.currency_code
        })
      end

      if pending_count > limit
        Librato.increment('ChargeBeeGiftWorker.exceeded_limit', {})
      end

      Librato.increment('ChargeBeeGiftWorker.success', sporadic: true)
      Librato.tracker.flush
    end

    def self.limit
      ENV['CS_CHARGEBEEGIFTWORKER_LIMIT'].to_i || 100
    end

  end
end

