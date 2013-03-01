class TechniquesController < ApplicationController
  def index
    @techniques = Activity.techniques.published.page(params[:page]).per(12)
  end

  def show
    @technique = Activity.techniques.find(params[:id])
  end
end