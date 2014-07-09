class Recommendation
  def self.activities_for(user,limit = nil)
    # difficulty = get_difficulty(user)
    # interests = get_interests(user)
    difficulty = nil
    interests = nil
    equipment = nil
    user.survey_results.each do |result|
      case result['search_scope']
      when 'difficulty'
        difficulty = get_difficulty(result['answer'])
      when 'interests'
        interests = result['answer']
      when 'by_equipment_title'
        equipment = result['answer']
      end
    end

    popular = Activity.chefsteps_generated.published.not_in_course.popular.first(6)
    activities = Activity.chefsteps_generated.published.not_in_course.popular
    activities = activities.difficulty(difficulty) if difficulty
    # by_interests = activities.tagged_with(interests, any: true) if interests
    # by_equipment = activities.by_equipment_titles(equipment) if equipment
    by_interests = interests ? activities.tagged_with(interests, any: true) : []
    by_equipment = equipment ? activities.by_equipment_titles(equipment) : []
    activities = (activities + by_interests + by_equipment + popular).uniq
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
    interests = user.survey_results['Which culinary topics interest you the most?']
    if interests && interests.length > 0
      interests
    else
      nil
    end
  end

end