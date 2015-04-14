module Api
  module V0
    class CirculatorsController < BaseController
      before_filter :ensure_authorized

      def index
        @user = User.find @user_id_from_token
        render json: @user.circulators, each_serializer: Api::CirculatorSerializer
      end

      def create
        User.transaction do
          user = User.find @user_id_from_token

          #TODO correctly validate serial number
          circulator = Circulator.new(params[:circulator])
          logger.info "Creating circulator #{circulator.inspect}}"

          circulator.save!

          circulatorUser = CirculatorUser.new
          circulatorUser.user = user
          circulatorUser.circulator = circulator

          unless params[:owner] == false
            circulatorUser.owner = true
          end

          circulatorUser.save!

          render json: circulator, serializer: Api::CirculatorSerializer
        end
      end

      def destroy
        circulator_user = CirculatorUser.find_by_circulator_and_user params[:id], @user_id_from_token
        if circulator_user
          if circulator_user.owner
            circulator_user.circulator.destroy
            render json: {status: 200} , status: 200
          else
            render json: {status: 401, message: "Unauthorized: only owner can delete a circulator."}, status: 401
          end
        else
          # Including helpful debug message for now
          render json: {status: 401, message: "Unauthorized: only owner can delete a circulator."}, status: 401
        end
      end

      def token
        circulator_id = params[:id]
        circulator_user = CirculatorUser.find_by_circulator_and_user params[:id], @user_id_from_token
        if circulator_user.nil?
          logger.info "Unauthorized access to circulator [#{circulator_id}] by user [#{@user_id_from_token}]"
          render json: {status: 401, message: "Unauthorized"}, status: 401
          return
        end
        token = AuthToken.for_circulator(circulator_user.circulator)
        render json: token.to_json
      end
    end
  end
end
