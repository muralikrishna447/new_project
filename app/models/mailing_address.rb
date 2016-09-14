class MailingAddress

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :address1, :address2, :city, :province, :zip

  validates :address1, :city, :province, :zip, presence: true
  validates :address1, :address2, length: {maximum: 50}
  validates :zip, numericality: { only_integer: true }
  validates :province, length: { is: 2 }

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
  
end
