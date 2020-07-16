class ClientViewsController < ApplicationController
  def show
    render params[:id], layout: nil
  rescue ActionView::MissingTemplate
    render_404
  end
end
