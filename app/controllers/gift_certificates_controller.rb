class GiftCertificatesController < ApplicationController
  respond_to :json

  has_scope :free_gifts, default: "false" do |controller, scope, value|
    value == "true" ? scope.free_gifts : scope
  end

  def index
    authorize! :manage, GiftCertificate
    respond_to do |format|
      format.json do
        @gift_certificates = apply_scopes(GiftCertificate).includes(:user, :assembly).offset(params[:offset]).limit(params[:limit])
        render json: @gift_certificates.as_json(include: [:user, :assembly])
      end
      format.html
    end
  end
end