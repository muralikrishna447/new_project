describe 'ChefStepsAdmin.Views.QuizImageUploader', ->
  beforeEach ->
    @fake_images = jasmine.createSpyObj('fake_images', ['create'])
    @view = new ChefStepsAdmin.Views.QuizImageUploader(collection: @fake_images)

  describe "#render", ->
    beforeEach ->
      spyOn(@view, 'openMultipleFilePicker')

    it "opens the filepicker dialog if no images", ->
      @fake_images.length = 0
      @view.render()
      expect(@view.openMultipleFilePicker).toHaveBeenCalled()

    it "doesn't open the dialog if images are present", ->
      @fake_images.length = 1
      @view.render()
      expect(@view.openMultipleFilePicker).not.toHaveBeenCalled()

  describe "#multipleFilePickerOnSuccess", ->
    beforeEach ->
      fpFiles = ['foo', 'bar', 'baz']
      @view.multipleFilePickerOnSuccess(fpFiles)

    it "adds each file to the collection", ->
      expect(@fake_images.create.callCount).toEqual(3)
