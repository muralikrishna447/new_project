module Api
  module V0
    class ComponentsController < BaseController

      before_filter :authenticate_active_admin_user!, only: [:index, :create, :update, :destroy]

      def index
        @components = Component.all
        render json: @components, each_serializer: Api::ComponentSerializer
      end

      def show
        begin
          @component = Component.friendly.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          return render_api_response 404, {message: 'Component not found'}
        end
        render json: @component, serializer: Api::ComponentSerializer
      end

      def create
        component_params = convert_hash_keys(params[:component])
        @component = Component.new(component_params)
        if @component.save
          render json: @component, serializer: Api::ComponentSerializer
        end
      end

      def update
        @component = Component.find(params[:id])
        component_params = convert_hash_keys(params[:component])
        if @component.update_attributes(component_params)
          render json: @component, serializer: Api::ComponentSerializer
        end
      end

      def destroy
        @component = Component.find(params[:id])
        if @component.destroy
          render nothing: true, status: 200
        end
      end

      private
      def underscore_key(k)
        if k == 'componentType' || k == 'componentParentType' || k == 'componentParentId'
          k.to_s.underscore.to_sym
        else
          k
        end
      end

      def convert_hash_keys(value)
        case value
          when Array
            value.map { |v| convert_hash_keys(v) }
            # or `value.map(&method(:convert_hash_keys))`
          when Hash
            Hash[value.map { |k, v| [underscore_key(k), convert_hash_keys(v)] }]
          else
            value
        end
      end

    end
  end
end
