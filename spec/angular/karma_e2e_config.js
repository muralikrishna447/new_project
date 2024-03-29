// Karma configuration
// Generated on Tue Oct 01 2013 20:15:03 GMT-0400 (EDT)

module.exports = function(config) {
  config.set({

    // base path, that will be used to resolve files and exclude
    basePath: '../..',


    // frameworks to use
    frameworks: ['ng-scenario'],

    preprocessors: {
      'spec/angular/**/*.coffee': ['coffee'],
    },


    // list of files / patterns to load in the browser
    files: [
      'http://localhost:3001/assets/angular.js',
      // 'http://localhost:3000/assets/angular-scenario.js',
      "http://code.jquery.com/jquery-1.10.1.min.js",
      'http://localhost:3001/assets/application.js',
      'spec/angular/**/u*.js.coffee',
      { pattern: 'app/assets/javascripts/**/*.js.coffee',
        watched: true,
        included: false,
        served: false
      }
    ],


    // list of files to exclude
    exclude: [

    ],


    // test results reporter to use
    // possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
    reporters: ['progress'],


    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    // logLevel: config.LOG_DEBUG,
    logLevel: config.LOG_INFO,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,


    // Start these browsers, currently available:
    // - Chrome
    // - ChromeCanary
    // - Firefox
    // - Opera
    // - Safari (only Mac)
    // - PhantomJS
    // - IE (only Windows)
    browsers: [
      // 'PhantomJS',
      "Chrome_without_security",
      // "Safari",
      // "Firefox"
    ],

    customLaunchers: {
      Chrome_without_security: {
        base: 'Chrome',
        flags: ['--disable-web-security']
      }
    },

    // If browser does not capture in given timeout [ms], kill it
    captureTimeout: 60000,


    // Continuous Integration mode
    // if true, it capture browsers, run tests and exit
    singleRun: false,

    urlRoot: "e2e",


    proxies: {
      '/': 'http://localhost:3001/'
    }

  });
};
