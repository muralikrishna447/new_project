class PagesController < ApplicationController

  def show
    @page = Page.find_published(params[:id])
    if @page.is_promotion && @page.redirect_path
      redirect_path = @page.redirect_path
      redirect_params = params.dup
      redirect_params.delete(:action)
      redirect_params.delete(:controller)
      redirect_params.delete(:id)
      redirect_params[:discount] = @page.discount_code if @page.discount_code
      redirect_path = redirect_path + '?' + redirect_params.to_query if redirect_params.keys.any?
      redirect_to redirect_path
    else
      respond_to do |format|
        format.html
        format.json do
          render json: @page.content
        end
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
