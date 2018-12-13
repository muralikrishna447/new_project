require 'spec_helper'

describe TurboEstimateCalculator do
    steak_guide_id = '2MH313EsysIOwGcMooSSkk'
    
    steak_expected_outputs = [
        {
            input: {
                guide_id: steak_guide_id,
                thickness_mm: 25.4,
                set_point: 55.0,
                weight_g: 300,
            },
            output: {
                bottom_20_cook_time: 25,
                top_20_cook_time: 32,
            }
        },
        {
            input: {
                guide_id: steak_guide_id,
                thickness_mm: 50.8,
                set_point: 55.0,
                weight_g: 600,
            },
            output: {
                bottom_20_cook_time: 79,
                top_20_cook_time: 109,
            }
        }
    ]
    
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
    
    # https://docs.google.com/document/d/11o4V6iu4x0mgdXgNp8xGdJjSrIrZy1FgJRaQBvG5tWg
    it 'Steak: should return correct bounds for the given parameters provided by the Math team' do
        steak_expected_outputs.each do |expectation|
            estimate = TurboEstimateCalculator.new(expectation[:input]).get_estimate
            # Hardcoded expected bounds, based on math team's expectations
            estimate[:result][:top_20_cook_time].should eq expectation[:output][:top_20_cook_time]
            estimate[:result][:bottom_20_cook_time].should eq expectation[:output][:bottom_20_cook_time]
        end
    end
end