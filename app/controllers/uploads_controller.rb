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
      redirect_to @upload, notice: 'Your photo has been uploaded!'
      track_event @upload
      mixpanel.track 'Photo Uploaded', { distinct_id: @upload.user.email, course: @upload.course ? @upload.course.title : 'none', activity: @upload.activity ? @upload.activity.title : "Custom Recipe" }
      mixpanel.set({ :distinct_id => @upload.user.email}, { course: @upload.course ? @upload.course.title : 'none', activity: @upload.activity ? @upload.activity.title : "Custom Recipe", :email => @upload.user.email })
    end
  end
end