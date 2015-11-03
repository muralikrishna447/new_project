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

  end

  def order_charged(stripe_event)
    # order = Order.where(stripe_id: stripe_event.data["id"]).first
    # setting = Setting.last
    # access_token = OAuth::AccessToken.new($qb_oauth_consumer, setting.quickbooks_token, setting.quickbooks_secret)

    # if false #Quickbooks::Model::SalesReceipt.find()
    #   #Invoices, SalesReceipts etc can also be defined in a single command
    #   salesreceipt = Quickbooks::Model::SalesReceipt.new({
    #     access_token: access_token,
    #     customer_id: 25,
    #     txn_date: stripe_event.event_at,
    #     payment_ref_number: order.charge_id, #optional payment reference number/string - e.g. stripe token
    #     deposit_to_account_id: 70, #The ID of the Account entity you want the SalesReciept to be deposited to
    #     payment_method_id: 333 #The ID of the PaymentMethod entity you want to be used for this transaction
    #   })
    #   salesreceipt.auto_doc_number! #allows Intuit to auto-generate the transaction number

    #   line_item = Quickbooks::Model::Line.new
    #   line_item.amount = 50
    #   line_item.description = "Plush Baby Doll"
    #   line_item.sales_item! do |detail|
    #     detail.unit_price = 50
    #     detail.quantity = 1
    #     detail.item_id = 500 # Item (Product/Service) ID here
    #   end

    #   salesreceipt.line_items << line_item

    #   service = Quickbooks::Service::SalesReceipt.new({access_token: access_token, company_id: "123" })
    #   created_receipt = service.create(salesreceipt)
    # end
  end

  def product_handler(stripe_event)
  end

  def sku_handler(stripe_event)
  end
end
