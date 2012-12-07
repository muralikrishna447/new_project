describe 'ChefStepsAdmin.Views.Modules.FilePickerUpload', ->
  beforeEach ->
    @view_module = ChefStepsAdmin.Views.Modules.FilePickerUpload

  describe "#openFilePicker", ->
    it "when filePickerType is single, calls filepicker.pick", ->
      spyOn(@view_module, 'getFilePickerType').andReturn(@view_module.singlePickerType)
      @view_module.openFilePicker()
      expect(filepicker.pick).toHaveBeenCalledWith(@view_module.filepickerOptions, @view_module.filePickerOnSuccess)

    it "when filePickerType is multiple, calls filepicker.pickMultiple", ->
      spyOn(@view_module, 'getFilePickerType').andReturn(@view_module.multiplePickerType)
      @view_module.openFilePicker()
      expect(filepicker.pickMultiple).toHaveBeenCalledWith(@view_module.filepickerOptions, @view_module.filePickerOnSuccess)

  describe "#filePickerOnSuccess", ->
    it "throws an NotImplementedError", ->
      expect(@view_module.filePickerOnSuccess).toThrow("NotImplementedError")

