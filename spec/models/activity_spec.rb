require 'spec_helper'

describe Activity, "#meta_description" do
  it "prefer short_description" do
    Fabricate(:activity, short_description: "A", description: "B", title: "C").meta_description.should == "A"
  end

  it "uses description before title" do
    Fabricate(:activity, description: "B", title: "C").meta_description.should == "B"
  end

  it "uses title if no other options" do
    Fabricate(:activity, title: "C").meta_description.should == "C"
  end

end

describe Activity do
  let(:activity) { Fabricate(:activity, title: 'foo') }

  describe 'changes queue AlgoliaSync' do
    it 'queues algolia on update_attributes' do
      expect(Resque).to receive(:enqueue).with(AlgoliaSync, activity.id).at_least(:once)
      activity.update_attributes(title: "dog")
    end
  end

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

  describe "#update_equipment_json" do
    let(:equipment1) { {optional: true, equipment: {id: 1, title: 'Blender'}} }
    let(:equipment2) { {optional: false, equipment: {id: 2, title: 'Spoon'}}  }
    let(:equipment_attrs) {[ equipment1, equipment2 ] }
    let(:equipment3) { {optional: false, equipment: {title: 'Fork'}}  }
    let(:replacement_attrs) {[ equipment3 ] }

    describe "create" do
      before do
        activity.update_equipment_json(equipment_attrs)
        activity.reload
        activity.equipment.reload
      end

      it "creates unique equipment for each non-empty attribute set" do
        activity.equipment.should have(2).equipment
      end

      it "creates equipment with specified attributes" do
        activity.equipment.first.title.should == 'Blender'
        activity.equipment.first.optional.should == true
      end

      it "creates new equipment when id isn't specified" do
        activity.update_equipment_json(replacement_attrs)
        activity.reload
        activity.equipment.reload
        activity.equipment.should have(1).equipment
        activity.equipment.first.title.should == 'Fork'
        activity.equipment.first.id.should_not == 1
        activity.equipment.first.id.should_not == 2
      end
    end

    describe "update" do

      before do
        activity.update_equipment_json(equipment_attrs)
        activity.reload
        equipment_attrs[0] = {optional: false, equipment: {id: 1, title: 'Blender'}}
        activity.update_equipment_json(equipment_attrs)
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
        activity.update_equipment_json(equipment_attrs)
        activity.equipment.reload
        activity.update_equipment_json(equipment_attrs[1..-1])
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
        activity.update_equipment_json(equipment_attrs)
        activity.equipment.reload
      end

      it "updates ordering" do
        activity.update_equipment_json([equipment2, equipment1])
        activity.equipment.reload
        activity.equipment.ordered.first.title.should == 'Spoon'
      end
    end
  end

  describe "#update_ingredients" do
    let(:soup) { {title: 'Soup', note: 'hot', display_quantity: '2', unit: 'g'}  }
    let(:pepper) { {title: 'Pepper', note: 'black', display_quantity: '1', unit: 'kg'}  }
    let(:ingredient_attrs) {[ soup, pepper, pepper,
                              { title: '', note: "blerg", display_quantity: '2', unit: '' }
    ]}


    describe "create" do
      before do
        activity.update_ingredients(ingredient_attrs)
      end

      it "creates unique ingredients for each non-empty attribute set" do
        activity.ingredients.should have(3).ingredients
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
        activity.ingredients.should have(3).ingredients
        activity.ingredients.first.title.should == 'Soup'
        activity.ingredients.first.display_quantity.should == '15'
        activity.ingredients.first.unit.should == 'foobars'
      end

      it "creates duplicate ingredients with different notes and quantity" do
        ingredient_attrs << ({title: 'Pepper', note: 'black-new', display_quantity: '2', unit: 'kg'})
        activity.update_ingredients(ingredient_attrs)
        activity.ingredients.should have(4).ingredients
        activity.ingredients.last.note.should == 'black-new'
        activity.ingredients[1].note.should == 'black'
      end
    end

    describe "destroy" do
      before do
        activity.update_ingredients(ingredient_attrs)
        activity.update_ingredients(ingredient_attrs[1..-1])
        activity.ingredients.reload
      end

      it "deletes ingredients not included in attribute set" do
        activity.ingredients.should have(2).ingredients
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

  describe "#update_ingredients_json" do
    let(:ingredient1) { {display_quantity: 10, ingredient: {id: 1, title: 'Parsley'}} }
    let(:ingredient2) { {display_quantity: 20, ingredient: {id: 2, title: 'Tofu'}}  }
    let(:ingredient_attrs) {[ ingredient1, ingredient2 ] }
    let(:ingredient3) { {display_quantity: 30, ingredient: {title: 'Pepper'}}  }
    let(:replacement_attrs) {[ ingredient3 ] }

    describe "create" do
      before do
        activity.update_ingredients_json(ingredient_attrs)
        activity.reload
        activity.ingredients.reload
      end

      it "creates unique ingredient for each non-empty attribute set" do
        activity.ingredients.should have(2).ingredient
      end

      it "creates ingredient with specified attributes" do
        activity.ingredients.first.title.should == 'Parsley'
        activity.ingredients.first.display_quantity.should == "10"
      end

      it "creates new ingredient when id isn't specified" do
        activity.update_ingredients_json(replacement_attrs)
        activity.reload
        activity.ingredients.reload
        activity.ingredients.should have(1).ingredient
        activity.ingredients.first.title.should == 'Pepper'
        activity.ingredients.first.id.should_not == 1
        activity.ingredients.first.id.should_not == 2
      end
    end

    describe "update" do

      before do
        activity.update_ingredients_json(ingredient_attrs)
        activity.reload
        ingredient_attrs[0] = {display_quantity: 11, ingredient: {id: 1, title: 'Parsley'}}
        activity.update_ingredients_json(ingredient_attrs)
        activity.ingredients.reload
      end

      it "updates existing ingredient" do
        activity.ingredients.should have(2).ingredient
        activity.ingredients.first.title.should == 'Parsley'
        activity.ingredients.first.display_quantity.should == "11"
      end
    end

    describe "destroy" do
      before do
        activity.update_ingredients_json(ingredient_attrs)
        activity.ingredients.reload
        activity.update_ingredients_json(ingredient_attrs[1..-1])
        activity.ingredients.reload
      end

      it "deletes ingredient not included in attribute set" do
        activity.ingredients.should have(1).ingredient
        activity.ingredients.first.title.should == 'Tofu'
        activity.ingredients.first.display_quantity.should == "20"
      end
    end

    describe "re-ordering" do
      before do
        activity.update_ingredients_json(ingredient_attrs)
        activity.ingredients.reload
      end

      it "updates ordering" do
        activity.update_ingredients_json([ingredient2, ingredient1])
        activity.ingredients.reload
        activity.ingredients.ordered.first.title.should == 'Tofu'
      end
    end
  end
