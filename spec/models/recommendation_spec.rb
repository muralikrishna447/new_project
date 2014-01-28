require 'spec_helper'

describe Recommendation do

  before :each do
    @user1 = Fabricate :user, name: 'Bob Smith'
    @activity1 = Fabricate :activity, title: 'Activity 1', published: true, tag_list: 'modernist, dinner'
    @activity2 = Fabricate :activity, title: 'Activity 2', published: true, tag_list: 'butchery'
    @activity3 = Fabricate :activity, title: 'Activity 3', published: true, tag_list: 'dinner'
  end

  context 'activities_for' do
    it 'returns an array of activities' do

    end
  end

  context 'activities_by_tags' do
    it 'returns recommendations based on a single tag' do
      expect(Recommendation.activities_by_tags('Modernist')).to include(@activity1)
      expect(Recommendation.activities_by_tags('Modernist')).to_not include(@activity2)
    end

    it 'returns recommendations based on multiple tags' do
      expect(Recommendation.activities_by_tags(['Modernist', 'Dinner'])).to include(@activity1)
      expect(Recommendation.activities_by_tags(['Modernist', 'Dinner'])).to include(@activity3)
      expect(Recommendation.activities_by_tags(['Modernist', 'Dinner'])).to_not include(@activity2)
    end
  end
end