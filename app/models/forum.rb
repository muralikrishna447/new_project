class Forum

  def self.categories
    response = HTTParty.get('https://chefsteps.vanillaforums.com/api/v1/categories/list.json?access_token=50e20b3672d3cb211635a7b9db196f46')
    c = ActiveSupport::JSON.decode(response.body)
    c = c['Categories'].map {|a| a[1]}.map{|h| Hash[h.map { |k,v| [k.underscore.to_sym, v] }]}
  end

  def self.discussions
    response = HTTParty.get('https://chefsteps.vanillaforums.com/api/v1/discussions/list.json?access_token=50e20b3672d3cb211635a7b9db196f46')
    c = ActiveSupport::JSON.decode(response.body)
    c = c['Discussions'].map{|h| Hash[h.map { |k,v| [k.underscore.to_sym, v] }]}
  end

  def self.discussions_by_category(category)
    response = HTTParty.get("https://chefsteps.vanillaforums.com/api/v1/discussions/category.json?access_token=50e20b3672d3cb211635a7b9db196f46&CategoryIdentifier=#{category}")
    c = ActiveSupport::JSON.decode(response.body)
    c = c['Discussions'].map{|h| Hash[h.map { |k,v| [k.underscore.to_sym, v] }]}
  end

  def self.user(user_email)
    response = HTTParty.get("https://chefsteps.vanillaforums.com/api/v1/users/get.json?access_token=50e20b3672d3cb211635a7b9db196f46&User.Email=#{user_email}")
    c = ActiveSupport::JSON.decode(response.body)
    # c = c['Profile'].map{|h| Hash[h.map { |k,v| [k.underscore.to_sym, v] }]}
  end

end
