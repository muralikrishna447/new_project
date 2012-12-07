describe 'ChefStepsAdmin.Views.QuizImage', ->
  beforeEach ->
    @view = new ChefStepsAdmin.Views.QuizImage()

  describe "#convertImage", ->
    beforeEach ->
      @view.imageOptions =
        foo: 50,
        bar: 60,
        baz: 70

    it "appends options as a query string", ->
      expect(@view.convertImage('some url')).toEqual('some url/convert?foo=50&bar=60&baz=70')

