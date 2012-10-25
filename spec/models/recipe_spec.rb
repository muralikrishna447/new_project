require 'spec_helper'

describe Recipe, "#update_ingredients" do
  let(:recipe) { Recipe.create(title: 'foo') }
  let(:ingredient_attrs) {[
    { title: 'Soup', quantity: 2, unit: 'g' },
    { title: 'Pepper', quantity: 1, unit: 'g' },
    { title: 'Pepper', quantity: 1, unit: 'g' }
  ]}

  before do
    recipe.update_ingredients(ingredient_attrs)
  end

  it "creates unique ingredients for each attribute set" do
    recipe.ingredients.should have(2).ingredients
  end

  it "creates ingredient with specified attributes" do
    recipe.ingredients.first.quantity.should == 2
    recipe.ingredients.first.unit.should == 'g'
    recipe.ingredients.first.title.should == 'Soup'
  end

end

