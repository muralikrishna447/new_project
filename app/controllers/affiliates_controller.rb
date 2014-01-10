class AffiliatesController < ApplicationController
  def share_a_sale
    if cookies['SSAID'].present? && cookies['SSAIDDATA'].present?
      amount = params[:amount]
      tracking = params[:tracking]
      uri = URI.parse('https://www.shareasale.com/q.cfm')
      uri.query = URI.encode_www_form({amount: amount, tracking: tracking, transtype: "SALE", merchantID: "51074", userID: cookies["SSAID"], ssaiddata: cookies["SSAIDDATA"]})
      if Rails.env.production?
        root_ca_path = "/etc/ssl/certs"
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")

        if (File.directory?(root_ca_path) && http.use_ssl?)
          http.ca_path = root_ca_path
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          http.verify_depth = 5
        end

        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
      end
      return render json: {response: response, body: response.body, code: response.code, message: response.message}, status: 200
    end
    render nothing: true
  end
end

