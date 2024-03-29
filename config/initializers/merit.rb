# Use this hook to configure merit parameters
Merit.setup do |config|
  # Check rules on each request or in background
  # config.checks_on_each_request = true

  # Define ORM. Could be :active_record (default) and :mongo_mapper and :mongoid
  # config.orm = :active_record

  # Define :user_model_name. This model will be used to grand badge if no :to option is given. Default is "User".
  # config.user_model_name = "User"

  # Define :current_user_method. Similar to previous option. It will be used to retrieve :user_model_name object if no :to option is given. Default is "current_#{user_model_name.downcase}".
  # config.current_user_method = "current_user"
end

# Create application badges (uses https://github.com/norman/ambry)
# Merit::Badge.create!({
#   id: 1,
#   name: 'just-registered'
# }, {
#   id: 2,
#   name: 'best-unicorn',
#   custom_fields: { category: 'fantasy' }
# })

Merit::Badge.create!({
  id: 1,
  name: 'new-student',
  description: 'Enroll into a Class',
  image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/jA2Oiu8ySQKZNLSTqlvq?cache=true'
})

Merit::Badge.create!({
  id: 2,
  name: 'spherification',
  description: 'Complete the Spherification Class',
  image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/UyGR5gjaQKupcq6qJSR4?cache=true'
})

Merit::Badge.create!({
  id: 3,
  name: 'macaron',
  description: 'Complete the Macaron Class',
  image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/04qCLrJ9Q9CEAacAVisg?cache=true'
})

Merit::Badge.create!({
  id: 4,
  name: 'poutine',
  description: 'Complete the Poutine Class',
  image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/l6M6wNJbR4CffTtCn95j?cache=true'
})

Merit::Badge.create!({
  id: 5,
  name: 'knife',
  description: 'Complete the Knife Sharpening Class',
  image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/QZt7rQzQK6gcuyYngoOb?cache=true'
})

Merit::Badge.create!({
  id: 6,
  name: 'siphon',
  description: 'Complete the Whipping Siphon Class',
  image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/GXn75GCTq6Yze8tUZFM8?cache=true'
})

Merit::Badge.create!({
  id: 7,
  name: 'meat',
  description: 'Complete the How to Cook Meats Class',
  image: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/zYyZBAzSLuCal9kyVcgE?cache=true'
})