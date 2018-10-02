class Shopify::Customer
  PREMIUM_MEMBER_TAG = 'premium-member'
  JOULE_PREMIUM_DISCOUNT_TAG = 'joule-premium-discount-eligible'

  def initialize(user, shopify_customer)
    raise "Shopify::Customer deprecated"

    @user = user
    @shopify_customer = shopify_customer
  end

  def self.find_for_user(user, email_override=nil)
    raise "Shopify::Customer deprecated"
    email = email_override || user.email
    shopify_customer = ShopifyAPI::Customer.search(:query => "email:\"#{email}\"").first
    if shopify_customer.nil?
      Rails.logger.info "No shopify customer found with email [#{email}]"
      return nil
    end

    # The search API is not consistent, not even eventually, find seems better.
    shopify_customer_id = shopify_customer.id
    shopify_customer = ShopifyAPI::Customer.find(shopify_customer_id)
    if shopify_customer.nil?
      raise "Unable to find shopify customer with id [#{shopify_customer_id}] and email [#{email}]"
    end

    # Mutating the object in a "find" method is not ideal
    if shopify_customer.multipass_identifier.nil?
      Rails.logger.info "No multipass identifier set for customer [#{shopify_customer_id}] setting now."
      shopify_customer.multipass_identifier = user.id
      shopify_customer.save!
    elsif shopify_customer.multipass_identifier.to_i != user.id
      # This will occur when a shopify customer is created with one email
      # address but that email is now attached to a different ChefSteps account.
      # Ideally we would handle email address changes better but at least his
      # closes the potential security hole.
      msg = "[shopify] customer mulitpass_identifier [#{shopify_customer.multipass_identifier.inspect}] does not match user id [#{user.id.inspect}]"
      Rails.logger.error msg
      raise msg
    end
    return Shopify::Customer.new(user, shopify_customer)
  end

  def self.create_for_user(user)
    raise "Shopify::Customer deprecated"
    Rails.logger.info "Creating Shopify customer for user [#{user.id}]"
    customer = ShopifyAPI::Customer.create(
      :email => user.email,
      :multipass_identifier => user.id)

    Rails.logger.info "Created Shopify customer [#{customer.inspect}]"
    return Shopify::Customer.new(user, customer)
  end

  def self.sync_user(user)
    raise "Shopify::Customer deprecated"
    Rails.logger.info "Syncing user [#{user.id}] to shopify"
    customer = find_for_user(user)
    if customer.nil?
      customer = create_for_user(user)
      Rails.logger.info "Created customer [#{customer.inspect}]"
    else
      Rails.logger.info "Found shopify customer [#{customer.inspect}]"
    end

    customer.sync_tags!
    Rails.logger.info "Finished syncing user [#{user.id}] to shopify"
    return customer
  end

  def self.find_or_create_referral_code_for_user(user)
    raise "Shopify::Customer deprecated"
    if ! user.referral_code
      code = 'sharejoule-' + unique_code { |code| User.unscoped.exists?(referral_code: code) }

      # For now at least, always doing a fixed $20.00 off Joule only, good for 5 uses
      ShopifyAPI::Discount.create(
        code: code,
        discount_type: 'fixed_amount',
        value: '20.00',
        usage_limit: 5,
        applies_to_resource: 'product',
        applies_to_id: Rails.configuration.shopify[:joule_product_id]
      )

      # Don't save user until shopify succeeds
      user.referral_code = code
      user.save!

      Rails.logger.info "Created unique referral discount code #{code} for #{user.id}"
    end

    return user.referral_code
  end

  def sync_tags!
    if @shopify_customer.respond_to?(:tags)
      current_tags = @shopify_customer.tags.split(',').sort!.collect {|tag| tag.strip}
    else
      current_tags = []
    end
    tags = Array.new(current_tags)
    tags.delete PREMIUM_MEMBER_TAG
    tags.delete JOULE_PREMIUM_DISCOUNT_TAG

    if @user.premium?
      tags << PREMIUM_MEMBER_TAG
    end
    if @user.can_receive_circulator_discount?
      tags << JOULE_PREMIUM_DISCOUNT_TAG
    end

    if current_tags != tags
      Rails.logger.info "Current tags #{current_tags.inspect} should be #{tags.inspect}.  Syncing"
      @shopify_customer.tags = tags
      @shopify_customer.save!
    else
      Rails.logger.info "Current tags #{current_tags.inspect} is #{tags.inspect}.  Not syncing"
    end
  end

  def tags
    @shopify_customer.tags
  end

  def update_email(old_email)
    new_email = @user.email
    if @shopify_customer.email == new_email
      Rails.logger.info "Shopify customer [#{@shopify_customer.id}] already has new email [#{new_email}]"
      return
    end

    if @shopify_customer.email != old_email
      msg = "Shopify customer [#{@shopify_customer.id}] email does not match old email [#{new_email}]"
      Rails.logger.info msg
      raise msg
    end

    Rails.logger.info "Updating shopify customer email "
    @shopify_customer.email = @user.email
    @shopify_customer.save!
  end

  def self.update_email(user, old_email)
    raise "Shopify::Customer deprecated"
    customer = self.find_for_user(user, old_email)
    customer.update_email(old_email)
  end
end
