class Ingredient < ActiveRecord::Base
  include CaseInsensitiveTitle

  has_many :step_ingredients, dependent: :destroy, inverse_of: :ingredient
  has_many :activity_ingredients, dependent: :destroy, inverse_of: :ingredient
  has_many :activities, through: :activity_ingredients, inverse_of: :ingredients
  has_many :steps, through: :step_ingredients, inverse_of: :ingredients

  attr_accessible :title, :product_url, :for_sale, :density

  # This is for activities that are used as an ingredient in higher level recipes.
  # Note the potential for confusion: the has_many activities is for activities
  # that use this ingredient. The sub_activity_id is for ingredients that *are*
  # a (nested) activity - which may in turn be used in some activity.
  attr_accessible :sub_activity_id

  scope :search_title, -> title { where('title iLIKE ?', '%' + title + '%') }
  scope :no_sub_activities, where('sub_activity_id IS NULL')

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

  # Replace all uses (in both activities and steps) of every ingredient in group with the self ingredient
  def merge(group)
    # Just to be sure
    group.delete(self)

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
        ingredient.destroy
      else
        raise "Unexpected dependencies remain for #{ingredient.title} (id: #{ingredient.id})... not deleting"
      end
    end

    self.reload

  end

end

