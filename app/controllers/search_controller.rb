class SearchController < ApplicationController

  def index
    if params[:q]
      @results = Search.query(params[:q]).paginate(:page => params[:page], :per_page => 12)
      if @results.blank?
        @noresults = Activity.published.limit(6)
      end
    end
  end
end