describe 'Handlebars helpers', ->

  describe '#each_with_index', ->

    it 'calls block function with item containing index and count', ->
      block = fn: (item)->
      spyOn(block, 'fn')
      Handlebars.helpers.each_with_index [{a: 1}, {b: 2}], block
      expect(block.fn.calls[0].args[0]).toEqual(a: 1, index: 0, count: 2)
      expect(block.fn.calls[1].args[0]).toEqual(b: 2, index: 1, count: 2)

  describe '#answer_width', ->
    it 'returns .span4 if answer count is modulo 3', ->
      expect(Handlebars.helpers.answer_width(3*1)).toEqual('span3')
      expect(Handlebars.helpers.answer_width(3*2)).toEqual('span3')
      expect(Handlebars.helpers.answer_width(3*3)).toEqual('span3')

    it 'returns .span6 if answer count is not modulo 3', ->
      expect(Handlebars.helpers.answer_width(1)).toEqual('span5')
      expect(Handlebars.helpers.answer_width(2)).toEqual('span5')
      expect(Handlebars.helpers.answer_width(4)).toEqual('span5')
