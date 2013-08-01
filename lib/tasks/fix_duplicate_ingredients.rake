task :fix_duplicate_ingredients => :environment do
  all_ingreds = Ingredient.where("sub_activity_id is null").order("title ASC")

  puts "Initial count #{all_ingreds.count} ingredients"
  grouped_ingreds = all_ingreds.group_by { |i| i.title.downcase }

  grouped_ingreds.each do |title, group|
    if group.count > 1

      keeper = group.find { |x| (x.product_url || "") != "" } || group[0]
      puts "Fixing #{group.count} copies of #{title} (url: #{keeper.product_url})"

      group.each do |ingredient|

        if ingredient.id != keeper.id
          ActivityIngredient.where(ingredient_id: ingredient.id).each do |ai|
            ai.ingredient = keeper
            ai.save
          end
          StepIngredient.where(ingredient_id: ingredient.id).each do |si|
            si.ingredient = keeper
            si.save
          end
          ingredient.reload
          if (ingredient.activities.count == 0) && (ingredient.steps.count == 0)
            ingredient.destroy
          else
            puts "Unexpected dependencies remain... not deleting"
            puts keeper.id
            puts ingredient.activities.count
            puts ingredient.steps.count
            puts group.inspect
          end
        end
      end

    end
  end

  puts "Final count #{grouped_ingreds.count} ingredients"

end