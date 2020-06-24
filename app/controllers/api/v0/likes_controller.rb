module Api
  module V0
    class LikesController < BaseController

      before_action :ensure_authorized

      def create
        if params[:likeable_type] && params[:likeable_id]
          @like = Like.new(likeable_type: params[:likeable_type], likeable_id: params[:likeable_id], user_id: @user_id_from_token)
          if @like.save!
            reindex(params[:likeable_type], params[:likeable_id])
          end
        end
        render json: @like.to_json
      end

      def destroy
        @like = Like.find params[:id]
        if @like.destroy
          reindex(@like.likeable_type, @like.likeable_id)
        end
        render json: @like.to_json
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
  end
end
