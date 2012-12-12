ActiveAdmin.register BoxSortImage, as: "Image" do
  belongs_to :question

  controller do
    def create
      @question = Question.find(params[:question_id])
      @image = @question.images.create
      @image.update_from_params(params)
      render json: ImagePresenter.new(@image).present
    end

    def update
      @image = BoxSortImage.find(params[:id])
      @image.update_from_params(params)
      head :ok
    end
  end

  collection_action :update_order, method: :post do
    @question = Question.find(params[:question_id])
    Rails.logger.info "****** Image order: #{params[:image_order]}"
    # @question.update_image_order(params[:image_order])
    head :ok
  end
end

