class UploadsController < ApplicationController
  before_action :authenticate_user!, only: [:create]

  def show
    @upload = Upload.find(params[:id])
  end

  def create
    @upload = Upload.new(params[:upload])
    @upload.user_id = current_user.id
    if @upload.save
      # redirect_to session[:return_to], notice: 'Your photo has been uploaded!'
      # session[:return_to] = nil
      respond_to do |format|

        format.html { redirect_to @upload, notice: 'Your photo has been uploaded!' }
        format.js { render :json => @upload, root: false }
      end
      track_event @upload
      mixpanel.track(@upload.user.id, 'Photo Uploaded', {course: @upload.assembly ? @upload.assembly.title : 'none', activity: @upload.activity ? @upload.activity.title : "Custom Recipe"})
    end
  end
end