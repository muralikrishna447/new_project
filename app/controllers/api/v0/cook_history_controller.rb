module Api
  module V0
    class CookHistoryController < BaseController

      def index
        render json: { message: "hello world!" }
      end
      
      def create
        binding.pry
      end
      
    end
  end
end
