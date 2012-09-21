# RailsAdmin config file. Generated on September 06, 2012 11:36
# See github.com/sferik/rails_admin for more informations

RailsAdmin.config do |config|


  config.current_user_method { current_user } # auto-generated

  config.main_app_name = ['Delve', 'Admin']

  config.attr_accessible_role { :admin }
  config.model ActivityEquipment do
    visible false
  end

  config.model RecipeIngredient do
    visible false
    object_label_method do
      :label
    end
  end

  config.model StepIngredient do
    visible false
    object_label_method do
      :label
    end
    configure :ingredient_order do
      visible false
    end
  end

  config.model Step do
    configure :step_order do
      visible false
    end
    configure :ingredients do
      orderable :true
    end
  end

  config.model Ingredient do
    configure :steps do
      visible false
    end
    configure :step_ingredients do
      visible false
    end
    configure :recipe_ingredients do
      visible false
    end
    configure :recipes do
      visible false
    end
  end

  config.model Recipe do
    configure :steps do
      orderable true
    end
    configure :recipe_order do
      visible false
    end
    configure :ingredients do
      orderable :true
    end
  end

  config.model Equipment do
    configure :activity_equipment do
      visible false
    end
  end

  config.model Activity do
    configure :activity_order do
      visible false
    end
    configure :recipes do
      orderable true
    end
    configure :steps do
      orderable true
    end
  end

end

