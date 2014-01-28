class Recommendation
  def self.activities_for(user)
    Activity.chefsteps_generated.published
  end

  # Accepts a single tag or an array of tags
  # Single: Recommendation.activities_by_tag('Modernist')
  # Array: Recommendation.activities_by_tag(['Modernist','Butchery'])
  def self.activities_by_tags(tags)
    Activity.chefsteps_generated.published.tagged_with(tags, :any => true)
  end
end