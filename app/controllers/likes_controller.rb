class LikesController < ApplicationController
  before_filter :authenticate_user!, only: [:create]

  def create
    if params[:likeable_type] && params[:likeable_id]
      @like = Like.new(likeable_type: params[:likeable_type], likeable_id: params[:likeable_id])
      @like.user_id = current_user.id
      if @like.save
        track_event @like
        track_receiver_event @like
      end
    end
    render nothing: true
    # redirect_to request.referrer
  end

  def by_user
    resource = params[:likeable_type]
    id = params[:likeable_id]
    if ['Activity'].include?(resource)
      @likeable = resource.singularize.classify.constantize.find(id)
      @likes = current_user.likes_object?(@likeable)
      render :json => @likes.to_json
    end
  end

end