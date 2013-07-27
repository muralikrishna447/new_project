class AssembliesController < ApplicationController
  def index
    if request.path == '/assemblies'
      @assemblies = Assembly.order('created_at asc').page(params[:page]).per(12)
    else
      @assembly_type = request.path.gsub(/^\//, "").singularize.titleize
      @assemblies = Assembly.where(assembly_type: @assembly_type).order('created_at asc').page(params[:page]).per(12)
    end
  end

  def show
    assembly = Assembly.find(params[:id])
    instance_variable_set("@#{assembly.assembly_type.underscore}", assembly)
    render "#{assembly.assembly_type.underscore.pluralize}_#{params[:action]}"
  end
end