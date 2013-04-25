class Course < ActiveRecord::Base
  extend FriendlyId
  include RankedModel
  include PublishableModel

  friendly_id :title, use: :slugged

  ranks :course_order

  scope :ordered, rank(:course_order)

  attr_accessible :description, :title, :short_description, :slug, :course_order

  has_many :inclusions, :dependent => :destroy, :order => 'activity_order ASC'
  has_many :activities, :through => :inclusions, :order => 'inclusions.activity_order ASC'
  has_many :enrollments
  has_many :users, through: :enrollments

  def update_activities(activity_hierarchy)
    activities.delete_all
    activity_hierarchy.each do |activity_info|
      activity_id, nesting_level, title = activity_info[0], activity_info[1], activity_info[2]
      logger.debug nesting_level if activity_id == 500
      if activity_id.present?
        begin
          activity = Activity.find(activity_id)
        rescue
          activity = Activity.create()
          activity.title = title
          activity.save!
          activity_id = activity.id
        end
        self.activities << activity
        self.save!
        incl = inclusions.find_by_activity_id(activity_id)
        incl.update_attributes(nesting_level: nesting_level)
      end
    end
    self
  end

  def first_published_activity
    inclusion = inclusions.find {|i| i.activity.published? && (i.nesting_level != 0)}
    inclusion.activity
  end

  def next_published_activity(activity, inclusion_list = inclusions)
    # I'm sure there is a clever one liner for this, writing on an airplane with no doc access
    found_pivot = false
    inclusion_list.each do |incl|
      return incl.activity if found_pivot && incl.activity.published? && (incl.nesting_level != 0)
      found_pivot = true if incl.activity == activity
    end
    nil
  end

  def prev_published_activity(activity)
    next_published_activity(activity, inclusions.reverse)
  end

  def activity_modules
    inclusions.select{|i| i.nesting_level == 0}.map{|i| i.activity}
  end

  def parent_module(activity)
    # Returns the module the current activity belongs to
    current_inclusion = inclusions.includes(:activity).select{|i| i.activity.id == activity.id}.first
    current_inclusion_index = inclusions.index(current_inclusion)
    current_parent_module = nil
    i = current_inclusion_index
    until current_parent_module
      i-=1
      if inclusions[i].nesting_level == 0
        current_parent_module = inclusions[i]
      end
    end
    return current_parent_module
  end

  def activities_within_module(module_activity)
    current_inclusion = inclusions.includes(:activity).select{|i| i.activity.id == module_activity.id}.first
    current_inclusion_index = inclusions.index(current_inclusion)
    activities_collected = false
    i = current_inclusion_index
    results = []
    until activities_collected
      i+=1
      if inclusions[i].nesting_level == 0
        activities_collected = true
      else
        results << inclusions[i].activity
      end
    end
    return results
  end
end
