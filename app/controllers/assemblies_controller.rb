class AssembliesController < ApplicationController

  before_filter :load_assembly, except: [:index, :redeem]

  # Commenting out for now until we figure out what to do for Projects

  # def index
  #   if request.path == '/assemblies'
  #     @assembly_type = 'Assembly'
  #     @assemblies = Assembly.published.order('created_at asc').page(params[:page]).per(12)
  #   else
  #     @assembly_type = request.path.gsub(/^\//, "").singularize.titleize
  #     @assemblies = Assembly.published.where(assembly_type: @assembly_type).order('created_at asc').page(params[:page]).per(12)
  #   end
  # end

  def show
    @upload = Upload.new
    case @assembly.assembly_type
    when 'Course'
      # Currently not requiring enrollment for free assembly-based course. This will probably want to change?
      if (current_user && current_user.enrolled?(@assembly)) || (! @assembly.price)
        render "#{@assembly.assembly_type.underscore.pluralize}_#{params[:action]}"
      else
        redirect_to landing_class_url(@assembly)
      end
    else
      render "#{@assembly.assembly_type.underscore.pluralize}_#{params[:action]}"
    end
  end

  def landing
    @upload = Upload.new
  end

  def show_as_json
    render :json => @assembly
  end

  # Note that although this is called "redeem", it only starts the redemption process
  # sending them to the landing page with the GC in the session. The reason we don't immediately

  def redeem
    session[:gift_token] = params[:gift_token]
    @gift_certificate = GiftCertificate.where(token: session[:gift_token]).first

    if @gift_certificate
      @assembly = @gift_certificate.assembly
      if ! @gift_certificate.redeemed
        # Normal redemption
        flash[:notice] = "To redeem your gift, click the orange button below!"      
        redirect_to landing_class_url(@assembly)
      else
        # Already redeemed, probably the same user so tell 'em what to do
        if current_user
          # Logged in? Just continue.
          flash[:notice] = "Gift code already redeemed; click the orange button below to continue your class. If you need assistance, contact <a href='mailto:info@chefsteps.com'>info@chefsteps.com</a>."
          redirect_to landing_class_url(@assembly)
        else
          # Not logged in, send 'em to log in
          flash[:notice] = "Gift code already redeemed; please sign in to continue your class. If you need assistance, contact <a href='mailto:info@chefsteps.com'>info@chefsteps.com</a>."       
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

private

  # This is obviously a very short term solution to price testing!
  # We'll need to make some sort of admin for this or use an off the shelf solution.
  def discounted_price(price, coupon)
    return 0 if ! price
    pct = 1
    case coupon
    when 'a1b71d389a50'
      pct = 29.0/39
    when 'be11c664ce1a'
      pct = 24.0/39
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
      @assembly = Assembly.find_published(params[:id], params[:token], can?(:update, @activity))
      session[:coupon] = params[:coupon] || session[:coupon]
      @discounted_price = discounted_price(@assembly.price, session[:coupon])
      @gift_certificate = GiftCertificate.where(token: session[:gift_token]).first if session[:gift_token]
 
    rescue 
      # If they are looking for a course that isn't yet published, take them to a page where
      # they can get on an email list to be notified when it is available.
      @course = Assembly.find(params[:id])
      if @course && @course.assembly_type == "Course" && (! @course.published?)
        @list_name = ("csp-" + @course.slug)[0...15]
        render "pre_registration"
        return false
      end
      raise
    end

    instance_variable_set("@#{@assembly.assembly_type.underscore}", @assembly)
  end
end