describe Api::V0::ComponentsController do

  before :each do
    @component = Fabricate :component, component_type: 'list', mode: 'api', metadata: { source: 'http://www.somelink.com' }
  end

  # GET /api/v0/component/:id
  it 'should get a component' do
    get :show, id: @component.id
    response.should be_success
    component = JSON.parse(response.body)
    component['componentType'].should eq('list')
  end

  it 'should create a component' do
    post :create, component: { component_type: 'list', mode: 'api'}
    response.should be_success
    component = JSON.parse(response.body)
    component['componentType'].should eq('list')
  end

  it 'should update a component' do
    post :update, id: @component.id, component: { mode: 'custom' }
    response.should be_success
    component = JSON.parse(response.body)
    component['mode'].should eq('custom')
  end

end
