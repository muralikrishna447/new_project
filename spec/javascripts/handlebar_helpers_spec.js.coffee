describe 'Handlebars helpers', ->

  describe '#each_with_index', ->

    it 'calls block function with item containing index and count', ->
      block = fn: (item)->
      spyOn(block, 'fn')
      Handlebars.helpers.each_with_index [{a: 1}, {b: 2}], block
      expect(block.fn.calls[0].args[0]).toEqual(a: 1, index: 0, count: 2)
      expect(block.fn.calls[1].args[0]).toEqual(b: 2, index: 1, count: 2)

    it "returns an empty string if array is undefined", ->
      expect(Handlebars.helpers.each_with_index null, null).toEqual('')

describe "#upload_button", ->
    it "returns and upload button with the id passed in", ->
      upload_button = Handlebars.helpers.upload_image_button('foo').string
      expect($(upload_button)).toHaveId('foo')
