class Shopify::Customer
  METAFIELD_NAMESPACE = 'chefsteps'
  PREMIUM_METAFIELD_NAME = 'premium-member'
  # Metafield key name is limited to 30 chars
  JOULE_DISCOUNT_METAFIELD_NAME = 'jp-discount-eligible'

  def initialize(user, shopify_customer)
    @user = user
    @shopify_customer = shopify_customer
  end
  
  def self.find_for_user(user)
    shopify_customer = ShopifyAPI::Customer.search(:query => "email:#{user.email}").first
    if shopify_customer.nil?
      Rails.logger.info "No shopify customer found with email [#{user.email}]"
      return nil
    end

    # The search API is not consistent, not even eventually, find seems better.
    shopify_customer_id = shopify_customer.id
    shopify_customer = ShopifyAPI::Customer.find(shopify_customer_id)
    if shopify_customer.nil?
      raise "Unable to find shopify customer with id [#{shopify_customer_id}] and email [#{user.email}]"
    end

    # This will occur when a shopify customer is created with one email
    # address but that email is now attached to a different ChefSteps account.
    # Ideally we would handle email address changes better but at least his
    # closes the potential security hole.
    if shopify_customer.multipass_identifier.to_i != user.id
      msg = "[shopify] customer mulitpass_identifier [#{shopify_customer.multipass_identifier.inspect}] does not match user id [#{user.id.inspect}]"
      Rails.logger.error msg
      raise msg
    end
    return Shopify::Customer.new(user, shopify_customer)

  end
  
  def self.create_for_user(user)
    Rails.logger.info "Creating Shopify customer for user [#{user.id}]"
    customer = ShopifyAPI::Customer.create(
      :email => user.email,
      :multipass_identifier => user.id)
    
    Rails.logger.info "Created Shopify customer [#{customer.inspect}]"
    return Shopify::Customer.new(user, customer)
  end
  
  def self.sync_user(user)
    Rails.logger.info "Syncing user [#{user.id}] to shopify"
    customer = find_for_user(user)
    if customer.nil?
      customer = create_for_user(user)
      Rails.logger.info "Created customer [#{customer.inspect}]"
    else
      Rails.logger.info "Found shopify customer [#{customer.inspect}]"
    end

    customer.sync_metafields!
    Rails.logger.info "Finished syncing user [#{user.id}] to shopify"
    return customer
  end

  def sync_metafields!
    premium = ShopifyAPI::Metafield.new({:namespace => METAFIELD_NAMESPACE,
      :key => PREMIUM_METAFIELD_NAME,
      :value_type => 'string',
      :value => @user.premium?})
    
    @shopify_customer.add_metafield(premium)
    Rails.logger.info "Adding metafield #{premium.inspect}"
    joule_discount = ShopifyAPI::Metafield.new({:namespace => METAFIELD_NAMESPACE,
      :key => JOULE_DISCOUNT_METAFIELD_NAME, 
      :value_type => 'string',
      :value => @user.can_receive_circulator_discount?})
    
    @shopify_customer.add_metafield(joule_discount)
    Rails.logger.info "Adding metafield #{joule_discount.inspect}"
  end  

  def metafields
    @shopify_customer.metafields
  end
end
