convertCtoF = (c) ->
  (Math.round(parseFloat(c * 1.8)) + 32)

convertFtoC = (f) ->
  (Math.round(parseFloat(f - 32) / 1.8))

angular.module('ChefStepsApp').filter "shortcode", ->
  (input) ->

    if input
      input.replace /\[(\w+)\s+([^\]]*)\]/g, (orig, shortcode, contents) ->
        arg1 = contents
        arg2 = null
        s = contents.match(/([^\s]*)\s(.*)/)
        if s && s.length == 3
          arg1 = s[1]
          arg2 = s[2]

        switch shortcode
          when 'c' then "<span class='temperature'>#{convertCtoF(contents)}&nbsp;&deg;F / #{contents}&nbsp;&deg;C</span>"
          when 'f' then "<span class='temperature'>#{contents}&nbsp;&deg;F / #{convertFtoC(contents)}&nbsp;&deg;C</span>"
          when 'cm' then "<a class='length-group'><span class='length' data-orig-value='#{contents}'>#{contents}&nbsp;cm</span></a>"
          when 'mm' then "<a class='length-group'><span class='length' data-orig-value='#{contents / 10.0}'>#{contents}&nbsp;mm</span></a>"
          when 'g' then "<span class='text-quantity-group'><span class='quantity-group qtyfade'><span class='lbs-qty'></span> <span class='lbs-label'></span> <span class='main-qty' data-orig-value='#{contents}'}}>#{contents}</span></span> <span class='unit qtyfade'>g</span></span>"
          when 'ea' then "<span class='text-quantity-group'><span class='quantity-group qtyfade'><span class='lbs-qty'></span> <span class='lbs-label'></span> <span class='main-qty'>#{contents}</span></span> <span class='unit qtyfade alwayshidden'>ea</span></span>"
          when 'courseActivity' 
            if arg2
              "<a ng-click='loadSubrecipe(#{arg1})'>#{arg2}</a>"
            else
              "<b>Badly formatted courseActivity shortcode<b>"
          when 'link'
            if arg2
              "<a href='#{arg1}' target='_blank'>#{arg2}</a>"
            else
              "<a href='#{arg1}' target='_blank'>#{arg1}</a>"
          when 'amzn'
            if arg2
              asin = arg1
              anchor_text = arg2
              "<a href='http://www.amazon.com/dp/#{asin}/?tag=delvkitc-20' target='_blank'>#{anchor_text}</a>"
            else
              orig
          when 'view'
           "<a ng-click=\"$parent.showNell('#{arg1}.html')\">#{arg2}</a>"           
          when 'fetchIngredient'
            """
             <div cs-fetch='#{arg1}' type='Ingredient' part='#{arg2}' card='_ingredient_embed_card.html'>
              </div>
            """
          when 'fetchActivity'
            """
              <div cs-fetch='#{arg1}' type='Activity' part='#{arg2}' card='_activity_embed_card.html'></div>
            """
          when 'linktocomments'
            "<a href='#comments'>#{contents}</a>"
          when 'quote'
            arg1 = arg1.replace('_', ' ')
            """
              <div class="quote-container">
                <hr/>
                <blockquote>
                  #{arg2}
                </blockquote>
                <div class="quote-source">
                  #{arg1}
                </div>
                <hr/>
              </div>
          """
          when 'fetchTool'
            """
              <div cs-fetch-tool='#{arg1}'></div>
            """
          when 'videoLoop'
            if window.ionic
              """
                <script>
                  this.app.service('LoopingVideoManager', [
                    '$document', '$location', function($document, $location) {
                      this.videos = [];
                      this.addVideoScope = function(scope) {
                        return this.videos.push(scope);
                      };
                      this.removeScope = function(currentScope) {
                        var videos;
                        videos = this.videos;
                        return videos.forEach(function(scope, i) {
                          if (scope === currentScope) {
                            return videos.splice(i, 1);
                          }
                        });
                      };
                      this.play = function(currentScope) {
                        var scope, _i, _len, _ref, _results;
                        _ref = this.videos;
                        _results = [];
                        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                          scope = _ref[_i];
                          if (scope === currentScope) {
                            scope.video[0].play();
                            scope.playing = true;
                            _results.push(mixpanel.track("Video Loop Played", {
                              "name": scope.videoName,
                              "url": $location.absUrl()
                            }));
                          } else {
                            scope.video[0].pause();
                            _results.push(scope.playing = false);
                          }
                        }
                        return _results;
                      };
                      this.pause = function(currentScope) {
                        currentScope.video[0].pause();
                        currentScope.playing = false;
                        return mixpanel.track("Video Loop Paused", {
                          "name": currentScope.videoName,
                          "url": $location.absUrl()
                        });
                      };
                      angular.element($document[0].body).on('click', (function(_this) {
                        return function(e) {
                          var isVideoLoop, service, videos;
                          videos = _this.videos;
                          service = _this;
                          console.log("clicked the body: " + e);
                          isVideoLoop = angular.element(e.target).inheritedData('videoLoop');
                          console.log("isVideoLoop: " + isVideoLoop);
                          if (isVideoLoop !== true) {
                            console.log("pausing video");
                            return videos.forEach(function(scope, i) {
                              if (scope.playing) {
                                return service.pause(scope);
                              }
                            });
                          }
                        };
                      })(this));
                      return this;
                    }
                  ]);

                  this.app.directive('csLoopingVideoPlayer', [
                    '$sce', 'LoopingVideoManager', '$timeout', '$location', function($sce, LoopingVideoManager, $timeout, $location) {
                      return {
                        restrict: 'A',
                        scope: {
                          videoName: '@',
                          videoImage: '@'
                        },
                        templateUrl: '/client_views/cs_looping_video.html',
                        controller: [
                          '$scope', '$element', function($scope, $element) {
                            $scope.video = $element.find("video");
                            $scope.video[0].defaultPlaybackRate = 1;
                            $scope.playbackRate = 1;
                            LoopingVideoManager.addVideoScope($scope);
                            $scope.playing = false;
                            $scope.sliderValue = 0;
                            $scope.baseUrl = "https://d29uyzek4esgj1.cloudfront.net/";
                            if ($scope.videoName) {
                              $scope.sources = [$scope.baseUrl + $scope.videoName + "-480p.mp4", $scope.baseUrl + $scope.videoName + "-480p.webm"];
                            }
                            $scope.timeToSlider = function(time) {
                              var sliderValue;
                              sliderValue = (100 / $scope.video[0].duration) * time;
                              return sliderValue;
                            };
                            $scope.sliderToTime = function(sliderValue) {
                              var time;
                              return time = sliderValue * $scope.video[0].duration / 100;
                            };
                            return $scope.onTimeUpdate = function() {
                              var currentTime, desiredTime, duration, video;
                              if (!$scope.mousedown) {
                                video = $element.find('video');
                                currentTime = video[0].currentTime;
                                desiredTime = $scope.sliderToTime($scope.sliderValue);
                                duration = video[0].duration;
                                return $scope.$apply(function() {
                                  return $scope.sliderValue = $scope.timeToSlider(currentTime);
                                });
                              }
                            };
                          }
                        ],
                        link: function(scope, element, attrs) {
                          element.data('videoLoop', true);
                          scope.trustedVideoUrl = function(videoUrl) {
                            return $sce.trustAsResourceUrl(videoUrl);
                          };
                          scope.toggle = function() {
                            if (scope.playing) {
                              return LoopingVideoManager.pause(scope);
                            } else {
                              return LoopingVideoManager.play(scope);
                            }
                          };
                          scope.setRate = function(rate) {
                            scope.playbackRate = rate;
                            scope.video[0].playbackRate = rate;
                            scope.showDisplay = true;
                            mixpanel.track("Video Loop Playback Rate Changed", {
                              "name": scope.videoName,
                              "rate": rate,
                              "url": $location.absUrl()
                            });
                            return $timeout((function() {
                              return scope.showDisplay = false;
                            }), 1000);
                          };
                          scope.speedUp = function() {
                            var currentRate, newRate;
                            currentRate = scope.video[0].playbackRate;
                            if (currentRate >= 1) {
                              newRate = currentRate + 1;
                            } else {
                              newRate = currentRate * 2;
                            }
                            return scope.setRate(newRate);
                          };
                          scope.slowDown = function() {
                            var currentRate, newRate;
                            currentRate = scope.video[0].playbackRate;
                            if (currentRate > 1) {
                              newRate = currentRate - 1;
                            } else {
                              newRate = currentRate / 2;
                            }
                            return scope.setRate(newRate);
                          };
                          scope.onmousedown = function() {
                            scope.mousedown = true;
                            LoopingVideoManager.pause(scope);
                            return console.log("Slider Focused: " + scope.mousedown);
                          };
                          scope.onmouseup = function() {
                            scope.mousedown = false;
                            LoopingVideoManager.play(scope);
                            return console.log("Slider Focused: " + scope.mousedown);
                          };
                          scope.$watch('sliderValue', function(newValue, oldValue) {
                            if (scope.mousedown && newValue !== oldValue) {
                              scope.video[0].currentTime = scope.sliderToTime(newValue);
                              return console.log("Video current time updated");
                            }
                          });
                          scope.video.bind('timeupdate', scope.onTimeUpdate);
                          return element.bind('$destroy', function() {
                            return LoopingVideoManager.removeScope(scope);
                          });
                        }
                      };
                    }
                  ]);
                </script>
                <style>
                  .video-loop-player {
                    position: relative;
                    margin-bottom: 1.1rem;
                  }
                  .video-loop-player video {
                    width: 100%;
                    display: block;
                    background-color: black;
                  }
                  .video-loop-player .video-loop-display {
                    position: absolute;
                    top: 0px;
                    left: 0px;
                    width: 100%;
                    height: 100%;
                    display: flex;
                    display: -webkit-flex;
                    display: -moz-flex;
                    display: -o-flex;
                    -webkit-align-content: center;
                    -moz-align-content: center;
                    -ms-align-content: center;
                    -o-align-content: center;
                    align-content: center;
                    -webkit-justify-content: center;
                    -moz-justify-content: center;
                    -ms-justify-content: center;
                    -o-justify-content: center;
                    justify-content: center;
                    -webkit-align-items: center;
                    -moz-align-items: center;
                    -ms-align-items: center;
                    -o-align-items: center;
                    align-items: center;
                    pointer-events: none;
                  }
                  .video-loop-player .video-loop-display .display-item {
                    -webkit-flex: 0 1 auto;
                    -moz-flex: 0 1 auto;
                    -ms-flex: 0 1 auto;
                    -o-flex: 0 1 auto;
                    flex: 0 1 auto;
                    font-size: 2.2rem;
                    color: white;
                  }
                  .video-loop-player .video-loop-overlay {
                    position: absolute;
                    top: 0px;
                    width: 100%;
                    height: 100%;
                  }
                  .video-loop-player .video-loop-controls {
                    position: absolute;
                    bottom: 0px;
                    left: 0px;
                    width: 100%;
                    height: 4.4rem;
                    font-size: 2.2rem;
                    display: flex;
                    display: -webkit-flex;
                    display: -moz-flex;
                    display: -o-flex;
                    -webkit-justify-content: space-between;
                    -moz-justify-content: space-between;
                    -ms-justify-content: space-between;
                    -o-justify-content: space-between;
                    justify-content: space-between;
                  }
                  .video-loop-player .video-loop-controls .video-loop-control {
                    box-sizing: border-box;
                    -moz-box-sizing: border-box;
                    -webkit-box-sizing: border-box;
                    -o-box-sizing: border-box;
                  }
                  .video-loop-player .video-loop-controls .video-loop-control.video-loop-button {
                    color: white;
                    padding: 1.1rem;
                    box-sizing: border-box;
                    -moz-box-sizing: border-box;
                    -webkit-box-sizing: border-box;
                    -o-box-sizing: border-box;
                  }
                  .video-loop-player .video-loop-controls .video-loop-control.video-loop-button:hover {
                    cursor: pointer;
                    color: #e25f25;
                  }
                  .video-loop-player .video-loop-controls .video-loop-control.video-loop-button-toggle {
                    color: white;
                    padding: 7px 10px;
                    font-size: 30px;
                    box-sizing: border-box;
                    -moz-box-sizing: border-box;
                    -webkit-box-sizing: border-box;
                    -o-box-sizing: border-box;
                  }
                  .video-loop-player .video-loop-controls .video-loop-control.video-loop-button-toggle:hover {
                    cursor: pointer;
                    color: #e25f25;
                  }
                  .video-loop-player .video-loop-controls .video-loop-control.video-loop-slider {
                    -webkit-flex: 1 1 auto;
                    -moz-flex: 1 1 auto;
                    -ms-flex: 1 1 auto;
                    -o-flex: 1 1 auto;
                    flex: 1 1 auto;
                  }
                  .video-loop-player .video-loop-controls .video-loop-control.video-loop-slider input[type="range"] {
                    width: 100%;
                    height: 2px;
                    vertical-align: -3px;
                    border-radius: 0px;
                    border: none;
                    box-sizing: border-box;
                    -moz-box-sizing: border-box;
                    -webkit-box-sizing: border-box;
                    -o-box-sizing: border-box;
                  }
                  .video-loop-player .video-loop-controls .video-loop-control.video-loop-slider input[type="range"]:hover {
                    cursor: pointer;
                  }
                  .video-loop-player .video-loop-controls .video-loop-control.video-loop-slider input[type="range"]::-webkit-slider-thumb {
                    height: 1.1rem;
                    width: 1.1rem;
                    background: white;
                  }
                  .video-loop-player .video-loop-controls .video-loop-control.video-loop-slider input[type="range"]::-webkit-slider-thumb:hover {
                    background: #e25f25;
                  }
                </style>
                <div cs-looping-video-player video-name='#{arg1}' video-image='#{arg2}'></div>
              """
            else
              """
                <div cs-looping-video-player video-name='#{arg1}' video-image='#{arg2}'></div>
              """
          else orig
    else
      ""
