require 'spec_helper'

describe CaseInsensitiveTitle do
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

