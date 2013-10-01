class Assembly < ActiveRecord::Base
  extend FriendlyId
  include PublishableModel
  friendly_id :title, use: [:slugged, :history]
  attr_accessible :description, :image_id, :title, :youtube_id, :slug, :assembly_type, :assembly_inclusions_attributes, :price, :badge_id
  has_many :assembly_inclusions, dependent: :destroy
  has_many :activities, through: :assembly_inclusions, source: :includable, source_type: 'Activity'
  has_many :quizzes, through: :assembly_inclusions, source: :includable, source_type: 'Quiz'

  has_many :likes, as: :likeable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  has_many :uploads
  has_many :enrollments, as: :enrollable

  scope :published, where(published: true)
  scope :projects, where(assembly_type: 'Project')

  accepts_nested_attributes_for :assembly_inclusions, allow_destroy: true

  ASSEMBLY_TYPE_SELECTION = ['Course', 'Project', 'Group']
  INCLUDABLE_TYPE_SELECTION = ['Activity', 'Quiz', 'Assembly']

  def ingredients
    activities.map(&:ingredients).flatten.sort_by{|i|i.ingredient.title}.reject{|i| i.unit == 'recipe'}
  end

  def grouped_ingredients
    self.ingredients.group_by{|assembly_ingredient| [assembly_ingredient.ingredient, assembly_ingredient.note, assembly_ingredient.unit]}
  end

  def combined_ingredients
    self.grouped_ingredients.map{ |ingredient_group| [ingredient_group[0], ingredient_group[1].map(&:quantity).inject(:+), ingredient_group[1][0].unit] }
  end

  def required_equipment
    activities.map(&:required_equipment).flatten.uniq{|e| e.title}.sort_by{ |e| e.title }
  end

  def optional_equipment
    optional = activities.map(&:optional_equipment).flatten
    required_titles = activities.map(&:required_equipment).flatten.map(&:title).map(&:downcase)
    displayable = []
    optional.each do |equipment|
      unless required_titles.include?(equipment.title.downcase)
        displayable << equipment
      end
    end
    displayable.uniq{|e| e.title}
  end

  def featured_image
    image_id
  end

  def faq
    title = self.slug + '-faq'
    Activity.find_by_slug(title)
  end

  def testimonials
    title = self.slug + '-testimonial'
    Page.find_by_slug(title)
  end

  def video_count
    assembly_activities = self.activities.select{|a| a.class.to_s == 'Activity'}
    activity_videos_count = assembly_activities.select{|a| a.youtube_id? }.count
    activity_step_videos_count = assembly_activities.map(&:steps).flatten.select{|s| s.youtube_id? }.count
    activity_videos_count + activity_step_videos_count
  end

  def badge
    b = Merit::Badge.find(self.badge_id)
    if self.badge_id && b
      b
    else
      nil
    end
  end
end
