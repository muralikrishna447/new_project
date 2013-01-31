class SearchController < ApplicationController

  def index
    query = params[:q]
    if query
      @results = Activity.published.where('title iLIKE ?', "%#{query}%")
    end
  end
end