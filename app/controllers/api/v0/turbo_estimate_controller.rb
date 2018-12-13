module Api
  module V0
    class TurboEstimateController < BaseController
      before_filter :ensure_authorized

      def get_turbo_estimate
        estimate = TurboEstimateCalculator.new(params).get_estimate
        
        if estimate[:error]
            render_api_response 400, { message: estimate[:error] }
            return
        end
        
        render_api_response 200, {
            top_20_cook_time: estimate[:result][:top_20_cook_time],
            bottom_20_cook_time: estimate[:result][:bottom_20_cook_time],
            protein_formula: estimate[:protein_formula]
        }
      end

    end
  end
end
