module MailingListHelper
  class MailChimpListManager
    def initialize
      @gibbon = Gibbon.new(MAILCHIMP_API_KEY)
    end

    def subscribe_user(email)
      params = {
        id: MAILCHIMP_LIST_ID,
        email_address: email
      }
      @gibbon.list_subscribe(params)
    end

  end
end

