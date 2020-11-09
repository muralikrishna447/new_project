class CutsService
  @@urls = []
  def self.initiate
    begin
      response = RestClient.get("#{Rails.configuration.shared_config[:catalog_endpoint]}/cuts/list/slugs")
      @@urls = JSON.parse(response.body)
    rescue StandardError => e
      Rails.logger.info("Cuts Service Failed #{e}")
    end
  end

  def self.get_routes
    @@urls
  end
end