module MailingListHelper
  class MailChimpListManager
    def initialize(list)
      @gb = Gibbon.new(MAILCHIMP_API_KEY)
      set_list_id(list)
    end

    def subscribe_user(email)
      params = {
        id: @list_id,
        email_address: email
      }
      @gb.list_subscribe(params)
    end

    private

    def set_list_id(list)
      list_ids = @gb.lists({filters: {list_name: list}})
      @list_id = list_ids['data'].first['id']
    end
  end
end

