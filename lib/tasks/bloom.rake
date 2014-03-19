namespace :bloom do
  require 'json'  
  desc "post comments"
  task :post_comments => :environment do
    conn = Faraday.new(:url => 'http://chefsteps-bloom.herokuapp.com') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    # @upload = Upload.find('macaron-with-chocolate-ganache')
    # @upload.comments.each do |comment|
    #   puts comment.inspect
    #   puts comment.user
    #   post_comment(conn, comment.user, @upload.class.to_s.downcase, @upload.id, comment.content)
    # end
    @comments = Comment.where(commentable_type: 'Upload')
    @comments.each do |comment|
      puts comment.inspect
      puts comment.user
      post_comment(conn, comment.user, comment.commentable.class.to_s.downcase, comment.commentable.id, comment.content)
    end

  end

  # task :get_comments => :environment do
  #   connect_to_bloom
  #   response = @bloom.get '/comments'
  #   @comments =  JSON.parse(response.body)
  #   @comments.each do |comment|
  #     puts comment.inspect
  #   end
  # end

  task :get_comments => :environment do
    connect_to_es
    response = @elasticsearch.get '/bloom/comment/_search', {size: 1000, realtime: true}

    comments = JSON.parse(response.body)['hits']['hits']
    comments.each do |comment|
      es_id = comment['_id']
      upload_id = comment['_source']['upload']
      puts '******'
      puts es_id
      puts upload_id
      # remove_db_params_on_comment(es_id)
      add_db_params_to_comment(es_id,'upload',upload_id)
      puts '******'
    end
    # response = @elasticsearch.get '/bloom/comment/SkJqrkYET0u46plX1pRASg'
    # comment = JSON.parse(response.body)
    # puts comment
    # upload_id = comment['_source']['upload']

    # post_body = {
    #   "script" => "ctx._source.test = 'some text'"
    # }

    # post_body = {
    #   "script" => "ctx._source.remove(\"test\")"
    # }

    # post_body = {
    #   "script" => "ctx._source.remove(\"db-params\")"
    # }

    # post_body = {
    #   "doc" => {
    #     "db-params" => {
    #       "commentsId" => "upload-#{upload_id}"
    #     }
    #   }
    # }

    # puts JSON.generate(post_body)
    # post_response = @elasticsearch.post do |req|
    #   req.url '/bloom/comment/SkJqrkYET0u46plX1pRASg/_update'
    #   req.headers['Content-Type'] = 'application/json'
    #   req.body = JSON.generate(post_body)
    # end
    # puts JSON.parse(post_response.body)

    # remove_db_params_on_comment('SkJqrkYET0u46plX1pRASg')
    # add_db_params_to_comment('SkJqrkYET0u46plX1pRASg','upload',upload_id)
  end

  def post_comment(conn, user, commentable_name, commentable_id, content)
    body = {
      "params" => {
        "save" => { 
          "author" => user.id,
          "content" => "<p>#{content}</p>",
          "#{commentable_name}" => commentable_id
        },
        "auth" => {
          "user" => user.id,
          "token" => user.authentication_token
        }
      }
    }
    conn.post do |req|
      req.url '/comments'
      req.headers['Content-Type'] = 'application/json'
      req.body = JSON.generate(body)
    end
  end

  def connect_to_bloom
    @bloom = Faraday.new(:url => 'http://chefsteps-bloom.herokuapp.com') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def connect_to_es
    @elasticsearch = Faraday.new(:url => 'http://d0d7d0e3f98196d4000.qbox.io/') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def add_db_params_to_comment(es_id, commentable_type, commentable_id)
    post_body = {
      "doc" => {
        "dbParams" => {
          "commentsId" => "#{commentable_type}-#{commentable_id}"
        }
      }
    }
    post_response = @elasticsearch.post do |req|
      req.url "/bloom/comment/#{es_id}/_update"
      req.headers['Content-Type'] = 'application/json'
      req.body = JSON.generate(post_body)
    end
    puts JSON.parse(post_response.body)
    puts '********'
  end

  def remove_db_params_on_comment(es_id)
    post_body = {
      "script" => "ctx._source.remove(\"dbParams\")"
    }
    post_response = @elasticsearch.post do |req|
      req.url "/bloom/comment/#{es_id}/_update"
      req.headers['Content-Type'] = 'application/json'
      req.body = JSON.generate(post_body)
    end
    puts JSON.parse(post_response.body)
    puts '********'
  end

end