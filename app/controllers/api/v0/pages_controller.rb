module Api
  module V0
    class PagesController < BaseController

      before_filter :authenticate_active_admin_user!, only: [:index, :create, :update]

      def index
        @pages = Page.all
        render json: @pages, each_serializer: Api::PageSerializer
      end

      def show
        begin
          @page = Page.friendly.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          return render_api_response 404, {message: 'Page not found'}
        end
        render json: @page, serializer: Api::PageSerializer
      end

      def create
        @page = Page.new(set_component_params)
        if @page.save
          render json: @page, serializer: Api::PageSerializer
        end
      end

      def update
        @page = Page.find(params[:id])
        if @page.update_attributes(set_component_params)
          render json: @page, serializer: Api::PageSerializer
        end
      end

      private
      def set_component_params
        # Allows the api to accept params[:page][:component] and updates it to something rails prefers for nested associations
        page_params = params[:page]
        if page_params[:components]
          converted_components = []
          page_params[:components].each do |component|
            converted_components << convert_hash_keys(component)
          end
          page_params[:components_attributes] = converted_components
          page_params.delete :components
        end
        params.require(:page).permit(:title, :content, :image_id, :primary_path, :short_description,
                                     :show_footer, :is_promotion, :redirect_path, :discount_id,
                                     components_attributes: [:id, :component_type, :meta, :name,
                                                             :component_parent_type, :component_parent_id,
                                                             :position, :slug, :_destroy])
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
