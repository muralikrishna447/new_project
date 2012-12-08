describe 'ChefStepsAdmin.Views.QuizImagesUploader', ->
  beforeEach ->
    @fake_images = jasmine.createSpyObj('fake_images', ['create'])
    @view = new ChefStepsAdmin.Views.QuizImagesUploader(collection: @fake_images)

  describe "#render", ->
    beforeEach ->
      spyOn(@view, 'openFilePicker')

    it "opens the filepicker dialog if no images", ->
      @fake_images.length = 0
      @view.render()
      expect(@view.openFilePicker).toHaveBeenCalled()

    it "doesn't open the dialog if images are present", ->
      @fake_images.length = 1
      @view.render()
      expect(@view.openFilePicker).not.toHaveBeenCalled()

  describe "#filePickerOnSuccess", ->
    beforeEach ->
      fpFiles = ['foo', 'bar', 'baz']
      @view.filePickerOnSuccess(fpFiles)

    it "adds each file to the collection", ->
      expect(@fake_images.create.callCount).toEqual(3)
