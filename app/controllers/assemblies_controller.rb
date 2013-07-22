class AssembliesController < ApplicationController
  def index
    @assemblies = Assembly.order('created_at asc')
  end

  def show
  end
end