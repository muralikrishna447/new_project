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

  describe '#option_width', ->
    it "returns 'span3' if answer count is modulo 3", ->
      expect(Handlebars.helpers.option_width(3*1)).toEqual('span3')
      expect(Handlebars.helpers.option_width(3*2)).toEqual('span3')
      expect(Handlebars.helpers.option_width(3*3)).toEqual('span3')

    it "returns 'span3 offset1' if answer count is not modulo 3", ->
      expect(Handlebars.helpers.option_width(1)).toEqual('span3 offset1')
      expect(Handlebars.helpers.option_width(2)).toEqual('span3 offset1')
      expect(Handlebars.helpers.option_width(4)).toEqual('span3 offset1')

describe "#upload_button", ->
    it "returns and upload button with the id passed in", ->
      upload_button = Handlebars.helpers.upload_image_button('foo').string
      expect($(upload_button)).toHaveId('foo')
