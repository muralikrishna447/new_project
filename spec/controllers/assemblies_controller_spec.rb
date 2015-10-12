require 'spec_helper'

describe AssembliesController do
  context "show" do
    before :each do
      @user = Fabricate :user, id: 29
      @collaborator = Fabricate :user, id: 30, role: 'collaborator'
      @activity1 = Fabricate :activity, title: 'Activity 1', description: 'an activity description', published: true
      @assembly1 = Fabricate :assembly, title: 'Assembly 1', description: 'an assembly description', assembly_type: 'Course', published: true
      @assembly_inclusion1 = Fabricate :assembly_inclusion, assembly: @assembly1, includable: @activity1
      @assembly_unpublished = Fabricate :assembly, title: 'Assembly Unpublished 1', description: 'an assembly description', assembly_type: 'Course', published: false
    end

    context 'user is not signed in' do
      it 'redirects to the landing page' do
        get :show, id: @assembly1.slug
        expect(response).to redirect_to(landing_assembly_path(@assembly1))
      end
    end

    context 'user is signed in' do
      before :each do
        sign_in @user
      end
      it 'redirects to the landing page if user is not enrolled' do
        get :show, id: @assembly1.slug
        expect(response).to redirect_to(landing_assembly_path(@assembly1))
      end
      it 'goes to the assembly activity if the user is enrolled' do
        enrollment = Fabricate :enrollment, enrollable: @assembly1, user: @user
        get :show, id: @assembly1.slug
        expect(response).to render_template(:courses_show)
      end
      it 'does not allow a user to view an unpublished assembly' do
        get :show, id: @assembly_unpublished.slug
        expect(response).to render_template(:pre_registration)
      end
    end

    context 'collaborator is signed in' do
      before :each do
        sign_in @collaborator
      end
      it 'allows collaborator to view an unpublished assembly' do
        get :landing, id: @assembly_unpublished
        expect(response).to be_success
      end
    end
  end
end
