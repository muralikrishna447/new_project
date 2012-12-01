class ChefSteps.Views.Checkbox extends Backbone.View
  events:
    'click': 'select'

  initialize: (options)->
    @radio = @$el.data('behavior') == 'radio'

    @$input = @$('input')

    @$el.toggleClass('active', @isChecked())

  select: (event)->
    if @isChecked()
      @$input.removeAttr('checked')
    else
      @$input.attr('checked', true)
    @$el.toggleClass('active', @isChecked())
    @clearOthers() if @radio

  isChecked: ->
    @$input.attr('checked') && true || false

  clearOthers: ->
    otherInputs = $("[name='#{@$input.attr('name')}']").not(@$input)
    otherInputs.removeAttr('checked')
    otherInputs.parent().removeClass('active')

