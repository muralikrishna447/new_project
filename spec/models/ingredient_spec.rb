require 'spec_helper'

describe Ingredient, "capitalize title" do
  let(:ingredient) { Fabricate(:ingredient, title: 'black Pepper') }

  it "capitalizes the first letter of the word when ingredient is created" do
    ingredient.title.should == 'Black Pepper'
  end

  it "capitalizes the first letter of the word when ingredient is updated" do
    ingredient.update_attributes(title: 'black pepper')
    ingredient.title.should == 'Black pepper'
  end
end

describe Ingredient, "#find_or_create_by_title" do
  let!(:ingredient) { Ingredient.find_or_create_by_title('new ingredient') }

  it "creates new ingredient if none exists with same title" do
    ingredient.should be_persisted
  end

  it "returns existing ingredient if one exists with exact title" do
    Ingredient.find_or_create_by_title('new ingredient')
    Ingredient.all.should == [ingredient]
  end

  it "returns existing ingredient if one exists with case insensitive title" do
    Ingredient.find_or_create_by_title('NeW IngreDienT')
    Ingredient.all.should == [ingredient]
  end
end
