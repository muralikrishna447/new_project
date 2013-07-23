class AssembliesController < ApplicationController
  def index
    if request.path == '/assemblies'
      @assemblies = Assembly.order('created_at asc')
    else
      assembly_type = request.path.gsub(/^\//, "").singularize.titleize
      @assemblies = Assembly.where(assembly_type: assembly_type).order('created_at asc')
    end
  end

  def show
    @assembly = Assembly.find(params[:id])
  end
end