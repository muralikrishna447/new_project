module ApplicationHelper
  def quantity_number(quantity)
    number_with_precision(quantity, precision: 2, strip_insignificant_zeros: true)
  end
end

