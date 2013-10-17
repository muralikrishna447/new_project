require 'spec_helper'

feature 'courses' do
  before :each do
    @course = Fabricate :assembly, title: 'Test Course', description: 'Test course description', published: true, assembly_type: 'Course'
  end

  context 'landing page' do

    describe 'faq' do
      it 'displays an faq section when an faq is available' do
        faq = Fabricate :activity, title: 'Test Course Faq', description: 'Test course faq description'
        visit landing_course_path @course
        page.status_code.should eq(200)
        expect(page).to have_content('FAQ')
      end

      it 'does not display an faq when an faq is not available' do
        visit landing_course_path @course
        page.status_code.should eq(200)
        expect(page).to_not have_content('FAQ')
      end
    end

    describe 'testimonials' do
      it 'displays a testimonials section when a testimonials page is available' do
        testimonials = Fabricate :page, title: 'Test Course Testimonial', content: "This course is awesome - George Jetson"
        visit landing_course_path @course
        page.status_code.should eq(200)
        expect(page).to have_content('This course is awesome - George Jetson')
      end

      it 'does not display a testimonials section when a testimonials page is not available' do
        visit landing_course_path @course
        page.status_code.should eq(200)
        expect(page).to_not have_content('Testimonials')
      end
    end

  end
end