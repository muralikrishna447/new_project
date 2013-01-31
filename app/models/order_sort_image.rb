class OrderSortImage < ActiveRecord::Base
  belongs_to :question,
             class_name: 'OrderSortQuestion'

  has_one :image,
          as: :imageable,
          dependent: :destroy

  delegate :filename,
           :filename=,
           :url,
           :url=,
           :caption,
           :caption=,
           to: :image,
           allow_nil: true

  # TODO[dbalatero]: This is shared logic from BoxSortImage, and needs refactoring.
  def update_from_params(params)
    self.image = Image.new unless self.image.present?
    self.image.update_attributes(separate_image_params(params))
    self.save!
    self
  end

private

  def separate_image_params(params)
    {
      caption: params[:caption],
      filename: params[:filename],
      url: params[:url]
    }
  end
end
