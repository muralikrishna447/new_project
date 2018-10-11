def create_webhook(endpoint, topic, type)
  w = ShopifyAPI::Webhook.new(
    :topic => topic,
    :address => "#{endpoint}?type=#{type}",
    :format => "json"  
  )
  w.save!
  puts "Created #{w.topic} -> #{w.address}"
end

task :configure_shopify_webhooks, [:endpoint] => :environment do |t, args| #, :endpoint
  raise "Shopify API calls are deprecated"

  endpoint = args[:endpoint]
  puts "=== Current configuration ==="
  webhooks = ShopifyAPI::Webhook.all
  puts "Found [#{webhooks.length}] webhooks"

  webhooks.each do |webhook|
    puts "[#{webhook.topic}] -> [#{webhook.address}]"
  end
  
  puts "Continuing in 2 seconds so you have time to consider your life choices..."
  sleep(2)
  puts "=== Deleting existing webhooks ==="
  webhooks.each do |webhook|
    puts "Destroying webhook #{webhook}"
    webhook.destroy
  end
  
  puts "=== Creating new webhooks ==="
  create_webhook(endpoint, 'orders/paid', 'order_paid')
  create_webhook(endpoint, 'orders/create', 'order_created')
  
  puts "Done."
end
