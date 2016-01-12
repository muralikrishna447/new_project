class Shopify::Order
  PREMIUM_SKU = 'cs10002'
  JOULE_SKU = 'cs10001'

  def initialize(api_order)
    @api_order = api_order
  end
  
  def self.find(order_id)
    api_order = ShopifyAPI::Order.find(order_id)
    Shopify::Order.new(api_order)
  end
  
  # Processes a shopify order.
  #  
  # For now, this means:
  #  * Making a customer premium when a customer purchases Premium or Joule
  #  * Creating fulfillment in Shopify for Premium orders
  #
  # Soon it will mean:
  #  * Handling gifts properly
  #  * Handling refunds properly
  #
  # A note on shopify fulfillment object:  Since there is a 1:1 mapping between
  # fulfillments in Shopify and line item units, premium membership associated
  # with Joule will not have an associated fulfillment object.
  
  def process!
    # TODO - fix order processing race condition - probably optimistic locking on user
    Rails.logger.info "Processing order [#{@api_order.id}] with financial_status [#{@api_order.financial_status}] and fulfillment_status [#{@api_order.fulfillment_status}]"
    
    # TODO - add test coverage for user not found scenarios
    user_id = @api_order.customer.multipass_identifier
    if user_id.nil?
      # TODO - emit metrics
      msg = "No multipass identifier set for Shopify customer email [#{@api_order.customer.email}]"
      Rails.logger.error(msg)
      raise msg
    end

    user = User.find(user_id)
    if user.nil?
      msg = "User [#{user_id}] from multipass_identifier not found."
      Rails.logger.error(msg)
      raise msg
    end

    # TODO - handle orders in 'bad' states
    # TODO - get unfulfilled line items but for now assume all unfulfilled
    
    @api_order.line_items.each do |item|
      Rails.logger.info "Processing line item [#{item.id}]"
      # Hard code the SKUs for now, we can talk when we have more than two
      if item.sku == JOULE_SKU        
        user.make_premium_member(item.price)
      elsif item.sku == PREMIUM_SKU
        user.make_premium_member(item.price)
        # TODO - handle quantities correctly
        ShopifyAPI::Fulfillment.create(
          :order_id => @api_order.id,
          :line_items => [{:id => item.id, :quantity => 1}])
      else
        raise "Unknown product sku [#{item.sku}]"
      end
    end
  end
end
