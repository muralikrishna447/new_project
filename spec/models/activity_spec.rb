require 'spec_helper'

describe Activity do
  let(:activity) { Activity.create(title: 'foo') }

  describe "#update_equipment" do
    let(:equipment1) { {title: 'Blender', product_url: 'over the rainbow', optional: "true"}  }
    let(:equipment2) { {title: 'Spoon', product_url: '', optional: "false"}  }
    let(:equipment_attrs) {[ equipment1, equipment2 ] }

    describe "create" do
      before do
        activity.update_equipment(equipment_attrs)
      end

      it "creates unique equipment for each non-empty attribute set" do
        activity.equipment.should have(2).equipment
      end

      it "creates equipment with specified attributes" do
        activity.equipment.first.title.should == 'Blender'
        activity.equipment.first.product_url.should == 'over the rainbow'
        activity.equipment.first.optional.should == true
      end
    end

    describe "update" do
      before do
        activity.update_equipment(equipment_attrs)
        equipment_attrs.first.merge!(product_url: 'stuff', optional: 'false')
        activity.update_equipment(equipment_attrs)
        activity.equipment.reload
      end

      it "updates existing equipment" do
        activity.equipment.should have(2).equipment
        activity.equipment.first.title.should == 'Blender'
        activity.equipment.first.product_url.should == 'stuff'
        activity.equipment.first.optional.should == false
      end
    end

    describe "destroy" do
      before do
        activity.update_equipment(equipment_attrs)
        activity.update_equipment(equipment_attrs[1..-1])
        activity.equipment.reload
      end

      it "deletes equipment not included in attribute set" do
        activity.equipment.should have(1).equipment
        activity.equipment.first.title.should == 'Spoon'
        activity.equipment.first.product_url.should == ''
        activity.equipment.first.optional.should == false
      end
    end

    describe "re-ordering" do
      before do
        activity.update_equipment(equipment_attrs)
      end

      it "updates ordering" do
        activity.update_equipment([equipment2, equipment1])
        activity.equipment.ordered.first.title.should == 'Spoon'
      end
    end

    describe "#update_recipes" do
      let(:recipe1) { Recipe.create(title: 'Mac n Cheese') }
      let(:recipe2) { Recipe.create(title: 'Hamburger Helper') }
      let(:recipe3) { Recipe.create(title: 'Scrambled Eggs') }
      let(:recipe_ids) { [ recipe1.id, recipe2.id, recipe3.id, '' ].map(&:to_s) }

      describe "update" do
        before do
          activity.update_recipes(recipe_ids)
        end

        it "associates recipes with the activity" do
          activity.recipes.should have(3).recipes
          activity.recipes.first.title.should == "Mac n Cheese"
        end
      end

      describe "destroy" do
        before do
          activity.update_recipes(recipe_ids)
          activity.update_recipes([recipe_ids.first])
          activity.recipes.reload
        end

        it "removes the association of recipes not included in the set" do
          activity.recipes.should have(1).recipes
          activity.recipes.first.title.should == "Mac n Cheese"
        end
      end

      describe "re-ordering" do
        before do
          activity.update_recipes(recipe_ids)
        end

        it "updates ordering" do
          activity.update_recipes([recipe2.id, recipe1.id])
          activity.recipes.ordered.first.title.should == 'Hamburger Helper'
        end
      end
    end
  end
end

