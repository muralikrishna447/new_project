namespace :disqus_comments do
  require 'nokogiri'
  require 'json'
  @migrated_comments = []

  task :migrate_classes => :environment do
    connect_to_elasticsearch
    connect_to_disqus_xml('~/Downloads/chefstepsproduction-2014-04-23T03-58-58.463508-all.xml')
    connect_to_disqus_api
    # puts @parsed
    @macarons = Assembly.find('french-macarons')
    migrate_one_assembly(@macarons)
  end

  def migrate_one_assembly(assembly)
    # Hash containing meta data to help with migration
    c = []
    disqus_thread_id = '1880805660'
    # disqus_thread_id = determine_disqus_thread_id("assembly-#{assembly.id}")

    # get the comments
    if disqus_thread_id
      disqus_comments = get_disqus_posts(disqus_thread_id)
      disqus_comments.each do |comment|
        unless @migrated_comments.include?(comment['@dsq:id'].to_i)
          image = get_disqus_image(comment['@dsq:id'])
          c_info = Hash.new
          c_info[:commentable_type] = 'assembly'
          c_info[:commentable_id] = assembly.id
          c_info[:disqus_thread_id] = disqus_thread_id
          c_info[:disqus_id] = comment['@dsq:id']
          c_info[:disqus_parent_id] = comment['parent']['@dsq:id'] if comment['parent']
          c_info[:disqus_user_email] = comment['author']['email']

          c_info[:created_at] = (comment['createdAt']).to_i * 1000

          c_info[:chefsteps_user_id] = get_chefsteps_user_id(comment['author']['email'])
          content = compose_content(comment,image)
          if c_info[:chefsteps_user_id]
            c_info[:content] = content
          else
            c_info[:content] = content + " - originally posted by #{comment['author']['name']}"
          end
          c << c_info
        end
      end
    end

    puts c

    # Loop through c_info and migrate the parents
    c.each do |comment_info|
      unless comment_info[:disqus_parent_id]
        post_to_es(comment_info)
        find_children(c, comment_info, 1)
      end
    end
  end

  def get_disqus_image(disqus_thread_id)
    disqus_data = @disqus.get('/api/3.0/posts/details.json', {post: disqus_thread_id, api_key: 'Y1S1wGIzdc63qnZ5rhHfjqEABGA4ZTDncauWFFWWTUBqkmLjdxloTb7ilhGnZ7z1'})
    media = JSON.parse(disqus_data.body)['response']['media']
    unless media.blank?
      image = media[0]['url']
    end
    image
  end

  def compose_content(comment,image)
    content = Nokogiri::HTML(comment['message']).text
    content = "<p>" + content + "</p>"
    content = content + "<img src='#{image}'>" unless image.blank?
    content
  end

  def post_to_es(comment_info)
    index = 'xchefsteps'
    type = 'comment'
    body = {
      'upvotes' => [],
      'asked' => [],
      'createdAt' => comment_info[:created_at],
      'author' => comment_info[:chefsteps_user_id],
      'content' => comment_info[:content],
      'dbParams' => {
        'commentsId' => "#{comment_info[:commentable_type]}_#{comment_info[:commentable_id]}"
      }
    }
    body["parentCommentId"] = comment_info[:bloom_parent_id] unless comment_info[:bloom_parent_id].blank?
    puts body
    response = @elasticsearch.index index: index, type: type, body: body
    puts response
    puts '* reponse *'
    comment_info[:bloom_id] = response["_id"]
    puts comment_info
    puts '*** Posting to Elasticsearch ***'
  end

  def find_children(data, parent, depth)
    children = data.select{|child| child[:disqus_parent_id] == parent[:disqus_id]}
    if children.length > 0
      children.each do |child|
        child[:bloom_parent_id] = parent[:bloom_id]
        post_to_es(child)
        # puts '   '*depth + child[:content]

        find_children(data, child, depth + 1)
      end
    end
  end

  def connect_to_disqus_xml(path_and_filename)
    xml = File.read(File.expand_path(path_and_filename))
    parser = Nori.new
    @parsed = parser.parse(xml)['disqus']
  end

  def determine_disqus_thread_id(activity_id)
    threads = @parsed['thread']
    thread = threads.select{|k,v| k["id"] == activity_id}[0]
    unless thread.blank?
      thread['@dsq:id']
    else
      nil
    end
  end

  def get_disqus_thread(thread_id)
    threads = @parsed['thread']
    thread = threads.select{|k,v| k['@dsq:id'] == thread_id}
    thread
  end

  # Get disqus comments by thread id
  def get_disqus_posts(thread_id)
    posts = @parsed['post']
    puts posts
    specific_posts = posts.select{|k,v| k['thread']['@dsq:id'] == thread_id}
    specific_posts
  end

  def filter_comments_without_parent(comments)
    comments_without_parents = []
    comments_with_parents = []
    comments.each do |comment|
      if comment['parent'].blank?
        comments_without_parents << comment
      else
        comments_with_parents << comment
      end
    end
    puts '***** WITHOUT PARENTS ******'
    puts comments_without_parents
    puts '***** WITH PARENTS ******'
    puts comments_with_parents
  end

  # Functions to help pull data from chefsteps
  def get_chefsteps_user_id(email)
    user = User.where(email: email).first
    user.id unless user.blank?
  end

  def connect_to_disqus_api
    @disqus = Faraday.new(:url => 'https://disqus.com') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  # def connect_to_es
  #   @elasticsearch = Faraday.new(:url => 'http://d0d7d0e3f98196d4000.qbox.io/') do |faraday|
  #     faraday.request  :url_encoded             # form-encode POST params
  #     faraday.response :logger                  # log requests to STDOUT
  #     faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
  #   end
  # end

  def connect_to_elasticsearch(options=nil)
    # @elasticsearch = Elasticsearch::Client.new host: 'http://d0d7d0e3f98196d4000.qbox.io', transport_options: options
    @elasticsearch = Elasticsearch::Client.new host: 'http://ginkgo-5521397.us-east-1.bonsai.io', transport_options: options
  end
end