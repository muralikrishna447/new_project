describe 'ChefSteps.Views.AuthForm', ->
  beforeEach ->
    loadFixtures('auth_form')
    @view = new ChefSteps.Views.AuthForm(el: $('form'))
    @$input = $('form .input')
    @$terms = $('form input#terms')
    @$submit = $('form input[type="submit"]')

  describe 'showErrors', ->
    beforeEach ->
      errors = errors: name: ['bad name']
      xhr = responseText: JSON.stringify(errors)
      @view.showErrors(null, xhr)

    it 'adds error class to input', ->
      expect(@$input).toHaveClass('error')

    it 'appends error to input', ->
      expect(@$input).toHaveText('bad name')

  describe 'clearError', ->
    beforeEach ->
      @$input.addClass('error').append('<p>ERROR</p>')
      $('form input').focus()

    it 'clears error class on focus', ->
      expect(@$input).not.toHaveClass('error')

    it 'removes error on focus', ->
      expect(@$input).not.toHaveText('ERROR')

  describe 'enableSubmit', ->
    it 'is enables submit if terms are accepted', ->
      @$terms.prop('checked', true)
      @$terms.trigger('change')
      expect(@$submit).not.toHaveAttr('disabled', 'disabled')

    it 'is disables submit if terms are not', ->
      @$terms.prop('checked', false)
      @$terms.trigger('change')
      expect(@$submit).toHaveAttr('disabled', 'disabled')
