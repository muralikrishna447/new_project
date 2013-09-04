ActiveAdmin.register_page 'Mixpanel' do
  require 'csv'
  require 'json'
  
  config = {api_key: 'ccf6e1e8a37992e4119e42a14557b4a2', api_secret: 'a2f59ee56f798fde108708277bddd4f7'}
  client = Mixpanel::Client.new(config)

  all_data = []
  data = client.request('engage', {

  })
  all_data << data['results']

  while data['results'].length >= data['page'] do
    next_page_number = data['page'] + 1
    data = client.request('engage', { session_id: data['session_id'], page: next_page_number})
    puts data['page']
    all_data << data['results']
  end

  page_action :get_csv, method: :get do
    csv_string = CSV.generate do |csv| 
      # data.to_a.each {|elem| csv << elem}
      column_names = [:distinct_id, :browser, :city, :country_code, :created, :email, :first_name, :initial_referer, :initial_referring_domain, :os, :region, :last_seen]
      csv << column_names
      data['results'].each do |hash|
        values = []
        hash.keys.each do |key|
          case key
          when '$distinct_id'
            values << hash[key]
          when '$properties'
            hash['$properties'].values.each do |value|
              values << value
            end
          end
        end
        csv << values
      end
    end
    send_data csv_string, filename: 'mixpanel_engage.csv'
  end

  action_item do
    link_to 'hello', admin_mixpanel_get_csv_path, method: :get
  end

  content do
    data
  end

end