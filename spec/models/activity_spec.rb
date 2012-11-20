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

  describe "#update_recipes" do
    let(:recipe1) { Fabricate(:recipe, title: 'Mac n Cheese') }
    let(:recipe2) { Fabricate(:recipe, title: 'Hamburger Helper') }
    let(:recipe3) { Fabricate(:recipe, title: 'Scrambled Eggs') }
    let(:recipe_ids) { [ recipe1.id, recipe2.id, recipe3.id, '' ].map(&:to_s) }
    let!(:stepA) { Fabricate(:step, title: 'Step A', recipe: recipe1) }
    let!(:stepB) { Fabricate(:step, title: 'Step B', recipe: recipe2) }

    describe "update" do
      before do
        activity.update_recipes(recipe_ids)
      end

      it "associates recipes with the activity" do
        activity.recipes.should have(3).recipes
        activity.recipes.first.title.should == "Mac n Cheese"
      end

      it "create activity recipe steps" do
        activity.recipe_steps.should have(2).steps
        activity.recipe_steps.first.title.should == 'Step A'
      end
    end

    describe "destroy" do
      before do
        activity.update_recipes(recipe_ids)
        activity.update_recipes([recipe_ids.first])
        activity.recipes.reload
        activity.recipe_steps.reload
      end

      it "removes the association of recipes not included in the set" do
        activity.recipes.should have(1).recipes
        activity.recipes.first.title.should == "Mac n Cheese"
      end

      it "removes the unassociated recipe steps" do
        activity.recipe_steps.should have(1).steps
        activity.recipe_steps.first.title.should == 'Step A'
      end
    end

    describe "re-ordering" do
      before do
        activity.update_recipes(recipe_ids)
      end

      it "updates ordering" do
        activity.update_recipes([recipe2.id, recipe1.id])
        activity.ordered_recipes.first.title.should == 'Hamburger Helper'
      end
    end
  end

  describe "#has_ingredients?" do
    let(:recipe1) { Fabricate.build(:recipe, :title => 'r1') }
    let(:recipe2) { Fabricate.build(:recipe, :title => 'r2') }

    before do
      recipe2.stub(:has_ingredients?).and_return(false)
      activity.recipes << recipe1
      activity.recipes << recipe2
    end

    subject { activity.has_ingredients? }

    context "with recipes with ingredients" do
      before do
        recipe1.stub(:has_ingredients?).and_return(true)
      end

      it { subject.should == true }
    end

    context "with recipes with no ingredients" do
      before do
        recipe1.stub(:has_ingredients?).and_return(false)
      end

      it { subject.should == false }
    end
  end
end

describe Activity, '#has_recipes?' do
  subject { Fabricate.build(:activity) }
  it { should_not have_recipes }
  context "with recipes" do
    before { subject.recipes << Fabricate.build(:recipe) }
    it { should have_recipes }
  end
end

describe Activity, "#update_recipe_steps" do
  let(:activity) { Fabricate(:activity) }
  let(:recipe1) { Fabricate(:recipe) }
  let(:stepA) { Fabricate(:step) }

  before do
    activity.recipes << recipe1
    recipe1.steps << stepA
    recipe1.steps.reload
    activity.recipes.reload
    activity.update_recipe_steps
  end

  it "adds recipe_steps" do
    activity.recipe_steps.should have(1).step
    activity.recipe_steps.first.step.should == stepA
  end
end

describe Activity, "#update_recipe_step_order" do
  let(:activity) { Fabricate.build(:activity) }
  let(:stepA) { Fabricate(:step) }
  let(:stepB) { Fabricate(:step) }
  let(:recipe1) { Fabricate(:recipe) }
  let(:recipe2) { Fabricate(:recipe) }

  before do
    recipe1.steps << stepA
    recipe2.steps << stepB
    activity.recipes << recipe1 << recipe2
    activity.update_recipe_steps
    activity_steps = activity.recipe_steps
    @requested_order = [activity_steps.last, activity_steps.first]
    activity_steps_order_ids = @requested_order.map(&:id).map(&:to_s)
    activity.update_recipe_step_order(activity_steps_order_ids)
  end

  it "orders the activity recipe steps" do
    activity.recipe_steps.ordered.should == @requested_order
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

describe Activity, 'ordering' do
  let!(:activity_last) { Fabricate(:activity, activity_order_position: 2, published: true) }
  let!(:activity_first) { Fabricate(:activity, activity_order_position: 0, published: true) }
  let!(:activity_middle) { Fabricate(:activity, activity_order_position: 1, published: true) }
  let!(:activity_private) { Fabricate(:activity, activity_order_position: 3) }

  its "ordered scope returns activities in order" do
    Activity.ordered.all.should == [activity_first, activity_middle, activity_last, activity_private]
  end

  context "#next" do
    it "returns the next published-ordered activity" do
      activity_first.next.should == activity_middle
      activity_middle.next.should == activity_last
    end

    it "returns nil if at end of collectin" do
      activity_last.next.should_not be
    end

    it "returns nil if called on private activity" do
      activity_private.next.should_not be
    end
  end

  context "#prev" do
    it "returns the previous published-ordered activity" do
      activity_last.prev.should == activity_middle
      activity_middle.prev.should == activity_first
    end

    it "returns nil if at beginning of collection" do
      activity_first.prev.should_not be
    end

    it "returns nil if called on private activity" do
      activity_private.prev.should_not be
    end
  end
end

describe Activity, 'publishing' do
  let!(:public_activity) { Fabricate(:activity, id: 1, published: true) }
  let!(:private_activity) { Fabricate(:activity, id: 2) }

  its "published flag is set to false by default" do
    private_activity.should_not be_published
  end

  its "published scope returns published activities only" do
    Activity.published.all.should == [public_activity]
  end

  context '#find_published' do
    it 'throws not found if activity does not exist with id' do
      lambda { Activity.find_published(42) }.should raise_error ActiveRecord::RecordNotFound
    end

    it 'returns activity if published' do
      Activity.find_published(1).should == public_activity
    end

    context 'for private activity' do
      it 'throws not found' do
        lambda { Activity.find_published(2) }.should raise_error ActiveRecord::RecordNotFound
      end

      it 'throws not found if token is invalid' do
        PrivateToken.should_receive(:valid?).with('bad_token').and_return(false)
        lambda { Activity.find_published(2, 'bad_token') }.should raise_error ActiveRecord::RecordNotFound
      end

      it 'returns activity if token is valid' do
        PrivateToken.should_receive(:valid?).with('good_token').and_return(true)
        Activity.find_published(2, 'good_token').should == private_activity
      end
    end
  end
end
