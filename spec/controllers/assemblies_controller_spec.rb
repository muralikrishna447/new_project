require 'spec_helper'

describe AssembliesController do
  before :each do
    @user = Fabricate :user, id: 29
    @premium_user = Fabricate :user, id: 31, premium_member: true
    @collaborator = Fabricate :user, id: 30, role: 'collaborator'
    @activity1 = Fabricate :activity, title: 'Activity 1', description: 'an activity description', published: true
    @assembly_free = Fabricate :assembly, title: 'Assembly 1', description: 'an assembly description', assembly_type: 'Course', published: true
    @assembly_inclusion1 = Fabricate :assembly_inclusion, assembly: @assembly_free, includable: @activity1
    @assembly_unpublished = Fabricate :assembly, title: 'Assembly Unpublished 1', description: 'an assembly description', assembly_type: 'Course', published: false

    @assembly_premium = Fabricate :assembly, title: 'Assembly Premium', description: 'an assembly description', assembly_type: 'Course', published: true, premium: true
  end

  context "show" do

    context 'user is not signed in' do
      it 'redirects to the landing page' do
        get :show, id: @assembly_free.slug
        expect(response).to redirect_to(landing_assembly_path(@assembly_free))
      end
    end

    context 'user is signed in' do
      before :each do
        sign_in @user
      end
      it 'redirects to the landing page if user is not enrolled' do
        get :show, id: @assembly_free.slug
        expect(response).to redirect_to(landing_assembly_path(@assembly_free))
      end
      it 'goes to the assembly activity if the user is enrolled' do
        enrollment = Fabricate :enrollment, enrollable: @assembly_free, user: @user
        get :show, id: @assembly_free.slug
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


  describe 'enroll' do
    def test_enroll(user, assembly, expected_status)
      sign_in(user) if user
      post :enroll, id: assembly.id
      expect(response.status).to eq(expected_status)
    end

    it 'errors if no user signed in' do
      test_enroll(nil, @assembly_free, 400)
    end

    it 'errors if enrolling non-premium user in premium class' do
      test_enroll(@user, @assembly_premium, 401)
    end

    it 'enrolls non-premium user in free class' do
      test_enroll(@user, @assembly_free, 200)
    end

    it 'enrolls premium user in free class' do
      test_enroll(@premium_user, @assembly_free, 200)
    end

    it 'enrolls premium user in premium class' do
      test_enroll(@premium_user, @assembly_premium, 200)
    end
  end

end
