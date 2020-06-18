module ActiveAdmin::ViewsHelper
  include ApplicationHelper
  def activity_promoted?(activity)
    activity.has_promoted? ? 'Yes' : 'No'
  end
end
