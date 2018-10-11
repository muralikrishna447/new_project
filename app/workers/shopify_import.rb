class ShopifyImport
  @queue = :shopify_import

  SHOPIFY_IMPORT_STATUS = 'shopify_import_status'
  SHOPIFY_ORDER_ID = 'shopify_order_id'

  def self.perform(stripe_order_id, skip_address = false, skip_billing = false)
    raise "ShopifyImport deprecated"
    import_to_shopify(stripe_order_id, skip_address, skip_billing)
    audit_imported_order(stripe_order_id)
  end

  def self.import_to_shopify(order_id, skip_address, skip_billing)
    raise "ShopifyImport deprecated"
    Rails.logger.info "Processing stripe order #{order_id}"

    stripe_order = Stripe::Order.retrieve(order_id)
    Rails.logger.info stripe_order.inspect

    import_status = stripe_order.metadata['shopify_import_status']

    Rails.logger.info "Import status: #{import_status.inspect}"
    if import_status.nil?
      import_status = 'in_progress'
      stripe_order.metadata['shopify_import_status'] = import_status
      stripe_order.save
    elsif import_status == 'in_progress'
      Rails.logger.info "Import already started - needs manual resolution"
      raise "Failed due to order in progress"
    elsif import_status == 'imported'
      Rails.logger.info "Finding and deleting shopify order for #{stripe_order.id}"
      begin
        shopify_order_id = stripe_order.metadata['shopify_order_id']
        o = ShopifyAPI::Order.find(shopify_order_id)
        Rails.logger.info "Found shopify order #{o.id}"
        o.cancel()
        o.destroy()
      rescue ActiveResource::ResourceNotFound
        Rails.logger.info "Shopify order #{shopify_order_id} not found"
      end

    elsif import_status == 'correctly_imported'
      Rails.logger.info "Order already imported"
      return
    end

    if stripe_order.status != 'paid'
      Rails.logger.warn "Stripe order not paid"
      # I know it's strange to mark this as correctly imported but...
      stripe_order.metadata['shopify_import_status'] = 'correctly_imported'
      stripe_order.save
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
    
    Rails.logger.info "Stripe card [#{stripe_card}]"
    
    shopify_order = {}
    shopify_order[:email] = user.email
    shopify_order[:processed_at] = Time.at(stripe_order.created).iso8601
    sku_item = stripe_order.items.select {|i| i.type == 'sku'}.first
    tax_item = stripe_order.items.select {|i| i.type == 'tax'}.first
    discount_item = stripe_order.items.select {|i| i.type == 'discount'}.first

    if discount_item
      discount = discount_item['amount']
    else
      discount = 0
    end

    line_item = {
      quantity: 1, 
      price: (sku_item['amount'] + discount).to_f / 100,
      taxable: true
    }

    add_all_but_joule_metafield = false
    if sku_item['parent'] == 'cs10001'
      line_item[:variant_id] = Rails.configuration.shopify[:joule_variant_id]
      add_all_but_joule_metafield = true
    elsif sku_item['parent'] == 'cs10002'
      line_item[:variant_id] = Rails.configuration.shopify[:premium_variant_id]
      shopify_order[:fulfillment_status] = "fulfilled"
      can_skip_address = true
    else
      raise "Unknown sku #{sku_item.inspect}"
    end

    shopify_order[:line_items] = [line_item]

    shopify_order[:total_tax] = tax_item['amount'].to_f / 100
    unless can_skip_address || skip_address
      if skip_address
        shopify_order[:tags] = "missing-address"
      end
      sc = stripe_card
      
      unless skip_billing
        shopify_order[:billing_address] = {
          last_name: sc['name'],
          address1: sc['address_line1'],
          address2: sc['address_line2'],
          city: sc['address_city'],
          province: sc['address_state'],
          zip: sc['address_zip'],
          country: sc['address_country']
        }
      end

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
    end
    # Import should trigger no emails
    shopify_order[:send_receipt] = false
    shopify_order[:send_fulfillment_receipt] = false
    shopify_order = ShopifyAPI::Order.create(shopify_order)
    Rails.logger.info "Created shopify order [#{shopify_order.id}]"
    Rails.logger.info "Shopify order [#{shopify_order.inspect}]"

    if !shopify_order.errors.empty?
      Rails.logger.error "Shopify order contains errors #{shopify_order.inspect}"
      
      # Revert import status to make retries less painful
      stripe_order.metadata['shopify_import_status'] = 'attempted'
      stripe_order.save

      raise "Failed to create shopify order"
    end

    if discount_item
      metafield = ShopifyAPI::Metafield.new({:namespace => Shopify::Order::METAFIELD_NAMESPACE,
        :key => 'premium-discount',
        :value_type => 'string',
        :value => (discount_item['amount'].to_f / 100).to_s})
      shopify_order.add_metafield(metafield)
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
    stripe_order.metadata[SHOPIFY_IMPORT_STATUS] = 'correctly_imported'
    stripe_order.save
  end

  def self.audit_imported_order(order_id)
    raise "ShopifyImport deprecated"
    stripe_order = Stripe::Order.retrieve(order_id)
    if stripe_order.status != 'paid'
      Rails.logger.info "Skipping audit as order is not paid"
      return
    end
    if stripe_order.metadata[SHOPIFY_IMPORT_STATUS] != 'correctly_imported'
      raise "Stripe order #{order_id} not imported"
    end
    # Barest of validations - make sure stripe order and shopify order are present / updated
    # Will prevent a million duplicates but little else
    shopify_order = ShopifyAPI::Order.find(stripe_order.metadata[SHOPIFY_ORDER_ID])
    shopify_total = (shopify_order.total_price.to_f * 100).to_i
    if shopify_total != stripe_order.amount
      raise "Totals do not match for order #{order_id} #{shopify_total} versus #{stripe_order.amount}"
    end
  end
end
