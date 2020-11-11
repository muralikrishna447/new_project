class SitemapsController < ApplicationController
  respond_to :xml
  caches_page :show, :expires_in => 1.hour

  def show
    @main_stuff = Activity.chefsteps_generated.published() |
                  Ingredient.well_edited.no_sub_activities() |
                  Assembly.pubbed_courses() |
                  Assembly.prereg_courses() |
                  Page.published()

    @other_routes = ["/", "/about", "/gallery", "/jobs", "/classes", "/joule", "/joule/app", "/joule/hardware", "/joule/discussion", "/joule/specs", "/press", "/press/faq", "/premium", '/cuts']
    @catalog_routes = CutsService.get_routes
    respond_to do |format|
      format.xml {
        render
      }
    end

  end
end
