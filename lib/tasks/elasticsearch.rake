namespace :es do

  task :migrate_db => :environment do
    connect_to_source({params: {size: 100000, pretty: true}})
    connect_to_target
    source_data = @source.search index: 'bloom', body: { query: { match_all: { } } }
    source_comments = source_data['hits']['hits']
    bulk_body = []
    source_comments.each do |comment|
      puts 'THIS IS THE COMMENT'
      # index = comment['_index']
      index = 'xchefsteps'
      type = comment['_type']
      id = comment['_id']
      data = comment['_source']
      c = {
        'index' => {
          '_index' => index,
          '_type' => type,
          '_id' => id,
          'data' => data
        }
      }
      bulk_body << c
    end
    puts bulk_body
    puts bulk_body.length

    target_data = @target.bulk body: bulk_body
    puts target_data
  end

  task :fix_at_mentions => :environment do
    source = connect_to('http://ginkgo-5521397.us-east-1.bonsai.io/xchefsteps/comment',{params: {size: 100000, pretty: true}})
    source_data = source.search(q: '*disqus_WygUd1dluR*')
    source_comments = source_data['hits']['hits']
    bulk_body = []
    source_comments.each do |comment|
      index = comment['_index']
      type = comment['_type']
      id = comment['_id']
      content = comment['_source']['content'].gsub('@disqus_WygUd1dluR:disqus', "<a href='http://www.chefsteps.com/profiles/chris-young'>Chris Young</a>")
      data = {'doc' => {'content' => content}}
      c = {
        'update' => {
          '_index' => index,
          '_type' => type,
          '_id' => id,
          'data' => data
        }
      }
      bulk_body << c
    end
    puts bulk_body
    puts bulk_body.length

    target = connect_to('http://ginkgo-5521397.us-east-1.bonsai.io',{params: {size: 100000, pretty: true}})
    result = target.bulk body: bulk_body
    puts result
  end

  task :fix_missing_users => :environment do
    source = connect_to('http://ginkgo-5521397.us-east-1.bonsai.io',{params: {size: 100000, pretty: true}})
    source_data = source.search(index: 'xchefsteps', type: 'comment', q: 'author:null')
    source_comments = source_data['hits']['hits']
    bulk_body = []
    source_comments.each do |comment|
      index = comment['_index']
      type = comment['_type']
      id = comment['_id']
      content = comment['_source']['content'].gsub('@disqus_WygUd1dluR:disqus', "<a href='http://www.chefsteps.com/profiles/chris-young'>Chris Young</a>")
      data = {'doc' => {'content' => content}}
      c = {
        'update' => {
          '_index' => index,
          '_type' => type,
          '_id' => id,
          'data' => data
        }
      }
      bulk_body << c
    end
    puts bulk_body
    puts bulk_body.length

    # target = connect_to('http://ginkgo-5521397.us-east-1.bonsai.io',{params: {size: 100000, pretty: true}})
    # result = target.bulk body: bulk_body
    # puts result
  end

  task :migrate_polls => :environment do
    migrated_ids = []
    connect_to_target
    @comments = Comment.where(commentable_type: 'PollItem')
    @comments.each do |comment|
      unless migrated_ids.include?(comment.id)
        puts comment.inspect
        index = 'xchefsteps'
        type = 'comment'
        body = {
          'upvotes' => [],
          'asked' => [],
          'createdAt' => comment.created_at.to_i*1000,
          'author' => comment.user.id,
          'content' => comment.content,
          'dbParams' => {
            'commentsId' => "poll_item_#{comment.commentable_id}"
          }
        }
        puts body
        @target.index index: index, type: type, body: body
        migrated_ids << comment.id
        puts migrated_ids.join(',')
        puts '_______________________'
      end
    end
  end

  task :delete_one_comment => :environment do
    connect_to_target
    @target.delete index: 'xchefsteps', type: 'comment', id: 'X7vzkwq3TXmm_mWVMrtmzQ'
  end

  def connect_to_source(options=nil)
    @source = Elasticsearch::Client.new host: 'http://d0d7d0e3f98196d4000.qbox.io', transport_options: options
  end

  def connect_to_target(options=nil)
    @target = Elasticsearch::Client.new host: 'http://ginkgo-5521397.us-east-1.bonsai.io', transport_options: options
    # @target = Elasticsearch::Client.new host: 'http://5b5d08a8de96bb85000.qbox.io', transport_options: options
  end

  def connect_to(host, options=nil)
    connection = Elasticsearch::Client.new host: host, transport_options: options
  end

end