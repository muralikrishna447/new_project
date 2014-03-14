# namespace :disqus do
#   task :get_comments => :environment do
#     @disqus = Faraday.new(:url => 'https://disqus.com') do |faraday|
#       faraday.request  :url_encoded             # form-encode POST params
#       faraday.response :logger                  # log requests to STDOUT
#       faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
#     end
#     access = {access_token: '1bd807b871c2405ab02dc5667984b15c', api_key: 'o3Q9ESDRAgLfyUtMSq8v0AeyFeNdlbUNHCEI2m5fvvyWPyNIPkxa9jpY1ksGrtfk', api_secret: '0PAZuOvBZkhEdRDC9CmcYjsSJlbhClfAohKlDQySaM7JlZ6IHijq91lGW3FAQvzF'}
#     # response = @disqus.get '/api/3.0/users/details.json', access

#     # threads_list_response = @disqus.get '/api/3.0/threads/list.json', access
#     # threads_list = JSON.parse(threads_list_response.body)['response']
#     # threads_list.each do |thread|
#     #   puts '******************'
#     #   puts thread
#     #   puts '******************'
#     # end

#     thread_open_response = @disqus.post '/api/3.0/threads/open.json', access.merge({thread: 2057223648})
#     thread_open = JSON.parse(thread_open_response.body)['response']
#     puts thread_open
#     # threads_open.each do |thread|
#     #   puts '******************'
#     #   puts thread
#     #   puts '******************'
#     # end
#   end
# end

namespace :disqus do
  task :get_comments => :environment do
    parse_disqus
    @thread = get_thread('2057223648')
    pp @thread

    @posts = get_posts('2057223648')
    pp @posts
  end

  def parse_disqus
    data_file = '~/Downloads/chefstepsproduction-2014-03-14T18-40-58.671900-all.xml'
    xml = File.read(File.expand_path(data_file))
    parser = Nori.new
    @parsed = parser.parse(xml)['disqus']
  end

  def get_thread(thread_id)
    threads = @parsed['thread']
    thread = threads.select{|k,v| k["@dsq:id"] == thread_id}
    thread
  end

  def get_posts(thread_id)
    posts = @parsed['post']
    specific_posts = posts.select{|k,v| k['thread']["@dsq:id"] == thread_id}
    specific_posts
  end
end