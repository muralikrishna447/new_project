require 'spec_helper'

feature 'courses' do
  before :each do
    @course = Fabricate :course, title: 'Test Course', description: 'Test course description'
  end

  context 'landing page' do
    it 'displays an faq' do
    end
  end
end