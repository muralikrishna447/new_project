require 'spec_helper'

feature 'class' do
  before :each do
    @class = Fabricate :assembly, title: 'Test class', description: 'Test class description', published: true, assembly_type: 'course'
    @activity = Fabricate :activity, title: 'Test Activity', description: 'Test activity description', published: true
    @inclusion = Fabricate :assembly_inclusion, assembly_id: @class.id, includable_type: 'Activity', includable_id: @activity.id
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
  end

  context 'assembly inclusions' do
    it 'loads an activity inside a class' do
      visit class_activity_path(@class, @activity)
      puts class_activity_path(@class, @activity)
      page.status_code.should eq(200)
    end
  end
end