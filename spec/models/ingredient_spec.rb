require 'spec_helper'

describe Ingredient do
  let(:ingredient) { Fabricate(:ingredient, title: 'black Pepper') }
  let(:ingredient2) { Fabricate(:ingredient, title: 'Black peepper') }
  let(:ingredient3) { Fabricate(:ingredient, title: 'Black pepper, whole') }
  let(:activity) { Fabricate(:activity, title: 'foo1') }
  let(:activity2) { Fabricate(:activity, title: 'foo2') }
  let(:activity3) { Fabricate(:activity, title: 'foo3') }
  let(:step3) { Fabricate(:step) }


  let(:activity_ingredient1) { Fabricate(:activity_ingredient, activity: activity, ingredient: ingredient, display_quantity: '1', unit: 'things') }
  let(:activity_ingredient2a) { Fabricate(:activity_ingredient, activity: activity2, ingredient: ingredient2, display_quantity: '2', unit: 'things') }
  let(:activity_ingredient2b) { Fabricate(:activity_ingredient, activity: activity2, ingredient: ingredient2, display_quantity: '2.5', unit: 'things') }
  let(:activity_ingredient3) { Fabricate(:activity_ingredient, activity: activity3, ingredient: ingredient3, display_quantity: '3', unit: 'things') }
  let(:step_ingredient3) { Fabricate(:step_ingredient, ingredient: ingredient3, display_quantity: '2', unit: 'things', note: "pebbly")}

  it "capitalizes the first letter of the word when ingredient is created" do
    ingredient.title.should == 'Black Pepper'
  end

  it "capitalizes the first letter of the word when ingredient is updated" do
    ingredient.update_attributes(title: 'black pepper')
    ingredient.title.should == 'Black pepper'
  end

  subject { Fabricate(:activity_ingredient, ingredient: ingredient, display_quantity: '12.52', unit: 'things') }

  its(:measurement) { should == '12.52 things' }
  its(:display_quantity) { should == '12.52' }
  its(:quantity) { should == 12.52 }

  it "handles non decimal characters in display" do
    subject.display_quantity = '10stuff'
    subject.quantity.should == 10
    subject.display_quantity = '1.12 stuff'
    subject.quantity.should == 1.12
    subject.display_quantity = 'stuff3.4'
    subject.quantity.should == 0
  end

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

  it "can merge manually marked duplicates" do
    activity_ingredient1.save
    activity_ingredient2a.save
    activity_ingredient2b.save
    activity_ingredient3.save
    step_ingredient3.save
    puts ingredient.inspect
    ingredient.activities.should have(1).activity
    ingredient.steps.should have(0).step
    ingredient2.activities.should have(2).activity

    ingredient.merge([ingredient2, ingredient3])
    ingredient.save

    ingredient.activities.should have(4).activity
    ingredient.steps.should have(1).step
    activity_ingredient3.reload
    activity_ingredient3.note.should == "whole"
    step_ingredient3.reload
    step_ingredient3.note.should == "whole, pebbly"
    Ingredient.exists?(ingredient).should == true
    Ingredient.exists?(ingredient2).should == false
    Ingredient.exists?(ingredient3).should == false
  end
end
