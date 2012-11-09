class ChefSteps.AuthForm extends Backbone.View
  events:
    'focus input': 'clearError'
    'ajax:error': 'showErrors'
    'change input#terms': 'enableSubmit'

  initialize: (options)->
    @$termsCheckbox = @$('input#terms')
    @$submitButton = @$('input[type="submit"]')

  clearError: (event)->
    $wrapper = $(event.target).parent('.input')
    $wrapper.find('p').remove()
    $wrapper.removeClass('error')

  clearErrors: ->
    @$('.error p').remove()

  showErrors: (event, xhr, status, error)->
    @clearErrors()
    allErrors = JSON.parse(xhr.responseText).errors
    _.each allErrors, (errors, field)=>
      @$("#user_#{field}_input").append('<p>' + errors[0] + '</p>').addClass('error')

  enableSubmit: (event)->
    termsAccepted = @$termsCheckbox.is(':checked')
    @$submitButton.attr('disabled', not termsAccepted)
