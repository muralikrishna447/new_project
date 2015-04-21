require 'spec_helper'

describe Recommendation do

  before :each do
    @user1 = Fabricate :user, name: 'Bob Smith', survey_results: {"interests" => ['Baking', 'Beverages']}
    @user2 = Fabricate :user, name: 'Bobby Smith', survey_results: {"interests" => ['Modernist']}
    @user3 = Fabricate :user, name: 'Askme Noquestions'
    @activity1 = Fabricate :activity, title: 'Activity 1', published: true, tag_list: ['Modernist','dinner'], difficulty: 'intermediate', likes_count: 10
    @activity2 = Fabricate :activity, title: 'Activity 2', published: true, tag_list: ['butchery'], difficulty: 'advanced', likes_count: 20
    @activity3 = Fabricate :activity, title: 'Activity 3', published: true, tag_list: ['dinner'], difficulty: 'intermediate', likes_count: 30
    @activity4 = Fabricate :activity, title: 'Activity 4', published: true, tag_list: ['dinner'], difficulty: 'advanced', likes_count: 40
    @activity5 = Fabricate :activity, title: 'Activity 5', published: true, tag_list: ['dinner'], difficulty: 'advanced', likes_count: 50
    @activity6 = Fabricate :activity, title: 'Activity 6', published: true, tag_list: ['dinner'], difficulty: 'easy', likes_count: 60
    @activity7 = Fabricate :activity, title: 'Activity 7', published: true, tag_list: ['dinner', 'baking'], difficulty: 'intermediate', likes_count: 70
  end

  context 'activities_for' do
    it 'returns baking recipes when a user marks it as an interest' do
      expect(Recommendation.activities_for(@user1)).to include(@activity7)
    end

    it 'returns modernist recipes when a user marks it as an interest' do
      expect(Recommendation.activities_for(@user2)).to include(@activity1)
    end

  end

  context 'by_tags' do
    it 'only includes matching recipes' do
      recipes = Recommendation.by_tags(['Modernist', 'dinner'])
      expect(recipes).to include(@activity7)
      expect(recipes).to_not include(@activity2)
    end

    it 'returns nothing when there are no matching recipes' do
      recipes = Recommendation.by_tags(['bbq'])
      expect(recipes.size).should eq(0)
    end

  end

end
