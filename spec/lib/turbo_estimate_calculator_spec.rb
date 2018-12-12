require 'spec_helper'

describe TurboEstimateCalculator do
    steak_guide_id = '2MH313EsysIOwGcMooSSkk'
    it 'should return estimates in the correct fields when valid parameters provided' do
        test_params = {
            guide_id: steak_guide_id,
            set_point: 60,
            thickness_mm: 25.4,
            weight_g: 225,
        }
        
        estimate = TurboEstimateCalculator.new(test_params).get_estimate
        
        estimate[:error].should eq nil
        estimate[:result][:top_20_cook_time].should be_kind_of(Integer)
        estimate[:result][:bottom_20_cook_time].should be_kind_of(Integer)
        estimate[:protein_formula].should eq :steak
    end
    
    it 'should return a nil result and an error message when required params are missing' do
        estimate = TurboEstimateCalculator.new({
            # guide_id: steak_guide_id,
            set_point: 60,
            thickness_mm: 25.4,
            weight_g: 225,
        }).get_estimate
        estimate[:result].should eq nil
        estimate[:error].should eq 'missing guide_id'
        
        estimate = TurboEstimateCalculator.new({
            guide_id: steak_guide_id,
            # set_point: 60,
            thickness_mm: 25.4,
            weight_g: 225,
        }).get_estimate
        estimate[:result].should eq nil
        estimate[:error].should eq 'missing set_point'
        
        estimate = TurboEstimateCalculator.new({
            guide_id: steak_guide_id,
            set_point: 60,
            # thickness_mm: 25.4,
            weight_g: 225,
        }).get_estimate
        estimate[:result].should eq nil
        estimate[:error].should eq 'missing thickness_mm'
        
        estimate = TurboEstimateCalculator.new({
            guide_id: steak_guide_id,
            set_point: 60,
            thickness_mm: 25.4,
            # weight_g: 225,
        }).get_estimate
        estimate[:result].should eq nil
        estimate[:error].should eq 'missing weight_g'
    end
    
    it 'should return a nil result and an error message when guide has no corresponding estimate formula' do
        estimate = TurboEstimateCalculator.new({
            guide_id: 'unknown-guide-id',
            set_point: 60,
            thickness_mm: 25.4,
            weight_g: 225,
        }).get_estimate
        estimate[:result].should eq nil
        estimate[:error].should eq 'no corresponding estimate formula for guide_id: unknown-guide-id'
    end
    
    it 'should return correct bounds for the given parameters' do
        estimate = TurboEstimateCalculator.new({
            guide_id: steak_guide_id,
            set_point: 60,
            thickness_mm: 25.4,
            weight_g: 225,
        }).get_estimate
        # Hardcoded expected bounds, based on math team's expectations
        estimate[:result][:top_20_cook_time].should eq 32
        estimate[:result][:bottom_20_cook_time].should eq 24
    end
end