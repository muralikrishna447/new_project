module Api
  module V0
    class CirculatorsController < BaseController
      before_filter :ensure_authorized

      def index
        @user = User.find @user_id_from_token
        render json: @user.circulators, each_serializer: Api::CirculatorSerializer
      end

      def create
        unless params[:circulator] && params[:circulator][:id]
          # TODO - once we settle on circulator_id format validation should be added
          render json: {status: 400, message: "Must specify circulator_id"}, status:400
          return
        end

        User.transaction do
          circulator_id = params[:circulator][:id]
          if Circulator.where(circulator_id: circulator_id).first
            # 400 is not the most helpful error here, we need a way to return
            # richer responses than an HTTP status
            logger.info ("Duplicate circulator id #{circulator_id}")
            render json: {status: 400, message: "Duplicate circulator id."}, status:400
            return
          end

          user = User.find @user_id_from_token

          #TODO correctly validate serial number
          circulator = Circulator.new(params[:circulator])
          circulator.circulator_id = circulator_id
          logger.info "Creating circulator #{circulator.inspect}}"
          circulator.save!

          aa = ActorAddress.create_for_circulator(circulator)
          circulatorUser = CirculatorUser.new user: user, circulator: circulator
          unless params[:owner] == false
            circulatorUser.owner = true
          end
          circulatorUser.save!

          render json: circulator, serializer: Api::CirculatorSerializer
        end
      end

      def destroy
        circulator = Circulator.where(circulator_id: params[:id]).first
        unless circulator
          logger.info "Tried to delete non-existent circulator #{params[:id]}"
          render_unauthorized
          return
        end
        circulator_user = CirculatorUser.find_by_circulator_and_user circulator, @user_id_from_token
        if circulator_user
          if circulator_user.owner
            circulator_user.circulator.destroy
            render json: {status: 200} , status: 200
          else
            logger.info "Non-owner #{circulator_user.inspect} attempted to delete circulator"
            # Including overly helpful debug message for now
            render json: {status: 401, message: "Unauthorized: only owner can delete a circulator."}, status: 401
          end
        else
          render_unauthorized
        end
      end

      def token
        circulator_id = params[:id]
        circulator = Circulator.where(circulator_id: params[:id]).first
        circulator_user = CirculatorUser.find_by_circulator_and_user circulator, @user_id_from_token
        if circulator_user.nil?
          logger.error "Unauthorized access to circulator [#{circulator_id}] by user [#{@user_id_from_token}]"
          render_unauthorized
          return
        end

        # minor hack
        aa = ActorAddress.where(address_id: circulator_id).first
        unless aa
          msg = "ActorAddress not found for circulator id #{circulator_id}"
          logger.error msg
          raise "ActorAddress not found for circulator id #{circulator_id}"
        end

        render json: aa.current_token.to_json
      end
    end
  end
end
