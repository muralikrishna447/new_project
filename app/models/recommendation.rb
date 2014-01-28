class Recommendation
  def self.activities_for(user)
    difficulty = get_difficulty(user)
    interests = get_interests(user)

    activities = Activity.chefsteps_generated.published
    activities = activities.difficulty(difficulty) if difficulty
    activities = activities.tagged_with(interests) if interests
    activities
  end

  def self.get_difficulty(user)
    cook_type = user.survey_results['What kind of cook are you?']
    case cook_type
    when 'Amateur'
      difficulty = 'easy'
    when 'Home Cook'
      difficulty = 'intermediate'
    when 'Culinary Student'
      difficulty = 'intermediate'
    when 'Professional'
      difficulty = 'advanced'
    else
      difficulty = nil
    end
    difficulty
  end

  def self.get_interests(user)
    interests = user.survey_results['Which culinary topics interest you the most?']
    interests ? interests.split(',') : nil
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