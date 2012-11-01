require 'spec_helper'

describe Step, '#title' do
  let(:step) { Step.new }

  it "returns '' if no index provided and step has no title" do
    step.title.should be_blank
  end

  it "returns 'Step INDEX+1' if index provided and step has no title" do
    step.title(5).should == "Step 6"
  end

  it "returns title if step has title" do
    step.title = 'the title'
    step.title.should == 'the title'
  end

end

describe Step, '#update_ingredients' do
  let(:step) { Step.create(title: 'foo') }
  let(:soup) { {title: 'Soup', quantity: 2, unit: 'g'}  }
  let(:pepper) { {title: 'Pepper', quantity: 1, unit: 'kg'}  }
  let(:ingredient_attrs) {[ soup, pepper, pepper,
    { title: '', quantity: 2, unit: '' }
  ]}


  describe "create" do
    before do
      step.update_ingredients(ingredient_attrs)
    end

    it "creates unique ingredients for each non-empty attribute set" do
      step.ingredients.should have(2).ingredients
    end

    it "creates ingredient with specified attributes" do
      step.ingredients.first.quantity.should == 2
      step.ingredients.first.unit.should == 'g'
      step.ingredients.first.title.should == 'Soup'
    end
  end

  describe "update" do
    before do
      step.update_ingredients(ingredient_attrs)
      ingredient_attrs.first.merge!(quantity: 15, unit: 'foobars')
      step.update_ingredients(ingredient_attrs)
      step.ingredients.reload
    end

    it "updates existing ingredients" do
      step.ingredients.should have(2).ingredients
      step.ingredients.first.title.should == 'Soup'
      step.ingredients.first.quantity.should == 15
      step.ingredients.first.unit.should == 'foobars'
    end
  end

  describe "destroy" do
    before do
      step.update_ingredients(ingredient_attrs)
      step.update_ingredients(ingredient_attrs[1..-1])
      step.ingredients.reload
    end

    it "deletes ingredients not included in attribute set" do
      step.ingredients.should have(1).ingredients
      step.ingredients.first.title.should == 'Pepper'
      step.ingredients.first.quantity.should == 1
      step.ingredients.first.unit.should == 'kg'
    end
  end

  describe "re-ordering" do
    before do
      step.update_ingredients(ingredient_attrs)
    end

    it "updates ordering" do
      step.update_ingredients([pepper, soup])
      step.ingredients.ordered.first.title.should == 'Pepper'
    end
  end
end

