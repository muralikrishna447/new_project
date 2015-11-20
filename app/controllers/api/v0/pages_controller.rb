module Api
  module V0
    class PagesController < BaseController

      before_filter :authenticate_active_admin_user!, only: [:index, :create, :update]

      def index
        @pages = Page.all
        render json: @pages, each_serializer: Api::PageSerializer
      end

      def show
        @page = Page.find_by_id(params[:id])
        if @page
          render json: @page, serializer: Api::PageSerializer
        else
          render_api_response 404, {message: 'Page not found.'}
        end
      end

      def create
        page_params = set_component_params(params[:page])
        @page = Page.new(page_params)
        if @page.save
          render json: @page, serializer: Api::PageSerializer
        end
      end

      def update
        @page = Page.find(params[:id])
        page_params = set_component_params(params[:page])
        if @page.update_attributes(page_params)
          render json: @page, serializer: Api::PageSerializer
        end
      end

      private
      def set_component_params(value)
        # Allows the api to accept params[:page][:component] and updates it to something rails prefers for nested associations
        page_params = value
        if value[:components]
          converted_components = []
          value[:components].each do |component|
            converted_components << convert_hash_keys(component)
          end
          page_params[:components_attributes] = converted_components
          page_params.delete :components
        end
        page_params
      end

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
