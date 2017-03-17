module Api
  module V0
    class CookHistoryController < BaseController
      before_filter :ensure_authorized

      def index
        page = params[:page] || 1
        user = User.find(@user_id_from_token)
        page_array = user.joule_cook_history_items.order('start_time DESC').page(page)
        serialized_items = ActiveModel::ArraySerializer.new(page_array, each_serializer: Api::JouleCookHistoryItemSerializer)
        render_api_response 200, {
          cookHistory: serialized_items,
          currentPage: page,
          totalPages: page_array.total_pages
        }
      end

      def find_by_guide
        guide_id = params[:guide_id]
        limit = params[:limit] || 999999

        if guide_id.blank?
          render_api_response 400, { message: "guide_id is required" }
          return
        end

        user = User.find(@user_id_from_token)
        results = user.joule_cook_history_items.order('start_time DESC').where(guide_id: guide_id).limit(limit)
        serialized_items = ActiveModel::ArraySerializer.new(results, each_serializer: Api::JouleCookHistoryItemSerializer)
        render_api_response 200, {
          cookHistory: serialized_items
        }
      end

      def create
        user = User.find(@user_id_from_token)
        cook_history_item = user.joule_cook_history_items.new(params[:cook_history])

        unless cook_history_item.valid?
          render_api_response 422, { errors: cook_history_item.errors }
        end

        case get_save_status(cook_history_item)
        when :success
          render_cook_history_item(cook_history_item)
        when :not_unique
          pre_existing_item = user.joule_cook_history_items.find_by_idempotency_id(params[:cook_history][:idempotency_id])
          if pre_existing_item
            render_cook_history_item(pre_existing_item)
          else # This means that a user is trying to create an entry that already exists, but has been "deleted"
            render_api_response 409, { message: "You are attempting to recreate a previously deleted resource" }
          end
        end
      end

      def destroy
        user = User.find(@user_id_from_token)
        item = user.joule_cook_history_items.find_by_external_id(params[:id])
        if item && item.destroy
          render_api_response 200, { message: "Successfully destroyed #{params[:id]}" }
        else
          render_api_response 404, { message: "Item not found" }
        end
      end

      private

      def get_save_status(record)
        begin
          :success if record.save
        rescue ActiveRecord::RecordNotUnique
          :not_unique
        end
      end

      def render_cook_history_item(item)
        serializer = Api::JouleCookHistoryItemSerializer.new(item)
        render_api_response 200, serializer.serializable_hash
      end

    end
  end
end
