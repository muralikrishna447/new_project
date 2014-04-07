namespace :comments do
  task :migrate_activities => :environment do
    connect_to_disqus_xml('~/Downloads/chefstepsproduction-2014-04-07T20-09-24.957262-all.xml')

    #go through each activity and get disqus id
    activities = Activity.any_user_generated.published
    activities.each do |activity|
      puts activity.id
      disqus_thread_id = determine_disqus_thread_id("activity-#{activity.id}")
      disqus_comments = get_disqus_posts(disqus_thread_id)
      puts disqus_comments
    end
    puts activities.count
  end

  task :migrate_polls => :environment do

  end

  task :migrate_ingredients => :environment do

  end

  def get_custom_comments
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

  def get_disqus_posts(thread_id)
    posts = @parsed['post']
    specific_posts = posts.select{|k,v| k['thread']["@dsq:id"] == thread_id}
    specific_posts
  end

  def connect_to_elasticsearch
  end

  def connect_to_bloom
  end
end