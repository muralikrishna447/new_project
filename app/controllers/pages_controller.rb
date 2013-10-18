class PagesController < ApplicationController

  def show
    @page = Page.find(params[:id])
  end

  def knife_collection
    @knife_page = Page.find 'knife-collection'
  end

  def test_purchaseable_course
    @page = Page.find 'test-purchaseable-course'
    @assembly = Assembly.find('test-purchaseable-course')
    @enrolled = current_user ? Enrollment.where(user_id: current_user.id, enrollable_id: @assembly.id, enrollable_type: 'Assembly').first : false
  end
end