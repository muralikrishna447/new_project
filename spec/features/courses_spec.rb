require 'spec_helper'

feature 'courses' do
  before :each do
    @course = Fabricate :assembly, title: 'Test Course', description: 'Test course description', published: true, assembly_type: 'Course'
  end

  context 'landing page' do
    it 'displays an faq section when an faq is present' do
      faq = Fabricate :activity, title: 'Test Course Faq', description: 'Test course faq description'
      visit landing_course_path @course
      expect(page).to have_content('FAQ')
    end

    it 'does not display an faq when an faq is not present' do
      visit landing_course_path @course
      expect(page).to_not have_content('FAQ')
    end
  end
end