class Shopify::Order
  PREMIUM_SKU = 'cs10002'
  JOULE_SKU = 'cs10001'
  
  METAFIELD_NAMESPACE = 'chefsteps' # duplicate code!?
  ALL_BUT_JOULE_FULFILLED_METAFIELD_NAME = 'all-but-joule-fulfilled'
  GIFT_ATTRIBUTE_NAME = "gift-order"

  def initialize(api_order)
    @api_order = api_order
  end
  
  def self.find(order_id)
    api_order = ShopifyAPI::Order.find(order_id)
    Shopify::Order.new(api_order)
  end

  def user
    return @user unless @user.nil?

    # TODO - add test coverage for user not found scenarios
    user_id = @api_order.customer.multipass_identifier
    if user_id.nil?
      # TODO - emit metrics
      msg = "No multipass identifier set for Shopify customer email [#{@api_order.customer.email}]"
      Rails.logger.error(msg)
      raise msg
    end

    @user = User.find(user_id)
    if @user.nil?
      msg = "User [#{user_id}] from multipass_identifier not found."
      Rails.logger.error(msg)
      raise msg
    end

    @user
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
    if all_but_joule_fulfilled?
      Rails.logger.info "Order already fulfilled."
      return
    end

    # TODO - handle orders in 'bad' states
    # TODO - get unfulfilled line items but for now assume all unfulfilled
    all_but_joule_fulfilled = true
    order_contains_joule = false
    @api_order.line_items.each do |item|
      Rails.logger.info "Processing line item [#{item.id}]"
      if item.fulfillment_status == 'fulfilled'
        Rails.logger.info "Line item already fulfilled"
        next
      end
      # Hard code the SKUs for now, we can talk when we have more than two
      if item.sku == JOULE_SKU
        order_contains_joule = true
        # TODO - add synchronization since we're not creating fulfilment objects here
        fulfill_premium(item, false)
        # TODO: actually check that premium discount was used
        user.use_premium_discount
      elsif item.sku == PREMIUM_SKU
        if !gift_order? && item.quantity > 1
          raise "Order contains more than one non-gift premium."
        end
        # TODO - check premium limit for non-gift
        fulfill_premium(item, true)
      else
        raise "Unknown product sku [#{item.sku}]"
      end
    end

    if order_contains_joule && all_but_joule_fulfilled
      all_but_joule = ShopifyAPI::Metafield.new({:namespace => METAFIELD_NAMESPACE,
        :key => ALL_BUT_JOULE_FULFILLED_METAFIELD_NAME,
        :value_type => 'string',
        :value => 'true'})
      @api_order.add_metafield(all_but_joule)
    end

    # Sync premium / discount status
    Shopify::Customer.sync_user(user)
  end
  
  def send_gift_receipt(item)
    # TODO - remove dupe
    #user = User.find(@api_order.customer.multipass_identifier)

    Rails.logger.info("Sending Gift Receipt")
    pgc = PremiumGiftCertificate.create!(purchaser_id: user.id, price: item.price, redeemed: false)
    PremiumGiftCertificateMailer.prepare(user, pgc.token) # deleted .deliver here because i'm not sure its needed
  end

  def all_but_joule_fulfilled?
    return true if @api_order.fulfillment_status == 'fulfilled'
    return true if @api_order.metafields.find { |metafield|
      metafield.key == ALL_BUT_JOULE_FULFILLED_METAFIELD_NAME && metafield.value == 'true' }
    return false
  end

  def gift_order?
    gift_attribute = @api_order.note_attributes.find {|attr| attr.name == 'gift-order'}
    Rails.logger.info("Found gift-order attribute #{gift_attribute.inspect}")
    return !gift_attribute.nil?
  end
  
  def fulfill_premium(item, should_fulfill)
    if gift_order?
      item.quantity.times do
        send_gift_receipt(item)
        if should_fulfill
          ShopifyAPI::Fulfillment.create(
            :order_id => @api_order.id,
            :line_items => [{:id => item.id, :quantity => 1}])
        else
          # TODO - create metafield for fulfilled quantity
        end
      end
    else
      user.make_premium_member(item.price)
    end
  end
end
