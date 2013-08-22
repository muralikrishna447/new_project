class PagesController < ApplicationController

  def show
    @page = Page.find(params[:id])
  end

  def knives_collection

  end

end