end


describe Activity, "#update_steps" do
  let(:activity) { Fabricate(:activity, title: 'foo') }

  let(:step1) { {title: 'Blend', directions: 'AAA'} }
  let(:step2) { {title: '', directions: 'BBB'} }
  let(:step3) { {title: '', directions: 'CCC', is_aside: true} }
  let(:step4) { {id: 'NEW_9999', title: '', directions: 'DDD'} }
  let(:step5) { {id: 'NEW_8888', title: '', directions: 'EEE'} }
  let(:step_attrs) {[ step1, step2, step3 ] }

  describe "create" do
    before do
      activity.update_steps(step_attrs)
    end

    it "creates unique steps for each non-empty attribute set" do
      activity.steps.should have(3).steps
    end

    it "creates steps with specified attributes" do
      activity.steps.first.title.should == 'Blend'
      activity.steps.first.directions.should == 'AAA'
    end

    it "hides number for asides by default" do
      activity.steps.first.hide_number.should_not == true
      activity.steps.last.hide_number.should == true
    end
  end

  describe "update" do
    before do
      activity.update_steps(step_attrs)
      step_attrs.first.merge!(title: 'Blend', directions: 'XXX')
      activity.update_steps(step_attrs)
      activity.steps.reload
    end

    it "updates existing steps" do
      activity.steps.should have(3).steps

      activity.steps.first.title.should == 'Blend'
      activity.steps.first.directions.should == 'XXX'
    end
  end

  describe "destroy" do
    before do
      activity.update_steps(step_attrs)
      activity.update_steps([step1, step3])
      activity.steps.reload
    end

    it "deletes steps not included in attribute set" do
      activity.steps.should have(2).steps
      activity.steps.first.directions.should == 'AAA'
      activity.steps.last.directions.should == 'CCC'
    end
  end

  describe "re-ordering" do
    before do
      activity.update_steps(step_attrs)
    end

    it "updates ordering" do
      activity.update_steps([step2, step1, step3])
      activity.steps.ordered.first.directions.should == 'BBB'
      activity.steps.ordered.last.directions.should == 'CCC'
    end
  end

  describe "re-order, add, and delete combined - ids maintained" do
    before do
      activity.update_steps(step_attrs)
      activity.steps.reload
    end

    it "updates ordering and maintains ids for old steps" do
      old_ids = activity.steps.map(&:id)
      activity.update_steps([step3, step4, step1, step5])
      activity.steps.reload
      new_ids = activity.steps.map(&:id)

      activity.steps.should have(4).steps
      activity.steps.ordered.map(&:directions).should == ['CCC', 'DDD','AAA', 'EEE']
      new_ids[0].should == old_ids[2]
      new_ids[1].should_not == 0
      new_ids[2].should == old_ids[0]
      new_ids[3].should_not == 0
      puts activity.steps.inspect
    end
  end
