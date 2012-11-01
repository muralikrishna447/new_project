require 'spec_helper'

describe Ingredient do
  describe "capitalize title" do
    let(:ingredient) { Fabricate(:ingredient, title: 'fOo Bar bAz') }

    describe "create" do
      it "capitalizes the first letter of the first word only" do
        ingredient.title.should == 'Foo bar baz'
      end
    end

    describe "update" do
      before do
        ingredient.update_attributes(title: 'NuCLeAR ISOtOpEs')
      end

      it "capitalizes the first letter of the first word only" do
        ingredient.title.should == 'Nuclear isotopes'
      end
    end
  end
end

