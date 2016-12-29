module Api
  module V0
    class CookHistoryController < BaseController
      before_filter :ensure_authorized

      def index
        user = User.find(@user_id_from_token)
        cook_history_items = user.cook_history_items.includes(:joule_cook_history_program).first(20)
        render_api_response 200, cook_history_items, Api::CookHistoryItemSerializer
      end
      
      def create
        user = User.find(@user_id_from_token)
        cook_history_item = user.cook_history_items.new(params[:cook_history])
        if cook_history_item.save
          render_api_response 200, cook_history_item, Api::CookHistoryItemSerializer
        end
      end
      
      def destroy
        user = User.find(@user_id_from_token)
        item = user.cook_history_items.find_by_uuid(params[:id])
        if item && item.destroy
          render_api_response 200, { message: "Successfully destroyed #{params[:id]}" }
        else
          render_api_response 404, { message: "Item not found" }
        end
      end
      
    end
  end
end
