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

    if options[:joule_data]
      sync_joule_data(member_info)
    end
  end

  def sync_shopify
    Shopify::Customer.sync_user @user
  end

  def get_joule_counts
    {
      connected_count: CirculatorUser.where(user_id: @user.id).count,
      ever_connected_count: CirculatorUser.with_deleted.where(user_id: @user.id).count
    }
  end

  def sync_joule_data(member_info)
    joule_counts = get_joule_counts()

    if joule_counts[:ever_connected_count] > 0
      merges = {
        JOULES_CONNECTED_MERGE_TAG => joule_counts[:connected_count],
        JOULES_EVER_CONNECTED_MERGE_TAG => joule_counts[:ever_connected_count]
      }

      if merges != member_info['merges']

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
  end
end
