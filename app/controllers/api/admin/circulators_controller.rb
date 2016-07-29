module Api
  module Admin
    class CirculatorsController < ApiAdminController
      def index
        @circulators = Circulator.last(10)
        render json: @circulators
      end
    end
  end
end
