class ChargebeeController < ApplicationController
  def generate_hp_url
    params = {
      :billing_address => {
        :first_name => "Jeremy",
        :last_name => "Shaffer",
        :line1 => "1501 Pike Pl",
        :city => "Seattle",
        :state => "WA",
        :zip => "98101",
        :country => "US"
      },
      :subscription => {
        :plan_id => "cbdemo_nuts"
      },
      :customer => {
        :id => "431067", # TODO should come from current auth'd user
        :email => "jshaffer@chefsteps.com", # TODO should come from current auth'd user
        :first_name => "Jeremy",
        :last_name => "Shaffer",
        :locale => "en-US",
        :phone => "+1-555-555-5555"
      }
    }

    result = ChargeBee::HostedPage.checkout_new(params)
    render :json => result.hosted_page.to_s
  end

  def create_portal_session
    customer_id = "431067"
    result = ChargeBee::PortalSession.create({ :customer => { :id => customer_id } })
    render :json => result.portal_session.to_s
  end
end
