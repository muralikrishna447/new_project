class Activity < ActiveRecord::Base
  extend FriendlyId
  include PublishableModel

  include ActsAsSanitized
  sanitize_input :title, :description, :short_description, :timing, :yield, :summary_tweet, :youtube_id, :vimeo_id, :difficulty

  acts_as_taggable
  acts_as_revisionable associations: [:ingredients, :as_ingredient, {:steps => :ingredients}, {:equipment => :equipment}], :dependent => :keep, :on_destroy => true

  friendly_id :title, use: [:slugged, :history]

  has_many :ingredients, dependent: :destroy, class_name: ActivityIngredient, inverse_of: :activity
  has_many :terminal_ingredients, class_name: Ingredient, through: :ingredients, source: :ingredient

  # The as_ingredient relationship returns the ingredient version of the activity
  has_one :as_ingredient, class_name: Ingredient, foreign_key: 'sub_activity_id'
  has_many :used_in_activities, source: :activities, through: :as_ingredient
  belongs_to :source_activity, class_name: Activity, foreign_key: 'source_activity_id'

  has_many :steps, inverse_of: :activity, dependent: :destroy

  has_many :equipment, class_name: ActivityEquipment, inverse_of: :activity, dependent: :destroy
  has_many :terminal_equipment, class_name: Equipment, through: :equipment, source: :equipment

  has_many :user_activities
  has_many :users, through: :user_activities

  has_many :assignments
  has_many :child_activities, through: :assignments

  has_many :uploads
  has_many :upload_users, through: :uploads, source: :user

  has_many :events, as: :trackable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :assembly_inclusions, as: :includable
  has_many :assemblies, through: :assembly_inclusions

  belongs_to :creator, class_name: User, foreign_key: 'creator'
  belongs_to :last_edited_by, class_name: User, foreign_key: 'last_edited_by_id'
  belongs_to :currently_editing_user, class_name: User, foreign_key: 'currently_editing_user'

  validates :title, presence: true

  scope :with_video, where("youtube_id <> '' OR vimeo_id <> ''")
  scope :recipes, where("activity_type iLIKE '%Recipe%'")
  scope :techniques, where("activity_type iLIKE '%Technique%'")
  scope :sciences, where("activity_type iLIKE '%Science%'")
  scope :activity_type, -> activity_type { where("activity_type iLIKE ?", '%' + activity_type + '%') }
  scope :difficulty, -> difficulty { where(:difficulty => difficulty) }
  scope :newest, order('published_at DESC')
  scope :oldest, order('published_at ASC')
  scope :by_created_at, -> direction { direction == 'desc' ? order('created_at DESC') : order('created_at ASC')}
  scope :by_published_at, -> direction { direction == 'desc' ? order('published_at DESC') : order('published_at ASC')}
  scope :by_updated_at, -> direction { direction == 'desc' ? order('updated_at DESC') : order('updated_at ASC')}
  scope :randomize, order('random()')
  scope :include_in_gallery, where(include_in_gallery: true)
  scope :include_in_feeds, where(include_in_gallery: true, show_only_in_course: false)
  scope :chefsteps_generated, where('creator = ?', 0)
  scope :any_user_generated, where('creator != ?', 0).where(source_activity_id: nil)
  scope :user_generated, -> user { where('creator = ?', user) }
  scope :popular, where('likes_count IS NOT NULL').order('likes_count DESC')
  scope :by_equipment_title, -> title { joins(:terminal_equipment).where("equipment.title iLIKE ?", '%' + title + '%') }
  scope :by_equipment_titles, -> titles { joins(:terminal_equipment).where("equipment.title iLIKE ANY (array[?])", titles.split(',').map{|a| "%#{a}%"} ) }
  scope :not_in_course, where(show_only_in_course: false)

  accepts_nested_attributes_for :steps, :equipment, :ingredients

  serialize :activity_type, Array

  attr_accessible :activity_type, :title, :youtube_id, :vimeo_id, :yield, :timing, :difficulty, :description, :short_description, :equipment, :ingredients, :nesting_level, :transcript, :tag_list, :featured_image_id, :image_id, :steps_attributes, :child_activity_ids
  attr_accessible :source_activity, :source_activity_id, :source_type, :author_notes, :currently_editing_user, :include_in_gallery, :creator
  attr_accessible :show_only_in_course, :summary_tweet

  include PgSearch
  multisearchable :against => [:attached_classes_weighted, :title, :tags_weighted, :description, :ingredients_weighted, :steps_weighted],
    :if => :published

  # Letters are the weighting
  pg_search_scope :search_all,
                  using: {tsearch: {prefix: true}},
                  against: [[:title, 'A'], [:description, 'C']],
                  associated_against: {terminal_equipment: [[:title, 'D']], terminal_ingredients: [[:title, 'D']], tags: [[:name, 'B']], steps: [[:title, 'C'], [:directions, 'C']]}

  TYPES = %w[Recipe Technique Science]


  include AlgoliaSearch

  algoliasearch index_name: "ChefSteps", per_environment: true, if: :has_title do

    # Searchable fields (may be used for display too)
    attribute :title, :description

    add_attribute :thumbnail do
      featured_image.present? ? JSON.parse(featured_image)["url"] + "/convert?fit=crop&w=370&h=208&quality=90&cache=true" : nil
    end

    add_attribute :ingredient_titles do
      terminal_ingredients.map(&:title)
    end

    add_attribute :equipment_titles do
      terminal_equipment.map(&:title)
    end

    add_attribute :equipment_titles do
      terminal_equipment.map(&:title)
    end

    add_attribute :step_titles do
      steps.map(&:title)
    end

    add_attribute :step_directions do
      steps.map(&:directions)
    end

    # Display fields
    attribute :slug
    add_attribute :url do
      activity_path(self)
    end

    add_attribute :image do
      featured_image.present? ? JSON.parse(featured_image)["url"] : nil
    end

    # Filter/facet/tags
    attribute :difficulty, :published, :include_in_gallery

    tags do
      tags.map(&:name)
    end

    add_attribute :chefsteps_generated do
      creator.blank?
    end

    # Sort fields
    attribute :likes_count
    add_attribute :date do
      published ? published_at : created_at
    end

    # Slave indices for sorting other than relevance - that is how Algolia works, each index
    # only has one sort order, defined in dashboard.
    add_slave "ChefStepsNewest", per_environment: true do
    end
    add_slave "ChefStepsOldest", per_environment: true do
    end
    add_slave "ChefStepsPopular", per_environment: true do
    end
  end

  # https://github.com/algolia/algoliasearch-rails/issues/59
  # https://github.com/algolia/algoliasearch-rails/issues/40
  after_touch :index!

  def has_title
    title.present?
  end

  include Rails.application.routes.url_helpers

  class SourceType
    # This is the default. Others are actually defined in activity_controller.js.coffee. Would
    # like to find a convenient way to dry this up.
    ADAPTED_FROM = 0
  end

  before_save :check_published

  before_save :strip_title
  def strip_title
    self.title = self.title.strip if self.title?
    true
  end

  after_commit :create_or_update_as_ingredient, :if => :persisted?
  def create_or_update_as_ingredient
    if self.id then
      i = Ingredient.find_or_create_by_sub_activity_id(self.id)
      i.update_attribute(:title, self.title)
    end
  end

  before_destroy :destroy_as_ingredient
  def destroy_as_ingredient
    Ingredient.find_by_sub_activity_id(self.id).destroy
  end

  def self.difficulty_enum
    ['easy', 'intermediate', 'advanced']
  end

  def optional_equipment
    # Using the optional/required scopes hits the database and messes up the
    # versions view (which depends on plucking everything from the in-memory temp model)
    equipment.select { |x| x.optional }
  end

  def required_equipment
    # See note in optional_equipment
    equipment.select { |x| ! x.optional }
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

  def meta_description
    return short_description if short_description.present?
    return description if description.present?
    return title if title.present?
    ""
  end

  def is_recipe?
    # ingredients.count > 0
    activity_type.include?('Recipe')
  end

  def step_by_step?
    steps.count > 0
  end

  def published_variations
    Activity.published.where(source_activity_id: self.id)
  end

  def update_equipment(equipment_attrs)
    if equipment_attrs
      reject_invalid_equipment(equipment_attrs)
      update_and_create_equipment(equipment_attrs)
      delete_old_equipment(equipment_attrs)
    end
    self
  end

  def update_equipment_json(equipment_attrs)
    # Easiest just to be rid of all of the old join records, we'll make them from scratch
    equipment.destroy_all()
    equipment.reload()
    if equipment_attrs
      equipment_attrs.each do |e|
        title = e[:equipment][:title]
        unless title.nil? || title.blank?
          title.strip!
          equipment_item = Equipment.where(id: e[:equipment][:id]).first_or_create(title: title)
          activity_equipment = ActivityEquipment.create!({
              activity_id: self.id,
              equipment_id: equipment_item.id,
              optional: e[:optional] || false,
              equipment_order_position: :last
          })
         end
      end
    end
    self
  end

  def update_ingredients_json(ingredients_attrs)
    # Easiest just to be rid of all of the old join records, we'll make them from scratch
    ingredients.destroy_all()
    ingredients.reload()
    if ingredients_attrs
      ingredients_attrs.each do |i|
        title = i[:ingredient][:title]
        unless title.nil? || title.blank?
          title.strip!

          the_ingredient = Ingredient.find_or_create_by_id_or_subactivity_or_ingredient_title(i[:ingredient][:id], title)

          ActivityIngredient.create!({
              activity_id: self.id,
              ingredient_id: the_ingredient.id,
              note: i[:note],
              display_quantity: i[:display_quantity],
              unit: i[:unit],
              ingredient_order_position: :last
          })
        end
      end
    end
    self
  end


  def reject_invalid_steps(step_attrs)
    step_attrs.select! do |step_attr|
      [:directions, :image_id, :youtube_id, :vimeo_id, :title].any? do |test|
        step_attr[test].present?
      end
    end
  end

  def update_steps(step_attrs)
    if step_attrs
      reject_invalid_steps(step_attrs)
      update_and_create_steps(step_attrs)
      delete_old_steps(step_attrs)
    end
    self
  end


  def update_ingredients(ingredient_attrs)
    if ingredient_attrs
      reject_invalid_ingredients(ingredient_attrs)
      update_and_create_ingredients(ingredient_attrs)
      delete_old_ingredients(ingredient_attrs)
    end
    self
  end

  def has_ingredients?
    !ingredients.empty?
  end

  def ordered_steps
    steps.ordered.activity_id_not_nil.all
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

  def to_json
    super(
      include: {
        tags: {},
        equipment: {
            only: :optional,
            include: {
                equipment: {
                    only: [:id, :title, :product_url]
                }
            }
        },
        ingredients: {
            only: [:note, :display_quantity, :quantity, :unit],
            include: {
                ingredient: {
                    only: [:id, :title, :slug, :product_url, :for_sale, :sub_activity_id]
                }
            }
        },
        steps: {
          include: {

            ingredients: {
                only: [:note, :display_quantity, :quantity, :unit],
                include: {
                    ingredient: {
                        only: [:id, :title, :slug, :product_url, :for_sale, :sub_activity_id]
                    }
                }
            }
          }
        }
      }
    )
  end

  # Played around with using amoeba gem but it was causing some validation problems and I got
  # too scared to mess with the (possibly wrong) inverse associations on ActivityIngredient and Activity Equipment.
  # So just opted for the most explicit solution. Could also be done by going through JSON.
  def deep_copy
    new_activity = self.dup
    new_activity.save!

    new_activity.source_activity = self
    new_activity.source_type = SourceType::ADAPTED_FROM
    new_activity.published = false
    new_activity.published_at = nil

    self.ingredients.each do |ai|
      new_ai = ai.dup
      new_ai.activity = new_activity
      new_activity.ingredients << new_ai
    end

    self.equipment.each do |ae|
      new_ae = ae.dup
      new_ae.activity = new_activity
      new_activity.equipment << new_ae
    end

    self.steps.each do |as|
      new_step = as.dup
      new_step.activity = new_activity
      new_activity.steps << new_step

      new_step.save!

      as.ingredients.each do |si|
        new_si = si.dup
        new_si.step = new_step
        new_step.ingredients << new_si
      end
    end

    new_activity.save!
    new_activity
  end

  def containing_course
    # This only walks up one chain of parents, but an activity or assembly can really
    # be in more than one parent. Will have to be fixed as soon as we are reusing an activity
    # in more than one course. This is also a very expensive way to do this, but
    # we don't expect it to be a very common request. At least there is an index.
    ai = AssemblyInclusion.where(includable_type: "Activity", includable_id: self.id).first
    parent = ai.assembly

    begin
      return parent if parent.assembly_type == "Course" || parent.assembly_type == "Project" || parent.assembly_type == "Recipe Development"
      ai = AssemblyInclusion.where(includable_type: "Assembly", includable_id: parent.id).first
      parent = ai.assembly
    end until ! parent
    nil
  rescue
    # Rather than a lot of null checks.
    nil
  end

  def disqus_id
    "activity-#{self.id}"
  end

  def always_include_disqus
    if self.activity_type.include?('Recipe') || self.activity_type.include?('Technique') || self.activity_type.include?('Science')
      true
    else
      false
    end
  end

  def gallery_path
    # if self.containing_course && self.containing_course.published
    #   parent = self.containing_course
    #   assembly_activity_path(parent, self)
    # else
    #   activity_path(self)
    # end
    if show_only_in_course
      if self.containing_course && self.containing_course.published && self.containing_course.price > 0
        parent = self.containing_course
        assembly_activity_path(parent, self)
      end
    else
      activity_path(self)
    end
  end

  def avatar_url
    if self.featured_image_id.blank?
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/U2RccgsARPyMmzJ5Ao0c/convert?fit=crop&w=70&h=70&cache=true"
    else
      url = ActiveSupport::JSON.decode(self.featured_image_id)["url"]
      avatar_url = "#{url}/convert?fit=crop&w=70&h=70&cache=true".gsub("www.filepicker.io", "d3awvtnmmsvyot.cloudfront.net")
    end
  end

  def search_data
    {
      'title' => title,
      'id' => id,
      'avatarUrl' => avatar_url,
      'path' => activity_path(self)
    }
  end

  private

  def check_published
    if self.published && self.published_at.blank?
      self.published_at = DateTime.now
    end
  end

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

  def update_and_create_steps(step_attrs)
    step_attrs.each do |step_attr|
      step_id = step_attr[:id]
      if step_id && (step_id.to_i == 0)
        step_id = nil
      end
      step = steps.find_or_create_by_id(step_id)
      step.bypass_sanitization = self.creator.blank?
      step.update_attributes(
        title: step_attr[:title],
        directions: step_attr[:directions],
        youtube_id: step_attr[:youtube_id],
        vimeo_id: step_attr[:vimeo_id],
        image_id: step_attr[:image_id],
        image_description: step_attr[:image_description],
        audio_clip: step_attr[:audio_clip],
        audio_title: step_attr[:audio_title],
        step_order_position: :last,
        hide_number: step_attr[:hide_number],
        is_aside: step_attr[:is_aside],
        presentation_hints: step_attr[:presentation_hints],
        extra: step_attr[:extra]
      )
      step.update_ingredients_json(step_attr[:ingredients])
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

