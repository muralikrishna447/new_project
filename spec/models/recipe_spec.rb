require 'spec_helper'

describe Recipe do
  let(:recipe) { Recipe.create(title: 'foo') }

  describe "#update_ingredients" do
    let(:soup) { {title: 'Soup', quantity: 2, unit: 'g'}  }
    let(:pepper) { {title: 'Pepper', quantity: 1, unit: 'kg'}  }
    let(:ingredient_attrs) {[ soup, pepper, pepper,
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
        recipe.update_ingredients(ingredient_attrs[1..-1])
        recipe.ingredients.reload
      end

      it "deletes ingredients not included in attribute set" do
        recipe.ingredients.should have(1).ingredients
        recipe.ingredients.first.title.should == 'Pepper'
        recipe.ingredients.first.quantity.should == 1
        recipe.ingredients.first.unit.should == 'kg'
      end
    end

    describe "update" do
      let(:updated_ingredient_attrs) { ingredient_attrs << { title: 'Soup', quantity: 15, unit: 'foobars' } }

      before do
        recipe.update_ingredients(ingredient_attrs)
        recipe.update_ingredients(updated_ingredient_attrs)
        recipe.ingredients.reload
      end

      it "updates existing ingredients" do
        recipe.ingredients.should have(2).ingredients
        recipe.ingredients.first.quantity.should == 15
        recipe.ingredients.first.unit.should == 'foobars'
      end
    end
  end

  describe "#update_steps" do
    let(:step1) { {title: 'step1', directions: "Foo and bar on the baz", image_id: '', youtube_id: 'pirate booty'} }
    let(:step2) { {title: '', directions: "Burrito bagel sandwich", image_id: 'happiness', youtube_id: ''} }
    let(:step3) { {title: 'step3', directions: "", image_id: '', youtube_id: ''} }
    let(:step_attrs) { [ step1, step2, step3 ] }

    describe "creation" do
      before do
        recipe.update_steps(step_attrs)
      end

      it "creates steps for each non-empty attribute set" do
        recipe.steps.should have(2).steps
      end

      it "creates steps with specified attributes" do
        recipe.steps.first.title.should == 'step1'
        recipe.steps.first.directions.should == 'Foo and bar on the baz'
        recipe.steps.first.image_id.should == ''
        recipe.steps.first.youtube_id.should == 'pirate booty'
      end
    end

    describe "update" do
      before do
        recipe.update_steps(step_attrs)
        step = recipe.steps.first
        step.directions = 'sit and spin'
        recipe.update_steps(step_attrs << step.to_json)
        recipe.steps.reload
      end

      it "updates existing ingredients" do
        recipe.steps.first.title.should == 'step1'
        recipe.steps.first.directions.should == 'sit and spin'
        recipe.steps.first.image_id.should == ''
        recipe.steps.first.youtube_id.should == ''
      end
    end

    # describe "deletion" do
    #   before do
    #     recipe.update_steps(step_attrs)
    #     recipe.update_steps(step_attrs[1..-1])
    #     recipe.steps.reload
    #   end

    #   it "deletes ingredients not included in attribute set" do
    #     recipe.steps.should have(1).steps
    #     recipe.steps.first.title.should == ''
    #     recipe.steps.first.directions.should == 'Burrito bagel sandwich'
    #     recipe.steps.first.image_id.should == 'happiness'
    #     recipe.steps.first.youtube_id.should == ''
    #   end
    # end
  end
end

