class BoxSortImage < ActiveRecord::Base

  belongs_to :question, class_name: 'BoxSortQuestion'
  has_one :image, as: :imageable

  delegate :filename, :filename=, :url, :url=, :caption=, :caption, to: :image, allow_nil: true

  attr_accessible :key_image, :key_rationale, :question_id

  def update_from_params(params)
    self.image = Image.new unless self.image.present?
    self.image.update_attributes(separate_image_params(params))
    self.update_attributes(separate_box_sort_params(params))
    self
  end

  private

  def separate_box_sort_params(params)
    {
      key_image: params[:key_image],
      key_rationale: params[:key_rationale]
    }
  end

  def separate_image_params(params)
    {
      caption: params[:caption],
      filename: params[:filename],
      url: params[:url]
    }
  end
end

