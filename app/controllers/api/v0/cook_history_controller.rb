module Api
  module V0
    class CookHistoryController < BaseController
      before_filter :ensure_authorized

      def index
        page = params[:page] || 1
        user = User.find(@user_id_from_token)
        page_array = user.joule_cook_history_items.page(page).per(20)
        serialized_items = ActiveModel::ArraySerializer.new(page_array, each_serializer: Api::JouleCookHistoryItemSerializer)
        render_api_response 200, {
          cookHistory: serialized_items,
          currentPage: page,
          totalPages: page_array.total_pages
        }
      end
      
      def create
        user = User.find(@user_id_from_token)
        cook_history_item = user.joule_cook_history_items.new(params[:cook_history])
        if cook_history_item.save
          serializer = Api::JouleCookHistoryItemSerializer.new(cook_history_item)
          render_api_response 200, serializer.serializable_hash
        end
      end
      
      def destroy
        user = User.find(@user_id_from_token)
        item = user.joule_cook_history_items.find_by_uuid(params[:id])
        if item && item.destroy
          render_api_response 200, { message: "Successfully destroyed #{params[:id]}" }
        else
          render_api_response 404, { message: "Item not found" }
        end
      end
      
    end
  end
end
