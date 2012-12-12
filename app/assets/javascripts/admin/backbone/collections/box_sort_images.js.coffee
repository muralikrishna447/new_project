class ChefStepsAdmin.Collections.BoxSortImages extends Backbone.Collection

  url: -> "images"

  updateOrder: (order) =>
    $.ajax "#{@url()}/update_order",
      type: 'POST',
      dataType: 'json'
      data: { image_order: order }

  model: ChefStepsAdmin.Models.BoxSortImage

