class StripeBatchProcessor
  @queue = :stripe_batch_processor
  def self.perform(event_type)
    case event_type
    when 'charged_orders'
      charged_order
    when 'cancelled_orders'
      cancelled_orders
    when 'charge_backs'
      # Going to have to query the stripe event log
    end
  end




  def charged_orders
    loop_stripe_orders(status: 'paid', limit: 1000) do |stripe_order|
      add_to_quickbooks(stripe_order)
    end
  end

  def add_to_quickbooks(stripe_order)
    # ECOMTODO Fill in with quickbooks connect code
  end

  def cancelled_orders
    loop_stripe_orders(status: 'cancelled', limit: 1000) do |stripe_order|
      add_to_quickbooks(stripe_order)
    end
  end


  def loop_stripe_orders(options)
    loop do
      stripe_orders = Stripe::Order.all(options)
      stripe_orders.each do |stripe_order|
        yield(stripe_order)
      end
      break unless stripe_orders.has_more
    end
  end
end
