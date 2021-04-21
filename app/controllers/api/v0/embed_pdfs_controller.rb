module Api
  module V0
    class EmbedPdfsController < BaseController
      def show
        begin
          @embed_pdf = EmbedPdf.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          return render_api_response 404, {message: 'EmbedPdf not found'}
        end
        render json: @embed_pdf, serializer: Api::EmbedPdfSerializer
      end
    end
  end
end
