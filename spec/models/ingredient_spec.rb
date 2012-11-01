require 'spec_helper'

describe Ingredient, "capitalize title" do
  let(:ingredient) { Fabricate(:ingredient, title: 'fOo Bar bAz') }

  it "capitalizes the first letter of the word when ingredient is created" do
    ingredient.title.should == 'Black Pepper'
  end

  it "capitalizes the first letter of the word when ingredient is updated" do
    ingredient.update_attributes(title: 'black pepper')
    ingredient.title.should == 'Black pepper'
  end
end

