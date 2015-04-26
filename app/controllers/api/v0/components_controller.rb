module Api
  module V0
    class ComponentsController < BaseController

      def show
        @component = Component.find(params[:id])
        render json: @component, serializer: Api::ComponentSerializer
      end

      def create
        @component = Component.new(params[:component])
        if @component.save
          render json: @component, serializer: Api::ComponentSerializer
        end
      end

      def update
        @component = Component.find(params[:id])
        if @component.update_attributes(params[:component])
          render json: @component, serializer: Api::ComponentSerializer
        end
      end

    end
  end
end