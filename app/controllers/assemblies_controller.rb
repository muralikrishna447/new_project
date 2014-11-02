class AssembliesController < ApplicationController
  before_filter :load_assembly, except: [:index, :redeem, :redeem_index, :trial, :force_ws_free_trial]

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
      if (current_user.enrolled?(@assembly)) || current_user.admin?
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
      redirect_to landing_assembly_path(@assembly)
    end
    # @hide_nav = true
    # @upload = Upload.new
    # case @assembly.assembly_type
    # when 'Course', 'Project'
    #   # Currently not requiring enrollment for free assembly-based course. This will probably want to change?
    #   if current_user && current_user.admin?
    #     render "courses_#{params[:action]}"
    #   else
    #     if (current_user && current_user.enrolled?(@assembly)) || (! @assembly.price)
    #       render "courses_#{params[:action]}"
    #     else
    #       @no_shop = true
    #       redirect_to landing_class_url(@assembly, anchor: '')
    #     end
    #   end
    # when 'Recipe Development'
    #   render "courses_#{params[:action]}"
    # else
    #   render "#{@assembly.assembly_type.underscore.pluralize.gsub(' ','_')}_#{params[:action]}"
    # end
  end

  def landing
    if session[:free_trial]
      @hours = Assembly.free_trial_hours(session[:free_trial])
      @free_trial_text = @hours.hours_to_pretty_time
      # @minimal = true if !current_user && session[:free_trial] && @hours
    end
    @no_shop = true
    @upload = Upload.new
    @split_name = "macaron_landing_no_campaign"
    if params[:utm_campaign]
      @split_name = "macaron_landing_campaign_#{params[:utm_campaign][0..4]}"
    end
    @no_video = params[:no_video]
  end

  def show_as_json
    # return redirect_to landing_class_url(@assembly)#, notice: "Your free trial has expired, please purchase the class to continue.  Please contact info@chefsteps.com if there is any problems." if current_user && current_user.enrollments.where(enrollable_id: @assembly.id, enrollable_type: @assembly.class).first.try(:free_trial_expired?) && @assembly.price > 0
    render :json => @assembly
  end

  def trial
    session[:free_trial] = params[:trial_token]
    session[:coupon] = params[:coupon] if params[:coupon]
    @assembly = Assembly.free_trial_assembly(session[:free_trial])
    hours = Assembly.free_trial_hours(session[:free_trial])

    # If 0 hours in the trial code, it means run a split test from a randomly generated
    # choice of hours. Shove it back in the session so it stays consistent for this user.
    if hours == 0
      hours = [1, 2, 24].sample
      session[:free_trial] = Base64.encode64("#{@assembly.id}-#{hours}")
    end

    if current_user && current_user.enrollments.where(enrollable_id: @assembly.id, enrollable_type: @assembly.class).first.try(:free_trial_expired?)
      redirect_to landing_class_url(@assembly)
    else
      # flash[:notice] = "Click Free Trial to start your #{hours.hours_to_pretty_time} trial"
      appended_params = params.reject{|k,v| [:controller, :action, :trial_token].include?(k.to_sym)}
      mixpanel.track(mixpanel_anonymous_id, "Free Trial Offered Server-Side", {slug: @assembly.slug, length: hours.to_s}.merge(appended_params))
      redirect_to landing_class_url(@assembly, appended_params)
    end
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

  # This is obviously a very short term solution to price testing!
  # We'll need to make some sort of admin for this or use an off the shelf solution.
  def discounted_price(price, coupon)
    return 0 if ! price
    pct = 1
    case coupon
    when 'b3a72a32da71'
      pct = 34.0/39
    when 'a1b71d389a50'
      pct = 29.0/39
    when 'be11c664ce1a'
      pct = 23.0/39
    when 'cc448c11505a'
      pct = 20.0/39
    when 'd035c58a0a8c'
      pct = 19.0/39
    when 'e8c479fa9279'
      pct = 14.0/39
    end
    (price * pct).round(2)
  end

  def load_assembly

    begin
      @assembly = Assembly.includes(:assembly_inclusions => :includable).find_published(params[:id], params[:token], can?(:update, @activity))
      # Once verified that coupons are working everywhere, delete the following:
      session[:coupon] = params[:coupon] || session[:coupon]
      @discounted_price = discounted_price(@assembly.price, session[:coupon])
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