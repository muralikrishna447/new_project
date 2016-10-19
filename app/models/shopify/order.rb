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

    if @api_order.customer.multipass_identifier.nil?
      Shopify::Customer.sync_user(user)
    end

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


    # TODO - Mark as starting fulfillment
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
        user.joule_purchased
      elsif item.sku == PREMIUM_SKU
        if !gift_order? && item.quantity > 1
          raise "Order contains more than one non-gift premium."
        end
        # TODO - check premium limit for non-gift
        fulfill_premium(item, true)
      else
        Rails.logger.info "Unknown sku [#{item.sku}]."
      end
    end

    # Exchange orders are, for the time being, identified by their total price
    if order_contains_joule && @api_order.total_price.to_f != 0
      JouleConfirmationMailer.prepare(user).deliver
    end

    if order_contains_joule && all_but_joule_fulfilled
      all_but_joule = ShopifyAPI::Metafield.new({:namespace => METAFIELD_NAMESPACE,
        :key => ALL_BUT_JOULE_FULFILLED_METAFIELD_NAME,
        :value_type => 'string',
        :value => 'true'})
      @api_order.add_metafield(all_but_joule)
    end

    initial_fulfillment_latency = Time.now - Time.parse(@api_order.created_at)
    Rails.logger.info "Initial fulfillment latency [#{initial_fulfillment_latency}]"
    Librato.timing 'shopify.fulfillment.initial.latency', initial_fulfillment_latency

    # Sync premium / discount status
    Shopify::Customer.sync_user(user)
    # TODO - figure out how to try to do this only once
    send_analytics
  end


  # PremiumWelcomeMailer.prepare(@user, data[:circulator_sale]).deliver rescue nil

  def send_gift_receipt(item)
    # TODO - remove dupe
    #user = User.find(@api_order.customer.multipass_identifier)

    Rails.logger.info("Sending Gift Receipt")
    pgc = PremiumGiftCertificate.create!(purchaser_id: user.id, price: item.price, redeemed: false)
    PremiumGiftCertificateMailer.prepare(user, pgc.token).deliver
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
    return !gift_attribute.nil? && gift_attribute.value == 'true'
  end
  
  def fulfill_premium(item, should_fulfill)
    item.quantity.times do
      if gift_order?
        send_gift_receipt(item)
      end
      if should_fulfill
        ShopifyAPI::Fulfillment.create(
          :order_id => @api_order.id,
          :line_items => [{:id => item.id, :quantity => 1}],
          :notify_customer => false)
      else
        # TODO - create metafield for fulfilled quantity
      end
    end

    if !gift_order?
      previously_premium = user.premium?
      user.make_premium_member(item.price)
      # use should_fulfill as a proxy for hackish proxy for contains joule
      unless previously_premium || 
        PremiumWelcomeMailer.prepare(user, !should_fulfill).deliver
      end
    end
  end
  
  def send_analytics()  
    segment_data = build_segment_data
    Rails.logger.info "Segment data: #{segment_data}"
    if !Analytics.track(segment_data)
      msg = "Error: problem tracking #{segment_data[:event]} #{segment_data}"
      Rails.logger.error(msg)
      raise msg
    end
    Analytics.identify(user_id: user.id, traits: {joule_purchase_count: user.joule_purchase_count})
    Analytics.flush()
    
    send_to_ga(build_transaction_ga_data)
    @api_order.line_items.each do |line_item|
      send_to_ga(build_product_ga_data(line_item))
    end
  end
  
  def build_segment_data
    data = extract_analytics_data
  
    products = @api_order.line_items.collect do |item|
      {
        id: item.sku,
        sku: item.sku,
        name: item.title,
        price: item.price,
        quantity: item.quantity
      }
    end

    skus = @api_order.line_items.collect{|line_item| line_item.sku}

    {
      event: 'Completed Order Workaround',
      user_id: user.id,
      context: {
        'GoogleAnalytics' => {
          clientId: data['google_analytics_client_id']
        },
        campaign: {
          name: data['utm_campaign'],
          source: data['utm_source'],
          medium: data['utm_medium'],
          term: data['utm_term'],
          content: data['utm_content']
        },
        referrer: {
          url: data['referrer']
        }
      },

      properties: {
        # Label drives goal 19, etc so is very important
        label: skus.join(","),
        product_skus: skus,
        orderId: @api_order.id,
        total: @api_order.total_price,
        revenue: @api_order.subtotal_price,
        tax: @api_order.total_tax,
        shipping: 0,
        # Make discount negative for backwards compatability
        discount: 0 - (@api_order.total_discounts || 0 ).to_f,
        gift: gift_order?,
        currency: 'USD',
        products: products,
      }
    }
  
  end

  # All these gibberish abbreviations are defined here:
  # https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters
  def build_common_ga_data
    data = extract_analytics_data

    ga_common = {
      'v' => 1,
      'tid' => ENV['GA_TRACKING_ID'],
      'cid' => data['google_analytics_client_id'],
      'uid' => user.id,
      'cu' => 'USD',
      'ti' => @api_order.id
    }
    ga_common['cn'] = data['utm_campaign'] if data['utm_campaign']
    ga_common['cs'] = data['utm_source'] if data['utm_source']
    ga_common['cm'] = data['utm_medium'] if data['utm_medium']
    ga_common['cc'] = data['utm_content'] if data['utm_content']
    ga_common['ck'] = data['utm_term'] if data['utm_term']
    ga_common['gclid'] = data['gclid'] if data['gclid']
    return ga_common
  end
  
  def build_transaction_ga_data
    ga_transaction = {
      't' => 'transaction',
      'ts' => 0,
      'tr' => @api_order.subtotal_price,
      'tt' => @api_order.total_tax,
    }.merge(build_common_ga_data)
  end

  def build_product_ga_data (line_item)
    ga_product = {
      't' => 'item',
      'iq' => line_item.quantity,
      'ip' => line_item.price,
      'in' => line_item.title,
      'ic' => line_item.sku
    }.merge(build_common_ga_data)
  end
  
  def google_analytics_client_id(ga_cookie)
    ga_cookie.gsub(/^GA\d\.\d\./, '')
  end
  
  def send_to_ga payload
    validation_url = 'https://www.google-analytics.com/debug/collect'
    validate_result = HTTParty.post(validation_url, { body: payload })
    Rails.logger.info("Validator result: #{validate_result.body.inspect}")
    if !JSON::parse(validate_result.body)['hitParsingResult'].first['valid']
      msg = "Error: invalid payload sent to GA: #{payload.inspect} #{validate_result.body.inspect}"
      Rails.logger.error(msg)
      raise msg
    end
    Rails.logger.info "GA data: #{payload}"
    submit_url = 'http://www.google-analytics.com/collect'
    HTTParty.post(submit_url, { body: payload })
  end

  def extract_analytics_data
    # There is JS in the shopify cart that copies the utm and _ga cookies to note attributes
    data = {}
        
    utm_data = @api_order.note_attributes.find {|attr| attr.name == 'utm'}
    if utm_data
      JSON.parse(utm_data.value).each_pair {|k,v| data[k] = v }
    end
    
    ga_data = @api_order.note_attributes.find {|attr| attr.name == 'ga'}
    data['google_analytics_client_id'] = google_analytics_client_id(ga_data.value) if ga_data

    return data
  end
end
