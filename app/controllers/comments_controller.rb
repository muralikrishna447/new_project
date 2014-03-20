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

  def info
    split_id = params['commentsId'].split('_')
    resource = split_id[0]
    id = split_id[1]
    @commentable = resource.singularize.classify.constantize.find(id)
    title = @commentable.title
    url = polymorphic_url(@commentable)
    info = Hash.new
    info['title'] = title
    info['url'] = url
    render :json => JSON.generate(info)
  end

private

  def load_commentable
    resource, id = request.path.split('/')[1, 2]
    @commentable = resource.singularize.classify.constantize.find(id.to_i)
    puts '---------------'
    puts resource
  end

end