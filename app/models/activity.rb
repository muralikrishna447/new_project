class Activity < ActiveRecord::Base
  extend FriendlyId
  include PublishableModel
  acts_as_taggable
  acts_as_revisionable associations: [:ingredients, :as_ingredient, :steps, :equipment, :quizzes, :inclusions], :dependent => :keep, :on_destroy => true

  friendly_id :title, use: :slugged

  has_many :ingredients, dependent: :destroy, class_name: ActivityIngredient, inverse_of: :activity
  # The as_ingredient relationship returns the ingredient version of the activity
  has_one :as_ingredient, class_name: Ingredient, foreign_key: 'sub_activity_id'
  has_many :used_in_activities, source: :activities, through: :as_ingredient

  has_many :steps, inverse_of: :activity, dependent: :destroy
  has_many :equipment, class_name: ActivityEquipment, inverse_of: :activity, dependent: :destroy

  has_many :quizzes

  has_many :inclusions, dependent: :destroy
  has_many :courses, :through => :inclusions

  has_many :user_activities
  has_many :users, through: :user_activities

  scope :with_video, where("youtube_id <> ''")
  scope :recipes, where("activity_type iLIKE '%Recipe%'")
  scope :techniques, where("activity_type iLIKE '%Technique%'")
  scope :sciences, where("activity_type iLIKE '%Science%'")

  accepts_nested_attributes_for :steps, :equipment, :ingredients

  serialize :activity_type, Array
  attr_accessible :activity_type, :title, :youtube_id, :yield, :timing, :difficulty, :description, :equipment, :nesting_level, :transcript, :tag_list, :featured_image_id, :image_id,  :steps_attributes
  include PgSearch
  multisearchable :against => [:attached_classes_weighted, :title, :tags_weighted, :description, :ingredients_weighted, :steps_weighted],
    :if => :published
  # multisearchable :against => [:attached_classes => 'A', :title => 'B', :tag_list => 'C', :description => 'D'],
  #   :if => :published
  # pg_search_scope :search, against: {:attached_classes => 'A', :title => 'B', :tag_list => 'C', :description => 'D'},
  #   using: {tsearch: {dictionary: "english", any_word: true}},
  #   associated_against: {steps: [:title, :directions], recipes: :title}

  TYPES = %w[Recipe Technique Science]

  before_save :strip_title
  def strip_title
    self.title = self.title.strip if self.title?
    true
  end

  after_commit :create_as_ingredient
  def create_as_ingredient
     Ingredient.find_or_create_by_sub_activity_id(self.id)
  end

  before_destroy :destroy_as_ingredient
  def destroy_as_ingredient
    Ingredient.find_by_sub_activity_id(self.id).destroy
  end

  def self.difficulty_enum
    ['easy', 'intermediate', 'advanced']
  end

  def optional_equipment
    equipment.optional.ordered
  end

  def required_equipment
    equipment.required.ordered
  end

  def next
    activities = Activity.ordered.published.all
    i = activities.index(self)
    return nil if i.nil?
    activities[i+1]
  end

  def prev
    activities = Activity.ordered.published.all
    i = activities.index(self)
    return nil if i.nil? || i == 0
    activities[i-1]
  end

  def has_description?
    description.present?
  end

  def is_recipe?
    # ingredients.count > 0
    activity_type.include?('Recipe')
  end

  def step_by_step?
    steps.count > 0
  end

  def update_equipment(equipment_attrs)
    reject_invalid_equipment(equipment_attrs)
    update_and_create_equipment(equipment_attrs)
    delete_old_equipment(equipment_attrs)
    self
  end

  def update_steps(step_attrs)
    reject_invalid_steps(step_attrs)
    update_and_create_steps(step_attrs)
    delete_old_steps(step_attrs)
    self
  end


  def update_ingredients(ingredient_attrs)
    reject_invalid_ingredients(ingredient_attrs)
    update_and_create_ingredients(ingredient_attrs)
    delete_old_ingredients(ingredient_attrs)
    self
  end

  def has_ingredients?
    !ingredients.empty?
  end

  def ordered_steps
    steps.ordered.activity_id_not_nil.all
  end

  def has_quizzes?
    quizzes.present?
  end

  def self.new_content
    published.with_video.order('updated_at DESC').reject{|a| a.youtube_id == Video.featured_id || a.youtube_id.length < 3}.sample(5)
  end

  def step_images
    steps.map(&:image_id).reject(&:blank?)
  end

  def self.text_search(query)
    if query.present?
      search(query)
    else
      published
    end
  end

  def attached_classes_weighted(weight = 10)
    attached_classes = []
    attached_classes << self.class
    attached_classes << 'Recipe' if is_recipe?
    attached_classes << 'Quiz' if quizzes.any?
    attached_classes*weight
  end

  def tags_weighted(weight = 5)
    tag_list.join(',')*weight
  end

  def ingredients_weighted(weight = 2)
    ingredients.map(&:ingredient).map(&:title).join(',')*weight
  end

  def steps_weighted(weight = 1)
    steps.map{|a|[a.title, a.directions]}.flatten.join(',')*weight
  end

  def true_ingredient_ids
    ingredients.map(&:ingredient_id)
  end

  def compare(activity)
    ingredients_a = true_ingredient_ids
    ingredients_b = activity.true_ingredient_ids
    (ingredients_a & ingredients_b).length.to_f/(ingredients_a+ingredients_b).uniq.length.to_f
    # (ingredients_a & ingredients_b).length.to_f/(ingredients_a).uniq.length.to_f
  end

  def related_by_ingredients
    # Todo Will need to optimize this
    # Activity.published.joins(:ingredients).where('activity_ingredients.ingredient_id IN(?) AND activities.id != ?', true_ingredient_ids, id).uniq
    ids = Activity.published.joins(:ingredients).uniq.map{|a| [self.compare(a), a.id]}.reject{|a| a[0] == 0 || self.id == a[1]}.sort{|a,b| a[0] <=> b[0]}.reverse.map{|a| a[1]}
    activities = Activity.find(ids).group_by(&:id)
    ids.map { |id| activities[id].first }
  end

  def featured_image
    if featured_image_id?
      featured_image_id
    elsif image_id?
      image_id
    else
      step_images.last
    end
  end


  def deep_json
    as_json(root: false,
            except: [:updated_at, :created_at],
            include: {:ingredients => {except: [:updated_at, :created_at]}})
  end

  private

  def reject_invalid_equipment(equipment_attrs)
    equipment_attrs.select! do |equipment_attr|
      [:title].all? do |test|
        equipment_attr[test].present?
      end
    end
  end

  def update_and_create_equipment(equipment_attrs)
    equipment_attrs.each do |equipment_attr|
      equipment_item = Equipment.find_or_create_by_title(equipment_attr[:title])
      activity_equipment = equipment.find_or_create_by_equipment_id_and_activity_id(equipment_item.id, self.id)
      activity_equipment.update_attributes(
        optional: equipment_attr[:optional] || false,
        equipment_order_position: :last
      )
      equipment_attr[:id] = equipment_item.id
    end
  end

  def delete_old_equipment(equipment_attrs)
    old_equipment_ids = equipment.map(&:equipment_id) - equipment_attrs.map {|i| i[:id].to_i }
    equipment.where(equipment_id: old_equipment_ids).destroy_all
  end

  def reject_invalid_steps(step_attrs)
    step_attrs.select! do |step_attr|
      [:directions].all? do |test|
        step_attr[test].present?
      end
    end
  end

  def update_and_create_steps(step_attrs)
    step_attrs.each do |step_attr|
      step = steps.find_or_create_by_id(step_attr[:id])
      step.update_attributes(
        title: step_attr[:title],
        directions: step_attr[:directions],
        youtube_id: step_attr[:youtube_id],
        image_id: step_attr[:image_id],
        image_description: step_attr[:image_description],
        audio_clip: step_attr[:audio_clip],
        audio_title: step_attr[:audio_title],
        step_order_position: :last
      )
      step_attr[:id] = step.id
    end
  end

  def delete_old_steps(step_attrs)
    old_step_ids = steps.map(&:id) - step_attrs.map {|i| i[:id].to_i }
    steps.where(id: old_step_ids).destroy_all
  end

  def delete_old_ingredients(ingredient_attrs)
    old_ingredient_ids = ingredients.map(&:ingredient_id) - ingredient_attrs.map {|i| i[:id].to_i }
    ingredients.where(ingredient_id: old_ingredient_ids).destroy_all
  end

  def update_and_create_ingredients(ingredient_attrs)
    ingredient_attrs.each do |ingredient_attr|
      title = ingredient_attr[:title].strip
      ingredient = Ingredient.find_or_create_by_subactivity_or_ingredient_title(title)
      activity_ingredient = ingredients.find_or_create_by_ingredient_id_and_activity_id(ingredient.id, self.id)
      activity_ingredient.update_attributes(
          note: ingredient_attr[:note],
          display_quantity: ingredient_attr[:display_quantity],
          unit: ingredient_attr[:unit],
          ingredient_order_position: :last
      )
      ingredient_attr[:id] = ingredient.id
    end
  end

  def reject_invalid_ingredients(ingredient_attrs)
    ingredient_attrs.select! do |ingredient_attr|
      [:title, :unit].all? do |test|
        ingredient_attr[test].present?
      end
    end
  end

end

