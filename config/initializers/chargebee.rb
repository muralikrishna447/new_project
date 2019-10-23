ChargeBee.configure(
  site: ENV['CHARGEBEE_SITE'],
  api_key: ENV['CHARGEBEE_API_KEY']
)


# Patching in the checkout_gift method which is not available in the version of Chargebee we are using
# The later version of Chargebee requires json_pure 2.0+ which is not compatible
# with our (very old) version of ActiveRecord's json serialization
ChargeBee::HostedPage.class_eval do
  def self.checkout_gift(params, env=nil, headers={})
    ChargeBee::Request.send('post', uri_path("hosted_pages","checkout_gift"), params, env, headers)
  end
end

module ChargeBee
  class Gift < Model

    class Gifter < Model
      attr_accessor :customer_id, :invoice_id, :signature, :note
    end

    class GiftReceiver < Model
      attr_accessor :customer_id, :subscription_id, :first_name, :last_name, :email
    end

    class GiftTimeline < Model
      attr_accessor :status, :occurred_at
    end

    attr_accessor :id, :status, :scheduled_at, :auto_claim, :claim_expiry_date, :resource_version,
                  :updated_at, :gifter, :gift_receiver, :gift_timelines

    # OPERATIONS
    #-----------

    def self.create(params, env=nil, headers={})
      Request.send('post', uri_path("gifts"), params, env, headers)
    end

    def self.retrieve(id, env=nil, headers={})
      Request.send('get', uri_path("gifts",id.to_s), {}, env, headers)
    end

    def self.list(params={}, env=nil, headers={})
      Request.send_list_request('get', uri_path("gifts"), params, env, headers)
    end

    def self.claim(id, env=nil, headers={})
      Request.send('post', uri_path("gifts",id.to_s,"claim"), {}, env, headers)
    end

    def self.cancel(id, env=nil, headers={})
      Request.send('post', uri_path("gifts",id.to_s,"cancel"), {}, env, headers)
    end

  end # ~Gift
end # ~ChargeBee

ChargeBee::Result.class_eval do
  def gift()
    gift = get(:gift, ChargeBee::Gift,
               {:gifter => ChargeBee::Gift::Gifter, :gift_receiver => ChargeBee::Gift::GiftReceiver, :gift_timelines => ChargeBee::Gift::GiftTimeline});
    return gift;
  end
end