class Recommendation
  def self.activities_for(user)
    cook_type = user.survey_results['What kind of cook are you?']
    case cook_type
    when 'Amateur'
      activities_by_cook_type = self.activities_by_difficulty('easy')
    when 'Home Cook'
      activities_by_cook_type = self.activities_by_difficulty('intermediate')
    when 'Culinary Student'
      activities_by_cook_type = self.activities_by_difficulty('intermediate')
    when 'Professional'
      activities_by_cook_type = self.activities_by_difficulty('advanced')
    end
    activities_by_cook_type
  end

  # Accepts a single tag or an array of tags
  # Single: Recommendation.activities_by_tag('Modernist')
  # Array: Recommendation.activities_by_tag(['Modernist','Butchery'])
  def self.activities_by_tags(tags)
    Activity.chefsteps_generated.published.tagged_with(tags, :any => true)
  end

  def self.activities_by_difficulty(difficulty)
    Activity.chefsteps_generated.published.difficulty(difficulty)
  end
end