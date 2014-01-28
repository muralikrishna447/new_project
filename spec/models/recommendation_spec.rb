require 'spec_helper'

describe Recommendation do

  before :each do
    @user1 = Fabricate :user, name: 'Bob Smith', survey_results: {"What kind of cook are you?"=>"Home Cook", "Tell us more about yourself:"=>"I am awesome!", "Which culinary topics interest you the most?"=>"Modernist Cuisine", "Dietary Restrictions. Select all that apply to you:"=>"Vegetarian"}
    @activity1 = Fabricate :activity, title: 'Activity 1', published: true, tag_list: 'modernist, dinner', difficulty: 'easy'
    @activity2 = Fabricate :activity, title: 'Activity 2', published: true, tag_list: 'butchery', difficulty: 'advanced'
    @activity3 = Fabricate :activity, title: 'Activity 3', published: true, tag_list: 'dinner', difficulty: 'intermediate'
  end

  context 'activities_for' do
    it 'returns easy recipes when a user is a home cook' do
      expect(Recommendation.activities_for(@user1)).to include(@activity3)
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

  context 'activities_by_difficulty' do
    it 'returns easy activities' do
      expect(Recommendation.activities_by_difficulty('easy')).to include(@activity1)
      expect(Recommendation.activities_by_difficulty('easy')).to_not include(@activity2)
    end
  end
end