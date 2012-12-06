describe 'ChefStepsAdmin.Views.Modules.FilePickerDisplay', ->
  beforeEach ->
    @view_module = ChefStepsAdmin.Views.Modules.FilePickerDisplay

  describe "#convertImage", ->
    beforeEach ->
      @view_module.imageOptions =
        foo: 50,
        bar: 60,
        baz: 70

    it "appends options as a query string", ->
      expect(@view_module.convertImage('some url')).toEqual('some url/convert?foo=50&bar=60&baz=70')

