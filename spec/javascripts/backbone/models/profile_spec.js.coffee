describe 'ChefSteps.Models.Profile', ->
  it "point to profile URL", ->
    model = new ChefSteps.Models.Profile(id: 1)
    expect(model.url()).toEqual('/profiles/1')

