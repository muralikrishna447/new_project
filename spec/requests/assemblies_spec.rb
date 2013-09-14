require 'spec_helper'

describe 'AssembliesController' do
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

    describe 'when request path == /projects ' do
      it 'assigns @assemblies' do
        get '/projects'
        expect(assigns(:assemblies)).to eq([@project])
      end

      it 'assigns @assembly_type' do
        get '/projects'
        expect(assigns(:assembly_type)).to eq('Project')
      end

      it 'assigns @project' do
        get project_path(@project)
        expect(assigns(:project)).to eq(@project)
      end

      it 'renders projects_show' do
        get project_path(@project)
        expect(response).to render_template("projects_show")
      end
    end

    describe 'when request path == /courses ' do
      # TODO Currently, the course index path uses the courses_controller, not the assemblies_controller
      # it 'assigns @assemblies' do
      #   get '/courses'
      #   expect(assigns(:assemblies)).to eq([@course])
      # end

      # it 'assigns @assembly_type' do
      #   get '/courses'
      #   expect(assigns(:assembly_type)).to eq('Course')
      # end

      it 'assigns @course' do
        get course_path(@course)
        expect(assigns(:course)).to eq(@course)
      end

      it 'redirects to the course landing page when user not enrolled' do
        get course_path(@course)
        expect(response).to redirect_to(landing_course_url(@course))
      end

      it 'renders courses_show when user is enrolled' do
        user = Fabricate :user, name: 'Test User', email: 'test@test.com', password: 'password'
        enrollment = Fabricate :enrollment, user: user, enrollable: @course
        # NOTE A way to get current_user auth in request specs
        post_via_redirect user_session_path, 'user[email]' => user.email, 'user[password]' => user.password
        get course_path(@course)
        expect(response).to render_template("courses_show")
      end
    end

  end
end