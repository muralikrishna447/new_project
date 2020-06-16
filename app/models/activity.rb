class Activity < ActiveRecord::Base
  extend FriendlyId
  include PublishableModel
  include ActsAsRevisionable

  include ActsAsSanitized
  sanitize_input :title, :description, :short_description, :timing, :yield, :summary_tweet, :youtube_id, :vimeo_id, :difficulty, :byline

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

  has_one :publishing_schedule
  has_one :guide_activity

  belongs_to :creator, class_name: User, foreign_key: 'creator'
  belongs_to :last_edited_by, class_name: User, foreign_key: 'last_edited_by_id'
  belongs_to :currently_editing_user, class_name: User, foreign_key: 'currently_editing_user'

  validates :title, presence: true
  validates :promote_order, :numericality => { greater_than_or_equal_to: 1, message: "Order should be greater than or equal to 1"}, if: -> { promoted? }

  scope :with_video, -> { where("youtube_id <> '' OR vimeo_id <> ''") }
  scope :recipes, -> { where("activity_type iLIKE '%Recipe%'") }
  scope :techniques, -> { where("activity_type iLIKE '%Technique%'") }
  scope :sciences, -> { where("activity_type iLIKE '%Science%'") }
  scope :activity_type, -> activity_type { where("activity_type iLIKE ?", '%' + activity_type + '%') }
  scope :difficulty, -> difficulty { where(:difficulty => difficulty) }
  scope :newest, -> { order('published_at DESC') }
  scope :oldest, -> { order('published_at ASC') }
  scope :by_created_at, -> direction { direction == 'desc' ? order('created_at DESC') : order('created_at ASC')}
  scope :by_published_at, -> direction { direction == 'desc' ? order('published_at DESC') : order('published_at ASC')}
  scope :by_updated_at, -> direction { direction == 'desc' ? order('updated_at DESC') : order('updated_at ASC')}
  scope :randomize, -> { order('random()') }
  scope :include_in_gallery, -> { where(include_in_gallery: true) }
  scope :include_in_feeds, -> { where(include_in_gallery: true) }
  scope :chefsteps_generated, -> { where('creator = ?', 0) }
  scope :any_user_generated, -> { where('creator != ?', 0).where(source_activity_id: nil)  }
  scope :not_a_fork, -> { where(source_activity_id: nil) }
  scope :user_generated, -> user { where('creator = ?', user) }
  scope :popular, -> { where('likes_count IS NOT NULL').order('likes_count DESC') }
  scope :by_equipment_title, -> title { joins(:terminal_equipment).where("equipment.title iLIKE ?", '%' + title + '%') }
  scope :by_equipment_titles, -> titles { joins(:terminal_equipment).where("equipment.title iLIKE ANY (array[?])", titles.split(',').map{|a| "%#{a}%"} ) }
  scope :not_premium, -> { where(premium: false) }

  accepts_nested_attributes_for :steps, :equipment, :ingredients, :publishing_schedule

  serialize :activity_type, Array

  attr_accessor :used_in, :forks, :upload_count, :is_promoted

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

  # Turning off auto index b/c on activity save we were getting up to 40 synchronous
  # algolia HTTP calls, taking up to 15 seconds. Queue to resque instead.
  # Leaving auto_remove on for simplicity since it is rare. Not using their enqueue
  # mechanism b/c it doesn't trigger reliably on a tags-only change b/c it is too clever.
  before_save :set_promote_order
  after_save :queue_algolia_sync

  def set_promote_order
    self.promote_order = nil unless promoted?
  end

  def promoted?
    is_promoted.to_i.positive?
  end

  def queue_algolia_sync
    Resque.enqueue(AlgoliaSync, id)
  end

  algoliasearch index_name: "ChefSteps", auto_index: false, per_environment: true, if: :has_title do

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
    attribute :slug, :premium, :studio
    add_attribute :url do
      activity_path(self)
    end

    add_attribute :image do
      featured_image.present? ? JSON.parse(featured_image)["url"] : nil
    end

    add_attribute :has_video do
      youtube_id.present? || vimeo_id.present?
    end

    attribute :activity_type

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
    attribute :promote_order
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
    add_slave "ChefStepsPromoted", per_environment: true do
    end
  end

  def has_title
    title.present?
  end

  def has_promoted?
    promote_order.present?
  end

  def promoted
    has_promoted? ? "Yes" : "No"
  end

  def has_video
    youtube_id.present? || vimeo_id.present?
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
      i = Ingredient.find_or_create_by(sub_activity_id: id)
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
    equipment.reload()
    equipment.destroy_all()
    equipment.reload()
    if equipment_attrs
      equipment_attrs.each_with_index do |e, idx|
        title = e[:equipment][:title]
        unless title.nil? || title.blank?
          title.strip!
          equipment_item = Equipment.where(id: e[:equipment][:id]).first_or_create(title: title)
          activity_equipment = ActivityEquipment.create!({
              activity_id: self.id,
              equipment_id: equipment_item.id,
              optional: e[:optional] || false,
              equipment_order: idx
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
      ingredients_attrs.each_with_index do |i, idx|
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
              ingredient_order: idx
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
    new_activity.first_published_at = nil

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
    id = recursive_find_root("Activity", self.id)
    return id if id == nil
    return Assembly.find(id)
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
    activity_path(self)
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

  def chefsteps_generated
    creator.blank?
  end

  private

  def check_published
    if self.published
      if self.published_at.blank?
        self.published_at = DateTime.now
        SlackInProdOnly::send "#just-published", "Just published #{chefsteps_generated ? "" : "[UGC]"} \'#{self.title}\' at https://www.chefsteps.com#{activity_path(self)}"
      end

      # first_published_at is stored but not used for any sorting purposes, so
      # we can manually adjust published_at when we want to muck with gallery and feeds without
      # losing this data for measurement purposes.
      if self.first_published_at.blank?
        self.first_published_at = self.published_at
      end
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
    equipment_attrs.each_with_index do |equipment_attr, idx|
      equipment_item = Equipment.find_or_create_by_title(equipment_attr[:title])
      activity_equipment = equipment.find_or_create_by_equipment_id_and_activity_id(equipment_item.id, self.id)
      equipment_attr[:optional] = 'true' if equipment_attr[:optional] == ''
      activity_equipment.update_attributes(
        optional: equipment_attr[:optional] || false,
        equipment_order: idx
      )
      equipment_attr[:id] = equipment_item.id
    end
  end

  def delete_old_equipment(equipment_attrs)
    old_equipment_ids = equipment.map(&:equipment_id) - equipment_attrs.map {|i| i[:id].to_i }
    equipment.where(equipment_id: old_equipment_ids).destroy_all
  end

  def update_and_create_steps(step_attrs)
    step_attrs.each_with_index do |step_attr, idx|
      step_id = step_attr[:id]
      if step_id && (step_id.to_i == 0)
        step_id = nil
      end
      step = steps.find_or_create_by(id: step_id)
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
        step_order: idx,
        hide_number: step_attr[:hide_number].nil? ?  step_attr[:is_aside] : step_attr[:hide_number], # is_aside hides number by default, if hide_number not explicitly specified
        is_aside: step_attr[:is_aside],
        presentation_hints: step_attr[:presentation_hints],
        extra: step_attr[:extra],
        appliance_instruction_text: step_attr[:appliance_instruction_text],
        appliance_instruction_image: step_attr[:appliance_instruction_image]
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
    ingredient_attrs.each_with_index do |ingredient_attr, idx|
      title = ingredient_attr[:title].strip
      ingredient = Ingredient.find_or_create_by_subactivity_or_ingredient_title(title)
      activity_ingredient = ingredients.find_or_create_by_ingredient_id_and_activity_id(ingredient.id, self.id)
      activity_ingredient.update_attributes(
          note: ingredient_attr[:note],
          display_quantity: ingredient_attr[:display_quantity],
          unit: ingredient_attr[:unit],
          ingredient_order: idx
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

  private
    # A given node (leaf or interior) in an Assemly tree can have multiple parents.
  # This is rare, typically e.g. an Activity will be in a single class, and this
  # will find it. But what sometimes happens is an activity gets put in one sub-assembly, which is in turn put in a class, then the sub-assembly is removed
  # from the class and the same process is repeated, but the original is never deleted.
  # So you end up with two paths [Class->Group->Activity] and [Defunct Group->Activity]
  # This function is written to make sure in that case we find the class.
  # We don't deal with the case where the same activity is in multiple real classes,
  # in that case one arbitrary one is found.
  def recursive_find_root(includable_type, includable_id)
    if includable_type == "Assembly"
      assembly = Assembly.find(includable_id)

      # Winner if we hit a valid root container
      return assembly if assembly.assembly_type == "Course" || assembly.assembly_type == "Project" || assembly.assembly_type == "Recipe Development"
    end

    AssemblyInclusion.where(includable_type: includable_type, includable_id: includable_id).each do |ai|

      # Take first parent that is a winner
      result = recursive_find_root("Assembly", ai.assembly_id)
      return result if result.present?
    end

    # Loser
    return nil
  end
end
