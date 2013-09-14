class AssembliesController < ApplicationController
  def index
    if request.path == '/assemblies'
      @assembly_type = 'Assembly'
      @assemblies = Assembly.published.order('created_at asc').page(params[:page]).per(12)
    else
      @assembly_type = request.path.gsub(/^\//, "").singularize.titleize
      @assemblies = Assembly.published.where(assembly_type: @assembly_type).order('created_at asc').page(params[:page]).per(12)
    end
  end

  def show
    assembly = Assembly.find_published(params[:id], params[:token], can?(:update, @activity))
    instance_variable_set("@#{assembly.assembly_type.underscore}", assembly)
    @upload = Upload.new
    case assembly.assembly_type
    when 'Course'
      if current_user && current_user.enrolled?(assembly)
        render "#{assembly.assembly_type.underscore.pluralize}_#{params[:action]}"
      else
        redirect_to landing_course_url(assembly)
      end
    else
      render "#{assembly.assembly_type.underscore.pluralize}_#{params[:action]}"
    end
  end

  def landing
    @assembly = Assembly.find(params[:id])
  end
end