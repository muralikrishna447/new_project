require 'spec_helper'

describe Recipe do
  let(:recipe) { Fabricate(:recipe, title: 'foo') }

  describe "#update_ingredients" do
    let(:soup) { {title: 'Soup', quantity: 2, unit: 'g'}  }
    let(:pepper) { {title: 'Pepper', quantity: 1, unit: 'kg'}  }
    let(:ingredient_attrs) {[ soup, pepper, pepper,
                              { title: '', quantity: 2, unit: '' }
    ]}


    describe "create" do
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

    describe "update" do
      before do
        recipe.update_ingredients(ingredient_attrs)
        ingredient_attrs.first.merge!(quantity: 15, unit: 'foobars')
        recipe.update_ingredients(ingredient_attrs)
        recipe.ingredients.reload
      end

      it "updates existing ingredients" do
        recipe.ingredients.should have(2).ingredients
        recipe.ingredients.first.title.should == 'Soup'
        recipe.ingredients.first.quantity.should == 15
        recipe.ingredients.first.unit.should == 'foobars'
      end
    end

    describe "destroy" do
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

    describe "re-ordering" do
      before do
        recipe.update_ingredients(ingredient_attrs)
      end

      it "updates ordering" do
        recipe.update_ingredients([pepper, soup])
        recipe.ingredients.ordered.first.title.should == 'Pepper'
      end
    end
  end

  describe "#update_steps" do
    let(:step1) { {title: 'step1', directions: "Foo and bar on the baz", image_id: '', youtube_id: 'pirate booty'} }
    let(:step2) { {title: '', directions: "Burrito bagel sandwich", image_id: 'happiness', youtube_id: ''} }
    let(:step3) { {title: 'step3', directions: "", image_id: '', youtube_id: ''} }
    let(:step_attrs) { [ step1, step2, step3 ] }

    describe "create" do
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
        recipe.steps.last.title.should == ''
      end
    end

    describe "update" do
      before do
        recipe.update_steps(step_attrs)
        update_attr_ids
        step_attrs.first[:directions] = 'put your left foot in'
        recipe.update_steps(step_attrs)
        recipe.steps.reload
      end

      it "updates existing ingredients" do
        recipe.steps.should have(2).steps
        recipe.steps.first.title.should == 'step1'
        recipe.steps.first.directions.should == 'put your left foot in'
      end

      context "and create" do
        before do
          step3[:directions] = 'now with a description'
          step_attrs << step3
          recipe.update_steps(step_attrs)
          recipe.steps.reload
        end

        it "updates existing ingredients" do
          recipe.steps.should have(3).steps
          recipe.steps.first.directions.should == 'put your left foot in'
          recipe.steps.last.directions.should == 'now with a description'
        end
      end
    end

    describe "destroy" do
      before do
        recipe.update_steps(step_attrs)
        update_attr_ids
        recipe.update_steps(step_attrs[1..-1])
        recipe.steps.reload
      end

      it "deletes ingredients not included in attribute set" do
        recipe.steps.should have(1).steps
        recipe.steps.first.title.should == ''
        recipe.steps.first.directions.should == 'Burrito bagel sandwich'
        recipe.steps.first.image_id.should == 'happiness'
        recipe.steps.first.youtube_id.should == ''
      end
    end

    describe "re-ordering" do
      before do
        recipe.update_steps(step_attrs)
        update_attr_ids
      end

      it "updates ordering" do
        recipe.update_steps([step2, step3, step1])
        recipe.steps.ordered.first.title.should == ''
        recipe.steps.ordered.last.title.should == 'step1'
      end
    end
    def update_attr_ids
      recipe.steps.each_with_index { |step,index| step_attrs[index][:id] = step.id.to_s }
    end
  end

  describe "#has_ingredients?" do
    subject { recipe.has_ingredients? }
    context "with ingredients" do
      before do
        recipe.ingredients.stub(:empty?).and_return(false)
      end

      it { subject.should == true }
    end

    context "with no ingredients" do
      before do
        recipe.ingredients.stub(:empty?).and_return(true)
      end

      it { subject.should == false }
    end
  end
end

