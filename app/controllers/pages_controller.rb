class PagesController < ApplicationController

  def show
    @page = Page.find(params[:id])
  end

  def knife_collection
    @knife_page = Page.find 'knife-collection'
  end

end