require 'spec_helper'

describe RecipeIngredient, 'Quantity behavior' do
  subject { Fabricate(:recipe_ingredient, display_quantity: '12.52', unit: 'things') }

  its(:measurement) { should == '12.52 things' }
  its(:display_quantity) { should == '12.52' }
  its(:quantity) { should == 12.52 }

  context "change via update_attributes" do
    before { subject.update_attributes(display_quantity: '13.00') }
    its(:measurement) { should == '13.00 things' }
    its(:display_quantity) { should == '13.00' }
    its(:quantity) { should == 13.0 }
  end

  context "change via assignment" do
    before { subject.display_quantity = '1' }
    its(:measurement) { should == '1 things' }
    its(:display_quantity) { should == '1' }
    its(:quantity) { should == 1.0 }
  end

end
