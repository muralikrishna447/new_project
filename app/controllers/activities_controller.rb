class ActivitiesController < ApplicationController
  include AggressiveCaching
  expose (:activity)
end

