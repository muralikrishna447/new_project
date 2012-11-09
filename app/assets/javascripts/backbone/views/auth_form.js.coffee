class ChefSteps.AuthForm extends Backbone.View
  events:
    'focus input': 'clearError'
    'change input#terms': 'enableSubmit'

  initialize: (options)->
    @$termsCheckbox = @$('input#terms')
    @$submitButton = @$('input[type="submit"]')

  clearError: (event)->
    $wrapper = $(event.target).parent('.input')
    $wrapper.find('p').remove()
    $wrapper.removeClass('error')

  enableSubmit: (event)->
    termsAccepted = @$termsCheckbox.is(':checked')
    @$submitButton.attr('disabled', not termsAccepted)
