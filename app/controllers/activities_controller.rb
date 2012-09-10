class ActivitiesController < ApplicationController
  expose (:activity)
  expose (:required_equipment) { activity.required_equipment }
  expose (:optional_equipment) { activity.optional_equipment }
  expose (:ingredients) { activity.ingredients }
end

