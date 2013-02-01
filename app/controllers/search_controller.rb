class SearchController < ApplicationController

  def index
    query = params[:q]
    if query
      @results = Activity.published.where('title iLIKE ?', "%#{query}%").reject{|a| a.step_images.blank? }
    else
      @results = Activity.published.where('title not iLIKE ?', '%quiz%').limit(9)
    end
  end
end