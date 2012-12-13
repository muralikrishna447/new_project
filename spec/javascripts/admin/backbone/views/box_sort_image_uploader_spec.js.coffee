describe 'ChefStepsAdmin.Views.BoxSortImageUploader', ->
  beforeEach ->
    @fake_images = jasmine.createSpyObj('fake_images', ['create'])
    @view = new ChefStepsAdmin.Views.BoxSortImageUploader(collection: @fake_images)

  describe "#filePickerOnSuccess", ->
    beforeEach ->
      fpFiles = ['foo', 'bar', 'baz']
      @view.filePickerOnSuccess(fpFiles)

    it "adds each file to the collection", ->
      expect(@fake_images.create.callCount).toEqual(3)

