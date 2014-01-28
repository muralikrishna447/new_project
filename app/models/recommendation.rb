class Recommendation
  def self.activities_for(user)
    difficulty = get_difficulty(user)
    interests = get_interests(user)

    activities = Activity.chefsteps_generated.published
    activities = activities.difficulty(difficulty) if difficulty
    activities = activities.tagged_with(interests, any: true) if interests
    activities = activities.popular
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
    if interests && interests.length > 0
      interests
    else
      nil
    end
  end

end