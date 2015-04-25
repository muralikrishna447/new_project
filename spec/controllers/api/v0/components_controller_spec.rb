describe Api::V0::ComponentsController do

  before :each do
    @component = Fabricate :component, id: 1, component_type: 'list', mode: 'api', metadata: { source: 'http://www.somelink.com' }
  end

  # GET /api/v0/component/:id
  it 'should return a component' do
    get :show, id: @component.id
    response.should be_success
    component = JSON.parse(response.body)
    component['componentType'].should eq('list')
  end

end
