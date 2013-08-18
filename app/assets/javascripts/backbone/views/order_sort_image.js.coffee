class ChefSteps.Views.OrderSortImage extends ChefSteps.Views.TemplatedView
  templateName: 'order_sort_image',
  tagName: 'div',
  className: 'draggable grid-item'

  initialize: (options)->
    @image = options.image

  render: =>
    @$el.html(@renderTemplate())
    @setImageId()
    @

  setImageId: ->
    @$el.attr('data-image-id', @image.id)
    @

  extendTemplateJSON: (json) ->
    json['image_id'] = @image.id
    json['image_caption'] = @image.caption
    json['image_url'] = window.cdnURL(@image.url + "/convert?fit=max&w=400&cache=true")
    json
