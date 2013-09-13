require 'spec_helper'

describe 'AssembliesController' do
  before :each do
    @assembly = Fabricate :assembly, title: 'Test Assembly', published: true
    @project = Fabricate :assembly, title: 'Test Project', published: true, assembly_type: 'Project'
  end

  describe 'GET index' do

    describe 'when request path == /assemblies ' do
      it 'assigns @assemblies' do
        get '/assemblies'
        expect(assigns(:assemblies)).to eq([@assembly, @project])
      end

      it 'assigns @assembly_type' do
        get '/assemblies'
        expect(assigns(:assembly_type)).to eq('Assembly')
      end
    end

    describe 'when request path == /projects ' do
      it 'assigns @assemblies' do
        get 'projects'
        expect(assigns(:assemblies)).to eq([@project])
      end

      it 'assigns @assembly_type' do
        get '/projects'
        expect(assigns(:assembly_type)).to eq('Project')
      end
    end

  end
end