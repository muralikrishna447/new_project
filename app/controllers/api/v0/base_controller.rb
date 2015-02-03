module Api
  module V0
    class BaseController < ActionController::Base

      protected

      def ensure_authorized
        begin
          token = request.authorization()
          puts "TOKEN IS: "
          puts token
          decoded = JWT.decode(token, 'SomeSecret')
          user = User.find decoded['user']['id']
        rescue Exception => e
          puts e
          render json: {status: '401 Unauthorized'}, status: 401
        end

      end
    end
  end
end