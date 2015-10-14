class AssembliesController < ApplicationController
  before_filter :load_assembly, except: [:index, :redeem, :redeem_index]

  # Commenting out for now until we figure out what to do for Projects

  def index
    if request.path == '/assemblies'
      @assembly_type = 'Assembly'
      @assemblies = Assembly.published.order('created_at desc').page(params[:page]).per(12)
    else
      @assembly_type = request.path.gsub(/^\//, "").singularize.titleize
      @assemblies = Assembly.published.where(assembly_type: @assembly_type).order('created_at desc').page(params[:page]).per(12)
    end
  end

  def show
    @hide_nav = true
    @upload = Upload.new
    if current_user
      if (current_user.enrolled?(@assembly)) || current_user.admin? || current_user.role == "collaborator"
        case @assembly.assembly_type
        when 'Course', 'Project', 'Recipe Development'
          render "courses_#{params[:action]}"
        else
          render "#{@assembly.assembly_type.underscore.pluralize.gsub(' ','_')}_#{params[:action]}"
        end
      else
        redirect_to landing_assembly_path(@assembly)
      end
    else
      if @assembly.assembly_type == 'Recipe Development'
        render "courses_#{params[:action]}"
      else
        redirect_to landing_assembly_path(@assembly)
      end
    end
  end

  def landing

    @no_shop = true
    @upload = Upload.new
    @split_name = "macaron_landing_no_campaign"
    if params[:utm_campaign]
      @split_name = "macaron_landing_campaign_#{params[:utm_campaign][0..4]}"
    end
    @no_video = params[:no_video]

    # For the old sous vide class, render a page showing the class has moved
    if @assembly.id == 47
      # Sous Vide 101 and 201
      @new_classes = Assembly.find([141,133]).reverse
      render "moved"
    else
      render "landing"
    end
  end

  def show_as_json
    render :json => @assembly
  end

  def enroll

    if ! current_user
      logger.info("Assembly#enroll no current_user: #{params.inspect}")
      render json: {status: 400, message: 'No user'}, status: 400 and return
    end

    if @assembly.premium && (! current_user.premium?)
      logger.info("Assembly#enroll Trying to enroll non-premium member in premium class: #{params.inspect}")
      render json: {status: 401, message: 'User not premium'}, status: 401 and return
    end

    logger.info("Creating enrollment, user: #{current_user.slug}, assembly: #{@assembly.slug}")
    @enrollment = Enrollment.create!(user_id: current_user.id, enrollable: @assembly)
    render nothing: true
  end

  # Note that although this is called "redeem", it only starts the redemption process
  # sending them to the landing page with the GC in the session. The reason we don't immediately
  # redeem it is they might not be logged in.

  def redeem
    session[:gift_token] = params[:gift_token]
    @gift_certificate = GiftCertificate.where(token: session[:gift_token].downcase).first

    if @gift_certificate
      @assembly = @gift_certificate.assembly
      if ! @gift_certificate.redeemed
        # Normal redemption
        flash[:notice] = "To get your gift, click the orange button below!"
        redirect_to landing_class_url(@assembly)
      else
        # Already redeemed, probably the same user so tell 'em what to do
        if current_user
          # Logged in? Just continue.
          flash[:notice] = "Gift code already used; click the orange button below to continue your class. If you need assistance, contact <a href='mailto:info@chefsteps.com'>info@chefsteps.com</a>."
          redirect_to landing_class_url(@assembly)
        else
          # Not logged in, send 'em to log in
          flash[:notice] = "Gift code already used; please sign in to continue your class. If you need assistance, contact <a href='mailto:info@chefsteps.com'>info@chefsteps.com</a>."
          session[:force_return_to] = request.original_url
          redirect_to sign_in_url
        end

      end

    else
      # Gift certificate we've never heard of. Someone try to rip us off?
      flash[:error] = "Invalid gift code. Contact <a href='mailto:info@chefsteps.com'>info@chefsteps.com</a>."
      redirect_to '/'
    end
  end

  def redeem_index
    render 'redeem_index'
  end

private

  def load_assembly

    begin
      @assembly = Assembly.includes(:assembly_inclusions => :includable).find_published(params[:id], params[:token], true)
      raise "Viewed Unplublished Assembly" if !@assembly.published? && cannot?(:update, @assembly)

      # Changing so that it accepts a param gift_token as well, this is solely for e2e testing and shouldn't be given to customers as it
      # doesn't store the information in the sesion so they MUST use it on that page.
      gc_token = session[:gift_token] || params[:gift_token]
      @gift_certificate = GiftCertificate.where(token: gc_token.downcase).first if gc_token

    rescue
      # If they are looking for a course that isn't yet published, take them to a page where
      # they can get on an email list to be notified when it is available.
      @course = Assembly.find(params[:id])
      if @course && @course.assembly_type == "Course" && (! @course.published?)
        if current_user && current_user.enrolled?(@course)
          @assembly = Assembly.find(params[:id])
          # Once verified that coupons are working everywhere, delete the following:
          session[:coupon] = params[:coupon] || session[:coupon]
        else
          @list_name = ("csp-" + @course.slug)[0...15]
          render "pre_registration"
        end
        return false
      end
      raise
    end

    instance_variable_set("@#{@assembly.assembly_type.underscore.gsub(' ','_')}", @assembly)
    # Hack to also make available as course so can be used for project without
    # revamping views completely right now
    @course = @assembly
  end
end