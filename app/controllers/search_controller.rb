class SearchController < ApplicationController

  def index
    if params[:q]
      @results = Search.query(params[:q]).page(params[:page]).per(12)
      if @results.blank?
        @noresults = Search.query('Recipe').limit(9)
      elsif @results.count < 6
        related_terms = @results.map(&:searchable).map(&:title).join(',')
        @related_results = (Search.query(related_terms) - @results).take(3)
      end
    end
  end
end