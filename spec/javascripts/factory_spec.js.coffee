class TestClass
  constructor: (@a, @b) ->

describe 'ChefSteps.new', ->
  beforeEach ->
    @subject = ChefSteps.new TestClass, 'a', 'b'

  it 'should construct TestClass', ->
    expect(@subject instanceof TestClass).toBeTruthy()

  it 'should assign the args', ->
    expect(@subject.a).toEqual('a')
    expect(@subject.b).toEqual('b')

