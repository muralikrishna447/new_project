require 'spec_helper'

describe Recipe do
  describe "#update_ingredients" do
    let(:recipe) { Recipe.create(title: 'foo') }
    let(:ingredient_attrs) {[
      { title: 'Soup', quantity: 2, unit: 'g' },
      { title: 'Pepper', quantity: 1, unit: 'g' },
      { title: 'Pepper', quantity: 1, unit: 'g' },
      { title: '', quantity: 2, unit: '' }
    ]}


    describe "creation" do
      before do
        recipe.update_ingredients(ingredient_attrs)
      end

      it "creates unique ingredients for each non-empty attribute set" do
        recipe.ingredients.should have(2).ingredients
      end

      it "creates ingredient with specified attributes" do
        recipe.ingredients.first.quantity.should == 2
        recipe.ingredients.first.unit.should == 'g'
        recipe.ingredients.first.title.should == 'Soup'
      end
    end

    describe "deletion" do
      before do
        recipe.update_ingredients(ingredient_attrs)
      end

      it "deletes ingredients not included in attribute set" do
        recipe.update_ingredients(ingredient_attrs[1..-1])
        recipe.ingredients.reload.should have(1).ingredients
        recipe.ingredients.first.quantity.should == 1
        recipe.ingredients.first.unit.should == 'g'
        recipe.ingredients.first.title.should == 'Pepper'
      end
    end

    describe "update" do
      let(:updated_ingredient_attrs) {[ { title: 'Soup', quantity: 15, unit: 'foobars' } ]}

      before do
        recipe.update_ingredients(ingredient_attrs)
        recipe.update_ingredients(updated_ingredient_attrs)
        recipe.ingredients.reload
      end

      it "updates existing ingredients" do
        recipe.ingredients.first.quantity.should == 15
        recipe.ingredients.first.unit.should == 'foobars'
      end
    end
  end
end

