<a href="https://codeclimate.com/github/rails/rails"><img src="https://codeclimate.com/github/rails/rails.png" /></a>

# Delve

To get started run:
```bash
$ script/setup
```

## Development

Postgres - OSX:
```bash
$ brew install autoconf
$ brew install postgres
```

You need to install phantomjs to run jasmine specs with guard.

PhantomJS - OSX:
```bash
$ brew install phantomjs
```

PhantomJS - Ubuntu:
```bash
$ sudo apt-get install phantomjs
```

For more info: [guard-jasmine](https://github.com/netzpirat/guard-jasmine)

## Forum Photo Uploads
We use Filepicker for image uploads.  The main code can be found in navigation_bootstrap.js.coffee.erb.

This file is precompiled, then synced with the cdn as navigation_bootstrap.js

To get vanilla to use this file, it is included in the Forum > Dashboard > Customize Theme

Make sure to use the latest uploaded version of navigation_bootstrap.js.  You may need to go to CloudFront account to find this.

=Staging2 ChefSteps
=

Deploying to Staging2
-
git checkout develop2
merge paid-courses (or whatever you are working on) into develop2
git push staging2 develop2:master

Run migrations on Staging2
-
heroku run rake db:migrate --app staging2-chefsteps

Copy Production Database to Staging2
-
1. heroku pgbackups:restore HEROKU_POSTGRESQL_CHARCOAL 'heroku pgbackups:url --app production-chefsteps' --app staging2-chefsteps

2. This will give a warning asking you to type in 'staging2-chefsteps' to confirm the destructive action.  **Make sure it says staging2.**


# Dan's Notes on E2E testing
To perform E2E testing on angular you need to have node.js installed if you don't already.  You will also need the Karma test runner installed, as well as the ng-scenario and coffee-preprocessor plugins for karma.  You can install them with the following commands:
```bash
brew install nodejs
npm install karma
npm install karma-ng-scenario
npm install karma-coffee-preprocessor
```

Once they are installed you can run the command:
```bash
karma start config/karma.js
```

This will start the server.  It will automatically watch all files in the spec/javascripts/e2e folder and run the tests when you save a file.
