class Recommendation
  def self.activities_for(user,limit = nil)
    interests = get_interests(user)
    suggestion = get_suggestion(user)

    activities = Activity.chefsteps_generated.published.not_premium.popular
    by_interests = interests ? activities.tagged_with(interests, any: true) : []
    by_suggestion = suggestion ? activities.tagged_with(suggestion, any: true) : []
    activities = (by_interests + by_suggestion).uniq
    activities = activities.sample(limit) if limit
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
    interests = user.survey_results['interests']
    if interests && interests.length > 0
      interests
    else
      nil
    end
  end

  def self.get_suggestion(user)
    suggestion = user.survey_results['suggestion']
    if suggestion && suggestion.length > 0
      suggestion
    else
      nil
    end
  end

  def self.by_tags(tags = [])
    activities = Activity.chefsteps_generated.published.not_premium.popular
    activities = activities.tagged_with(tags, any: true)
    activities
  end

end