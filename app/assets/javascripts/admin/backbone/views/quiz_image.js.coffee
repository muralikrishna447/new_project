class ChefStepsAdmin.Views.QuizImage extends Backbone.View
  className: 'quiz-image'

  render: =>
    @$el.html(@make("img", {src: @imageSrc()}))
    @

  imageSrc: =>
    @convertImage(@model.get('url'))

  convertImage: (url) =>
    optionsQueryString = $.param(@imageOptions)
    "#{url}/convert?#{optionsQueryString}"

  imageOptions:
    w: 150,
    h: 150,
    fit: 'crop'

