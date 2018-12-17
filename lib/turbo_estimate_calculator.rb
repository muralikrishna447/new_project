class TurboEstimateCalculator

    @@steak_guide_ids = ["2MH313EsysIOwGcMooSSkk"]
    @@test_guide_id = "3SI1nKyKQMqGWa2WqqoCEi" # Cryo oranges guide
    
    def initialize(params)
        @guide_id = params[:guide_id]
        @set_point = params[:set_point] && params[:set_point].to_f
        @thickness_mm = params[:thickness_mm] && params[:thickness_mm].to_f
        @weight_g = params[:weight_g] && params[:weight_g].to_f
    end
    
    # TODO: This is a placeholder estimate formula, for more information, see:
    # https://docs.google.com/document/d/11o4V6iu4x0mgdXgNp8xGdJjSrIrZy1FgJRaQBvG5tWg
    def get_steak_estimate
        top_20_cook_time =    5.49 + 0.0*@thickness_mm + 0.0391*@thickness_mm**2 + 0.0041*@weight_g + 0.0*@set_point
        bottom_20_cook_time = 5.49 + 0.0*@thickness_mm + 0.0277*@thickness_mm**2 + 0.0041*@weight_g + 0.0*@set_point
        return {
            top_20_cook_time: top_20_cook_time.round,
            bottom_20_cook_time: bottom_20_cook_time.round
        }
    end
    
    # Our test guide estimate is used by devs to test the turbo lifecycle in around 2 mintues instead of ~20
    def get_test_guide_estimate
        return {
            top_20_cook_time: 2,
            bottom_20_cook_time: 1
        }
    end

    def get_estimate
        # Validation
        if !@guide_id
            return { error: 'missing guide_id' }
        elsif !@set_point
            return { error: 'missing set_point' }
        elsif !@thickness_mm
            return { error: 'missing thickness_mm' }
        elsif !@weight_g
            return { error: 'missing weight_g' }
        end
        
        if @@steak_guide_ids.include?(@guide_id)
            return { result: get_steak_estimate, protein_formula: :steak }
        elsif @guide_id == @@test_guide_id
            return { result: get_test_guide_estimate, protein_formula: :test_citrus_reticulata }
        else
            return { error: "no corresponding estimate formula for guide_id: #{@guide_id}" }
        end
    end
    
end