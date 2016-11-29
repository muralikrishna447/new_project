
def get_config(env)
  conf = {
    'staging' => {
      shopify_key: ENV['SHOPIFY_API_KEY'],
      shopify_pass: ENV['SHOPIFY_PASSWORD'],
      shopify_store: 'chefsteps-staging',
    },
    'production' => {
      shopify_key: ENV['SHOPIFY_API_KEY'],
      shopify_pass: ENV['SHOPIFY_PASSWORD'],
      shopify_store: 'delve',
    }
  }[env]
  raise "No config for environment: #{env}" unless conf
  return conf
end

def setup_shopify(conf)
  raise "No API key provided" unless conf[:shopify_key]
  raise "No API password provided" unless conf[:shopify_pass]
  raise "No Shopify store provided" unless conf[:shopify_store]
  ShopifyAPI::Base.site = "https://#{conf[:shopify_key]}:#{conf[:shopify_pass]}" \
                          "@#{conf[:shopify_store]}.myshopify.com/admin"
end
