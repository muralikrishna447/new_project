class CreateJoinTableSuggestedRecipeUser < ActiveRecord::Migration[5.2]
  def change
    create_join_table :suggested_recipes, :users do |t|
      t.index [:suggested_recipe_id, :user_id], name: 'index_sug_recipes_users_on_sug_recipe_id_and_user_id'
    end
  end
end
