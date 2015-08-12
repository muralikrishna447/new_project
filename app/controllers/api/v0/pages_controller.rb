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
        @page = Page.new(params[:page])
        puts @page.inspect
        if @page.save
          render json: @page, serializer: Api::PageSerializer
        else
          puts 'ERRORRR'
        end
      end

      def update
        @page = Page.find(params[:id])
        if @page.update_attributes(params[:page])
          render json: @page, serializer: Api::PageSerializer
        end
      end

    end
  end
end
