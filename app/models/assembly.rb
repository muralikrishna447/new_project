class Assembly < ActiveRecord::Base
  extend FriendlyId
  include PublishableModel
  friendly_id :title, use: [:slugged, :history]
  attr_accessible :description, :image_id, :prereg_image_id, :title, :youtube_id, :slug, :assembly_type, :assembly_inclusions_attributes, :price, :badge_id, :show_prereg_page_in_index, :short_description, :upload_copy, :buy_box_extra_bullets, :preview_copy, :testimonial_copy, :prereg_email_list_id
  has_many :assembly_inclusions, :order => "position ASC", dependent: :destroy
  has_many :activities, through: :assembly_inclusions, source: :includable, source_type: 'Activity'
  has_many :quizzes, through: :assembly_inclusions, source: :includable, source_type: 'Quiz'
  has_many :pages, through: :assembly_inclusions, source: :includable, source_type: 'Page'
  has_many :assignments, through: :assembly_inclusions, source: :includable, source_type: 'Assignment'

  has_many :likes, as: :likeable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  has_many :uploads
  has_many :enrollments, as: :enrollable

  has_many :gift_certificates, inverse_of: :assembly


  scope :published, where(published: true)
  scope :projects, where(assembly_type: 'Project')
  scope :recipe_developments, where(assembly_type: 'Recipe Development')
  scope :pubbed_courses, where(assembly_type: 'Course', published: true)
  scope :prereg_courses, where(assembly_type: 'Course', published: false, show_prereg_page_in_index: true)

  accepts_nested_attributes_for :assembly_inclusions, allow_destroy: true

  ASSEMBLY_TYPE_SELECTION = ['Course', 'Project', 'Group', 'Recipe Development', 'Kit']
  INCLUDABLE_TYPE_SELECTION = ['Activity', 'Quiz', 'Assembly', 'Page', 'Assignment']

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
    Page.find_by_slug(title)
  end

  def testimonials
    title = self.slug + '-testimonial'
    Page.find_by_slug(title)
  end

  def landing_bottom
    Page.find_by_slug(self.slug + '-landing-bottom')
  end

  def ingredients_equipment
    Page.find_by_slug(self.slug + '-ingredients-equipment')
  end

  def leaf_activities
    inclusions = assembly_inclusions.to_a
    3.times do
      inclusions.map! { |incl| incl.includable_type == "Assembly" ? incl.includable.assembly_inclusions : incl }
      inclusions.flatten!
    end
    inclusions.select { |incl| incl.includable_type == "Activity" }.map(&:includable)
  end

  def video_count
    assembly_activities = leaf_activities
    activity_videos_count = assembly_activities.select{|a| a.youtube_id? }.count
    activity_step_videos_count = assembly_activities.map(&:steps).flatten.select{|s| s.youtube_id? }.map(&:youtube_id).uniq.count
    activity_videos_count + activity_step_videos_count
  end

  def sciences
    assembly_activities = leaf_activities
    assembly_activities.select{|a| a.activity_type.include?("Science")}
  end

  def badge
    b = Merit::Badge.find(self.badge_id)
    if self.badge_id && b
      b
    else
      nil
    end
  end

  def average_rating
    comments.where("rating IS NOT NULL").average('rating').to_f
  end

  def only_one_level
    self.assembly_inclusions.map(&:includable_type).include?('Assembly') ? false : true
  end

  def paid?
    price && price > 0
  end

  def self.free_trial_hours(b64string)
    Base64.decode64(b64string).split('-').map(&:to_i)[1]
  end

  def self.free_trial_assembly(b64string)
    Assembly.find(Base64.decode64(b64string).split('-').map(&:to_i)[0])
  end 

    # This is obviously a very short term solution to price testing!
  # We'll need to make some sort of admin for this or use an off the shelf solution.

  def discounted_price(coupon)
    return 0 if ! self.price

    pct = 1
    case coupon
    when 'a2a72a39da72'
      pct = 0.75
    when 'b1b01d389a50'
      pct = 0.5
    end

    (self.price * pct).round(2)
  end

end
