class IngredientSerializer < ApplicationSerializer

  attributes :id, :title, :slug, :product_url, :created_at, :updated_at, :for_sale, :sub_activity_id, :density, :youtube_id, :image_id, :text_fields, :tags
  attributes :frequently_used_with
  attributes :chefsteps_activities
  attributes :editing_users

  def frequently_used_with
    ActiveRecord::Base.connection.execute("select count(*), i.id, i.title, i.slug from activity_ingredients i_to_a join activity_ingredients a_to_i on a_to_i.activity_id = i_to_a.activity_id join ingredients i on i.id = a_to_i.ingredient_id where i_to_a.ingredient_id = #{object.id} AND i.sub_activity_id IS NULL group by i.id order by count DESC limit 5;")
  end

  # Don't want the whole nested mash of each activity, just a few fields.
  # If at some point we need more, maybe use @options?
  def chefsteps_activities
    object.activities.chefsteps_generated.select("title, slug, published")
  end

  def editing_users
    Event.where(trackable_type: "Ingredient", trackable_id: object.id, action: "edit").order("created_at desc").includes(:user).map(&:user).uniq()
  end

end