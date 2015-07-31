class SitemapsController < ApplicationController
  respond_to :xml
  caches_page :show, :expires_in => 1.hour

  def show
    # This will have to change when we start to have deep links that rails doesn't know about and that
    # aren't reachable by a non-deep-linked alternative.


    @main_stuff = Activity.published() |
                  Ingredient.no_sub_activities() |
                  Assembly.pubbed_courses() |
                  Assembly.prereg_courses() |
                  Assembly.projects().published() |
                  Page.all() |
                  Upload.approved()

    @other_routes = ["/", "/about", "/gallery", "/jobs"]
    respond_to do |format|
      format.xml {
        render
      }
    end

  end
end