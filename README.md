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
