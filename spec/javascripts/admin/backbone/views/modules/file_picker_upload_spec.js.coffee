describe 'ChefStepsAdmin.Views.Modules.FilePickerUpload', ->
  beforeEach ->
    @view_module = ChefStepsAdmin.Views.Modules.FilePickerUpload

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

  describe "#multipleFilePickerOnSuccess", ->
    it "throws an NotImplementedError", ->
      expect(@view_module.multipleFilePickerOnSuccess).toThrow("NotImplementedError")

  describe "#singleFilePickerOnSuccess", ->
    it "throws an NotImplementedError", ->
      expect(@view_module.singleFilePickerOnSuccess).toThrow("NotImplementedError")

