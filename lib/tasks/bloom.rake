namespace :bloom do
  require 'hashie'
  task :migrate_chefsteps_to_bloom => :environment do
    connect_to_new_bloom
    ginko = connect_to('http://ginkgo-5521397.us-east-1.bonsai.io',{params: {size: 100000, pretty: true}})
    source_data = ginko.search index: 'xchefsteps', type: 'comment', body: { query: { match_all: { } } }
    source_comments = source_data['hits']['hits']
    source_comments.each do |comment|

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
        "createdAt" => created_at,
        "apiKey" => 'xchefsteps',
        "U2FsdGVkX19re0c2zy0ElfLsPY3sj11JsbCs81IK7Todj0mzFMb5%2B8zPBGJtyuFl" => "\\".first
      }
      if comment['_id'] == 'NgwF0jx2Ts66OTXFOBPqbA'
        puts '*'*40
        puts 'Trying to migrate this: '
        puts comment
        puts '-'* 40
        puts 'Map data to new structure: '
        puts update_data
        puts '*'*40
        # auth_params = {'apiKey' => 'xchefsteps', 'auth' => 'U2FsdGVkX19re0c2zy0ElfLsPY3sj11JsbCs81IK7Todj0mzFMb5%2B8zPBGJtyuFl'}
        # data_with_auth = update_data.merge(auth_params)
        # puts data_with_auth
        bloom_response = @bloom.post('/comments', update_data)
        # bloom_response = @bloom.basic_auth('xchefsteps','U2FsdGVkX19re0c2zy0ElfLsPY3sj11JsbCs81IK7Todj0mzFMb5%2B8zPBGJtyuFl')
        puts bloom_response.body
        # puts bloom_response
      end
      
    end
    puts source_comments.size
  end

  task :delete_one_comment => :environment do
    target = connect_to('http://ginkgo-5521397.us-east-1.bonsai.io',{params: {size: 100000, pretty: true}})
    target.delete index: 'xchefsteps', type: 'comment', id: 'mpi_W5qQRbq281bhrIMVQg'
  end

  ## Example with options:
  ## connect_to('http://ginkgo-5521397.us-east-1.bonsai.io',{params: {size: 100000, pretty: true}})
  def connect_to(host, options=nil)
    Elasticsearch::Client.new host: host, transport_options: options
  end

  def connect_to_new_bloom
    @bloom = Faraday.new(:url => 'http://api.usebloom.com') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end
end