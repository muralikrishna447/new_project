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
          render_api_response 400, {message: "Must specify circulator.id"}
          return
        end

        User.transaction do
          circulator_id = params[:circulator][:id]
          if Circulator.where(circulator_id: circulator_id).first
            # 400 is not the most helpful error here, we need a way to return
            # richer responses than an HTTP status
            logger.info ("Duplicate circulator id #{circulator_id}")
            render_api_response 409, {message: "Duplicate circulator id."}
            return
          end

          user = User.find @user_id_from_token

          #TODO correctly validate serial number
          circ_params = params[:circulator]
          circulator = Circulator.new
          circulator.notes = circ_params[:notes]
          circulator.serial_number = circ_params[:serial_number]
          circulator.circulator_id = circulator_id

          secret_key = nil
          if circ_params[:secret_key]
            if circ_params[:secret_key].length != 32
              render_api_response 400, {message: "Invalid secret key"}
              return
            end
            # We receive a hex encoded string... convert to a binary
            # string before saving to database
            secret_key = [circ_params[:secret_key]].pack('H*')
          end

          circulator.secret_key = secret_key
          logger.info "Creating circulator #{circulator.inspect}"

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
        unless params[:id]
          render_api_response 400, {message: "Must specify id"}
          return
        end

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
            render_api_response 403, {message: "Unauthorized: only owner can delete a circulator."}
          end
        else
          render_unauthorized
        end
      end

      def token
        circulator_id = params[:id]
        unless params[:id]
          render_api_response 400, {message: "Must specify id"}
          return
        end
        circulator = Circulator.where(circulator_id: params[:id]).first

        if circulator.nil?
          render_api_response 403, {message: 'Circulator not found'}
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

        render_api_response 200, {token: aa.current_token.to_jwt}
      end
    end
  end
end
