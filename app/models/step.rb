class Step < ApplicationRecord

  belongs_to :activity, touch: true, inverse_of: :steps

  has_many :ingredients, class_name: 'StepIngredient', dependent: :destroy, inverse_of: :step

  serialize :presentation_hints, JSON

  include ActsAsSanitized
  sanitize_input :title, :directions, :image_description, :extra, :youtube_id, :vimeo_id, :image_id, :image_description, :subrecipe_title, :audio_clip, :audio_title, :presentation_hints, :appliance_instruction_text, :appliance_instruction_image

  scope :ordered, -> { order(:step_order) }
  scope :activity_id_not_nil, -> { where('activity_id IS NOT NULL') }

  default_scope { ordered }

  def title(index=nil)
    return "Step %d" % (index.to_i + 1) if self[:title].blank? and index.present?
    return "" if self[:title] == "-"
    self[:title] || ''
  end

  def update_ingredients(ingredient_attrs)
    reject_invalid_ingredients(ingredient_attrs)
    update_and_create_ingredients(ingredient_attrs)
    delete_old_ingredients(ingredient_attrs)
    self
  end

  def update_ingredients_json(ingredients_attrs)
    # Easiest just to be rid of all of the old join records, we'll make them from scratch
    log_data = Proc.new do |action|
      "#{action} updating activity #{activity.id} for -- Step Id -- #{id} "\
                "-- step_ingredient ids #{ingredients.pluck(:id)} " \
                "-- ingredient ids #{ingredients.pluck(:ingredient_id)} "\
                "-- ingredients count #{ingredients.count} at #{Time.now}"
    end
    logger.info(log_data["Before"])
    ingredients.destroy_all()
    ingredients.reload()
    if ingredients_attrs
      ingredients_attrs.each_with_index do |i, idx|
        title = i[:ingredient][:title]
        unless title.nil? || title.blank?
          title.strip!

          the_ingredient = Ingredient.find_or_create_by_id_or_subactivity_or_ingredient_title(i[:ingredient][:id], title)

          StepIngredient.create!({
                                     step_id: self.id,
                                     ingredient_id: the_ingredient.id,
                                     note: i[:note],
                                     display_quantity: i[:display_quantity],
                                     unit: i[:unit],
                                     ingredient_order: idx
                                 })
        end
      end
    end
    ingredients.reload()
    logger.info(log_data["After"])
    self
  end


  private

  def reject_invalid_ingredients(ingredient_attrs)
    ingredient_attrs.select! do |ingredient_attr|
      [:title, :unit].all? do |test|
        ingredient_attr[test].present?
      end
    end
  end

  def update_and_create_ingredients(ingredient_attrs)
    ingredient_attrs.each_with_index do |ingredient_attr, idx|
      title = ingredient_attr[:title].strip
      ingredient = Ingredient.find_or_create_by_subactivity_or_ingredient_title(title)
      step_ingredient = ingredients.find_or_create_by(ingredient_id: ingredient.id, step_id: self.id)
      step_ingredient.update_attributes(
        note: ingredient_attr[:note],
        display_quantity: ingredient_attr[:display_quantity],
        unit: ingredient_attr[:unit],
        ingredient_order: idx
      )
      ingredient_attr[:id] = ingredient.id
    end
  end

  def delete_old_ingredients(ingredient_attrs)
    old_ingredient_ids = ingredients.map(&:ingredient_id) - ingredient_attrs.map {|i| i[:id].to_i }
    ingredients.where(ingredient_id: old_ingredient_ids).destroy_all
  end
end
