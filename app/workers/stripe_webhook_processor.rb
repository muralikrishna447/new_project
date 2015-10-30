class StripeWebhookProcessor
  @queue = :stripe_webhook_processor
  def self.perform(stripe_event_id)
    stripe_event = StripeEvent.find(stripe_event_id)
    return if stripe_event.processed

    # For the reports
    case stripe_event.event_type
    when 'charge.succeeded'

    when 'charge.refunded'

    when 'charge.dispute.created'

    when 'charge.dispute.closed'

    end

    # For the future orders
    case stripe_event.event_type
    when 'order.created'
      order_created(stripe_event)
    when 'order.payment_failed'
      order_created(stripe_event)
    when 'order.payment_succeeded'

    when 'order.updated'

    end

    # For the credit cards
    # case stripe_event.event_type
    # when ''
    # when ''
    # end

    # For the ecommerce products
    case stripe_event.event_type
    when 'sku.created'
      sku_handler(stripe_event)
    when 'sku.updated'
      sku_handler(stripe_event)
    when 'product.created'
      product_handler(stripe_event)
    when 'product.updated'
      product_handler(stripe_event)
    end

    stripe_event.processed = true
    stripe_event.save
  end








  def order_created(stripe_event)
    order_id = stripe_event.data["id"]
    unless Order.exists?(stripe_id: order_id)
      order = Order.new
      user = User.where(stripe_id: stripe_event.data["customer"]["id"]).first
      order.user_id = user.id
      order.stripe_id  = order_id
      order.total_amount = stripe_event.data["amount"]
      order.stripe_created_at = Time.parse(stripe_event.data["created"])
      order.stripe_updated_at = Time.parse(stripe_event.data["updated"])
      order.stripe_status = stripe_event.data["status"]
      order.metadata = stripe_event.data["metadata"]

      if stripe_event.data["charge"].present?
        charge = stripe_event.data["charge"]
        source = charge["source"]
        order.charge_id = charge["id"]
        order.billing_line_1 = source["address_line1"]
        order.billing_line_2 = source["address_line2"]
        order.billing_city = source["address_city"]
        order.billing_state = source["address_state"]
        order.billing_zip_code = source["address_zip"]
        order.billing_country = source["address_country"]
        order.card_type = source["brand"]
        order.last_4 = source["last4"]
      end

      if stripe_event.data["shipping"].present?
        shipping = stripe_event.data["shipping"]
        order.shipping_name = shipping["name"]
        order.shipping_phone = shipping["phone"]
        if shipping["address"].present?
          address = shipping["address"]
          order.shipping_line_1 = address["line1"]
          order.shipping_line_2 = address["line2"]
          order.shipping_city = address["city"]
          order.shipping_state = address["state"]
          order.shipping_zip_code = address["postal_code"]
          order.shipping_country = address["country"]
        end
      end


    end
  end

  def order_charged(stripe_event)
    order = Order.where(stripe_id: stripe_event.data["id"]).first
    setting = Setting.last
    access_token = OAuth::AccessToken.new($qb_oauth_consumer, setting.quickbooks_token, setting.quickbooks_secret)

    if false #Quickbooks::Model::SalesReceipt.find()
      #Invoices, SalesReceipts etc can also be defined in a single command
      salesreceipt = Quickbooks::Model::SalesReceipt.new({
        access_token: access_token,
        customer_id: 25,
        txn_date: stripe_event.event_at,
        payment_ref_number: order.charge_id, #optional payment reference number/string - e.g. stripe token
        deposit_to_account_id: 70, #The ID of the Account entity you want the SalesReciept to be deposited to
        payment_method_id: 333 #The ID of the PaymentMethod entity you want to be used for this transaction
      })
      salesreceipt.auto_doc_number! #allows Intuit to auto-generate the transaction number

      line_item = Quickbooks::Model::Line.new
      line_item.amount = 50
      line_item.description = "Plush Baby Doll"
      line_item.sales_item! do |detail|
        detail.unit_price = 50
        detail.quantity = 1
        detail.item_id = 500 # Item (Product/Service) ID here
      end

      salesreceipt.line_items << line_item

      service = Quickbooks::Service::SalesReceipt.new({access_token: access_token, company_id: "123" })
      created_receipt = service.create(salesreceipt)
    end
  end

  def product_handler(stripe_event)
    product = Product.where(stripe_id: stripe_event.data["id"]).first
    product = Product.new if product.blank?

    product.stripe_id = stripe_event.data["id"]
    product.name = stripe_event.data["name"]
    product.caption = stripe_event.data["caption"]
    product.attributes = stripe_event.data["attributes"]
    product.description = stripe_event.data["description"]
    product.images = stripe_event.data["images"]
    product.metadata = stripe_event.data["metadata"]
    product.active = stripe_event.data["active"]
    product.shippable = stripe_event.data["shippable"]
    product.url = stripe_event.data["url"]

    product.stripe_created_at = Time.parse(stripe_event.data["created"])
    product.stripe_updated_at = Time.parse(stripe_event.data["updated"])

    product.length = stripe_event.data["package_dimensions"]["length"]
    product.width = stripe_event.data["package_dimensions"]["width"]
    product.height = stripe_event.data["package_dimensions"]["height"]
    product.weight = stripe_event.data["package_dimensions"]["weight"]

    product.save
  end

  def sku_handler(stripe_event)
    variant = Variant.where(stripe_id: stripe_event.data["id"]).first
    variant = Variant.new if variant.blank?

    product = Product.where(stripe_id: stripe_event.data["product"]).first

    variant.product_id = product.id unless product.blank?

    variant.stripe_id = stripe_event.data["id"]

    # Gather these from the product for now
    # ECOMTODO Change when we build a product admin tool
    variant.name = variant.product.name
    variant.caption = variant.product.caption
    variant.description = variant.product.description

    # do this for now don't want to permanently tie to stripe's id
    variant.sku = variant.stripe_id
    variant.active = stripe_event.data["active"]
    variant.price = stripe_event.data["price"]
    variant.quantity_available = stripe_event.data["inventory"]["quantity"]
    variant.inventory_value = stripe_event.data["inventory"]["value"]
    variant.inventory_type = stripe_event.data["inventory"]["type"]

    variant.stripe_created_at = Time.parse(stripe_event.data["created"])
    variant.stripe_updated_at = Time.parse(stripe_event.data["updated"])

    variant.attributes = stripe_event.data["attributes"]
    variant.attributes = stripe_event.data["metadata"]

    variant.currency = stripe_event.data["currency"]
    variant.image = stripe_event.data["image"]

    variant.length = stripe_event.data["package_dimensions"]["length"]
    variant.width = stripe_event.data["package_dimensions"]["width"]
    variant.height = stripe_event.data["package_dimensions"]["height"]
    variant.weight = stripe_event.data["package_dimensions"]["weight"]

    variant.save
  end
end
