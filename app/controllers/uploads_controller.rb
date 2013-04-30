class UploadsController < ApplicationController
  def create
    @upload = Upload.new(params[:upload])
    @upload.user_id = current_user.id
    if @upload.save
      redirect_to session[:return_to]
      session[:return_to] = nil
    else
    end
  end
end