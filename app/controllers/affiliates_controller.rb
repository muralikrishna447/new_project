class AffiliatesController < ApplicationController
  def share_a_sale
    amount = params[:amount]
    tracking = params[:tracking]
    uri = URI('https://www.shareasale.com/q.cfm')
    uri.query = URI.encode_www_form({amount: amount, tracking: tracking, transtype: "SALE", merchantID: "51074", userID: cookies["SSAID"], ssaiddata: cookies["SSAIDDATA"]})
    if Rails.env.production?
      Net::HTTP.get_response(uri)
    end
    render nothing: true, status: 200
  end
end

