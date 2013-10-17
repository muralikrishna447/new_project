require 'spec_helper'

describe Equipment do
  let(:equipment) { Fabricate(:equipment, title: 'chef Knife') }
  let(:equipment2) { Fabricate(:equipment, title: 'Shun Edo Chef Knife') }
  let(:equipment3) { Fabricate(:equipment, title: 'Rusty Chef Knife') }
  let(:activity) { Fabricate(:activity, title: 'foo1') }
  let(:activity2) { Fabricate(:activity, title: 'foo2') }
  let(:activity3) { Fabricate(:activity, title: 'foo3') }

  let(:activity_equipment1) { Fabricate(:activity_equipment, activity: activity, equipment: equipment, optional: false) }
  let(:activity_equipment2) { Fabricate(:activity_equipment, activity: activity2, equipment: equipment2, optional: true) }
  let(:activity_equipment3a) { Fabricate(:activity_equipment, activity: activity3, equipment: equipment3, optional: false) }
  let(:activity_equipment3b) { Fabricate(:activity_equipment, activity: activity3, equipment: equipment2, optional: false) }

  context "concerns" do
    context "CaseInsensitiveTitle" do
      it "capitalizes the first letter of the word when equipment is created" do
        equipment.title.should == 'Chef Knife'
      end

      it "capitalizes the first letter of the word when equipment is updated" do
        equipment.update_attributes(title: 'chef knife')
        equipment.title.should == 'Chef knife'
      end
    end
  end

  describe "#titles" do
    before(:each){ 3.times{|x| Fabricate(:equipment, title: "Equipment #{x}") } }
    it "should return all equipment records" do
      Equipment.titles.size.should eq 3
    end
    it "should return an array" do
      Equipment.titles.should be_an(Array)
    end
    it "should have equipment titles in the array" do
      Equipment.titles.should eq ["Equipment 0","Equipment 1","Equipment 2"]
    end
  end

  context "merge action" do
    before(:each) do
      equipment.save
      equipment2.save
      equipment3.save
      activity.save
      activity2.save
      activity3.save
      activity_equipment1.save
      activity_equipment2.save
      activity_equipment3a.save
      activity_equipment3b.save
    end

    describe ".merge" do
      it "should return an equipment record" do
        equipment.merge([equipment,equipment2]).should be_an(Equipment)
      end

      it "should destroy the merged equipment record" do
        equipment.merge([equipment2])
        Equipment.where(id: equipment2.id).first.should be_nil
      end

      it "should replace the activity equipment for the merged equipment" do
        equipment.merge([equipment2])
        activity_equipment2.reload.equipment.should eq equipment
        activity_equipment3b.reload.equipment.should eq equipment
      end
    end

    describe ".replace_activity_equipment_with" do
      it "should change equipment2's activities to equipment 1" do
        equipment2.replace_activity_equipment_with(equipment)
        activity_equipment2.reload.equipment.should eq equipment
        activity_equipment3b.reload.equipment.should eq equipment
        activity_equipment3a.reload.equipment.should_not eq equipment
      end
    end
  end
end