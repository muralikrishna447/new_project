require 'signifyd'
require 'retriable'

module Fraud
  class PaymentProcessor
    include Shopify::PaymentCapturer

    # Minimum Signifyd score needed to capture payment automatically.
    SIGNIFYD_MIN_SCORE = 450.0

    # We'll tolerate an order not being available in Signifyd
    # for up to one hour.
    SIGNIFYD_NOT_FOUND_WINDOW_SECONDS = 3600.0

    # We store the Signifyd score on the order as a note attribute.
    SIGNIFYD_SCORE_ATTR_NAME = 'signifyd-fraud-score'

    @queue = 'PaymentProcessor'

    def self.perform(order_id)
      raise "PaymentProcessor deprecated"
      Rails.logger.info("PaymentProcessor starting perform on order with id #{order_id}")
      order = Shopify::Utils.order_by_id(order_id)

      if capturable?(order)
        signifyd_case = signifyd_case(order)
        if signifyd_case
          process_capturable_order(order, signifyd_case)
        elsif order_is_new?(order)
          # There could be a case where we try to process the order before
          # it is available to look up in Signifyd's API. We set a short time
          # window where we take a pass if a very recent order cannot be found.
          # Outside of the time window, we raise an error.
          Rails.logger.warn "PaymentProcessor order with id #{order.id} is capturable " \
                            'and has no Signifyd case, but is very new, so skipping it for now'
          return
        else
          msg = "PaymentProcessor order with id #{order.id} has no Signifyd case and is capturable"
          Rails.logger.error msg
          raise msg
        end
      else
        # Assume that if the order has a score that we've previously closed
        # the Signifyd case. This is a cheap way to avoid more Shopify API
        # calls. Not foolproof, but more than good enough.
        return if order_has_score?(order)

        # Ensure we close cases in Signifyd that are not capturable
        # (e.g., orders that have been cancelled) so they don't
        # clutter up the review queue.
        signifyd_case = signifyd_case(order)
        close_signifyd_case(order, signifyd_case) if signifyd_case
      end

      Librato.tracker.flush
      Rails.logger.info "PaymentProcessor finished perform on order with id #{order_id}"
    end

    def self.process_capturable_order(order, signifyd_case)
      raise "PaymentProcessor deprecated"
      fraud_score = signifyd_case['score']
      add_score_to_order(order, fraud_score)

      # We use PremiumOrderProcessor to capture premium-only orders.
      if Shopify::Utils.contains_only_premium?(order)
        Rails.logger.info("PaymentProcessor order with id #{order.id} has " \
                          'only premium line item, not capturing payment and closing signifyd case')
        close_signifyd_case(order, signifyd_case)
      elsif fraud_score > SIGNIFYD_MIN_SCORE
        Rails.logger.info("PaymentProcessor order with id #{order.id} has " \
                          "Signifyd score #{fraud_score} and is above min score, capturing payment")
        capture_and_close(order, signifyd_case)
      else
        Rails.logger.info("PaymentProcessor order with id #{order.id} has " \
                          "Signifyd score #{fraud_score} and is below min score, not capturing payment")
      end
    end

    # Looks up the Signifyd case for the specified Shopify order.
    # Returns nil if the case cannot be found.
    def self.signifyd_case(order)
      raise "PaymentProcessor deprecated"
      response = nil
      Retriable.retriable tries: 3 do
        begin
          response = Signifyd::Case.find(order_id: order.order_number)
        rescue Signifyd::InvalidRequestError
          # No case for that order number exists
          return nil
        end
      end
      if response[:code] != 200
        raise "Signifyd returned unexpected response code #{response[:code]} for order number #{order.number}"
      end
      response[:body]
    end

    # Adds the Signifyd score and risk level to the Shopify
    # order risks so it's visible there. Fancy!
    def self.add_score_to_order(order, score)
      raise "PaymentProcessor deprecated"
      return if order_has_score?(order)

      order.note_attributes.push(ShopifyAPI::NoteAttribute.new(
        name: SIGNIFYD_SCORE_ATTR_NAME,
        value: score
      ))
      save_order_notes(order)

      recommendation = 'accept'
      if score <= SIGNIFYD_MIN_SCORE
        recommendation = 'investigate'
        # Premium-only orders are known to score low due to lack of
        # shipping address and they aren't manually reviewed, so don't count
        # them in the metrics.
        unless Shopify::Utils.contains_only_premium?(order)
          Librato.increment 'fraud.payment-processor.orders.lowscore.count', sporadic: true
        end
      end
      risk = ShopifyAPI::OrderRisk.new(
        display: true,
        message: "The Signifyd fraud score is #{score.to_i}.",
        recommendation: recommendation,
        score: (1000 - score) / 1000,
        source: 'external'
      )
      risk.prefix_options[:order_id] = order.id
      Shopify::Utils.send_assert_true(risk, :save)
    end

    def self.capture_and_close(order, signifyd_case)
      raise "PaymentProcessor deprecated"
      capture_payment(order)
      Librato.increment 'fraud.payment-processor.capture.count', sporadic: true
      close_signifyd_case(order, signifyd_case)
    end

    def self.close_signifyd_case(order, signifyd_case)
      raise "PaymentProcessor deprecated"
      case_id = signifyd_case['caseId']
      status = signifyd_case['status']
      if status == 'DISMISSED'
        Rails.logger.info("PaymentProcessor Signifyd case with id #{case_id} is already closed")
      else
        Rails.logger.info("PaymentProcessor Signifyd case with id #{case_id} " \
                          "has status #{status}, closing")
        Retriable.retriable tries: 3 do
          Signifyd::Case.update(case_id, 'status' => 'DISMISSED')
        end
      end
    end

    def self.order_is_new?(order)
      raise "PaymentProcessor deprecated"
      processed_at = Time.parse(order.processed_at)
      (Time.now - processed_at) <= SIGNIFYD_NOT_FOUND_WINDOW_SECONDS
    end

    def self.order_has_score?(order)
      raise "PaymentProcessor deprecated"
      return true if order.note_attributes.find { |attr| attr.name == SIGNIFYD_SCORE_ATTR_NAME }
      false
    end

    private

    def self.save_order_notes(order)
      # We create a new order object with the minimal set of fields so as
      # to not trigger Shopify's built-in address validation which may
      # cause the save to fail.
      updated = ShopifyAPI::Order.new(
        id: order.id,
        note_attributes: order.note_attributes
      )

      Shopify::Utils.send_assert_true(updated, :save)
    end
  end
end
