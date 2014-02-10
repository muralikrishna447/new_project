class Recommendation
  def self.activities_for(user)
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
        equipment = [result['answer']]
      end
    end

    popular = Activity.chefsteps_generated.published.popular.first(6)
    activities = Activity.chefsteps_generated.published.popular
    activities = activities.difficulty(difficulty) if difficulty
    activities = activities.tagged_with(interests, any: true) if interests
    activities = activities.by_equipment_titles(equipment) if equipment
    activities = (activities + popular).uniq.take(6)
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