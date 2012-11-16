class ChefSteps.Views.TemplatedView extends Backbone.View

  getTemplate: =>
    throw new Error("NoTemplateSpecifiedError") unless @templateName

    name = "templates/#{@templateName}"
    @template ||= Handlebars.templates[name]


  setupTemplate: =>
    @getTemplate()
    @getTemplateJSON()

  getTemplateJSON: =>
    templateJSON = {}
    templateJSON = @model.toJSON() if @model
    templateJSON

  renderTemplate: =>
    templateJSON = @setupTemplate()
    @template(templateJSON)

