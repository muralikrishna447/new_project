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

  context "#trial" do
    let!(:assembly){ Fabricate(:assembly, title: "Free Trial", assembly_type: "Course", price: 39.00, published: true ) }
    let!(:trial_code) { Base64.encode64("#{assembly.id}-1") }

    subject { get :trial, trial_token: trial_code }

    it 'it should set the trial code into the session' do
      subject
      expect(session[:free_trial]).to eq trial_code
    end

    it 'it should redirect to the landing page' do
      expect(subject).to redirect_to(landing_class_url(assembly))
    end
  end

  context "#trial duration split" do
    let!(:assembly){ Fabricate(:assembly, title: "Free Trial", assembly_type: "Course", price: 39.00, published: true ) }
    let!(:trial_code) { Base64.encode64("#{assembly.id}-0") }

    subject { get :trial, trial_token: trial_code }

    it 'it should pick a non-zero trial duration and store in session' do
      subject
      expect(Assembly.free_trial_hours(session[:free_trial])).not_to eq 0
    end
  end
end
