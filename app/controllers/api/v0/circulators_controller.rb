module Api
  module V0
    class CirculatorsController < BaseController
      before_filter :ensure_authorized
      before_filter :ensure_circulator_owner, only: [:update, :destroy]
      before_filter :ensure_circulator_user, only: [:token]

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
          circulator.name = circ_params[:name]
          circulator.last_accessed_at = Time.now.utc
          circulator.serial_number = circ_params[:serial_number]
          circulator.circulator_id = circulator_id

          secret_key = nil
          if circ_params[:secret_key]
            non_hex = /[^a-fA-F0-9]/
            sk = circ_params[:secret_key]
            if (sk.length != 32 && sk.length != 20) or non_hex.match sk
              render_api_response 400, {message: "Invalid secret key"}
              return
            end
            # We receive a hex encoded string... convert to a binary
            # string before saving to database
            secret_key = [sk].pack('H*')
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

      def update
        if params[:circulator]
          @circulator.name = params[:circulator][:name] if params[:circulator][:name]
          @circulator.notes = params[:circulator][:notes] if params[:circulator][:notes]
        end
        @circulator.last_accessed_at = Time.now.utc
        @circulator.save
        render_api_response 200, {}
      end

      def destroy
        @circulator.destroy
        render_api_response 200
      end

      def token
        # Assume that address_id matches circulator_id
        aa = ActorAddress.where(address_id: @circulator.circulator_id).first
        unless aa
          msg = "ActorAddress not found for circulator id #{circulator_id}"
          raise msg
        end

        render_api_response 200, {token: aa.current_token.to_jwt}
      end
    end
  end
end
