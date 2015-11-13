# Synchronizes user data from the master, usually CS database to various
# external systems.

# Currently:
#  - Mailchimp for premium users
#
# But eventually other attributes too!

class UserSync
  PREMIUM_GROUP_NAME = "Premium Member"
  
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
    sync_mailchimp_premium
  end
  
  def sync_mailchimp_premium()
    mailchimp_config = Rails.configuration.mailchimp

    list_id = mailchimp_config[:list_id]
    member_info = Gibbon::API.lists.member_info({:id => list_id, :emails => [{:email => @user.email}]})
    @logger.info member_info.inspect

    if member_info['success_count'] == 0
      @logger.warn "User not found in MailChimp #{member_info.inspect}"
    end
    member_info = member_info['data'][0]
    
    mailchimp_premium = is_mailchimp_premium? member_info
    cs_premium = @user.premium_member # TODO - update with real method once merged

    @logger.info "Mailchimp premium [#{mailchimp_premium}]  ChefSteps premium [#{cs_premium}]"

    if mailchimp_premium && !cs_premium
      msg = "User #{@user.id} is premium in mailchimp and not the database"
      @logger.error msg
      raise msg
    end
    
    if !cs_premium
      @logger.info "Not a premium member, not syncing to mailchimp"
      return
    end
    
    if mailchimp_premium
      @logger.info "Already premium in mailchimp"
      return
    end
    
    # Note - if more attributes are added to the group then those values will
    # need to be copied from the initial read request or else they will be
    # deleted.
    merge_vars = {
        groupings: [
        {
          id: mailchimp_config[:premium_group_id],
          groups: [PREMIUM_GROUP_NAME]
        }
      ]
    }

    Gibbon::API.lists.update_member(
      id: Rails.configuration.mailchimp[:list_id],
      email: { email: @user.email },
      merge_vars: merge_vars
    )
  end
  
  
  private
  def is_mailchimp_premium? member_info
    return false unless member_info
    return false unless member_info['GROUPINGS']
    
    purchases = member_info['GROUPINGS'].find do |e|
      e['id'] == Rails.configuration.mailchimp[:premium_group_id]
    end
    return false unless purchases
    return false unless purchases['groups']
    
    premium_purchase = purchases['groups'].find do |e|
      e['name'] == PREMIUM_GROUP_NAME
    end
    return false if premium_purchase.nil?

    return true if premium_purchase["interested"] == true
    
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
