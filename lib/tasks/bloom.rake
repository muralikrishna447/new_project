namespace :bloom do
  require 'hashie'
  include ActionView::Helpers::JavaScriptHelper
  task :migrate_chefsteps_to_bloom => :environment do
    # connect_to_new_bloom
    migrated = []
    ginko = connect_to('http://ginkgo-5521397.us-east-1.bonsai.io',{params: {size: 100000, pretty: true}})
    bloom = connect_to('https://boxwood-2704780.us-east-1.bonsai.io',{params: {size: 100000, pretty: true}})
    source_data = ginko.search index: 'xchefsteps', type: 'comment', body: { query: { match_all: { } } }
    source_comments = source_data['hits']['hits']
    bulk_body = []
    source_comments.each do |comment|
      unless migrated.include?(comment['_id'])
        # Extract the old data
        content = comment['_source']['content']
        comments_id = comment['_source']['dbParams']['commentsId']
        comments_type = "comments"
        author = comment['_source']['author'].to_s
        parent_comment_id = comment['_source']['parentCommentId']

        likes = []
        comment['_source']['upvotes'].each do |vote|
          vote_item = {
            "user" => vote['author'],
            "createdAt" => vote['createdAt']
          }
          likes << vote_item
        end

        created_at = comment['_source']['createdAt']

        # Map it to the new data
        update_data = {
          "content" => content,
          "dbParams" => {
              "commentsId" => comments_id,
              "commentsType" => comments_type
          },
          "parentCommentId" => parent_comment_id,
          "author" => author,
          "likes" => likes,
          "createdAt" => created_at
        }
      
        puts '*'*40
        puts 'Trying to migrate this: '
        puts comment
        puts '-'* 40
        puts 'Map data to new structure: '
        puts update_data
        puts '*'*40

        index = comment['_index']
        type = comment['_type']
        id = comment['_id']
        c = {
          'index' => {
            '_index' => index,
            '_type' => type,
            '_id' => id,
            'data' => update_data
          }
        }
        bulk_body << c

        # puts bulk_body
        # puts bulk_body.length

        migrated << "'#{id}'"
        puts migrated.join(',')
        puts 'Migrated size'
        puts migrated.size
      end
    end
    target_data = bloom.bulk body: bulk_body
    puts target_data
    puts 'Source comments size'
    puts source_comments.size
  end

  task :delete_one_comment => :environment do
    [].each do |id|
      target = connect_to('http://ginkgo-5521397.us-east-1.bonsai.io',{params: {size: 100000, pretty: true}})
      target.delete index: 'xchefsteps', type: 'comment', id: id
    end
  end

  task :delete_from_bloom => :environment do
    ['NdKeGJAjQyOzcAwOUS4PYQ','pOub7Kj9QQG3jB2Ugqlsnw','YCwaNxNCQbirX8de181PTw','TV4YdzafQgCzcdNwMtAp3w','pnSwJk6hQaijI-dKezNppw','7PmnxrFARbCn7UOR7DtdLg','oelgAz7xR5W23rFxQKmMPg','V9bYhRy-RkWQYOL-TwQHDw','6ZYBLEMnRVqEIXEeL54XnQ'].each do |id|
      target = connect_to('https://boxwood-2704780.us-east-1.bonsai.io',{params: {size: 100000, pretty: true}})
      target.delete index: 'xchefsteps', type: 'comment', id: id
    end
  end

  task :get_all_bloom_ids => :environment do
    bloom = connect_to('https://boxwood-2704780.us-east-1.bonsai.io',{params: {size: 100000, pretty: true}})
    source_data = bloom.search index: 'xchefsteps', type: 'comment', body: { query: { match_all: { } } }
    source_comments = source_data['hits']['hits']
    ids = []
    source_comments.each do |comment|
      ids << "'#{comment['_id']}'"
    end
    puts ids.join(',')
  end

  ## Example with options:
  ## connect_to('http://ginkgo-5521397.us-east-1.bonsai.io',{params: {size: 100000, pretty: true}})
  def connect_to(host, options=nil)
    Elasticsearch::Client.new host: host, transport_options: options
  end

  def connect_to_new_bloom
    @bloom = Faraday.new(:url => 'https://api.usebloom.com') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def get_auth(user_id)
    user = User.find(user_id)
    user.encrypted_bloom_info
  end
end