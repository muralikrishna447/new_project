window.ChefStepsAdmin ||= {}

ChefStepsAdmin.Models ||= {}
ChefStepsAdmin.Collections ||= {}
ChefStepsAdmin.Views ||= {}

Handlebars.templates ||= {}

ChefStepsAdmin.init = ->
  ChefStepsAdmin.router = new ChefStepsAdmin.Router()
  ChefStepsAdmin.router.initializeRoutes()
  ChefStepsAdmin.router.parse(window.location.pathname + window.location.search)

$ ->
  ChefStepsAdmin.init()