end

describe Activity, 'deep_copy' do
  let(:activity) { Fabricate.build(:activity) }
  let(:equipment1) { {title: 'Blender', optional: "true"}  }
  let(:equipment_attrs) {[ equipment1] }
  let(:soup) { {title: 'Soup', note: 'hot', display_quantity: '2', unit: 'g'}  }
  let(:pepper) { {title: 'Pepper', note: 'black', display_quantity: '1', unit: 'kg'}  }
  let(:ingredient_attrs) {[ soup]}
  let(:step1) { {title: 'Blend', directions: 'blend it'} }
  let(:step_attrs) {[ step1] }

  before do
    activity.save!
    activity.update_equipment(equipment_attrs)
    activity.update_ingredients(ingredient_attrs)
    activity.update_steps(step_attrs)
    activity.published = true
    activity.save!
    activity.reload
    activity.ingredients.reload
  end

  it 'makes a copy with expected differences' do
    a2 = activity.deep_copy
    a2.source_activity.should == activity
    a2.source_type.should == Activity::SourceType::ADAPTED_FROM
    a2.published.should == false
    a2.published_at.should == nil
    a2.first_published_at.should == nil
    a2.ingredients.should have(1).ingredients
    a2.equipment.should have(1).equipment
    a2.steps.should have(1).steps
    a2.ingredients.first.id.should_not == activity.ingredients.first.id
    a2.ingredients.first.ingredient_id.should == activity.ingredients.first.ingredient_id
    a2.equipment.first.id.should_not == activity.equipment.first.id
    a2.equipment.first.equipment_id.should == activity.equipment.first.equipment_id
    a2.steps.first.id.should_not == activity.steps.first.id
  end
end

describe Activity, 'save' do
  let(:activity) { Fabricate.build(:activity) }

  it 'starts with no publish dates' do
    activity.published_at.should == nil
    activity.first_published_at.should == nil
  end

  it 'should not have published dates if saved unpublished' do
    activity.save!
    activity.reload
    activity.published_at.should == nil
    activity.first_published_at.should == nil
  end

  it 'should have published dates if saved published ' do
    activity.published = true
    activity.save!
    activity.reload
    activity.published_at.should_not == nil
    activity.first_published_at.should_not == nil
    # Unclear why I need to convert to to_s here. The code in check_published clearly sets them to the same
    # value but both == and === fail when comparing the DateTimes directly.
    activity.first_published_at.to_s.should == activity.published_at.to_s
  end

  it 'should not change publish dates when resaved after already published' do
    activity.published = true
    activity.save!
    activity.reload
    published_at = activity.published_at
    first_published_at = activity.first_published_at
    Timecop.travel(Time.now + 1.day) do
      activity.save!
      activity.reload
      activity.published_at.should == published_at
      activity.first_published_at.should == first_published_at
    end
  end

  it 'should not change publish dates when unpublished and re-published' do
    activity.published = true
    activity.save!
    activity.reload
    published_at = activity.published_at
    first_published_at = activity.first_published_at

    Timecop.travel(Time.now + 1.day) do
      activity.published = false
      activity.save!
      activity.reload
    end

    Timecop.travel(Time.now + 2.day) do
      activity.published = true
      activity.save!
      activity.reload
    end

    activity.published_at.should == published_at
    activity.first_published_at.should == first_published_at
  end

  it 'should leave first_published_at alone when manually mucking with published_at' do
    activity.published = true
    activity.save!
    activity.reload
    published_at = activity.published_at
    first_published_at = activity.first_published_at

    happy_fun_time = Time.now + 1.minute
    activity.published_at = happy_fun_time
    activity.save!
    activity.reload

    activity.published_at.utc.to_s.should == happy_fun_time.utc.to_s
    activity.first_published_at.should == first_published_at
  end

