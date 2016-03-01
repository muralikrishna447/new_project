class LegalController < ApplicationController
  before_filter :load_vars

  private
  def load_vars
    @eula_terms_url = terms_url
    @eula_privacy_url = privacy_url
  end
end
