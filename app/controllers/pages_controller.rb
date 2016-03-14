class PagesController < ApplicationController

  def show
    @page = Page.find_published(params[:id])
    respond_to do |format|
      format.html
      format.json do
        render json: @page.content
      end
    end
  end

  def knife_collection
    # @knife_page = Page.find 'knife-collection'
  end

  def mobile_about
    @mobile_about = Page.find 'mobile-about'
    render layout: false
  end

  def market_ribeye
    if params[:add_to_cart]
      redirect_to multipass_api_v0_shopping_users_path(product_id: params[:product_id], quantity: params[:quantity])
    end
  end

  def joule_crawler
  end

end
