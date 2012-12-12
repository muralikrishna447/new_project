ActiveAdmin.register BoxSortImage, as: "Image" do
  belongs_to :question

  controller do
    def create
      @question = Question.find(params[:question_id])
      @image = @question.images.create()
      @image.update_from_params(params)
      render json: ImagePresenter.new(@image).present
    end

    def update
      @image = BoxSortImage.find(params[:id])
      @image.update_from_params(params)
      head :ok
    end
  end
end

