require 'retriable'

module CsSpree::Api::Promotions

  # headers["X-Spree-Token"] = CsSpree.api_key
  # self.site = CsSpree.hostname

  # During Development Phase : Basic Auth is required too
  # headers["Authorization"] = 'Basic ZGVsdmU6ZGVlcGVy'


  def self.ensure_share_joule(code)
    Rails.logger.info "#{self.name}.ensure(#{code})"

    # TODO Make the API call

    # url = "https://www.filestackapi.com/api/store/S3?key=#{Rails.configuration.filepicker_rails.api_key}"
    # response = HTTParty.post(url, {body: {url: self.image_url(image_path)}})
    # result = JSON.parse(response.body)
    # # Put URL back to traditional www.filepicker.io because that is what regexps elsehwere
    # # expect to find and turn into CDN url.
    # result['url'].gsub! 'cdn.filestackcontent.com', 'www.filepicker.io/api/file'
    # result.to_json





  end




end