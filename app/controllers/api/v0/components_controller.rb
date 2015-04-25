module Api
  module V0
    class ComponentsController < BaseController

      def show
        @component = Component.find(params[:id])
        render json: @component, serializer: Api::ComponentSerializer
      end

    end
  end
end