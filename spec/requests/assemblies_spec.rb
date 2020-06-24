require 'spec_helper'

describe 'AssembliesController', pending: true do
  before :each do
    @assembly = Fabricate :assembly, title: 'Test Assembly', published: true
    @project = Fabricate :assembly, title: 'Test Project', published: true, assembly_type: 'Project'
    @course = Fabricate :assembly, title: 'Test Course', published: true, assembly_type: 'Course'
  end

  describe 'GET index' do

    describe 'when request path == /assemblies ' do
      it 'assigns @assemblies' do
        get '/assemblies'
        expect(assigns(:assemblies)).to eq([@assembly, @project, @course])
      end

      it 'assigns @assembly_type' do
        get '/assemblies'
        expect(assigns(:assembly_type)).to eq('Assembly')
      end

    end

    describe 'when request path == /courses ' do
      it 'assigns @course' do
        get class_path(@course)
        expect(assigns(:course)).to eq(@course)
      end

      it 'redirects to the course landing page when user not enrolled' do
        get course_path(@course)
        expect(response).to redirect_to(landing_class_url(@course))
      end

      it 'renders courses_show when user is enrolled' do
        user = Fabricate :user, name: 'Test User', email: 'test@test.com', password: 'password'
        enrollment = Fabricate :enrollment, user: user, enrollable: @course
        # NOTE A way to get current_user auth in request specs
        post user_session_path, params: {'user[email]' => user.email, 'user[password]' => user.password}
        follow_redirect!
        get class_path(@course)
        expect(response).to render_template("courses_show")
      end
    end
  end
end
