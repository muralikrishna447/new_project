require 'spec_helper'

feature 'class' do
  before :each do
    @class = Fabricate :assembly, title: 'Test class', description: 'Test class description', published: true, assembly_type: 'course'
    @activity = Fabricate :activity, title: 'Test Activity', description: 'Test activity description', published: true
    @inclusion = Fabricate :assembly_inclusion, assembly: @class, includable: @activity
  end


  context 'landing page' do

    describe 'faq' do
      it 'displays an faq section when an faq is available', pending: true do
        faq = Fabricate :page, title: 'Test class Faq', content: 'Test class faq description'
        puts landing_class_path @class
        visit landing_class_path @class
        page.status_code.should eq(200)
        expect(page).to have_content('FAQ')
      end

      it 'does not display an faq when an faq is not available', pending: true do
        visit landing_class_path @class
        page.status_code.should eq(200)
        expect(page).to_not have_content('FAQ')
      end
    end
  end

end