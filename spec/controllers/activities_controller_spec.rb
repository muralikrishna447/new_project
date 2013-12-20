require 'spec_helper'

describe ActivitiesController do

  before :each do
    @user = Fabricate(:user, id: 29)
    sign_in @user
    @activity = Fabricate :activity, title: 'Single Activity', description: 'description', published: true
    @assembly_activity = Fabricate :activity, title: 'Assembly Activity', description: 'description', show_only_in_course: true
    @assembly = Fabricate :assembly, title: 'Assembly Title', assembly_type: 'Course', description: 'description', price: 39
    @inclusion = Fabricate :assembly_inclusion, assembly: @assembly, includable: @assembly_activity
  end

  describe 'GET maybe_redirect_activity' do
    it 'redirects to the class activity when activity is marked as show only in course' do
      get :show, id: @assembly_activity.slug
      expect(response).to redirect_to(class_path(@assembly_activity.containing_course))
    end

    it 'redirects to an activity with params' do
      get :show, id: @activity.slug, token: 'helloimatoken'
      expect(response).to render_template(:show)
    end

    it 'redirects to the class activity if its not marked show only in course but a user is enrolled' do
      activity1 = Fabricate :activity, title: 'Activity 1', description: 'description', published: true
      assembly1 = Fabricate :assembly, title: 'Assembly1', description: 'description', published: true, assembly_type: 'Course'
      inclusion1 = Fabricate :assembly_inclusion, assembly: assembly1, includable: activity1
      enrollment = Fabricate :enrollment, enrollable: assembly1, user: @user
      get :show, id: activity1.slug
      expect(response).to redirect_to(class_activity_path(assembly1, activity1))
    end
  end

end
