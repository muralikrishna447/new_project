namespace :backup do

  task :comments => :environment do
    connect_to_es
    body = {
      "type" => "fs",
      "settings" => {
        "location" => "/mount/backups/my_backup",
        "compress" => "true"
      }
    }
    @elasticsearch.put do |req|
      req.url '/_snapshot/my_backup'
      req.headers['Content-Type'] = 'application/json'
      req.body = JSON.generate(body)
    end
  end

  def connect_to_es
    @elasticsearch = Faraday.new(:url => 'http://d0d7d0e3f98196d4000.qbox.io/') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

end