end

describe Activity, 'gallery_path' do

  before :each do
    @plain_activity = Fabricate :activity, id: 1, title: 'Plain Activity', published: true
    @activity_within_class = Fabricate :activity, id: 2, title: 'Activity within class', published: true
    @activity_within_rd = Fabricate :activity, id: 3, title: 'Activity within rd', published: true
    @activity_within_class_unpublished = Fabricate :activity, id: 4, title: 'Activity within class unpublished', published: true

    @assembly_type_class = Fabricate :assembly, id: 1, title: 'Assembly Class', published: true, assembly_type: 'Course'
    @inclusion1 = Fabricate :assembly_inclusion, assembly_id: @assembly_type_class.id, includable_type: 'Activity', includable_id: @activity_within_class.id

    @assembly_type_rd = Fabricate :assembly, id: 2, title: 'Assembly RD', published: true, assembly_type: 'Recipe Development'
    @inclusion2 = Fabricate :assembly_inclusion, assembly_id: @assembly_type_rd.id, includable_type: 'Activity', includable_id: @activity_within_rd.id

    @assembly_type_class_unpublished = Fabricate :assembly, id: 3, title: 'Assembly Class Unpublished', published: false, assembly_type: 'Course'
    @inclusion3 = Fabricate :assembly_inclusion, assembly_id: @assembly_type_class_unpublished.id, includable_type: 'Activity', includable_id: @activity_within_class_unpublished.id
  end

  # it 'returns the correct path for plain activities' do
  #   @plain_activity.gallery_path.should eq('/activities/plain-activity')
  # end

  # it 'returns the correct path for activities within an class' do
  #   @activity_within_class.gallery_path.should eq('/classes/assembly-class')
  # end

  # it 'returns the correct path for activities within an recipe development' do
  #   @activity_within_rd.gallery_path.should eq('/recipe-development/assembly-rd')
  # end

  # it 'returns the activity path if containing course is not published' do
  #   @activity_within_class_unpublished.gallery_path.should eq('/activities/activity-within-class-unpublished')
  # end

end

describe Activity, 'Save with Promote order' do
  let(:activity) { Fabricate.build(:activity) }
  let(:promote_order_err_msg) { ['Order should be greater than or equal to 1'] }

  it 'should promote_order needs to save if is_promoted is 1' do
    activity.is_promoted = '1'
    activity.promote_order = 1
    activity.save!

    expect(activity.promote_order).to eq(1)
  end

  it 'should not save activity if promote_order nil when is_promoted is 1' do
    activity.is_promoted = '1'
    activity.promote_order = nil
    expect(activity.save).to be false
    expect(activity.errors.messages[:promote_order]).to eq promote_order_err_msg
  end

  it 'should not save activity if promote_order 0 when is_promoted is 1' do
    activity.is_promoted = '1'
    activity.promote_order = 0
    expect(activity.save).to be false
    expect(activity.errors.messages[:promote_order]).to eq promote_order_err_msg
  end

  it 'should not save activity if promote_order negative when is_promoted is 1' do
    activity.is_promoted = '1'
    activity.promote_order = -1
    expect(activity.save).to be false
    expect(activity.errors.messages[:promote_order]).to eq promote_order_err_msg
  end

  it 'promote_order should not save if is_promoted is 0' do
    activity.is_promoted = '0'
    activity.promote_order = 1
    activity.save
    expect(activity.promote_order).to be_nil
  end

  it 'promoted? method returns true is is_promoted is 1' do
    activity.is_promoted = '1'
    expect(activity.promoted?).to be true
  end

  it 'promoted? method returns false is is_promoted is 0' do
    activity.is_promoted = '0'
    expect(activity.promoted?).to be false
  end

  it 'promoted? method returns true is is_promoted is -1' do
    activity.is_promoted = '-1'
    expect(activity.promoted?).to be false
  end

  it 'has_promoted? method returns true if promote_order is available' do
    activity.promote_order = 1
    expect(activity.has_promoted?).to be true
  end

  it 'has_promoted? method returns true if promote_order is nil' do
    activity.promote_order = nil
    expect(activity.has_promoted?).to be false
  end

end
