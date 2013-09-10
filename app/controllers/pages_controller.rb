class PagesController < ApplicationController

  def show
    @page = Page.find(params[:id])
  end

  def knife_collection
    @knife_page = Page.find 'knife-collection'
  end

  def test_purchaseable_course
    @page = Page.find 'test-purchaseable-course'
    @course = Course.find('test-purchaseable-course')
  end
end