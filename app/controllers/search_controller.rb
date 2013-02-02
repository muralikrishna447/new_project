class SearchController < ApplicationController

  def index
    if params[:q]
      @results = Search.query(params[:q]).page(params[:page]).per(12)
      if @results.blank?
        @noresults = Activity.published.limit(6)
      end
    end
  end
end