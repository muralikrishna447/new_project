class Recommendation
  def self.activities_for(user,limit = nil)
    interests = get_interests(user)

    # popular = Activity.chefsteps_generated.published.not_in_course.popular.first(6)
    activities = Activity.chefsteps_generated.published.not_in_course.popular
    by_interests = interests ? activities.tagged_with(interests, any: true) : []
    activities = (by_interests).uniq
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

end