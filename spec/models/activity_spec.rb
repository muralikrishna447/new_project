require 'spec_helper'

describe Activity do
  let(:activity) { Activity.create(title: 'foo') }

  describe "#update_equipment" do
    let(:equipment1) { {title: 'Blender', product_url: 'over the rainbow', optional: "true"}  }
    let(:equipment2) { {title: 'Spoon', product_url: '', optional: "false"}  }
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
        activity.equipment.first.product_url.should == 'over the rainbow'
        activity.equipment.first.optional.should == true
      end
    end

    describe "update" do
      before do
        activity.update_equipment(equipment_attrs)
        equipment_attrs.first.merge!(product_url: 'stuff', optional: 'false')
        activity.update_equipment(equipment_attrs)
        activity.equipment.reload
      end

      it "updates existing equipment" do
        activity.equipment.should have(2).equipment
        activity.equipment.first.title.should == 'Blender'
        activity.equipment.first.product_url.should == 'stuff'
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
        activity.equipment.first.product_url.should == ''
        activity.equipment.first.optional.should == false
      end
    end
  end
end

