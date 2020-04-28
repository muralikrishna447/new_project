module Quantity
  extend ActiveSupport::Concern

  included do
    before_save :store_quantity
  end

  def measurement
    "#{display_quantity} #{unit}"
  end

  def display_quantity=(raw_display_quantity)
    self[:display_quantity] = raw_display_quantity
    store_quantity
  end

  private

  def store_quantity
    self.quantity = BigDecimal.new(self.display_quantity || '0', 3)
  end
end
