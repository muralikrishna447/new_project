# No longer used mixpanel analytics
ActiveAdmin.register_page 'Mixpanel' do
  menu false
  require 'csv'
  require 'json'
  
  config = {api_key: 'ccf6e1e8a37992e4119e42a14557b4a2', api_secret: 'a2f59ee56f798fde108708277bddd4f7'}
  client = Mixpanel::Client.new(config)

  page_action :get_csv, method: :get do
    all_data = []
    data = client.request('engage', {

    })
    data['results'].each do |item|
      all_data << item
    end

    while data['results'].length >= data['page'] do
      next_page_number = data['page'] + 1
      data = client.request('engage', { session_id: data['session_id'], page: next_page_number})
      data['results'].each do |item|
        all_data << item
      end
    end
    csv_string = CSV.generate do |csv| 
      all_data.each do |hash|
        keys = []
        values = []
        to_insert = []

        to_insert << hash['$properties']['$email']
        hash['$properties'].keys.each do |key|
          unless /\A\$/.match(key)
            to_insert << key
            to_insert << hash['$properties'][key]
          end
        end
        csv << to_insert
        # hash['$properties'].keys.each do |key|
        #   keys << key
        # end
        # hash['$properties'].values.each do |value|
        #   values << value
        # end

        # csv << keys
        # csv << values
      end
    end
    send_data csv_string, filename: 'mixpanel_engage.csv'
  end

  content do
    link_to 'Download Mixpanel People Data', admin_mixpanel_get_csv_path, method: :get
  end

end
