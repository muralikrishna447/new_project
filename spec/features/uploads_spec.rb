require 'spec_helper'

feature 'uploads' do
  include AcceptanceMacros
  before :each do
    @assembly = Fabricate :assembly, title: 'Test Course', description: 'Test course description', published: true, assembly_type: 'Course'
  end

  context 'courses', pending: true do
    describe 'upload page' do
      it 'displays a form' do
        login_user
        visit course_path(@assembly)
        expect(page.body).to have_content('Test Course')
      end
    end
  end
end