class TechniquesController < ApplicationController
  def index
    @techniques = Technique.published.page(params[:page]).per(12)
  end

  def show
    @technique = Technique.find(params[:id])
  end
end