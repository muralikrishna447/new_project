window.ChefStepsAdmin ||= {}

ChefStepsAdmin.Models ||= {}
ChefStepsAdmin.Models.Modules ||= {}
ChefStepsAdmin.Collections ||= {}
ChefStepsAdmin.Views ||= {}
ChefStepsAdmin.Views.Modules ||= {}

Handlebars.templates ||= {}

ChefStepsAdmin.init = ->
  ChefStepsAdmin.router = new ChefStepsAdmin.Router()
  ChefStepsAdmin.router.initializeRoutes()
  ChefStepsAdmin.router.parse(window.location.pathname + window.location.search)

$ ->
  ChefStepsAdmin.init()
