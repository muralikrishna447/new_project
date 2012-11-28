class ChefSteps.Views.ProgressDial extends Backbone.View
  initialize: (options)->
    @$el.knob()
    setTimeout(@animateDial, 2000)

  animateDial: =>
    step = 0.2
    stepDelay = 5
    if @$el.val() < @$el.data('max')
      @$el.val(parseFloat(@$el.val()) + step).trigger('change')
      setTimeout(@animateDial, stepDelay)

