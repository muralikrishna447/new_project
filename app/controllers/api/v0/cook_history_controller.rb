module Api
  module V0
    class CookHistoryController < BaseController
      before_filter :ensure_authorized

      def index
        user = User.find(@user_id_from_token)
        cook_history_items = user.cook_history_items.includes(:joule_cook_history_program)
        render json: cook_history_items, each_serializer: Api::CookHistoryItemSerializer
      end
      
      def create
        user = User.find(@user_id_from_token)
        cook_history_item = user.cook_history_items.new(params[:cook_history])
        render nothing: true, status: 200 if cook_history_item.save
      end
      
      def destroy
        user = User.find(@user_id_from_token)
        item = user.cook_history_items.find(params[:id])
        render nothing: true, status: 200 if item.destroy
      end
      
    end
  end
end
