describe 'ChefSteps.Views.Checkbox', ->
  beforeEach ->
    loadFixtures('checkboxes')

  describe 'checkboxes', ->
    beforeEach ->
      @checkbox1 = new ChefSteps.Views.Checkbox(el: '#checkboxes > div:first')
      @checkbox2 = new ChefSteps.Views.Checkbox(el: '#checkboxes > div:last')

    it 'initializes radio attribute to false if behavior attribute is not radio', ->
      expect(@checkbox1.isRadio).toBe(false)

    it 'adds active class if input is checked', ->
      expect(@checkbox1.$el).not.toHaveClass('active')
      expect(@checkbox2.$el).toHaveClass('active')

    describe 'on select', ->
      beforeEach ->
        @checkbox1.select()

      it "sets input's checked attribute", ->
        expect(@checkbox1.$input).toHaveAttr('checked')

      it "sets active class", ->
        expect(@checkbox1.$el).toHaveClass('active')

      it 'does not clear other checkbox', ->
        expect(@checkbox2.$el).toHaveClass('active')
        expect(@checkbox2.$input).toHaveAttr('checked')

      it 'clears itself when selected again', ->
        @checkbox1.select()
        expect(@checkbox1.$el).not.toHaveClass('active')
        expect(@checkbox1.$input).not.toHaveAttr('checked')

  describe 'radio buttons', ->
    beforeEach ->
      @radio1 = new ChefSteps.Views.Checkbox(el: '#radios > div:first')
      @radio2 = new ChefSteps.Views.Checkbox(el: '#radios > div:last')

    it 'initializes radio attribute to true if behavior attribute is radio', ->
      expect(@radio1.isRadio).toBe(true)

    it 'adds active class if input is checked', ->
      expect(@radio1.$el).not.toHaveClass('active')
      expect(@radio2.$el).toHaveClass('active')

    describe 'on select', ->
      beforeEach ->
        @radio1.select()

      it "sets input's checked attribute", ->
        expect(@radio1.$input).toHaveAttr('checked')

      it "sets active class", ->
        expect(@radio1.$el).toHaveClass('active')

      it 'clears other radio button', ->
        expect(@radio2.$el).not.toHaveClass('active')
        expect(@radio2.$input).not.toHaveAttr('checked')

      it 'clears itself when selected again', ->
        @radio1.select()
        expect(@radio1.$el).not.toHaveClass('active')
        expect(@radio1.$input).not.toHaveAttr('checked')
