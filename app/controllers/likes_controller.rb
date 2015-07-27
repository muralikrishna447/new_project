class LikesController < ApplicationController
  before_filter :authenticate_user!, only: [:create, :unlike]


  def create
    if params[:likeable_type] && params[:likeable_id]
      @like = Like.new(likeable_type: params[:likeable_type], likeable_id: params[:likeable_id])
      @like.user_id = current_user.id
      if @like.save
        track_event @like
        track_receiver_event @like
        reindex(params[:likeable_type], params[:likeable_id])
      end
    end
    render nothing: true
    # redirect_to request.referrer
  end

  def unlike
    if params[:likeable_type] && params[:likeable_id]
      @like = Like.where(likeable_type: params[:likeable_type], likeable_id: params[:likeable_id], user_id: current_user.id).first.destroy
      reindex(params[:likeable_type], params[:likeable_id])
    end
    render nothing: true
  end

  def by_user
    if ! current_user
      render json: []
      return
    end

    resource = params[:likeable_type]
    id = params[:likeable_id]
    if ['Activity', 'Upload'].include?(resource)
      @likeable = resource.singularize.classify.constantize.find(id)
      @likes = current_user.likes_object?(@likeable) ? [true] : []
      render :json => @likes.to_json
    end
  end

  private
  def reindex(likeable_type, likeable_id)
    # If the likeable object is indexed by Algolia, trigger reindex so the count is updated
    klazz = likeable_type.constantize
    if klazz.method_defined?(:index!)
      klazz.find(likeable_id).index! rescue nil
    end
  end

end