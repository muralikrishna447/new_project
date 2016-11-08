module Fulfillment
  class Fulfillable
    attr_reader :order

    attr_reader :line_items

    def initialize(params = {})
      @order = params[:order]
      @line_items = params[:line_items]
    end

    def ==(other)
      order == other.order && line_items == other.line_items
    end
  end
end
