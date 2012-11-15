class ChefSteps.Views.TemplatedView extends Backbone.View

  getTemplate: =>
    throw new Error("NoTemplateSpecifiedError") unless @templateName

    name = "templates/#{@templateName}"
    @template ||= Handlebars.templates[name]

