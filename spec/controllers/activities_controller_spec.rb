require 'spec_helper'

describe ActivitiesController do

  # before :each do
  #   @user = Fabricate(:user, id: 29)
  #   sign_in @user
  #   @activity = Fabricate :activity, title: 'Single Activity', description: 'description', published: true
  #   @assembly_activity = Fabricate :activity, title: 'Assembly Activity', description: 'description', show_only_in_course: true
  #   @assembly = Fabricate :assembly, title: 'Assembly Title', assembly_type: 'Course', description: 'description', price: 39
  #   @inclusion = Fabricate :assembly_inclusion, assembly: @assembly, includable: @assembly_activity
  # end

  # describe 'GET show' do
  #   it 'redirects to the class activity when activity is marked as show only in course' do
  #     get :show, id: @assembly_activity.slug
  #     expect(response).to redirect_to(class_path(@assembly_activity.containing_course))
  #   end

  #   it 'redirects to an activity with params' do
  #     get :show, id: @activity.slug, token: 'helloimatoken'
  #     expect(response).to render_template(:show)
  #   end

  #   it 'redirects to the class activity if its not marked show only in course but a user is enrolled' do
  #     activity1 = Fabricate :activity, title: 'Activity 1', description: 'description', published: true
  #     assembly1 = Fabricate :assembly, title: 'Assembly1', description: 'description', published: true, assembly_type: 'Course'
  #     inclusion1 = Fabricate :assembly_inclusion, assembly: assembly1, includable: activity1
  #     enrollment = Fabricate :enrollment, enrollable: assembly1, user: @user
  #     get :show, id: activity1.slug
  #     expect(response).to redirect_to(class_activity_path(assembly1, activity1))
  #   end

  #   # it 'redirects to a project if the recipe is within a project' do
  #   #   activity2 = Fabricate :activity, title: 'Activity 2', description: 'description', published: true
  #   #   assembly2 = Fabricate :assembly, title: 'Assembly 2', description: 'description', published: true, assembly_type: 'Project'
  #   #   inclusion2 = Fabricate :assembly_inclusion, assembly: assembly2, includable: activity2
  #   #   get :show, id: activity2.slug
  #   #   expect(response).to redirect_to(assembly_activity_path(assembly2, activity2))
  #   # end

  # end

  # before :each do
  #   @user = Fabricate :user, id: 29
  #   sign_in @user
  #   @activity = Fabricate :activity, title: 'A Single Activity', description: 'an activity description', published: true


  # end

  describe 'show' do
    it 'goes to an activity' do
      activity = Fabricate :activity, title: 'A Single Activity', description: 'an activity description', published: true
      get :show, id: activity.slug
      expect(response).to render_template(:show)
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
