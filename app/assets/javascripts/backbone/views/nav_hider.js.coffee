class ChefSteps.Views.NavHider extends Backbone.View
  initialize: (options)->
    $(options.showElement).click(@showOrHide)

  showOrHide: =>
    console.log @$('#header')
    if @$('#header').is(':visible')
      @hide()
    else
      @show()

  hide: =>
    @$('#header').slideUp()
    @$('#footer').fadeOut()

  show: =>
    @$('#header').slideDown()
    @$('#footer').fadeIn()
