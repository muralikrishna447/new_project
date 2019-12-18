class PagesController < ApplicationController

  def show
    @page = Page.find_published(params[:id])
    if @page.is_promotion && @page.redirect_path

      # Keep any url params (utm parameters for example)
      page_params = params.dup
      page_params.delete(:action)
      page_params.delete(:controller)
      page_params.delete(:id)
      page_params[:discount_id] = @page.discount_id if @page.discount_id.present?

      uri = URI(@page.redirect_path)
      uri_path = uri.path
      uri_params = uri.query ? Rack::Utils.parse_query(uri.query) : {}

      redirect_params = uri.query ? uri_params.merge(page_params) : page_params

      redirect_path = uri_path
      redirect_path = uri_path + '?' + redirect_params.to_query if redirect_params.keys.any?

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
