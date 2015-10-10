module Api
  module V0
    class LikesController < BaseController

      before_filter :ensure_authorized

      def create
        if params[:likeable_type] && params[:likeable_id]
          @like = Like.new(likeable_type: params[:likeable_type], likeable_id: params[:likeable_id])
          @like.user_id = current_user.id
          if @like.save!
            reindex(params[:likeable_type], params[:likeable_id])
          end
        end
        render json: @like.to_json
      end

      # private
      # def underscore_key(k)
      #   if k == 'componentType' || k == 'componentParentType' || k == 'componentParentId'
      #     k.to_s.underscore.to_sym
      #   else
      #     k
      #   end
      # end
      #
      # def convert_hash_keys(value)
      #   case value
      #     when Array
      #       value.map { |v| convert_hash_keys(v) }
      #       # or `value.map(&method(:convert_hash_keys))`
      #     when Hash
      #       Hash[value.map { |k, v| [underscore_key(k), convert_hash_keys(v)] }]
      #     else
      #       value
      #   end
      # end
      
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
