FROM ruby:2.0.0-p648
RUN apt-get update -qq \
  && apt-get install -y nodejs libpq-dev postgresql-client build-essential \
  && apt-get clean autoclean && apt-get autoremove -y \
  && rm -rf /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log
COPY . /app
WORKDIR /app
ADD Gemfile /app/
ADD Gemfile.lock  /app/
RUN bundle install
# We precompile assets during the build phase to reduce release times,
# but we disable asset sync because we don't want to do that until relase
# and because is requires visibility into Heroku config vars, which are
# not available to us here during the build phase.
RUN ASSET_SYNC_ENABLED=false bundle exec rake assets:precompile
