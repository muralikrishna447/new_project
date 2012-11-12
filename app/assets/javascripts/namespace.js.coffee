window.ChefSteps ||= {}
window.ChefSteps.Models ||= {}
window.ChefSteps.Views ||= {}

ChefSteps.init = (options)->
  _.each $('.user-form'), (form)->
    new ChefSteps.Views.AuthForm(el: form)

