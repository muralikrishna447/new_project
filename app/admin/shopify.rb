ActiveAdmin.register_page 'Shopify' do

 # config = {api_key: ENV['SHOPIFY_API_KEY'], api_secret: ENV['SHOPIFY_API_SECRET']}

 breadcrumb do
   ['admin', 'shopify']
 end

 content do
   render partial: 'shopify'
 end

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
