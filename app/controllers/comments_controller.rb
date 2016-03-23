class CommentsController < ApplicationController

  before_filter :authenticate_user!, only: [:create]
  before_filter :load_commentable, only: [:index, :create]

  def index
    @comments = @commentable.comments
    render :json => @comments.to_json(:include => :user)
  end

  def create
    @comment = @commentable.comments.new(params[:comment])
    @comment.user_id = current_user.id
    if @comment.save
      render :json => @comment.to_json(:include => :user)
      track_event @comment
      track_receiver_event @comment
    end
  end

  # Used by Bloom Dashboard to get context
  def info
    commentsId = params['commentsId']
    @commentable = find_commentable(commentsId)
    if @commentable
      title = @commentable.title
      url = determine_url(@commentable)
      info = Hash.new
      info['title'] = title
      info['url'] = url
      render :json => JSON.generate(info)
    else
      render :nothing => true, status: 404
    end
  end

private

  def load_commentable
    resource, id = request.path.split('/')[1, 2]
    @commentable = resource.singularize.classify.constantize.find(id.to_i)
    puts '---------------'
    puts resource
  end

  def find_commentable(commentsId)
    pos = commentsId.rindex('_')
    if pos
      class_name = commentsId[0...pos]
      id = commentsId[pos+1..-1]
      class_name.gsub('_', ' ').titleize.gsub(' ','').singularize.classify.constantize.find(id)
    end
  end

  def determine_url(commentable)
    polymorphic_url(commentable)
  end

end