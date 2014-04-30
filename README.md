<a href="https://codeclimate.com/github/rails/rails"><img src="https://codeclimate.com/github/rails/rails.png" /></a>

# Delve

To get started run:
```bash
$ script/setup
```

# Development

To set up a new machine:



## Required
   
      * install homebrew (brew.sh)
      * brew doctor
      * brew install postgres
      * set postgres to open at login (per output of previous cmd)
      * cat > ~/.curlc
      * 
         * location
      * rails ready install (github.com/joshfng/railsready)
      * close your shell and reopen it
      * git clone https://github.com/ChefSteps/ChefSteps.git
      * cd ChefSteps
      * install latest Xcode
      * launch Xcode once
      * xcode-select —install
      * rvm install ruby (the version our Gemfile calls for)
      * bundle
      * createuser -l -s -r delve
      * rake db:create
      * install heroku toolbelt (toolbelt.heroku.com)
      * rake copy_production_db (you’ll need your heroku acct/passwd and say yes to creating a new public key)
      * rails s
      * in another window:
      * 
         * rake db:test:prepare
         * guard


## Personal / Optional
 
      * install Chrome or other preferred browser
      * install iterm2 or other shell
      * install sublime text 3 or other text editor
      * clipmenu


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

Staging2 ChefSteps
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
npm install -g karma
npm install -g karma-ng-scenario
npm install -g karma-coffee-preprocessor
createdb delve_angular
```

Once they are installed you can run the command:
script/e2e
```

This will start the server.  It will automatically watch all files in the spec/javascripts/e2e folder and run the tests when you save a file.


