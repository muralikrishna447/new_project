class CommentsController < ApplicationController
  
  before_filter :authenticate_user!, only: [:create]
  before_filter :load_commentable

  def index
    @comments = @commentable.comments
    render nothing: true
  end

  def create
    @comment = @commentable.comments.new(params[:comment])
    @comment.user_id = current_user.id
    if @comment.save
      # redirect_to @commentable
      redirect_to request.referer
    else
      render :new
    end
  end

private

  def load_commentable
    resource, id = request.path.split('/')[1, 2]
    @commentable = resource.singularize.classify.constantize.find(id)
    puts '---------------'
    puts resource
  end

end