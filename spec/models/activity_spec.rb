require 'spec_helper'

describe Activity do
  let(:activity) { Fabricate(:activity, title: 'foo') }

  describe "#update_equipment" do
    let(:equipment1) { {title: 'Blender', optional: "true"}  }
    let(:equipment2) { {title: 'Spoon', optional: "false"}  }
    let(:equipment_attrs) {[ equipment1, equipment2 ] }

    describe "create" do
      before do
        activity.update_equipment(equipment_attrs)
      end

      it "creates unique equipment for each non-empty attribute set" do
        activity.equipment.should have(2).equipment
      end

      it "creates equipment with specified attributes" do
        activity.equipment.first.title.should == 'Blender'
        activity.equipment.first.optional.should == true
      end
    end

    describe "update" do
      before do
        activity.update_equipment(equipment_attrs)
        equipment_attrs.first.merge!(title: 'BleNdeR', optional: 'false')
        activity.update_equipment(equipment_attrs)
        activity.equipment.reload
      end

      it "updates existing equipment" do
        activity.equipment.should have(2).equipment
        activity.equipment.first.title.should == 'Blender'
        activity.equipment.first.optional.should == false
      end
    end

    describe "destroy" do
      before do
        activity.update_equipment(equipment_attrs)
        activity.update_equipment(equipment_attrs[1..-1])
        activity.equipment.reload
      end

      it "deletes equipment not included in attribute set" do
        activity.equipment.should have(1).equipment
        activity.equipment.first.title.should == 'Spoon'
        activity.equipment.first.optional.should == false
      end
    end

    describe "re-ordering" do
      before do
        activity.update_equipment(equipment_attrs)
      end

      it "updates ordering" do
        activity.update_equipment([equipment2, equipment1])
        activity.equipment.ordered.first.title.should == 'Spoon'
      end
    end
  end

  describe "#update_ingredients" do
    let(:soup) { {title: 'Soup', display_quantity: '2', unit: 'g'}  }
    let(:pepper) { {title: 'Pepper', display_quantity: '1', unit: 'kg'}  }
    let(:ingredient_attrs) {[ soup, pepper, pepper,
                              { title: '', display_quantity: '2', unit: '' }
    ]}


    describe "create" do
      before do
        activity.update_ingredients(ingredient_attrs)
      end

      it "creates unique ingredients for each non-empty attribute set" do
        activity.ingredients.should have(2).ingredients
      end

      it "creates ingredient with specified attributes" do
        activity.ingredients.first.display_quantity.should == '2'
        activity.ingredients.first.unit.should == 'g'
        activity.ingredients.first.title.should == 'Soup'
      end
    end

    describe "update" do
      before do
        activity.update_ingredients(ingredient_attrs)
        ingredient_attrs.first.merge!(title: 'SouP', display_quantity: '15', unit: 'foobars')
        activity.update_ingredients(ingredient_attrs)
        activity.ingredients.reload
      end

      it "updates existing ingredients" do
        activity.ingredients.should have(2).ingredients
        activity.ingredients.first.title.should == 'Soup'
        activity.ingredients.first.display_quantity.should == '15'
        activity.ingredients.first.unit.should == 'foobars'
      end
    end

    describe "destroy" do
      before do
        activity.update_ingredients(ingredient_attrs)
        activity.update_ingredients(ingredient_attrs[1..-1])
        activity.ingredients.reload
      end

      it "deletes ingredients not included in attribute set" do
        activity.ingredients.should have(1).ingredients
        activity.ingredients.first.title.should == 'Pepper'
        activity.ingredients.first.display_quantity.should == '1'
        activity.ingredients.first.unit.should == 'kg'
      end
    end

    describe "re-ordering" do
      before do
        activity.update_ingredients(ingredient_attrs)
      end

      it "updates ordering" do
        activity.update_ingredients([pepper, soup])
        activity.ingredients.ordered.first.title.should == 'Pepper'
      end
    end
  end
end

describe Activity, "#update_steps" do
  let(:activity) { Fabricate(:activity, title: 'foo') }

  let(:step1) { {title: 'Blend', directions: 'blend it'} }
  let(:step2) { {title: '', directions: 'cut it'} }
  let(:step_attrs) {[ step1, step2 ] }

  describe "create" do
    before do
      activity.update_steps(step_attrs)
    end

    it "creates unique steps for each non-empty attribute set" do
      activity.steps.should have(2).steps
    end

    it "creates steps with specified attributes" do
      activity.steps.first.title.should == 'Blend'
      activity.steps.first.directions.should == 'blend it'
    end
  end

  describe "update" do
    before do
      activity.update_steps(step_attrs)
      step_attrs.first.merge!(title: 'Blend', directions: 'stuff')
      activity.update_steps(step_attrs)
      activity.steps.reload
    end

    it "updates existing steps" do
      activity.steps.should have(2).steps
      activity.steps.first.title.should == 'Blend'
      activity.steps.first.directions.should == 'stuff'
    end
  end

  describe "destroy" do
    before do
      activity.update_steps(step_attrs)
      activity.update_steps(step_attrs[1..-1])
      activity.steps.reload
    end

    it "deletes steps not included in attribute set" do
      activity.steps.should have(1).steps
      activity.steps.first.title.should == ''
      activity.steps.first.directions.should == 'cut it'
    end
  end

  describe "re-ordering" do
    before do
      activity.update_steps(step_attrs)
    end

    it "updates ordering" do
      activity.update_steps([step2, step1])
      activity.steps.ordered.first.directions.should == 'cut it'
    end
  end
end

describe Activity, 'has_quizzes?' do
  let(:activity) { Fabricate.build(:activity) }

  it 'returns false if activity has no quizzes' do
    activity.should_not have_quizzes
  end

  it 'returns true if activity has quizzes' do
    activity.quizzes.append(Fabricate.build(:quiz))
    activity.should have_quizzes
  end
end
