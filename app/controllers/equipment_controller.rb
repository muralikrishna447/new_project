class EquipmentController < ApplicationController
  respond_to :json

  def index
    result = Equipment.where('title iLIKE ?', '%' + params[:q] + '%').all
    respond_with result
  end

end
