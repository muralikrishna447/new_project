class ChefStepsAdmin.Models.BoxSortImage extends Backbone.Model

  destroySuccess: => @destroy()

  getImage: => { filename: @get('filename'), url: @get('url') }

_.defaults(ChefStepsAdmin.Models.BoxSortImage.prototype, ChefStepsAdmin.Models.Modules.FilePicker)

