module Api
  module V0
    class ComponentsController < BaseController

      def index
        @components = Component.all
        render json: @components, each_serializer: Api::ComponentSerializer
      end

      def show
        @component = Component.find(params[:id])
        render json: @component, serializer: Api::ComponentSerializer
      end

      def create
        puts "Params: #{params}"
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

      private
      def underscore_key(k)
        if k == 'componentType'
          k.to_s.underscore.to_sym
        else
          k
        end
      end

      def convert_hash_keys(value)
        puts "VALUE IS: #{value}"
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
