class UploadsController < ApplicationController
  before_filter :authenticate_user!, only: [:create]

  def show
    @upload = Upload.find(params[:id])
  end

  def create
    @upload = Upload.new(params[:upload])
    @upload.user_id = current_user.id
    if @upload.save
      # redirect_to session[:return_to], notice: 'Your photo has been uploaded!'
      # session[:return_to] = nil
      redirect_to user_upload_path(@upload.user, @upload), notice: 'Your photo has been uploaded!'
      track_event @upload
      mixpanel.track 'Photo Uploaded', {
        course: @upload.course ? @upload.course.title : 'none',
        recipe: @upload.activity ? @upload.activity.title : "Custom Recipe"
      }
    end
  end
end