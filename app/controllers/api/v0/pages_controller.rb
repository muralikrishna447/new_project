module Api
  module V0
    class PagesController < BaseController

      before_filter :authenticate_active_admin_user!, only: [:index, :create, :update]

      def index
        @pages = Page.all
        render json: @pages, each_serializer: Api::PageSerializer
      end

      def show
        @page = Page.find(params[:id])
        render json: @page, serializer: Api::PageSerializer
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
          page_params[:component_pages_attributes] = value[:components]
          page_params.delete :components
        end
        page_params
      end

    end
  end
end
