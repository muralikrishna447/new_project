class AssembliesController < ApplicationController

  before_filter :load_assembly, except: [:index]

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
      if current_user && current_user.enrolled?(@assembly)
        render "#{@assembly.assembly_type.underscore.pluralize}_#{params[:action]}"
      else
        redirect_to landing_course_url(@assembly)
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

private

  def load_assembly
    @assembly = Assembly.find_published(params[:id], params[:token], can?(:update, @activity))
    instance_variable_set("@#{@assembly.assembly_type.underscore}", @assembly)
  end
end