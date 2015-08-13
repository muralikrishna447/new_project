describe Api::V0::PagesController do

  before :each do
    @admin_user = Fabricate :user, name: 'Admin User', email: 'admin@chefsteps.com', role: 'admin'

    @page = Fabricate :page, title: 'Test Page'
    @component_1 = Fabricate :component, component_type: 'hero'
    @component_2 = Fabricate :component, component_type: 'matrix'
    @component_3 = Fabricate :component, component_type: 'matrix'
    @component_page_1 = Fabricate :component_page, component: @component_1, page: @page, position: 3
    @component_page_2 = Fabricate :component_page, component: @component_2, page: @page, position: 2
    @component_page_3 = Fabricate :component_page, component: @component_3, page: @page, position: 5

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
    page = JSON.parse(response.body)
    page['title'].should eq('Test Page')
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
      { id: @component_page_1.id, position: 1 },
      { id: @component_page_2.id, position: 2 },
      { id: @component_page_3.id, position: 3 }
    ]
    page = {
      title: 'Sous Vide',
      components: components
    }
    post :update, id: @page.id, page: page
    response.should be_success
    page = JSON.parse(response.body)
    page['title'].should eq('Sous Vide')
    page['components'].first['id'].should eq(@component_page_1.id)
    page['components'].last['id'].should eq(@component_page_3.id)
  end
end
