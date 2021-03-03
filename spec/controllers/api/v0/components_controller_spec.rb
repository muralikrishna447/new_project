require 'spec_helper'

describe Api::V0::ComponentsController do
  include Docs::V0::Components::Api

  context 'authenticated user is admin role', :dox do
    before :each do
      @admin_user = Fabricate :user, name: 'Admin User', email: 'admin@chefsteps.com', role: 'admin'
      @component = Fabricate :component, component_type: 'matrix', meta: {size: 'standard'}, name: 'myComponent'
      sign_in @admin_user
      controller.request.env['HTTP_AUTHORIZATION'] = @admin_user.valid_website_auth_token.to_jwt
    end

    describe 'GET #index' do
      include Docs::V0::Components::Index
      # GET /api/v0/components
      it 'should get an index of components' do
        get :index
        response.should be_success
      end
    end

    describe 'GET #show' do
      include Docs::V0::Components::Show
      # GET /api/v0/components/:id
      it 'should get a component by id' do
        get :show, params: {id: @component.id}
        response.should be_success
        component = JSON.parse(response.body)
        component['componentType'].should eq('matrix')
      end

      # GET /api/v0/components/:slug
      it 'should get a component by slug' do
        get :show,  params: {id: @component.slug}
        response.should be_success
        component = JSON.parse(response.body)
        component['componentType'].should eq('matrix')
      end

      # GET /api/v0/components/:id
      it 'should return 404 when component not found by id' do
        get :show,  params: {id: 9999}
        response.code.should == '404'
      end

      # GET /api/v0/components/:slug
      it 'should return 404 when component not found by slug' do
        get :show,  params: {id: 'not-a-slug'}
        response.code.should == '404'
      end
    end

    describe 'POST #create' do
      include Docs::V0::Components::Create
      # POST /api/v0/components
      it 'should create a component' do
        post :create,  params: {component: {component_type: 'matrix'}}
        response.should be_success
        component = JSON.parse(response.body)
        puts component
        component['componentType'].should eq('matrix')
      end
    end

    describe 'PUT #update' do
      include Docs::V0::Components::Update
      # PUT /api/v0/components/:id
      it 'should update a component' do
        put :update,  params: {id: @component.id, component: {component_type: 'madlib'}}
        response.should be_success
        component = JSON.parse(response.body)
        component['componentType'].should eq('madlib')
      end
    end

    describe 'DELETE #destroy' do
      include Docs::V0::Components::Destroy
      # DELETE /api/v0/components/:id
      it 'should destroy a component' do
        delete :destroy,  params: {id: @component.id}
        response.should be_success
      end
    end
  end

  context 'authenticated user is user role', :dox do
    before :each do
      @user = Fabricate :user, name: 'Normal User', email: 'user@chefsteps.com', role: 'user'
      @component = Fabricate :component, component_type: 'matrix', meta: {size: 'standard'}, name: 'myComponent'
      sign_in @user
      controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
    end

    describe 'GET #show' do
      include Docs::V0::Components::Show
      # GET /api/v0/components/:id
      it 'should get a component for id' do
        get :show,  params: {id: @component.id}
        response.should be_success
        component = JSON.parse(response.body)
        component['componentType'].should eq('matrix')
      end
    end

    describe 'POST #create' do
      include Docs::V0::Components::Create
      # POST /api/v0/components
      it 'should fail to create a component' do
        post :create,  params: {component: {component_type: 'matrix'}}
        response.code.should == '401'
      end
    end

    describe 'PUT #update' do
      include Docs::V0::Components::Update
      # PUT /api/v0/components/:id
      it 'should fail to update a component' do
        put :update,  params: {id: @component.id, component: {component_type: 'madlib'}}
        response.code.should == '401'
      end
    end

    describe 'DELETE #destroy' do
      include Docs::V0::Components::Destroy
      # DELETE /api/v0/components/:id
      it 'should fail to destroy a component' do
        delete :destroy,  params: {id: @component.id}
        response.code.should == '401'
      end
    end
  end
end
