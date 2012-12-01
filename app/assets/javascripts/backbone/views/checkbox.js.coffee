class ChefSteps.Views.Checkbox extends Backbone.View
  events:
    'click': 'select'

  initialize: (options)->
    @radio = @$el.data('behavior') == 'radio'

    @$input = @$('input')

    checked = @$input.attr('checked') && true || false
    @$el.toggleClass('active', checked)

  select: ->
    if @radio
      otherInputs = $("[name='#{@$input.attr('name')}']")
      otherInputs.removeAttr('checked')
      otherInputs.parent().removeClass('active')

    @$input.attr('checked', true)
    @$el.addClass('active')
