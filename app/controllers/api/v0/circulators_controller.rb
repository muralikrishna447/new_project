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
        user = User.find @user_id_from_token
        circulator = Circulator.where(circulator_id: params[:id]).first

        unless circulator
          logger.info "Tried to delete non-existent circulator #{params[:id]}"
          if user.admin?
            render_api_response 404, {message: "Circulator does not exist"}
          else
            render_unauthorized
          end
          return
        end


        if user.admin?
          logger.info("Allowing admin user #{user.email} to delete circulator")
          circulator.destroy
          render json: {status: 200} , status: 200
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

        if circulator.nil?
          render json: {status: 404, message: "Circulator not found"}, status:404
          return
        end

        circulator_user = CirculatorUser.find_by_circulator_and_user circulator, @user_id_from_token
        if circulator_user.nil?
          logger.error "Unauthorized access to circulator [#{circulator_id}] by user [#{@user_id_from_token}]"
          render_unauthorized
          return
        end

        # Assume that address_id matches circulator_id
        aa = ActorAddress.where(address_id: circulator_id).first
        unless aa
          msg = "ActorAddress not found for circulator id #{circulator_id}"
          raise msg
        end

        response = {token: aa.current_token.to_jwt, status:200}
        render json: response
      end
    end
  end
end
