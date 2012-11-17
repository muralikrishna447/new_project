describe 'ChefSteps.Models.Profile', ->
  it "point to profile URL", ->
    model = new ChefSteps.Models.Profile(id: 1)
    expect(model.url()).toEqual('/profiles/1')

  it "returns human friendly chef type for known chef type", ->
    model = new ChefSteps.Models.Profile(chef_type: 'professional_chef')
    expect(model.chefType()).toEqual('Professional Chef')

  it "returns empty string for unknown chef type", ->
    model = new ChefSteps.Models.Profile(chef_type: 'unknown')
    expect(model.chefType()).toEqual('')

