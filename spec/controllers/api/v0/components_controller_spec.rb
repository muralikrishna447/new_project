describe Api::V0::ComponentsController do

  before :each do
    @admin_user = Fabricate :user, name: 'Admin User', email: 'admin@chefsteps.com', role: 'admin'
    @component = Fabricate :component, component_type: 'matrix', meta: { size: 'standard' }
    sign_in @admin_user
  end

  # GET /api/v0/components
  it 'should get an index of components' do
    get :index
    response.should be_success
  end

  # GET /api/v0/components/:id
  it 'should get a component' do
    get :show, id: @component.id
    response.should be_success
    component = JSON.parse(response.body)
    component['componentType'].should eq('matrix')
  end

  # POST /api/v0/components
  it 'should create a component' do
    post :create, component: { component_type: 'matrix'}
    response.should be_success
    component = JSON.parse(response.body)
    puts component
    component['componentType'].should eq('matrix')
  end

  # PUT /api/v0/components/:id
  it 'should update a component' do
    post :update, id: @component.id, component: { component_type: 'madlib' }
    response.should be_success
    component = JSON.parse(response.body)
    component['componentType'].should eq('madlib')
  end
end
