require 'spec_helper'

describe Api::V0::ComponentsController do

  context 'authenticated user is admin role' do
    before :each do
      @admin_user = Fabricate :user, name: 'Admin User', email: 'admin@chefsteps.com', role: 'admin'
      @component = Fabricate :component, component_type: 'matrix', meta: {size: 'standard'}, name: 'myComponent'
      sign_in @admin_user
      controller.request.env['HTTP_AUTHORIZATION'] = @admin_user.valid_website_auth_token.to_jwt
    end

    # GET /api/v0/components
    it 'should get an index of components' do
      get :index
      response.should be_success
    end

    # GET /api/v0/components/:id
    it 'should get a component by id' do
      get :show, id: @component.id
      response.should be_success
      component = JSON.parse(response.body)
      component['componentType'].should eq('matrix')
    end

    # GET /api/v0/components/:slug
    it 'should get a component by slug' do
      get :show, id: @component.slug
      response.should be_success
      component = JSON.parse(response.body)
      component['componentType'].should eq('matrix')
    end

    # GET /api/v0/components/:id
    it 'should return 404 when component not found by id' do
      get :show, id: 9999
      response.code.should == '404'
    end

    # GET /api/v0/components/:slug
    it 'should return 404 when component not found by slug' do
      get :show, id: 'not-a-slug'
      response.code.should == '404'
    end

    # POST /api/v0/components
    it 'should create a component' do
      post :create, component: {component_type: 'matrix'}
      response.should be_success
      component = JSON.parse(response.body)
      puts component
      component['componentType'].should eq('matrix')
    end

    # PUT /api/v0/components/:id
    it 'should update a component' do
      post :update, id: @component.id, component: {component_type: 'madlib'}
      response.should be_success
      component = JSON.parse(response.body)
      component['componentType'].should eq('madlib')
    end

    # DELETE /api/v0/components/:id
    it 'should destroy a component' do
      post :destroy, id: @component.id
      response.should be_success
    end
  end

  context 'authenticated user is user role' do
    before :each do
      @user = Fabricate :user, name: 'Normal User', email: 'user@chefsteps.com', role: 'user'
      @component = Fabricate :component, component_type: 'matrix', meta: {size: 'standard'}, name: 'myComponent'
      sign_in @user
      controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
    end

    # GET /api/v0/components/:id
    it 'should get a component by id' do
      get :show, id: @component.id
      response.should be_success
      component = JSON.parse(response.body)
      component['componentType'].should eq('matrix')
    end

    # POST /api/v0/components
    it 'should fail to create a component' do
      post :create, component: {component_type: 'matrix'}
      response.code.should == '401'
    end

    # PUT /api/v0/components/:id
    it 'should fail to update a component' do
      post :update, id: @component.id, component: {component_type: 'madlib'}
      response.code.should == '401'
    end

    # DELETE /api/v0/components/:id
    it 'should fail to destroy a component' do
      post :destroy, id: @component.id
      response.code.should == '401'
    end
  end
end
