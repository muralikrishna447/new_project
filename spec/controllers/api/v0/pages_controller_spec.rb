describe Api::V0::PagesController do

  before :each do
    @admin_user = Fabricate :user, name: 'Admin User', email: 'admin@chefsteps.com', role: 'admin'
    @page = Fabricate :page, title: 'Test Page'
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
    post :update, id: @page.id, page: { title: 'Sous Vide' }
    response.should be_success
    page = JSON.parse(response.body)
    page['title'].should eq('Sous Vide')
  end
end
