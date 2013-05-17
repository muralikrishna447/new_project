class UploadsController < ApplicationController
  before_filter :authenticate_user!

  def show
  end
  
  def create
    @upload = Upload.new(params[:upload])
    @upload.user_id = current_user.id
    if @upload.save
      redirect_to session[:return_to], notice: 'Your photo has been upload!'
      session[:return_to] = nil
    end
    track_event @upload
  end
end