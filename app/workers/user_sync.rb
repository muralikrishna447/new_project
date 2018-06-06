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
  PREMIUM_STARTED_AT_MERGE_TAG = "PREMSTART"

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
  end

  def sync_mailchimp
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
      @logger.warn "MAILCHIMP User not subscribed to list, actual status [#{member_info['status']}]"
      return
    end

    existing_merges = member_info['merges']

    # Example
    # {
    # "success_count"=>1,
    # "error_count"=>0,
    # "errors"=>[],
    # "data"=>[{
    #   "email"=>"chefsteps@example.com",
    #   "id"=>"053eb345",
    #   "euid"=>"05ab345",
    #   "email_type"=>"html",
    #   "ip_signup"=>nil, "timestamp_signup"=>nil, "ip_opt"=>"54.12.12.133",
    #   "timestamp_opt"=>"2015-11-26 00:40:45", "member_rating"=>2, "info_changed"=>"2018-04-11 20:23:28",
    #   "web_id"=>131523589, "leid"=>131523589, "language"=>nil, "list_id"=>"a61ebdcaa6",
    # "list_name"=>"ChefSteps", "merges"=>{"EMAIL"=>"chefsteps@example.com",
    # "NAME"=>"Stu", "COUNTRY"=>"United States", "SOURCE"=>"api_standard",
    # "PREMSTART"=>"2017-11-02", "MRBUYDT"=>"2017-06-01", "MRJBUYDT"=>"2017-06-01",
    # "MRCBUYDT"=>"", "MRJCONNDT"=>"2017-05-06", "MRJAPPDT"=>"2018-04-02",
    # "MRRECIPE"=>"Basic Salmon", "JOULSHIPDT"=>"2017-06-01", "MRSKU"=>"cs20001",
    # "MMERGE15"=>"39", "MMERGE17"=>"1", "MMERGE18"=>"2018-03-11", "MMERGE21"=>"2017-11-01",
    # "MMERGE23"=>"", "MMERGE10"=>"352492",
    # "GROUPINGS"=>[
    # {"id"=>8141, "name"=>"Joule Waitlist", "form_field"=>"hidden", "groups"=>[
    # {"name"=>"UK", "interested"=>false},
    # {"name"=>"Canada", "interested"=>false}]},
    # {"id"=>8145, "name"=>"Survey Panels", "form_field"=>"hidden", "groups"=>[
    # {"name"=>"Joule Customer Feedback", "interested"=>false}, {"name"=>"Weekly Joule Cook", "interested"=>false},
    # {"name"=>"Seattle Joule Cook", "interested"=>false}]},
    # {"id"=>8149, "name"=>"Accessories Waitlist", "form_field"=>"hidden", "groups"=>[
    # {"name"=>"UK", "interested"=>false}]}]},
    # "status"=>"subscribed", "timestamp"=>"2015-11-26 00:40:45", "is_gmonkey"=>false,
    # "lists"=>[{"id"=>"009c78fb86", "status"=>""}],
    # "geo"=>{"latitude"=>"39.0329000", "longitude"=>"-77.4866000", "gmtoff"=>"-5", "dstoff"=>"-4",
    # "timezone"=>"America/New_York", "cc"=>"US", "region"=>"VA"},
    # "clients"=>{"name"=>"Gmail", "icon_url"=>"http://us3.admin.mailchimp.com/images/email-client-icons/gmail.png"},
    # "static_segments"=>[{"id"=>12309, "name"=>"Welcome Series Complete", "added"=>"2018-02-12 21:02:42"}], "notes"=>[]}]}

    if existing_merges.nil?
      @logger.warn "MAILCHIMP ERROR NO Existing merges, will hopefully not overwrite [#{member_info}]"
      existing_merges = {}
    end
    sync_merge_fields(existing_merges)
  end

  def sync_merge_fields(exsting_merges)
    update_merges = exsting_merges.dup
    patch_joule_data(update_merges)
    patch_premium(update_merges)

    if update_merges != exsting_merges
      @logger.info("MAILCHIMP Sync user #{@user.id} merge fields, #{update_merges.inspect}")
      Gibbon::API.lists.update_member(
        {
          id: Rails.configuration.mailchimp[:list_id],
          email: {
            email: @user.email
          },
          replace_interests: false,
          merge_vars: update_merges
        }
      )
    else
      @logger.info("MAILCHIMP Sync user #{@user.id} no updates #{update_merges.inspect}")
    end
  end

  def get_joule_counts
    {
      connected_count: CirculatorUser.where(user_id: @user.id).count,
      ever_connected_count: CirculatorUser.with_deleted.where(user_id: @user.id).count
    }
  end

  def patch_joule_data(update_merges)
    joule_counts = get_joule_counts()
    update_merges[JOULES_CONNECTED_MERGE_TAG] = joule_counts[:connected_count]
    update_merges[JOULES_EVER_CONNECTED_MERGE_TAG] = joule_counts[:ever_connected_count]
  end

  def patch_premium(update_merges)
    if @user.premium_membership_created_at.present?
      premium_start_tag = @user.premium_membership_created_at.strftime('%Y-%m-%d')
      if premium_start_tag.blank? && @user.premium_member?
        premium_start_tag = '2000-01-01'
      end
      update_merges[PREMIUM_STARTED_AT_MERGE_TAG] = premium_start_tag
    end
  end
end
