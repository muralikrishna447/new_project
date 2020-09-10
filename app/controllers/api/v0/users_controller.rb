require 'aws-sdk'
require_dependency 'beta_feature_service'
require_dependency 'external_service_token_checker'
module Api
  module V0
    class UsersController < BaseController
      # Required since this only this controller contains the code to actually
      # set the cookie and not just generate the token
      include Devise::Controllers::Rememberable
      before_action :ensure_authorized, except: [:create, :log_upload_url, :make_premium, :update_settings]
      before_action(BaseController.make_service_filter(
        [ExternalServiceTokenChecker::SPREE_SERVICE]), only: [:make_premium, :update_settings]
      )

      skip_before_action :detect_country unless ENV['CS_FORCE_DETECT_COUNTRY']

      LOG_UPLOAD_URL_EXPIRATION = 60*30 #Seconds

      def me
        @user = User.find @user_id_from_token

        remember_me @user # sets remember_user_token cookie
        warden.set_user @user # sets session cookie, unsure if this is necessary

        if @user
          render json: @user, serializer: Api::UserMeSerializer
        else
          render json: {status: 501, message: 'User not found.'}, status: 501
        end
      end

      def create
        params[:source] ||= "api_standard"
        # TODO - deprecate this branch completely, in the short-run we need to
        # verify that this branch is not used.
        if params[:user][:provider] && params[:user][:provider] == 'facebook'
          Rails.logger.info "DEPRECATED: facebook branch of UsersController#create"
          render_unauthorized
        else
          @user = User.new(user_params)
          @user.country_code = detect_country_code
          create_new_user(@user, @user.opt_in, params[:source])
        end
      end

      def update
        @user = User.find params[:id]
        if @user_id_from_token == @user.id
          logger.info "Updating user #{@user.inspect}"
          logger.info "Updating with: #{params[:user]}"
          if @user.update_attributes(user_params)
            Resque.enqueue(Forum, 'update_user', Rails.application.config.shared_config[:bloom][:api_endpoint], @user.id)
            render json: @user.to_json(only: [:id, :name, :slug, :email], methods: :avatar_url), status: 200
          else
            render json: {status: 400, message: "Bad Request.  Could not update user with params #{params[:user]}"}, status: 400
          end
        else
          render json: {status: 401, message: 'Unauthorized.', debug: "From token: #{@user_id_from_token}, ID: #{@user.id}"}, status: 401
        end
      end


      # Authenticated by user token (see before_actions)
      def update_my_settings
        update_settings_impl(@user_id_from_token, "me")
      end

      # Authenticated by External Service (see before_actions)
      def update_settings
        update_settings_impl(params[:id], "external")
      end


      def shown_terms
        @user = User.find @user_id_from_token
        @user.was_shown_terms
        render json: {status: 200}, status: 200
      end

      def international_joule
        # ECOMMTODO Do mailchimp stuff
        @user = User.find @user_id_from_token
        # Something like this
        # email_list_add_to_group(@user.email, '8061', ['international_joule'])
        render json: {}, code: :ok
      end

      def log_upload_url
        # Based on the steps here:
        # http://docs.aws.amazon.com/AmazonS3/latest/dev/UploadObjectPreSignedURLRubySDK.html#UploadObjectPreSignedURLRubySDKV1

        # We want to be liberal in accepting logs so if someone provides a bad
        # token they end up in the anon bucket
        ensure_authorized(false)
        prefix = "date"
        if @user_id_from_token
          user_prefix = "user/#{@user_id_from_token}"
        else
          user_prefix = 'anon'
        end
        random_prefix = SecureRandom.hex[0..7]
        partition = "dt=#{Time.now.strftime('%Y-%m-%d-%H')}"
        # For posterity here is the old key object_key = "#{user_prefix}/#{Time.now.to_a.reverse[4..8].join('/')}-#{random_prefix}-#{request.remote_ip}-#{params[:tag]}"
        object_key= "#{prefix}/#{partition}/#{user_prefix}/#{Time.now.strftime('%Y/%m/%d/%H/%M/%S')}-#{random_prefix}-#{request.remote_ip}"
        Rails.logger.info "Creating log upload url for key [#{object_key}]"
        # We use an old version of the AWS SDK
        s3 = AWS::S3.new(region:'us-west-2')
        obj = s3.buckets[Rails.configuration.remote_log_bucket].objects[object_key]
        url = obj.url_for(:write, :content_type => 'text/plain', :expires => LOG_UPLOAD_URL_EXPIRATION)
        Rails.logger.info "Created signed url [{#{url.to_s}}]"
        render_api_response 200, {:upload_url => url.to_s}
      end

      def capabilities
        user = User.find @user_id_from_token

        unless user
          return render_api_response 404, {:message => "User not found"}
        end

        render_api_response 200, {:capabilities => user.capabilities}
      end

      #API needed for spree, called when a customer purchases ChefSteps premium
      def make_premium
        [:id, :price].each do |param|
          unless params[param]
            return render_api_response 400, {message: "Bad Request: #{param} parameter missing."}
          end
        end

        user = User.find(params[:id])
        unless user
          return render_api_response 404, {:message => "User not found"}
        end

        user.make_premium_member(params[:price].to_f)
        return render_api_response 200, {:message => "Success"}
      end

      private

      def update_settings_impl(user_id, mode)
        @user = User.find user_id

        # settings_params = (params[:settings] || {}).slice(*UserSettings::API_FIELDS)

        logger.info "Update_settings (#{mode}) for user #{user_id}"
        logger.info "Updating with: #{user_settings_params}"

        settings = @user.settings || @user.build_settings
        if settings.update_attributes(user_settings_params)
          render json: settings, serializer: Api::UserSettingsSerializer
        else
          render json: {status: 400, message: "Bad Request.  Could not update user settings (#{mode}) with params", errors: settings.errors}, status: 400
        end
      end

      def create_new_user(user, opt_in, source)
        if user.save
          aa = ActorAddress.create_for_user @user, client_metadata: "create"
          subscribe_and_track user, opt_in, source
          Resque.enqueue(UserSync, @user.id)
          Resque.enqueue(EmployeeAccountProcessor, @user.id)
          render json: {status: 200, message: 'Success', token: aa.current_token.to_jwt}, status: 200
        else
          logger.warn "create_new_user errors: #{user.errors.inspect}"
          render json: {status: 400, message: 'Bad Request: An error occured when trying to create this user.'}, status: 400
        end
      end

      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation,
                                     :remember_me, :location, :quote, :website, :chef_type, :from_aweber,
                                     :viewed_activities, :signed_up_from, :bio, :image_id, :referred_from,
                                     :referrer_id, :survey_results, :events_count, :opt_in)
      end

      def user_settings_params
        params.fetch(:settings, {}).permit( :country_iso2,
                                            :has_purchased_truffle_sauce,
                                            :has_viewed_turbo_intro,
                                            :locale,
                                            :preferred_temperature_unit)
      end

    end
  end
end
