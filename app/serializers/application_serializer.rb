class ApplicationSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  if Rails.env.development?
    host = "localhost:3000"
  elsif Rails.env.test?
    host = "test.host"
  else
    host = "www.chefsteps.com"
  end
  Rails.application.routes.default_url_options = {:host => host}
end
