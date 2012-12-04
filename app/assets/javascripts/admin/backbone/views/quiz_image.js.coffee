class ChefStepsAdmin.Views.QuizImage extends Backbone.View
  className: 'quiz-image'

  initialize: (options) =>
    @model.on('change:image_url', @render, @)

  render: =>
    @$el.html(@make("img", {src: @imageSrc()}))
    @

  imageSrc: =>
    @model.get('image_url')

  addOptions: (url) =>
    optionsQueryString = $.param(@imageOptions)
    "#{url}/convert?#{optionsQueryString}"

  imageOptions:
    w: 150,
    h: 150,
    fit: 'crop'

