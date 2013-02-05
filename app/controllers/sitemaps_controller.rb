class SitemapsController < ApplicationController
  respond_to :xml
  caches_page :show

  def show
    @courses = Course.where(:published => true)
    @activities = Activity.where(:published => true)
    @other_routes = ["/","/about"]
    respond_to do |format|
      format.xml
    end
  end
end