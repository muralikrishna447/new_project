require 'spec_helper'

describe Recommendation do

  before :each do
    @user1 = Fabricate :user, name: 'Bob Smith', survey_results: [{"copy"=>"What kind of cook are you?", "answer"=>"Home Cook", 'search_scope'=>'difficulty'}, {"copy"=>"Which culinary topics interest you the most?", "answer"=>"Modernist Cuisine,Food Science"}, {"copy"=>"What equipment do you have in your kitchen?", "search_scope"=>"by_equipment_title", "answer"=>"Immersion Blender,Whipping Siphon"}]
    @user2 = Fabricate :user, name: 'Bobby Smith', survey_results: [{"copy"=>"Which culinary topics interest you the most?", "answer"=>"Modernist Cuisine,Food Science"}]
    @activity1 = Fabricate :activity, title: 'Activity 1', published: true, tag_list: 'modernist cuisine, dinner', difficulty: 'easy', likes_count: 10
    @activity2 = Fabricate :activity, title: 'Activity 2', published: true, tag_list: 'butchery', difficulty: 'advanced', likes_count: 20
    @activity3 = Fabricate :activity, title: 'Activity 3', published: true, tag_list: 'dinner', difficulty: 'intermediate', likes_count: 30
  end

  context 'activities_for' do
    it 'returns intermediate recipes when a user is a home cook' do
      expect(Recommendation.activities_for(@user1)).to include(@activity3)
    end

    it 'returns modernist recipes when a user marks it as an interest' do
      expect(Recommendation.activities_for(@user2)).to include(@activity1)
    end
  end

end