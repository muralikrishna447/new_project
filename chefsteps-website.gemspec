Gem::Specification.new do |gem|
  gem.name        = "chefsteps-website"
  gem.version     = "0.0.1"
  gem.summary     = "Selected portions of the chefSteps Website, questionably packaged"
  gem.authors     = ["ChefSteps"]
  gem.homepage    = 'http://chefsteps.com'
  gem.add_dependency "paranoia", "~> 2.2.0.pre"
  gem.add_dependency 'attr_encrypted', "~> 3.0.0"
  gem.add_dependency 'hashids'
end
