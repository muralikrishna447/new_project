describe 'ChefStepsAdmin.Views.Modules.FilePicker', ->
  beforeEach ->
    @view_module = ChefStepsAdmin.Views.Modules.FilePicker

  describe "#openMultipleFilePicker", ->
    beforeEach ->
      @view_module.openMultipleFilePicker()

    it "calls filepicker.pickMultiple", ->
      expect(filepicker.pickMultiple).toHaveBeenCalledWith(@view_module.filepickerOptions, @view_module.multipleFilePickerOnSuccess)

  describe "#openFilePicker", ->
    beforeEach ->
      @view_module.openFilePicker()

    it "calls filepicker.pick", ->
      expect(filepicker.pick).toHaveBeenCalledWith(@view_module.filepickerOptions, @view_module.singleFilePickerOnSuccess)

