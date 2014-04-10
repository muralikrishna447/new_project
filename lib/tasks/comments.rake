namespace :comments do
  require 'nokogiri'
  require 'json'
  task :migrate_activities => :environment do
    connect_to_disqus_xml('~/Downloads/chefstepsproduction-2014-04-07T20-09-24.957262-all.xml')
    connect_to_es
    #go through each activity and get disqus id
    # activities = Activity.any_user_generated.published
    
    # activities.each do |activity|
    #   migrate_one(activity)
    # end

    activity = Activity.find('honey-sriracha')
    # activity = Activity.find('buffalo-style-chicken-skin')
    migrate_one(activity)

  end

  task :migrate_polls => :environment do

  end

  task :migrate_ingredients => :environment do

  end

  def migrate_one(activity)
    # Hash containing meta data to help with migration
    c = []

    disqus_thread_id = determine_disqus_thread_id("activity-#{activity.id}")

    # get the comments
    disqus_comments = get_disqus_posts(disqus_thread_id)
    disqus_comments.each do |comment|
      c_info = Hash.new
      c_info[:commentable_type] = 'activity'
      c_info[:commentable_id] = activity.id
      c_info[:disqus_thread_id] = disqus_thread_id
      c_info[:disqus_id] = comment['@dsq:id']
      c_info[:disqus_parent_id] = comment['parent']['@dsq:id'] if comment['parent']
      c_info[:disqus_user_email] = comment['author']['email']
      
      c_info[:created_at] = (comment['createdAt']).to_i

      c_info[:chefsteps_user_id] = get_chefsteps_user_id(comment['author']['email'])
      content = Nokogiri::HTML(comment['message']).text
      if c_info[:chefsteps_user_id]
        c_info[:content] = content
      else
        c_info[:content] = content + " - originally posted by #{comment['author']['name']}"
      end
      # puts comment
      # puts "******THAT WAS THE COMMENT********"
      # puts c_info
      # puts "******THAT WAS THE INFO********"
      c << c_info
    end

    # Loop through c_info and migrate the parents
    # c.each do |comment_info|
    #   unless comment_info[:disqus_parent_id]
    #     post_to_es(comment_info)
    #     find_children(c, comment_info, 1)
    #   end
    # end

    comment_info = c.first
    post_to_es(comment_info)
    find_children(c, comment_info, 1)
  end

  def post_to_es(comment_info)
    puts '******************************'
    post_body = {
      "doc" => {
        "createdAt" => comment_info[:created_at],
        "author" => comment_info[:chefsteps_user_id],
        "content" => comment_info[:content],
        "dbParams" => {
          "commentsId" => "#{comment_info[:commentable_type]}_#{comment_info[:commentable_id]}"
        }
      }
    }
    post_body["doc"]["parentCommentId"] = comment_info[:bloom_parent_id] unless comment_info[:bloom_parent_id].blank?
    puts post_body
    post_response = @elasticsearch.post do |req|
      req.url "/bloom/comment"
      req.headers['Content-Type'] = 'application/json'
      req.body = JSON.generate(post_body)
    end
    puts post_response
    # puts comment_info
    comment_info[:bloom_id] = 'Bloom ID from Response'
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
    thread['@dsq:id']
  end

  def get_disqus_thread(thread_id)
    threads = @parsed['thread']
    thread = threads.select{|k,v| k['@dsq:id'] == thread_id}
    thread
  end

  # Get disqus comments by thread id
  def get_disqus_posts(thread_id)
    posts = @parsed['post']
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

  def connect_to_es
    @elasticsearch = Faraday.new(:url => 'http://d0d7d0e3f98196d4000.qbox.io/') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def connect_to_bloom
  end

  # Functions to help pull data from chefsteps
  def get_chefsteps_user_id(email)
    user = User.where(email: email).first
    user.id unless user.blank?
  end

  def connect_to_es
    @elasticsearch = Faraday.new(:url => 'http://d0d7d0e3f98196d4000.qbox.io/') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  task :update_events_count => :environment do
    User.reset_column_information
    User.find_each do |user|
      if User.reset_counters user.id, :events
        user.reload
        puts 'updated'
        puts user.inspect
        puts '*********'
      end
    end
  end
end