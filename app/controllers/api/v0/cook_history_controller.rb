module Api
  module V0
    class CookHistoryController < BaseController
      before_filter :ensure_authorized

      def index
        serialized_items = ActiveModel::ArraySerializer.new(
          cook_history_entries_collapsed(20),
          each_serializer: Api::JouleCookHistoryItemSerializer
        )
        render_api_response 200, { cookHistory: serialized_items }
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
        entry = user.joule_cook_history_items.find_by_external_id(params[:id])
        if entry
          destroy_all_by_cook_id(user.joule_cook_history_items, entry.cook_id)
        else
          return render_api_response 404, { message: "Entry not found" }
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
      
      def destroy_all_by_cook_id(user_entries, cook_id)
        entries_to_destroy = user_entries.where(cook_id: cook_id)
        logger.info "Destroying #{entries_to_destroy.count} cook history entries with cook_id: #{cook_id}"
        if entries_to_destroy.destroy_all
          render_api_response 200, { message: "Successfully destroyed #{params[:id]} and associated entries." }
        else
          render_api_response 500, { message: "Unable to destroy associated entries." }
        end
      end
      
      def cook_history_entries_collapsed(page_size)
        db_lookup_size = JouleCookHistoryItem.db_lookup_size
        current_page = 0
        end_of_list = false
        
        entries_by_cook_id = {}
        entry_query = User.find(@user_id_from_token)
          .joule_cook_history_items
          .order('id DESC')
        while !end_of_list && entries_by_cook_id.length < page_size
          entries = entry_query.page(current_page)
          end_of_list = entries.length < db_lookup_size
          current_page += 1
          
          # Insert most recent cook_id instance
          # only works if entries is ordered 'id DESC'
          entries.each do |entry|
            unless entries_by_cook_id[entry.cook_id]
              entries_by_cook_id[entry.cook_id] = entry
            end
          end
          
        end
        entries_by_cook_id.values.sort_by{|entry| -entry.id}.first(page_size)
      end
      
    end
  end
end
