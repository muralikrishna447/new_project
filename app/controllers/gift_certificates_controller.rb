class GiftCertificatesController < ApplicationController
  respond_to :json

  def index
    authorize! :manage, GiftCertificate
    respond_to do |format|
      format.json do
        @gift_certificates = GiftCertificate.where(price: 0).offset(params[:offset]).limit(params[:limit])
        render json: @gift_certificates.as_json(include: [:user, :assembly])
      end
      format.html
    end
  end
end