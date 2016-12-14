# Synchronizes user data from the master, usually CS database to various
# external systems.

# Currently:
#  - Mailchimp for premium users
#  - Mailchimp for joule purchases
#
# But eventually other attributes too!
#
# TODO - add some sort of request id

class UserSync
  PREMIUM_GROUP_NAME = "Premium Member"
  JOULE_PURCHASE_GROUP_NAME = "Joule Purchase"

  # Unfortunate limit to merge tag name length
  JOULES_CONNECTED_MERGE_TAG = "JL_CONN"
  JOULES_EVER_CONNECTED_MERGE_TAG = "JL_EVR_CON"
  REFERRAL_CODE_MERGE_TAG = "REFER_CODE"

  @queue = :user_sync

  def self.perform(user_id)
    UserSync.new(user_id).sync
  end

  def initialize(user_id)
    @logger = Rails.logger # TODO - set up proper logging
    @logger.info "Syncing user data for [#{user_id}]"
    @user = User.find(user_id)
  end

  def sync
    sync_mailchimp
    sync_shopify
  end

  def sync_mailchimp(options = {premium: true, joule: true, joule_data: true})
    list_id = Rails.configuration.mailchimp[:list_id]
    member_info = Gibbon::API.lists.member_info({:id => list_id, :emails => [{:email => @user.email}]})
    @logger.info member_info.inspect
    if member_info['success_count'] == 0
      @logger.warn "User not found in MailChimp #{member_info.inspect}"
      return
    elsif member_info['data'][0]['status'] == 'unsubscribed'
      @logger.warn "User unsubscribed from list #{member_info.inspect}"
      return
    end

    member_info = member_info['data'][0]

    if member_info['status'] != 'subscribed'
      @logger.warn "User not subscribed to list, actual status [#{member_info['status']}]"
      return
    end

    # TODO - This is a quick fix that will still remove the user from groups
    # other than premium and joule purchase

    groups = []
    if options[:premium]
      add_to_group_param(groups, member_info, :premium_group_id, PREMIUM_GROUP_NAME, @user.premium?)
    end

    if options[:joule]
      # This is deprecated b/c it is nearly worthless - it doesn't account for amazon, anonymous purchase, etc
      add_to_group_param(groups, member_info, :joule_group_id, JOULE_PURCHASE_GROUP_NAME, @user.joule_purchase_count > 0)
    end

    if options[:premium] || options[:joule]
      add_to_groups(groups)
    end

    if options[:joule_data]
      sync_joule_data(member_info)
    end
  end

  def sync_shopify
    Shopify::Customer.sync_user @user
  end

  def sync_joule_data(member_info)
    existing_merges = member_info['merges'] || {}
    merges = existing_merges

    merges[JOULES_CONNECTED_MERGE_TAG] = CirculatorUser.where(user_id: @user.id).count
    merges[JOULES_EVER_CONNECTED_MERGE_TAG] = CirculatorUser.with_deleted.where(user_id: @user.id).count

    if merges[JOULES_EVER_CONNECTED_MERGE_TAG] > 0
      if ! @user.referral_code
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
        @user.referral_code = code
        @user.save!
        @logger.info("Created unique referral discount code #{code} for #{@user.id}")
      end

      merges[REFERRAL_CODE_MERGE_TAG] = @user.referral_code
    end

    if merges != existing_merges

      @logger.info("Sync user #{@user.id} joule counts, #{merges.inspect}")

      Gibbon::API.lists.update_member(
        {
          id: Rails.configuration.mailchimp[:list_id],
          email: {
            email: @user.email
          },
          replace_interests: false,
          merge_vars: merges
        }
      )

    end
  end

  def add_to_group_param(groups, member_info, group_id, group_name, db_value)
    mailchimp_value = in_mailchimp_group?(member_info, group_id, group_name)

    @logger.info "#{group_name}: Mailchimp [#{mailchimp_value}], ChefSteps [#{db_value}]"

    if mailchimp_value && !db_value
      msg = "User #{@user.id} is a #{group_name} in mailchimp and not the database"
      @logger.error msg
      raise msg
    end

    if !db_value
      @logger.info "Not a #{group_name}"
      return
    end
    groups << [group_id, group_name]
  end

  def add_to_groups (groups)
    # Note - if more attributes are added to the group then those values will
    # need to be copied from the initial read request or else they will be
    # deleted.
    groupings = groups.collect do |id, name|
      {id: Rails.configuration.mailchimp[id], groups: [name]}
    end
    merge_vars = {
        groupings: groupings
    }

    Gibbon::API.lists.update_member(
      id: Rails.configuration.mailchimp[:list_id],
      email: { email: @user.email },
      merge_vars: merge_vars,
      replace_interests: false
    )
  end

  def in_mailchimp_group?(member_info, id, group_name)
    return false unless member_info
    return false unless member_info['GROUPINGS']

    group_outer = member_info['GROUPINGS'].find do |e|
      e['id'] == Rails.configuration.mailchimp[id]
    end
    return false unless group_outer
    return false unless group_outer['groups']

    group_inner = group_outer['groups'].find do |e|
      e['name'] == group_name
    end
    return false if group_inner.nil?

    return true if group_inner["interested"] == true

    return false
  end
end
