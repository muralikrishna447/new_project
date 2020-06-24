class AssembliesController < ApplicationController
  before_action :load_assembly, except: [:index, :redeem, :redeem_index]

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
    head :ok
  end


private

  def load_assembly

    begin
      @assembly = Assembly.includes(:assembly_inclusions => :includable).find_published(params[:id], params[:token], true)
      raise "Viewed Unplublished Assembly" if !@assembly.published? && cannot?(:update, @assembly)

    rescue
      # If they are looking for a course that isn't yet published, take them to a page where
      # they can get on an email list to be notified when it is available.
      @course = Assembly.friendly.find(params[:id])
      if @course && @course.assembly_type == "Course" && (! @course.published?)
        if current_user && current_user.enrolled?(@course)
          @assembly = Assembly.friendly.find(params[:id])
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
