require 'spec_helper'

describe ActivitiesController do

  describe 'show' do

    context 'outside an assembly' do
      before :each do
        @activity = Fabricate :activity, title: 'A Single Activity', description: 'an activity description', published: true
        @studio_activity = Fabricate :activity, title: 'A studio pass Activity', description: 'an activity description', published: true, studio: true
        step = Fabricate :step, extra: "Hola"
        @activity.steps << step
        @normal_user = Fabricate :user, name: 'A User', email: 'noraml_user@user.com', role: 'user'
        @premium_user = Fabricate :user, name: 'Another User', email: 'premium_anotheruser@user.com', role: 'user', premium_member: true
      end

      it 'goes to an activity' do
        get :show, params: {id: @activity.slug}
        expect(response).to render_template(:show)
      end

      it 'goes to an activity within a sous vide class' do
        @activity1 = Fabricate :activity, title: 'Sous vide chicken', description: 'an activity description', published: true
        @assembly1 = Fabricate :assembly, title: 'Assembly 1', description: 'an assembly description', assembly_type: 'Course', published: true
        @assembly_inclusion1 = Fabricate :assembly_inclusion, assembly: @assembly1, includable: @activity1
        get :show, params: {id: @activity1.slug}
        expect(response).to render_template(:show)
      end

      it 'only returns secret circulator machine instructions if asked nicely' do
        get :get_as_json, params: {id: @activity.slug}
        expect(response.body).to_not include("Hola")
        get :get_as_json, params: {param_info: 'a9a77bd9f', id: @activity.slug}
        expect(response.body).to include("Hola")
      end

      it 'shows smart app banner ad' do
        get :show, params: {id: @activity.slug}
        assigns(:show_app_add).should_not be_nil
      end

      it 'stduiopass activity steps and ingredients should not be included for non-studio or non-premium or non-admin user' do
        sign_in @premium_user
        get :get_as_json, params: {id: @studio_activity.slug}
        response.code.should eq("200")
        res = JSON.parse(response.body)
        expect(res).to have_key('steps')
        expect(res).to have_key('ingredients')
      end

      it 'stduiopass activity steps and ingredients should included for studio or premium or admin user' do
        sign_in @normal_user
        get :get_as_json, params: {id: @studio_activity.slug}
        response.code.should eq("200")
        res = JSON.parse(response.body)
        expect(res).not_to have_key('steps')
        expect(res).not_to have_key('ingredients')
      end

      it 'normal activity steps and ingredients should included for normal user' do
        sign_in @normal_user
        get :get_as_json, params: {id: @activity.slug}
        response.code.should eq("200")
        res = JSON.parse(response.body)
        expect(res).to have_key('steps')
        expect(res).to have_key('ingredients')
      end

      it 'normal activity steps and ingredients should included for studio user as well' do
        sign_in @premium_user
        get :get_as_json, params: {id: @activity.slug}
        response.code.should eq("200")
        res = JSON.parse(response.body)
        expect(res).to have_key('steps')
        expect(res).to have_key('ingredients')
      end

      context 'start in edit' do
        before :each do
          @admin = Fabricate :user, name: 'An Admin', email: 'admin@chefsteps.com', role: 'admin'
          @user1 = Fabricate :user, name: 'A User', email: 'user@user.com', role: 'user'
          @user2 = Fabricate :user, name: 'Another User', email: 'anotheruser@user.com', role: 'user'
          @chefsteps_activity = Fabricate :activity, title: 'A New Recipe', published: true
          @user1_activity = Fabricate :activity, title: 'A User Recipe', creator: @user1.id, published: true
          @un_published_activity = Fabricate :activity, title: 'A Unpublished Recipe', creator: @user1, published: false
        end

        it 'redirects if a non admin tries to edit a chefsteps activity' do
          sign_in @user1
          get :show, params: {id: @chefsteps_activity.slug, start_in_edit: true}
          expect(response).to redirect_to(@chefsteps_activity)
        end

        it 'redirects if a user tries to edit another users activity' do
          sign_in @user2
          get :show, params: {id: @user1_activity.slug, start_in_edit: true}
          expect(response).to redirect_to(@user1_activity)
        end

        it 'redirects if a user tries to edit another users unpublished activity' do
          sign_in @user2
          get :show, params: { id: @un_published_activity.slug, start_in_edit: true }
          expect(response).to redirect_to(@un_published_activity)
        end

        it 'allows a user to edit their own activity' do
          sign_in @user1
          get :show, params: {id: @user1_activity.slug, start_in_edit: true}
          expect(response).to be_success
        end

        it 'allows admin to edit a chefsteps activity' do
          sign_in @admin
          get :show, params: {id: @chefsteps_activity.slug, start_in_edit: true}
          expect(response).to be_success
        end

        it 'allows admin to edit any activity' do
          sign_in @admin
          get :show, params: {id: @user1_activity.slug, start_in_edit: true}
          expect(response).to be_success
        end
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
        @user1_activity = Fabricate :activity, title: 'A User Recipe', creator: @user1.id, published: true

      end

      it 'does not allow a non admin to update a chefsteps recipe' do
        sign_in @user1
        put :update_as_json, params: {id: @chefsteps_activity.slug, activity: {title: 'New Title'}}
        expect(response).to_not be_success
      end

      it 'does not allow a user to update another users activity' do
        sign_in @user2
        put :update_as_json, params: {id: @user1_activity.slug, activity: {title: 'New Title'}}
        expect(response).to_not be_success
      end
    end
  end

  describe 'update' do
    context 'update_as_json with steps' do
      before :each do
        @admin = Fabricate :user, name: 'An Admin', email: 'admin@chefsteps.com', role: 'admin'
        @chefsteps_activity = Fabricate :activity, title: 'A New Recipe', published: true
        @step = Fabricate :step, title: "First Step"
        @chefsteps_activity.steps << @step
      end

      it 'add new steps and removing existing steps for activity' do
        sign_in @admin
        put :update_as_json, params: {format: 'json', id: @chefsteps_activity.slug, activity: {title: 'New Title'},
                                      steps: [{title: 'New Step'}]}
        expect(@chefsteps_activity.steps.count).to eq(1)
      end

      it 'add the steps with existing steps for activity' do
        sign_in @admin
        put :update_as_json, params: {format: 'json', id: @chefsteps_activity.slug, activity: {title: 'New Title'},
                                      steps: [@step.attributes, {title: 'New Step'}]}
        expect(@chefsteps_activity.steps.count).to eq(2)
      end

      it 'existing steps should avaliable if steps params blank for activity' do
        sign_in @admin
        put :update_as_json, params: {format: 'json', id: @chefsteps_activity.slug, activity: {title: 'New Title'}, steps: []}
        expect(@chefsteps_activity.steps.count).to eq(1)
      end
    end

    context 'update_as_json with steps and ingredients' do
      before :each do
        @admin = Fabricate :user, name: 'An Admin', email: 'admin@chefsteps.com', role: 'admin'
        @chefsteps_activity = Fabricate :activity, title: 'A New Recipe', published: true
        @step = Fabricate :step, title: "First Step"
        @ingredient = Fabricate :ingredient, title: "Cold Water"
        @chefsteps_activity.steps << @step
        @ingredients = [{"unit"=>"a/n", "display_quantity"=>nil, "note"=>"",
                         "ingredient"=>{"title"=>"Banana water"}}]
      end

      it 'add new steps with new ingredients and removing existing steps for activity' do
        sign_in @admin
         put :update_as_json, params: {format: 'json', id: @chefsteps_activity.slug, activity: {title: 'New Title'},
                                       steps: [{title: 'New Step', "ingredients"=> @ingredients}]}
        @chefsteps_activity.reload
        expect(@chefsteps_activity.steps.count).to eq(1)
        expect(@chefsteps_activity.steps.first.ingredients.count).to eq(1)
      end

      it 'Existing step and ingredients with new step without ingredients for activity' do
        sign_in @admin
        StepIngredient.create!({step_id: @step.id, ingredient_id: @ingredient.id })
        @step.reload
        existing_step_ingredients = [{"quantity"=>"0.0", "unit"=>"a/n", "display_quantity"=>nil, "note"=>"",
                                     "ingredient"=> {title: 'Cold Water', id: @step.ingredients.first.ingredient_id}}]
        put :update_as_json, params: {format: 'json', id: @chefsteps_activity.slug, activity: {title: 'New Title'},
                                      steps: [@step.attributes.merge("ingredients"=> existing_step_ingredients), {title: 'New Step'}]}
        @chefsteps_activity.reload
        expect(@chefsteps_activity.steps.count).to eq(2)
        expect(@chefsteps_activity.steps.first.ingredients.map(&:title)).to eq(['Cold Water'])
        expect(@chefsteps_activity.steps.first.ingredients.count).to eq(1)
        expect(@chefsteps_activity.steps.map(&:title)).to eq(["First Step",'New Step'])
        expect(@chefsteps_activity.steps.last.ingredients.count).to eq(0)
      end

      it 'existing steps with new ingredients for activity' do
        sign_in @admin
        put :update_as_json, params: {format: 'json', id: @chefsteps_activity.slug, activity: {title: 'New Title'},
                                      steps: [@step.attributes.merge(ingredients: @ingredients), {title: 'New Step'}]}
        expect(@chefsteps_activity.steps.count).to eq(2)
        expect(@chefsteps_activity.steps.first.ingredients.map(&:title)).to eq(["Banana water"])
        expect(@chefsteps_activity.steps.first.ingredients.count).to eq(1)
      end

      it 'should delete existing step ingredients if ingredients has empty' do
        sign_in @admin
        StepIngredient.create!({step_id: @step.id, ingredient_id: @ingredient.id })
        @step.reload
        expect(@chefsteps_activity.steps.first.ingredients.map(&:title)).to eq(['Cold Water'])
        expect(@chefsteps_activity.steps.first.ingredients.count).to eq(1)
        put :update_as_json, params: {format: 'json', id: @chefsteps_activity.slug, activity: {title: 'New Title'},
                                      steps: [@step.attributes.merge("ingredients"=> nil), {title: 'New Step'}]}
        @chefsteps_activity.reload
        expect(@chefsteps_activity.steps.count).to eq(2)
        expect(@chefsteps_activity.steps.first.ingredients.count).to eq(0)
        expect(@chefsteps_activity.steps.map(&:title)).to eq(["First Step",'New Step'])
        expect(@chefsteps_activity.steps.last.ingredients.count).to eq(0)
      end

      it 'should not delete existing step ingredients if no ingredients params' do
        sign_in @admin
        StepIngredient.create!({step_id: @step.id, ingredient_id: @ingredient.id })
        @step.reload
        expect(@chefsteps_activity.steps.first.ingredients.map(&:title)).to eq(['Cold Water'])
        expect(@chefsteps_activity.steps.first.ingredients.count).to eq(1)
        put :update_as_json, params: {format: 'json', id: @chefsteps_activity.slug, activity: {title: 'New Title'},
                                      steps: [@step.attributes, {title: 'New Step'}]}
        @chefsteps_activity.reload
        expect(@chefsteps_activity.steps.count).to eq(2)
        expect(@chefsteps_activity.steps.first.ingredients.count).to eq(1)
        expect(@chefsteps_activity.steps.first.ingredients.map(&:title)).to eq(["Cold Water"])
        expect(@chefsteps_activity.steps.map(&:title)).to eq(["First Step",'New Step'])
        expect(@chefsteps_activity.steps.last.ingredients.count).to eq(0)
      end
    end
  end
end
