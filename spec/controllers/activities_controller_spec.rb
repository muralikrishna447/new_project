require 'spec_helper'

describe ActivitiesController do

  describe 'show' do
    it 'goes to an activity' do
      activity = Fabricate :activity, title: 'A Single Activity', description: 'an activity description', published: true
      get :show, id: activity.slug
      expect(response).to render_template(:show)
    end

    it 'only returns secret circulator machine instructions if asked nicely' do
      activity = Fabricate :activity, title: 'A Single Activity', description: 'an activity description', published: true
      step = Fabricate :step, extra: "Hola"
      activity.steps << step
      get :get_as_json, id: activity.slug
      expect(response.body).to_not include("Hola")
      get :get_as_json, param_info: 'a9a77bd9f', id: activity.slug
      expect(response.body).to include("Hola")
    end

    context 'within an assembly' do
      before :each do
        @user = Fabricate :user, id: 29
        sign_in @user

        @activity1 = Fabricate :activity, title: 'Activity 1', description: 'an activity description', published: true
        @assembly1 = Fabricate :assembly, title: 'Assembly 1', description: 'an assembly description', assembly_type: 'Course', published: true
        @assembly_inclusion1 = Fabricate :assembly_inclusion, assembly: @assembly1, includable: @activity1


        @activity2 = Fabricate :activity, title: 'Activity 2', description: 'an activity description', published: true, show_only_in_course: true
        @assembly2 = Fabricate :assembly, title: 'Assembly 2', description: 'an assembly description', assembly_type: 'Course', published: true, price: 20
        @assembly_inclusion2 = Fabricate :assembly_inclusion, assembly: @assembly2, includable: @activity2
      end

      it 'goes to an activity even if show_only_in_course is false' do
        get :show, id: @activity1.slug
        expect(response).to render_template(:show)
      end

      it 'redirects to the landing page if show_only_in_course is true and user is not enrolled' do
        get :show, id: @activity2.slug
        puts response.inspect
        expect(response).to redirect_to(landing_assembly_path(@assembly2))
      end

      it 'goes to the activity if show_only_in_course is true and user is enrolled' do
        enrollment = Fabricate :enrollment, enrollable: @assembly2, user: @user
        puts response.inspect
        get :show, id: @activity2.slug
        expect(response).to render_template(:show)
      end

    end

  end

end
