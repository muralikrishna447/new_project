require 'spec_helper'

feature 'class' do
  before :each do
    @class = Fabricate :assembly, title: 'Test class', description: 'Test class description', published: true, assembly_type: 'course'
  end

  context 'landing page' do

    describe 'faq' do
      it 'displays an faq section when an faq is available' do
        faq = Fabricate :page, title: 'Test class Faq', content: 'Test class faq description'
        puts landing_class_path @class
        visit landing_class_path @class
        page.status_code.should eq(200)
        expect(page).to have_content('FAQ')
      end

      it 'does not display an faq when an faq is not available' do
        visit landing_class_path @class
        page.status_code.should eq(200)
        expect(page).to_not have_content('FAQ')
      end
    end

    describe 'testimonials' do
      it 'displays a testimonials section when a testimonials page is available' do
        testimonials = Fabricate :page, title: 'Test class Testimonial', content: "This class is awesome - George Jetson"
        visit landing_class_path @class
        page.status_code.should eq(200)
        expect(page).to have_content('This class is awesome - George Jetson')
      end

      it 'does not display a testimonials section when a testimonials page is not available' do
        visit landing_class_path @class
        page.status_code.should eq(200)
        expect(page).to_not have_content('Testimonials')
      end
    end

  end
end