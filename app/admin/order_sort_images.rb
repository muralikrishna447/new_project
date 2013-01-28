ActiveAdmin.register OrderSortImage do
  belongs_to :order_sort_question, param: :question_id
  menu false

  controller do
    def create
      @question = OrderSortQuestion.find(params[:order_sort_question_id])
      @image = @question.images.create
      @image.update_from_params(params)
      render json: ImagePresenter.new(@image).present
    end

    def update
      @image = OrderSortImage.find(params[:id])
      @image.update_from_params(params)
      head :ok
    end
  end
end
