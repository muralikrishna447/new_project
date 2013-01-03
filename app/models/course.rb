class Course < ActiveRecord::Base
  extend FriendlyId
  include RankedModel
  include PublishableModel

  friendly_id :title, use: :slugged

  ranks :course_order

  scope :ordered, rank(:course_order)

  attr_accessible :description, :title, :slug, :course_order

  has_many :inclusions
  has_many :activities, :through => :inclusions, :order => 'inclusions.activity_order ASC'

  def update_activities(activity_ids)
    activities.delete_all
    activity_ids.each do |activity_id|
      if activity_id.present?
        activity = Activity.find(activity_id)
        self.activities << activity
        self.save!
      end
    end
    self
  end

  def hierarchical_activities
    a = activities.slice_before {|x| x.nesting_level == 0}.to_a
    a2 = a.collect do |m|
      m.slice_before{ |x| x.nesting_level == 1 }.to_a
    end
    a2.to_a
  end

  def first_published_activity
    activities.find {|a| a.published? && (! a.is_module_head?)}
  end

  def next_published_activity(activity)
    # I'm sure there is a clever one liner for this, writing on an airplane with no doc access
    found_pivot = false
    activities.each do |a|
      return a if found_pivot && a.published? && (! a.is_module_head?)
      found_pivot = true if a == activity
    end
    nil
  end

  def prev_published_activity(activity)
    # I'm sure there is a clever one liner for this, writing on an airplane with no doc access
    found_pivot = false
    activities.reverse.each do |a|
      return a if found_pivot && a.published? && (! a.is_module_head?)
      found_pivot = true if a == activity
    end
    nil
  end
end
