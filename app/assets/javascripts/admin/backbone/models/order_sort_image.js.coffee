class ChefStepsAdmin.Models.OrderSortImage extends Backbone.Model

  destroySuccess: => @destroy()

  getImage: => { filename: @get('filename'), url: @get('url') }

_.defaults(ChefStepsAdmin.Models.OrderSortImage.prototype, ChefStepsAdmin.Models.Modules.FilePicker)
