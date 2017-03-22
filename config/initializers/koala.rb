# As of 7/26/16, the current version of FB graph api is v2.7
# At the moment, bumping the version past v2.3 has some missing data (email, profile pic)
# The likely issue is FB updated their api and Koala needs to update the gem and/or docs
# The minimum requirement is v2.1 so hopefully v2.3 buys us some time.

# Update - As of 3/1/17, we were able to upgrade to 2.7.  Upgrading from 2.2 to 2.7 required including fields
# expample: Koala::Facebook::API.new(token).get_object('me', {fields: 'email,name'})

Koala.config.api_version = "v2.7"
