module Api
  module V0
    class CirculatorsController < BaseController
      before_filter :ensure_authorized

      def index
        @user = User.find @user_id_from_token
        render json: @user.circulators, each_serializer: Api::CirculatorSerializer
      end

      def create
        # with and without auto-ownership
        # TODO - where are the transaction boundaries?
        User.transaction do
          user = User.find @user_id_from_token
          #correctly validate serial number

          # TODO - make it idempotent
          circulator = Circulator.new(params[:circulator])
          logger.info "Creating circulator #{circulator.inspect}}"

          circulator.save!

          circulatorUser = CirculatorUser.new
          circulatorUser.user = user
          circulatorUser.circulator = circulator

          if params[:owner]
            circulator.owner = true
          end

          circulatorUser.save!

          render json: circulator, serializer: Api::CirculatorSerializer
        end
      end

      def token
        circulator_id = params[:id]
        circulator_user = CirculatorUser.where(circulator_id: params[:id], user_id: @user_id_from_token).first
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
