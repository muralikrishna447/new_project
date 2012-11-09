window.ChefSteps = window.ChefSteps || {}

ChefSteps.init = ->
  _.each $('.user-form'), (form)->
    new ChefSteps.AuthForm(el: $(form))

$ ->
  ChefSteps.init()

