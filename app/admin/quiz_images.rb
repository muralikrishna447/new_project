ActiveAdmin.register QuizImage, as: "Image" do
  belongs_to :quiz

  controller do
    def create
      @quiz = Quiz.find(params[:quiz_id])

      @image = @quiz.images.create(get_attributes(params))

      render json: ImagePresenter.new(@image).present
    end

    def update
      @image = QuizImage.find(params[:id])
      @image.update_attributes(get_attributes(params))
      render json: ImagePresenter.new(@image).present
    end

    private

    def get_attributes(params)
      {
       caption: params[:caption],
       filename: params[:filename],
       url: params[:url]
      }
    end
  end
end

