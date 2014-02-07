class Recommendation
  def self.activities_for(user)
    # difficulty = get_difficulty(user)
    # interests = get_interests(user)
    difficulty = nil
    interests = nil
    user.survey_results.each do |result|
      case result['search_scope']
      when 'difficulty'
        difficulty = get_difficulty(result['answer'])
      end
    end

    activities = Activity.chefsteps_generated.published.popular
    activities = activities.difficulty(difficulty) if difficulty
    activities = activities.tagged_with(interests, any: true) if interests
    activities = activities.first(6)
    activities
  end

  def self.get_difficulty(answer)
    case answer
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