require 'spec_helper'

describe Recommendation do

  before :each do
    @user1 = Fabricate :user, name: 'Bob Smith', survey_results: {"What kind of cook are you?"=>"Home Cook", "Which culinary topics interest you the most?"=>""}
    @user2 = Fabricate :user, name: 'Bobby Smith', survey_results: {"Which culinary topics interest you the most?"=>"Modernist Cuisine, Baking"}
    @activity1 = Fabricate :activity, title: 'Activity 1', published: true, tag_list: 'modernist cuisine, dinner', difficulty: 'easy'
    @activity2 = Fabricate :activity, title: 'Activity 2', published: true, tag_list: 'butchery', difficulty: 'advanced'
    @activity3 = Fabricate :activity, title: 'Activity 3', published: true, tag_list: 'dinner', difficulty: 'intermediate'
  end

  context 'activities_for' do
    it 'returns intermediate recipes when a user is a home cook' do
      expect(Recommendation.activities_for(@user1)).to include(@activity3)
      expect(Recommendation.activities_for(@user1)).to_not include(@activity2)
    end

    it 'returns modernist recipes when a user marks it as an interest' do
      expect(Recommendation.activities_for(@user2)).to include(@activity1)
    end
  end

end