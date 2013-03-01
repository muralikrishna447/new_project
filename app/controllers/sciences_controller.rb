class SciencesController < ApplicationController
  def index
    @sciences = Activity.sciences.published.page(params[:page]).per(12)
  end

  def show
    @science = Activity.sciences.find(params[:id])
  end
end