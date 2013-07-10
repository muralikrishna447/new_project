class CommentsController < ApplicationController
  
  before_filter :authenticate_user!
  before_filter :load_commentable

  def create
    @comment = @commentable.comments.new(params[:comment])
    @comment.user_id = current_user.id
    if @comment.save
      redirect_to @commentable
    else
      render :new
    end
  end

private

  def load_commentable
    resource, id = request.path.split('/')[1, 2]
    @commentable = resource.singularize.classify.constantize.find(id)
  end

end