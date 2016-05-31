# - Need to try hard to avoid dupes!
#      - use metafield in stripe for synchronization
#      - shopify_order_id: “in_flight” or else order id
# 
# - Make sure customer exists with correct multipass identifier
# - Add meta field for stripe order id, "our" stripe order id, and user id - why not!
# 
# order
#      - tax lines need to be correct - fortunately we have only one sku...
#      charge
#           card
#                - billing address


# stripe order for export object
#  - comparator method
# 

# staging values:

Stripe.api_key =  'sk_live_WAwZz56nyVf1OAH2D6uCMmfK'

PREMIUM_VARIANT_ID = '13403946119'
JOULE_VARIANT_ID = '11152885767'

PREMIUM_VARIANT_ID = 
JOULE_VARIANT_ID

SHOPIFY_IMPORT_STATUS = 'shopify_import_status'
SHOPIFY_ORDER_ID = 'shopify_order_id'

#Rails.logger.log_level = :debug
order_id = 'or_8NUA1GccgVEV5r'

Rails.logger = Logger.new(STDOUT)
def import_to_shopify(order_id)
  Rails.logger.info "Processing stripe order #{order_id}"

  stripe_order = Stripe::Order.retrieve(order_id)
  if stripe_order.status != 'paid'
    Rails.logger.warn "Stripe order not paid"
    return
  end
  Rails.logger.debug stripe_order.inspect

  import_status = stripe_order.metadata['shopify_import_status']

  Rails.logger.info "Import status: #{import_status.inspect}"
  if import_status.nil?
    import_status = 'in_progress'
    stripe_order.metadata['shopify_import_status'] = import_status
    stripe_order.save
  elsif import_status == 'in_progress'
    Rails.logger.info "Import already started - needs manual resolution"
    Rails.logger.info "Shopify order id (possible not set): [#{order.metadata['shopify_order_id']}]"
    return
  elsif import_status == 'imported'
    Rails.logger.info "Order already imported"
    return
  end

  Rails.logger.info "Stripe customer #{stripe_order.customer}"
  user = User.where(stripe_id: stripe_order.customer).first
  if user.nil?
    Rails.logger.error "No user found with stripe id."
  else
    Rails.logger.info "Found user id #{user.id} with email #{user.email}"
  end

  # Verify that shopify user is in order, emails match, etc
  customer = Shopify::Customer.sync_user(user)

  customer = Stripe::Customer.retrieve(stripe_order.customer)
  charge = Stripe::Charge.retrieve(stripe_order.charge)
  stripe_card = charge['card']
  
  Rails.logger.debug "Stripe card [#{stripe_card}]"
  
  shopify_order = {}
  shopify_order[:email] = user.email
  sku_item = stripe_order.items.select {|i| i.type == 'sku'}.first
  tax_item = stripe_order.items.select {|i| i.type == 'tax'}.first

  line_item = {
    quantity: 1, 
    price: sku_item['amount'].to_f / 100,
    taxable: true,
  }

  add_all_but_joule_metafield = true
  if sku_item['parent'] == 'cs10001'
    line_item[:variant_id] = JOULE_VARIANT_ID
    add_all_but_joule_metafield = true
    # Ensures order is unfulfilled
    shopify_order[:fulfillements] = []
  elsif sku_item['parent'] == 'cs10002'
    line_item[:variant_id] = PREMIUM_VARIANT_ID
  else
    raise "Unknown sku #{sku_item.inspect}"
  end

  shopify_order[:line_items] = [line_item]

  #shopify_order[:total_tax] = tax_item['amount'].to_f / 100
  shopify_order[:total_tax] = 1200.to_f / 100
  
  sc = stripe_card
  shopify_order[:billing_address] = {
    last_name: sc['name'],
    address1: sc['address_line1'],
    address2: sc['address_line2'],
    city: sc['address_city'],
    province: sc['address_state'],
  zip: sc['address_zip'],
    country: sc['address_country']
  }
  
  ssa = stripe_order['shipping']['address']
  # Means first name will not be filled in better than sketchy split?
  last_name = stripe_order['shipping']['name'] 
  phone = stripe_order['shipping']['phone']
  shopify_order[:shipping_address] = {   
     last_name: last_name,
     address1: ssa['line1'],
     address2: ssa['line2'],
     city: ssa['city'],
     province: ssa['state'],
     zip: ssa['postal_code'],
     country: ssa['country'],
    phone: phone
  }

  # "shipping": {"address":{"city":"Seattle","country":"United States","line1":"1811 e spring","line2":null,
  #   "postal_code":"98122","state":"WA"},"name":"asd asd","phone":null},

  # Import should trigger no emails
  shopify_order[:send_receipt] = false
  shopify_order[:send_fulfillment_receipt] = false

  shopify_order = ShopifyAPI::Order.create(shopify_order)
  Rails.logger.info "Created shopify order [#{shopify_order.id}]"
  Rails.logger.debug "Shopify order [#{shopify_order.inspect}]"

  if !shopify_order.errors.empty?
    raise "Failed to create shopify order"
  end

  if add_all_but_joule_metafield
    metafield = ShopifyAPI::Metafield.new({:namespace => Shopify::Order::METAFIELD_NAMESPACE,
      :key => Shopify::Order::ALL_BUT_JOULE_FULFILLED_METAFIELD_NAME,
      :value_type => 'string',
      :value => 'true'})
    shopify_order.add_metafield(metafield)
  end

  Rails.logger.info "Persisting order id in stripe order"
  stripe_order.metadata[SHOPIFY_ORDER_ID] = shopify_order.id
  stripe_order.save

  Rails.logger.info "Adding stripe order id as metafield"
  metafield = ShopifyAPI::Metafield.new({:namespace => Shopify::Order::METAFIELD_NAMESPACE,
    :key => 'stripe-order-id',
    :value_type => 'string',
    :value => stripe_order.id})
  shopify_order.add_metafield(metafield)
   
  stripe_order.metadata[SHOPIFY_IMPORT_STATUS] = 'imported'
  stripe_order.save

end


def audit_imported_order(order_id)
  stripe_order = Stripe::Order.retrieve(order_id)

  if stripe_order.metadata[SHOPIFY_IMPORT_STATUS] != 'imported'
    raise "Stripe order #{order_id} not imported"
  end
  # Barest of validations - make sure stripe order and shopify order are present / updated
  # Will prevent a million duplicates but little else
  shopify_order = ShopifyAPI::Order.find(stripe_order.metadata[SHOPIFY_ORDER_ID])
  

    
end

import_to_shopify(order_id)
audit_imported_order(order_id)
