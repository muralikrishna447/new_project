module Api
  module V0
    class CookHistoryController < BaseController
      before_filter :ensure_authorized
      before_each :get_user

      def index
        cook_history_items = user.joule_cook_history_items
          .order('start_time ASC').last(20)
        render_api_response 200, cook_history_items, Api::JouleCookHistoryItemSerializer
      end
      
      def create
        cook_history_item = user.joule_cook_history_items.new(params[:cook_history])
        if cook_history_item.save
          serializer = Api::JouleCookHistoryItemSerializer.new(cook_history_item)
          render_api_response 200, serializer.serializable_hash
        end
      end
      
      def destroy
        item = user.joule_cook_history_items.find_by_uuid(params[:id])
        if item && item.destroy
          render_api_response 200, { message: "Successfully destroyed #{params[:id]}" }
        else
          render_api_response 404, { message: "Item not found" }
        end
      end
      
      private
      
      def get_user
        user = User.find(@user_id_from_token)
      end
      
    end
  end
end
