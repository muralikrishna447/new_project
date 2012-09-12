module MailingListHelper
  class MailChimpListManager
    def initialize(list)
      @gibbon = Gibbon.new(MAILCHIMP_API_KEY)
    end

    def subscribe_user(email)
      params = {
        id: MAILCHIMP_LIST_ID,
        email_address: email
      }
      @gb.list_subscribe(params)
    end

  end
end

