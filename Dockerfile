FROM ruby:2.5.0
RUN apt-get update -qq \
  && apt-get install -y nodejs libpq-dev postgresql-client build-essential \
  && apt-get clean autoclean && apt-get autoremove -y \
  && rm -rf /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log
COPY . /app
WORKDIR /app
ADD Gemfile /app/
ADD Gemfile.lock  /app/
# Make sure bundler is at the exact same version that Gemfile.lock was
# bundled with. Depending on the versions, the bundle command will fail
# if its version is different from the version we bundled with.
RUN gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)"
RUN bundle install
# We precompile assets during the build phase to reduce release times,
# but we disable asset sync because we don't want to do that until relase
# and because is requires visibility into Heroku config vars, which are
# not available to us here during the build phase.
RUN ASSET_SYNC_ENABLED=false bundle exec rake assets:precompile
