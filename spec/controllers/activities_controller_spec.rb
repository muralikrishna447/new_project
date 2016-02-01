require 'spec_helper'

describe ActivitiesController do

  describe 'show' do

    context 'outside an assembly' do
      before :each do
        @activity = Fabricate :activity, title: 'A Single Activity', description: 'an activity description', published: true
        step = Fabricate :step, extra: "Hola"
        @activity.steps << step
      end

      it 'goes to an activity' do
        get :show, id: @activity.slug
        expect(response).to render_template(:show)
      end

      it 'goes to an activity within a sous vide class' do
        @activity1 = Fabricate :activity, title: 'Sous vide chicken', description: 'an activity description', published: true
        @assembly1 = Fabricate :assembly, title: 'Assembly 1', description: 'an assembly description', assembly_type: 'Course', published: true
        @assembly_inclusion1 = Fabricate :assembly_inclusion, assembly: @assembly1, includable: @activity1
        get :show, id: @activity1.slug
        expect(response).to render_template(:show)
      end

      it 'only returns secret circulator machine instructions if asked nicely' do
        get :get_as_json, id: @activity.slug
        expect(response.body).to_not include("Hola")
        get :get_as_json, param_info: 'a9a77bd9f', id: @activity.slug
        expect(response.body).to include("Hola")
      end

      it 'shows smart app banner ad' do
        get :show, id: @activity.slug
        assigns(:show_app_add).should_not be_nil
      end

      context 'start in edit' do
        before :each do
          @admin = Fabricate :user, name: 'An Admin', email: 'admin@chefsteps.com', role: 'admin'
          @user1 = Fabricate :user, name: 'A User', email: 'user@user.com', role: 'user'
          @user2 = Fabricate :user, name: 'Another User', email: 'anotheruser@user.com', role: 'user'
          @chefsteps_activity = Fabricate :activity, title: 'A New Recipe', published: true
          @user1_activity = Fabricate :activity, title: 'A User Recipe', creator: @user1, published: true
        end

        it 'redirects if a non admin tries to edit a chefsteps activity' do
          sign_in @user1
          get :show, id: @chefsteps_activity.slug, start_in_edit: true
          expect(response).to redirect_to(@chefsteps_activity)
        end

        it 'redirects if a user tries to edit another users activity' do
          sign_in @user2
          get :show, id: @user1_activity.slug, start_in_edit: true
          expect(response).to redirect_to(@user1_activity)
        end

        it 'allows a user to edit their own activity' do
          sign_in @user1
          get :show, id: @user1_activity.slug, start_in_edit: true
          expect(response).to be_success
        end

        it 'allows admin to edit a chefsteps activity' do
          sign_in @admin
          get :show, id: @chefsteps_activity.slug, start_in_edit: true
          expect(response).to be_success
        end

        it 'allows admin to edit any activity' do
          sign_in @admin
          get :show, id: @user1_activity.slug, start_in_edit: true
          expect(response).to be_success
        end

      end
    end

    context 'algolia' do

      it 'pushes an update to Algolia on save' do
        @activity = Fabricate :activity, title: 'A Single Activity', description: 'an activity description', published: true
        WebMock.assert_requested :put, "https://jgv2odt81s.algolia.net/1/indexes/ChefSteps_test/#{@activity.id}"
      end
    end

  end

  describe 'update' do
    context 'update_as_json' do
      before :each do
        @admin = Fabricate :user, name: 'An Admin', email: 'admin@chefsteps.com', role: 'admin'
        @user1 = Fabricate :user, name: 'A User', email: 'user@user.com', role: 'user'
        @user2 = Fabricate :user, name: 'Another User', email: 'anotheruser@user.com', role: 'user'
        @chefsteps_activity = Fabricate :activity, title: 'A New Recipe', published: true
        @user1_activity = Fabricate :activity, title: 'A User Recipe', creator: @user1, published: true

      end

      it 'does not allow a non admin to update a chefsteps recipe' do
        sign_in @user1
        put :update_as_json, id: @chefsteps_activity.slug, activity: {title: 'New Title'}
        expect(response).to_not be_success
      end

      it 'does not allow a user to update another users activity' do
        sign_in @user2
        put :update_as_json, id: @user1_activity.slug, activity: {title: 'New Title'}
        expect(response).to_not be_success
      end
    end
  end
end
