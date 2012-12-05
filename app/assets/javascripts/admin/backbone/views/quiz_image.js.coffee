class ChefStepsAdmin.Views.QuizImage extends Backbone.View
  className: 'quiz-image'

  render: =>
    @$el.html(@make("img", {src: @imageSrc()}))
    @

  imageSrc: =>
    @addOptions(@model.get('url'))

  addOptions: (url) =>
    optionsQueryString = $.param(@imageOptions)
    "#{url}/convert?#{optionsQueryString}"

  imageOptions:
    w: 150,
    h: 150,
    fit: 'crop'

