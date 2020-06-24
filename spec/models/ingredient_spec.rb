require 'spec_helper'

describe Ingredient do
  let(:ingredient) { Fabricate(:ingredient, title: 'black Pepper', image_id: "foo", tag_list: ["a","b"]) }
  let(:ingredient2) { Fabricate(:ingredient, title: 'Black peepper', image_id: "bar", text_fields: "baz", tag_list: ["c"]) }
  let(:ingredient3) { Fabricate(:ingredient, title: 'Black pepper, whole', density: 1, product_url: "sneegle", tag_list: ["c", "d"]) }
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
    Ingredient.exists?(ingredient.id).should == true
    Ingredient.exists?(ingredient2.id).should == false
    Ingredient.exists?(ingredient3.id).should == false
  end

  it "copies over details from merged ingredients" do
    ingredient.merge([ingredient2, ingredient3])
    ingredient.image_id.should == "foo"
    ingredient.text_fields.should == "baz"
    ingredient.density.should == 1
    ingredient.product_url.should == "sneegle"
    ingredient.tag_list.should =~ ["a", "b", "c", "d"]
  end

  context "text_fields" do
    before :each do
      @ingredient = Fabricate :ingredient, title: 'Some Ingredient', text_fields: {"hello" => "hey"}
    end
    it "sanition does not corrupt the hash" do
      @ingredient.text_fields = {"hello" => "world"}
      @ingredient.save
      expect(@ingredient.text_fields["hello"]).to eq("world")
    end
    it "sanitizes hash values" do
      @ingredient.text_fields = {"hello" => "big > small"}
      @ingredient.save
      expect(@ingredient.text_fields["hello"]).to eq("big &gt; small")
    end
  end
end
