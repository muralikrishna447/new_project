class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    user_json = @user.to_json(only: [:id, :name], methods: :avatar_url)
    encrypted = ChefstepsBloom.encrypt(user_json)
    render text: encrypted
  end

  def get_user
    if params[:secret] && params[:secret] == 'ilovesousvideYgpsagNPdJ'
      @user = User.find(params[:userId])
      user_json = {id: @user.id.to_s, name: @user.name, avatarUrl: @user.avatar_url, email: @user.email}
      user_json.merge!({employee: true}) if @user.role == 'admin' && /@chefsteps.com\z/.match(@user.email)
      render json: user_json.to_json
    else
      render text: 'Authorized Access', status: 401
    end
  end

  # Bloom will also be using this endpoint
  def index
    if params[:ids]
      ids = params[:ids].split(',')
      @users = User.where(id: [ids])
    elsif params[:emails]
      emails = params[:emails].split(',')
      @users = User.where(email: [emails])
    end
    render json: @users.to_json(only: [:id, :name, :slug], methods: :avatar_url)
  end

  # For Bloom Dashboard
  def cs
    @admins = User.where(role: 'admin')
    render json: @admins.to_json(only: [:id, :email])
  end

  def session_me
    if current_user
      token = current_user.valid_website_auth_token
      method_includes = [:avatar_url]
      # Don't leak admin flag if user is not admin

      user_data = {id: current_user.id, name: current_user.name, slug:current_user.slug, email: current_user.email, avatar_url: current_user.avatar_url}
      user_data[:token] = token.to_jwt
      user_data[:intercom_user_hash] = intercom_user_hash(current_user)
      if current_user.admin?
        user_data[:admin] = true
      end
      render json: user_data.to_json, status:200
    else
      render json: {logged_in: false}.to_json, status: 200
    end
  end

  def preauth
    unless current_user
      logger.info "Preauth redirecting to sign-in"
      redirect_to '/sign_in?returnTo=/users/preauth'
      return
    end
    logger.info "Preauth for [#{current_user.email}] admin [#{current_user.admin?}]"
    @existing_preauth_cookie = false
    unless current_user.admin?
      return render status:401
    end

    if params[:clear]
      cookies.delete :cs_preauth
    else
      if cookies[:cs_preauth]
        logger.info "Existing preauth cookie present #{cookies[:cs_preauth]}"
        @existing_preauth_cookie = true
      end
      # Always set new cookie to keep things simple
      logger.info "Setting preauth cookie for user #{current_user.id} / #{current_user.email}"
      cookies.permanent[:cs_preauth] = current_user.valid_website_auth_token.to_jwt
    end

    @preauth_cookie = cookies[:cs_preauth]
  end


  unless Rails.env.production?
    def set_location
      @ip_address = (cookies[:cs_location] || request.ip)
      if request.post?
        ip_address = "#{params[:ip_address_1]}.#{params[:ip_address_2]}.#{params[:ip_address_3]}.#{params[:ip_address_4]}"
        cookies[:cs_location] = ip_address
      elsif request.delete?
        cookies.delete :cs_location
      end
    end
  end

end
