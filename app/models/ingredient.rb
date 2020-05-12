class Ingredient < ActiveRecord::Base
  include CaseInsensitiveTitle
  extend FriendlyId
  include ActsAsRevisionable

  acts_as_taggable
  acts_as_revisionable :dependent => :keep, :on_destroy => true

  friendly_id :title, use: [:slugged, :history, :finders]

  include ActsAsSanitized
  sanitize_input :title, :product_url
  before_validation :sanitize_text_fields

  has_many :step_ingredients, dependent: :destroy, inverse_of: :ingredient
  has_many :activity_ingredients, dependent: :destroy, inverse_of: :ingredient
  has_many :activities, through: :activity_ingredients, inverse_of: :ingredients
  has_many :steps, through: :step_ingredients, inverse_of: :ingredients
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :events, as: :trackable, dependent: :destroy

  serialize :text_fields, JSON

  scope :search_title, -> title { where('title iLIKE ?', '%' + title + '%') }
  scope :exact_search , -> title { where(title: title) }
  scope :no_sub_activities, -> { where('sub_activity_id IS NULL') }
  scope :with_image, -> { where('image_id IS NOT NULL') }
  scope :no_image, -> { where('image_id IS NULL') }
  scope :with_purchase_link, -> { where('product_url IS NOT NULL') }
  scope :no_purchase_link, -> { where('product_url IS NULL') }

  # These don't chain properly with search so doing something simpler for now
  # scope :started, where('CHAR_LENGTH(text_fields) >= 10').joins(:events).where(events: {action: 'edit'}).group('ingredients.id').having("count(DISTINCT(events.user_id)) > 0 AND count(DISTINCT(events.user_id)) < 3")
  # scope :well_edited, where('CHAR_LENGTH(text_fields) >= 10').joins(:events).where(events: {action: 'edit'}).group('ingredients.id').having("count(DISTINCT(events.user_id)) >= 3")

  MIN_WELL_EDITED_LENGTH = 150

  scope :not_started, -> { where('CHAR_LENGTH(text_fields) < 10') }
  scope :started, -> { where('CHAR_LENGTH(text_fields) > 10 AND CHAR_LENGTH(text_fields) < ?', MIN_WELL_EDITED_LENGTH) }
  scope :well_edited, -> { where('CHAR_LENGTH(text_fields) > ?', MIN_WELL_EDITED_LENGTH) }

  include PgSearch
  multisearchable :against => [:title, :text_fields, :product_url]

  # Letters are the weighting
  pg_search_scope :search_all,
                  using: {tsearch: {prefix: true}},
                  against: [[:title, 'A'], [:text_fields, 'C']],
                  associated_against: {tags: [[:name, 'B']]}

  before_save :fix_title
  def fix_title
    if self.sub_activity_id?
      self.title= Activity.find_by_id(self.sub_activity_id).title
    end
    self.title = self.title.strip if self.title?
    true
  end

  def title
=begin
    if sub_activity_id?
      act = Activity.find_by_id(sub_activity_id)
      if act != nil
        return act.title
      end
    end
=end
    read_attribute(:title)
  end

  def self.titles
    all.map(&:title)
  end

  def self.find_or_create_by_subactivity_or_ingredient_title(title)
    title.strip!
    sub_act = Activity.find_by_title(title)
    if sub_act != nil
      return find_or_create_by_sub_activity_id(sub_act.id)
    end
    find_or_create_by_title(title)
  end

  def self.find_or_create_by_id_or_subactivity_or_ingredient_title(id, title)
    # Try first by id
    the_ingredient = Ingredient.find_by_id(id)

    # Otherwise, try by title because it is possible for a user to type fast and not get
    # an autocompleted ingredient with an id filled it, but it is still in the database
    the_ingredient = Ingredient.find_or_create_by_subactivity_or_ingredient_title(title) if ! the_ingredient

    the_ingredient
  end


  def self.maybe_move_title_to_note(oi, title)
    old_title = oi.ingredient.title
    new_title, new_note = old_title.split(',')
    if new_note
      new_title.strip!
      new_note.strip!

      if (new_title.downcase == title.downcase) && (! new_note.blank?)
        if oi.note.blank?
          oi.note = new_note
        else
          oi.note = new_note + ", " + oi.note
        end
        oi.save
        oi.reload
      end
    end
  end

  def merge_in_useful_details(other)
    self.product_url = other.product_url if self.product_url.to_s == ''
    self.density = other.density if ! self.density
    self.image_id = other.image_id if self.image_id.to_s == ''
    self.youtube_id = other.youtube_id if self.youtube_id.to_s == ''
    self.text_fields = other.text_fields if self.text_fields.to_s == ''
    other.tag_list.each { |tag| self.tag_list.add(tag) }
  end

  # Replace all uses (in both activities and steps) of every ingredient in group with the self ingredient
  def merge(group)
    # Just to be sure
    group.delete(self)

    # If the ones we are going to delete have any useful wiki details in fields that
    # are blank in the final ingredient, copy them over.
    group.each do |ingredient|
      self.merge_in_useful_details(ingredient)
    end
    self.save

    group.each do |ingredient|
      ActivityIngredient.where(ingredient_id: ingredient.id).each do |ai|
        Ingredient.maybe_move_title_to_note(ai, self.title)
        ai.ingredient = self
        ai.save
      end

      StepIngredient.where(ingredient_id: ingredient.id).each do |si|
        Ingredient.maybe_move_title_to_note(si, self.title)
        si.ingredient = self
        si.save
      end

      ingredient.reload
      if (ingredient.activities.count == 0) && (ingredient.steps.count == 0)
        ingredient.delete
      else
        raise "Unexpected dependencies remain for #{ingredient.title} (id: #{ingredient.id})... not deleting"
      end
    end

    self.reload

  end

  def well_edited
    text_fields && text_fields.to_s.length > MIN_WELL_EDITED_LENGTH
  end

  def avatar_url
    if self.image_id.blank?
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/U2RccgsARPyMmzJ5Ao0c/convert?fit=crop&w=70&h=70&cache=true"
    else
      url = ActiveSupport::JSON.decode(self.image_id)["url"]
      avatar_url = "#{url}/convert?fit=crop&w=70&h=70&cache=true".gsub("www.filepicker.io", "d3awvtnmmsvyot.cloudfront.net")
    end
  end

  private
  def sanitize_text_fields
    if self.text_fields && self.text_fields.class.to_s == "Hash"
      self.text_fields.each do |key, value|
        text_fields[key] = Sanitize.fragment(value, Sanitize::Config::RELAXED)
      end
    end
  end
end

