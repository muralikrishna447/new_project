namespace :comments do
  task :migrate_activities => :environment do
    connect_to_disqus_xml('~/Downloads/chefstepsproduction-2014-04-07T20-09-24.957262-all.xml')

    #go through each activity and get disqus id
    activities = Activity.any_user_generated.published
    
    activities.each do |activity|
      # Hash containing meta data to help with migration
      c = []

      disqus_thread_id = determine_disqus_thread_id("activity-#{activity.id}")

      # get the comments
      disqus_comments = get_disqus_posts(disqus_thread_id)
      disqus_comments.each do |comment|
        c_info = Hash.new
        c_info[:activity_id] = activity.id
        c_info[:disqus_thread_id] = disqus_thread_id
        c_info[:disqus_id] = comment["@dsq:id"]
        c_info[:disqus_parent_id] = comment['parent']["@dsq:id"] if comment['parent']
        puts c_info
        puts "******THAT WAS THE INFO********"
      end
      
      # get only comments without parent
      # disqus_comments_without_parent = filter_comments_without_parent(disqus_comments)

      # check to see if comments without parents have any children

      # recursive children



    end
    puts activities.count
  end

  task :migrate_polls => :environment do

  end

  task :migrate_ingredients => :environment do

  end

  def connect_to_disqus_xml(path_and_filename)
    xml = File.read(File.expand_path(path_and_filename))
    parser = Nori.new
    @parsed = parser.parse(xml)['disqus']
  end

  def determine_disqus_thread_id(activity_id)
    threads = @parsed['thread']
    thread = threads.select{|k,v| k["id"] == activity_id}[0]
    thread["@dsq:id"]
  end

  def get_disqus_thread(thread_id)
    threads = @parsed['thread']
    thread = threads.select{|k,v| k["@dsq:id"] == thread_id}
    thread
  end

  # Get disqus comments by thread id
  def get_disqus_posts(thread_id)
    posts = @parsed['post']
    specific_posts = posts.select{|k,v| k['thread']["@dsq:id"] == thread_id}
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

  def connect_to_elasticsearch
  end

  def connect_to_bloom
  end
end