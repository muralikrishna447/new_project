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

  def sync_mailchimp(options = {premium: true, joule: true})
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
    end

    # TODO - This is a quick fix that will still remove the user from groups
    # other than premium and joule purchase

    groups = []
    if options[:premium]
      add_to_group_param(groups, member_info, :premium_group_id, PREMIUM_GROUP_NAME, @user.premium?)
    end

    if options[:joule]
      add_to_group_param(groups, member_info, :joule_group_id, JOULE_PURCHASE_GROUP_NAME, @user.joule_purchase_count > 0)
    end

    add_to_groups(groups)
  end

  def sync_shopify
    Shopify::Customer.sync_user @user
  end

  private

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
    return if groups.empty?

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
      merge_vars: merge_vars
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
    # For an example of the gibberish returned by the mailchimp API
    # {"email"=>"first@chocolateyshatner.com", "id"=>"7f6ce81444",
    # "euid"=>"7f6ce81444", "email_type"=>"html", "ip_signup"=>nil,
    # "timestamp_signup"=>nil, "ip_opt"=>"66.235.0.136",
    # "timestamp_opt"=>"2015-11-12 04:42:41", "member_rating"=>2,
    # "info_changed"=>"2015-11-12 05:24:59", "web_id"=>12023693,
    # "leid"=>12023693, "language"=>nil, "list_id"=>"5f55993b84",
    # "list_name"=>"Chefsteps Staging List",
    # "merges"=>{"EMAIL"=>"first@chocolateyshatner.com", "FNAME"=>"",
    # "LNAME"=>"", "GROUPINGS"=>[{"id"=>757, "name"=>"Purchases",
    # "form_field"=>"hidden", "groups"=>[{"name"=>"Premium Member",
    # "interested"=>false}]}]}, "status"=>"subscribed", "timestamp"=>"2015-11-12
    # 04:42:41", "is_gmonkey"=>false, "lists"=>[], "geo"=>[], "clients"=>[],
    # "static_segments"=>[], "notes"=>[]}
  end
end
