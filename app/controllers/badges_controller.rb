class BadgesController < ApplicationController
  def index
    @badges = Merit::Badge.all
  end
end