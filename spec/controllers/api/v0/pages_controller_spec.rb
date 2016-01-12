describe Api::V0::PagesController do

  before :each do
    @admin_user = Fabricate :user, name: 'Admin User', email: 'admin@chefsteps.com', role: 'admin'

    @page = Fabricate :page, title: 'Test Page'
    @component_1 = Fabricate :component, id: 1, component_type: 'hero', component_parent: @page, position: 4
    @component_2 = Fabricate :component, id: 2, component_type: 'matrix', component_parent: @page, position: 5
    @component_3 = Fabricate :component, id: 3, component_type: 'matrix', component_parent: @page, position: 6

    sign_in @admin_user
    controller.request.env['HTTP_AUTHORIZATION'] = @admin_user.valid_website_auth_token.to_jwt
  end

  # GET /api/v0/pages
  it 'should get an index of components' do
    get :index
    response.should be_success
  end

  # GET /api/v0/pages/:id
  it 'should get a page' do
    get :show, id: @page.id
    response.should be_success
    JSON.parse(response.body)['title'].should eq(@page.title)
  end

  it 'should get a page by slug' do
    get :show, id: @page.slug
    response.should be_success
    JSON.parse(response.body)['title'].should eq(@page.title)
  end

  it 'should return 404 for pages not found by id' do
    get :show, id: 9999
    response.code.should == '404'
  end

  it 'should return 404 for pages not found by slug' do
    get :show, id: 'doesnt-exist'
    response.code.should == '404'
  end

  # POST /api/v0/pages
  it 'should create a page' do
    post :create, page: { title: 'Another Page'}
    response.should be_success
    page = JSON.parse(response.body)
    page['title'].should eq('Another Page')
  end

  # PUT /api/v0/pages/:id
  it 'should update a page' do
    put :update, id: @page.id, page: { title: 'Sous Vide' }
    response.should be_success
    page = JSON.parse(response.body)
    page['title'].should eq('Sous Vide')
  end

  it 'should update a page with a new comonent_page association' do
    components = [
      { id: @component_1.id, position: 1 },
      { id: @component_2.id, position: 2 },
      { id: @component_3.id, position: 3 }
    ]
    page = {
      title: 'Sous Vide',
      components: components
    }
    post :update, id: @page.id, page: page
    response.should be_success
    page = JSON.parse(response.body)
    page['title'].should eq('Sous Vide')
    page['components'].first['id'].should eq(@component_1.id)
    page['components'].last['id'].should eq(@component_3.id)
  end

  it 'should not update a page if components do not exist' do
    components = [
      { id: @component_1.id, position: 1 },
      { id: @component_2.id, position: 2 },
      { id: @component_3.id, position: 3 },
      { id: 99999, position: 4 }
    ]
    page = {
      title: 'Sous Vide',
      components: components
    }
    post :update, id: @page.id, page: page
    response.should_not be_success
  end

  it 'should remove a component' do
    components = [
      { id: @component_1.id, position: 1 },
      { id: @component_2.id, position: 2 },
      { id: @component_3.id, position: 3, _destroy: true }
    ]
    page = {
      title: 'Sous Vide',
      components: components
    }
    post :update, id: @page.id, page: page
    response.should be_success
    page = JSON.parse(response.body)
    puts page
    page['components'].count.should eq(2)
  end
end
