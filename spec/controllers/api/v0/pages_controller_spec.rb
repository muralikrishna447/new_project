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

  describe 'Json Data' do
    before(:each) do
      Component.delete_all
      @page = Fabricate :page, title: 'Fresh Page'
      @data = JSON.parse(File.read("#{Rails.root}/spec/fixtures/sample_page_component_data.json"))
    end

    it 'should create a page with components' do
      post :update, id: @page.id, page: @data
      page = JSON.parse(response.body)
      response.should be_success
      page['components'].count.should eq(@data['components'].count)
      page['title'].should eq(@data['title'])
      @page.components.map(&:component_type).compact.should_not be_blank
    end

    it 'should check component meta key as camelcase' do
      post :update, id: @page.id, page: @data
      response.should be_success
      @page.components[1].meta['items'].first['content'].keys.should eq(@data['components'][1]['meta']['items'].first['content'].keys)
      @page.components[5].meta['items'].first['content'].keys.should eq(@data['components'][5]['meta']['items'].first['content'].keys)
      hero_component_data = @page.components.where(component_type: 'hero').first.meta['items'][0]['content']
      hero_component_data['youtubeId'].should_not be_blank
      @page.components[5].meta['items'].first['content'].values.should eq(@data['components'][5]['meta']['items'].first['content'].values)
      return_keys = %w[title description image url buttonMessage heroType alignType]
      request_component = @data['components'][1]['meta']['items'].first['content']
      hero_component_data.select{|k, _v| return_keys.include? k}.values.should eq(request_component.select{|k, _v| return_keys.include? k}.values)

      post :update, id: @page.id, page: @data.deep_transform_keys{ |key| key.to_s.underscore }
      page = JSON.parse(response.body)
      response.should be_success
      page['components'][1]['meta']['items'].first['content'].keys.should_not eq(@data['components'][1]['meta']['items'].first['content'].keys)
    end

    it 'should check all components meta data values' do
      post :update, id: @page.id, page: @data
      response.should be_success
      @page.components.length.times.each do |index|
        verify_big_data(
            @page.components[index].meta,
            @data['components'][index]['meta']
        )
      end
    end

    it 'should accept only page & components whitelisted attributes' do
      @data['invalid_column'] = 'test'
      @data['components'][0]['invalid_column'] = 'test'
      @data['components'][6]['invalid_column'] = 'unwanted'
      post :update, id: @page.id, page: @data
      response.should be_success
      page = JSON.parse(response.body)
      page['shortDescription'].should eq(@data['shortDescription'])
      @page.components.length.times.each do |index|
        verify_big_data(
            @page.components[index].meta,
            @data['components'][index]['meta']
        )
      end
    end

    it 'should accept component meta data with all keys and value as given' do
      @data['components'][0]['meta']['NewKey'] = 'Test'
      @data['components'][0]['meta']['new_key'] = 'test'
      @data['components'][1]['meta']['items'][0]['content']['NewContent'] = 'First Recipe'
      @data['components'][1]['meta']['items'][0]['content']['new_content'] = 'Second Recipe'
      post :update, id: @page.id, page: @data
      response.should be_success
      @page.components[0].meta['NewKey'].should eq(@data['components'][0]['meta']['NewKey'])
      @page.components[0].meta['new_key'].should eq(@data['components'][0]['meta']['new_key'])
      @page.components[1].meta['items'][0]['content']['NewContent'].should eq(@data['components'][1]['meta']['items'][0]['content']['NewContent'])
      @page.components[1].meta['items'][0]['content']['new_content'].should eq(@data['components'][1]['meta']['items'][0]['content']['new_content'])
    end

    it 'should accept component destroy key' do
      @data['components'][0]['_destroy'] = true
      post :update, id: @page.id, page: @data
      response.should be_success
      page = JSON.parse(response.body)
      page['components'].count.should eq(@data['components'].count - 1 )
    end

    it 'should check components meta data minimum properties' do
      post :update, id: @page.id, page: @data
      response.should be_success
      @page.components.map(&:meta).should_not be_blank
      @page.components.map(&:meta).compact.count.should eq(@data['components'].map{|c| c['meta']}.compact.count)
      @page.components.where(component_type: 'banner').last.meta['items'][0]['content']['customButton'].keys.should eq(%w[type theme title url])
    end

    it 'should return error for component type blank' do
      @data['components'] << { 'id': '', "componentType": nil }
      post :update, id: @page.id, page: @data
      response.should_not be_success
      response.code.should == '500'
    end

    it 'should return 404 for pages not found by id' do
      post :update, id: 122, page: @data
      response.should_not be_success
    end

    it 'should not update a page if components do not exist' do
      @data['components'] << { id: 1111, position: 20 }
      post :update, id: @page.id, page: @data
      response.should_not be_success
    end
  end

  private

  def verify_big_data(response, request)
    case request.class.name
    when 'String'
      request.should eq response
    when 'Fixnum', 'TrueClass', 'FalseClass'
      request.to_s.should eq response.to_s
    when 'Hash'
      request.each_pair do |key, _|
        verify_big_data(response[key], request[key])
      end
    when 'Array'
      request.length.times.each do |index|
        verify_big_data(response[index], request[index])
      end
    else
      raise 'Invalid data'
    end
  end

end
