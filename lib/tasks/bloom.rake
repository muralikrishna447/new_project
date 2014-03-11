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

  task :get_comments => :environment do
    connect_to_bloom
    response = @bloom.get '/comments'
    puts response
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

end