window.ChefSteps ||= {}
window.ChefSteps.Models ||= {}
window.ChefSteps.Views ||= {}

ChefSteps.init = ->
  _.each $('.user-form'), (form)->
    new ChefSteps.Views.AuthForm(el: form)

$ ->
  ChefSteps.init()

