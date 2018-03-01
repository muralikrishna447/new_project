require 'aws-sdk'
require_dependency 'beta_feature_service'
require_dependency 'external_service_token_checker'
module Api
  module V0
    class UsersController < BaseController
      # Required since this only this controller contains the code to actually
      # set the cookie and not just generate the token
      include Devise::Controllers::Rememberable
      before_filter :ensure_authorized, except: [:create, :log_upload_url, :make_premium]
      before_filter(BaseController.make_service_filter(
        [ExternalServiceTokenChecker::SPREE_SERVICE]), only: [:make_premium]
      )
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
        optout = (params[:optout] && params[:optout]=="true") #email list optout
        params[:source] ||= "api_standard"
        # TODO - deprecate this branch completely, in the short-run we need to
        # verify that this branch is not used.
        if params[:user][:provider] && params[:user][:provider] == 'facebook'
          Rails.logger.info "DEPRECATED: facebook branch of UsersController#create"
          render_unauthorized
        else
          @user = User.new(params[:user])
          create_new_user(@user, optout, params[:source])
        end
      end

      def update
        @user = User.find params[:id]
        if @user_id_from_token == @user.id
          logger.info "Updating user #{@user.inspect}"
          logger.info "Updating with: #{params[:user]}"
          if @user.update_attributes(params[:user])
            Resque.enqueue(Forum, 'update_user', Rails.application.config.shared_config[:bloom][:api_endpoint], @user.id)
            render json: @user.to_json(only: [:id, :name, :slug, :email], methods: :avatar_url), status: 200
          else
            render json: {status: 400, message: "Bad Request.  Could not update user with params #{params[:user]}"}, status: 400
          end
        else
          render json: {status: 401, message: 'Unauthorized.', debug: "From token: #{@user_id_from_token}, ID: #{@user.id}"}, status: 401
        end
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

        # Hardcoding the list of possible capabilities for now.
        capability_list = [
          'beta_guides',
          'multi_circ',
          'fbjoule',
          'update_during_pairing',
          'sqlite',
          'enable_react_native_alerts'
        ]
        cache_key = "user-capabilities-#{user.id}"
        user_capabilities = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
          capability_list.select {|c|
            BetaFeatureService.user_has_feature(user, c)
          }
        end
        render_api_response 200, {:capabilities => user_capabilities}
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
      def create_new_user(user, optout, source)
        if user.save
          aa = ActorAddress.create_for_user @user, client_metadata: "create"
          subscribe_and_track user, optout, source
          Resque.enqueue(UserSync, @user.id)
          render json: {status: 200, message: 'Success', token: aa.current_token.to_jwt}, status: 200
        else
          logger.warn "create_new_user errors: #{user.errors.inspect}"
          render json: {status: 400, message: 'Bad Request: An error occured when trying to create this user.'}, status: 400
        end
      end
    end
  end
end
