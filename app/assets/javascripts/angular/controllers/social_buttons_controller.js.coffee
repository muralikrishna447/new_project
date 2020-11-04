angular.module('ChefStepsApp').controller 'SocialButtonsController', ["$scope",  "$timeout", "$http", "$element", '$rootScope', ($scope,  $timeout, $http, $element, $rootScope) ->
  $scope.expandSocial = false;
  $scope.$on 'expandSocialButtons', ->
    $element.find('.pulse-anim-before').addClass('pulse-anim')
    $timeout ( ->
      $element.find('.pulse-anim-before').removeClass('pulse-anim')
    ), 400

  $scope.openSocialWindow = (mixpanel_name, url, spec) ->
    $scope.expandSocial = false
    window.open(url, "_blank", spec || "width=500, height=300, top=100, left=100")
    share_cat = $scope.socialURL().split("/")[3]
    # abtest = localStorageService.get('Split Test: Social Buttons Solid vs Outline')
    # mixpanel.track('Share', { 'Network': mixpanel_name, 'URL' : $scope.socialURL(), 'ShareCat' : share_cat})
    social_attributes = _.extend({ 'Network': mixpanel_name, 'URL' : $scope.socialURL(), 'ShareCat' : share_cat}, $rootScope.splits)

  $scope.shareTwitter = ->
    $scope.twitterCount = if $scope.twitterCount? then $scope.twitterCount + 1 else 1
    $scope.openSocialWindow 'Twitter', "https://twitter.com/intent/tweet?text=" + $scope.tweetMessage() + " " + $scope.socialTitle() + " @ChefSteps&url=" + window.escape($scope.socialURL())

  $scope.shareCS140 = ->
    $scope.openSocialWindow 'Twitter', "https://twitter.com/intent/tweet?text=" + $scope.cs140Message() + " %23cs140 @ChefSteps&url=" + window.escape($scope.socialURL())

  $scope.shareFacebook = ->
    console.log "SHARE FB"
    $scope.facebookCount = if $scope.facebookCount? then $scope.facebookCount + 1 else 1
    $scope.openSocialWindow 'Facebook', "https://www.facebook.com/sharer/sharer.php?u=" + encodeURIComponent($scope.socialURL()), 'width=626,height=436,top=100,left=100'

  $scope.shareGooglePlus = ->
    $scope.gplusCount = if $scope.gplusCount? then $scope.gplusCount + 1 else 1
    $scope.openSocialWindow 'Google Plus', "https://plus.google.com/share?url=" + encodeURIComponent($scope.socialURL()), 'width=600,height=600,top=100,left=100'

  $scope.sharePinterest = ->
    $scope.pinterestCount = if $scope.pinterestCount? then $scope.pinterestCount + 1 else 1
    $scope.openSocialWindow 'Pinterest', "https://pinterest.com/pin/create/button/?url=" + encodeURIComponent($scope.socialURL()) + "&media=" + encodeURIComponent($scope.socialMediaItem()) + "&description=" + encodeURIComponent($scope.socialTitle()), 'width=300,height=600,top=100,left=100'

  $scope.shareEmail = ->
    $scope.openSocialWindow 'Email', "mailto:?subject="+ encodeURIComponent($scope.emailSubject()) + "&body=" + encodeURIComponent($scope.emailBody())

  $scope.shareEmbedly = ->
    embedly 'modal',
      url: $scope.socialURL() + "?utm_source=embedly"

  # Maybe make this a service with caching?
  $scope.getSocialCounts = ->
    www_url = encodeURIComponent($scope.socialURL().replace("//chefsteps", "//www.chefsteps"))

    fb_url = "https://graph.facebook.com/fql?q=SELECT%20total_count%20FROM%20link_stat%20WHERE%20url='" + www_url + "'"
    $http.get(fb_url).success((data) ->
      $scope.facebookCount = data.data[0]?.total_count || 0
    )

    # twitter_url = "http://urls.api.twitter.com/1/urls/count.json?callback=JSON_CALLBACK&url=" + www_url
    twitter_url = "https://cdn.api.twitter.com/1/urls/count.json?callback=JSON_CALLBACK&url=" + www_url
    $http.jsonp(twitter_url).success((data) ->
      $scope.twitterCount = data.count
    )

    pinterest_url = "https://api.pinterest.com/v1/urls/count.json?callback=JSON_CALLBACK&url=" + www_url
    $http.jsonp(pinterest_url).success((data) ->
      $scope.pinterestCount = data.count
    )

    # This is super hacky. Google doesn't have an API for this yet.
    # Many pages, but here is one ref: https://gist.github.com/jonathanmoore/2640302
    # It doesn't work on localhost, I'm *hoping* it works in production.
    # Crap, doesn't look like it is going to, at least not using chefsteps.dev. Just
    # commenting this bs out for now. Next fix would be to add an ajax API in one of our
    # controllers to get the gplus count, to avoid CORS.
    if false
      gplus_api_key = 'AIzaSyD2wo1XzKk1anYQm95yBqklTLEPCy90srk'
      gplus_url = 'https://clients6.google.com/rpc?key=' + gplus_api_key
      $http.post(gplus_url,
      [{
        "method":"pos.plusones.get",
        "id":"p",
        "params":{
          "nolog":true,
          "id": www_url,
          "source":"widget",
          "userId":"@viewer",
          "groupId":"@self"
        },
        "jsonrpc":"2.0",
        "key":"p",
        "apiVersion":"v1"
      }]
      ).success((data) ->
        $scope.gplusCount = data.result.metadata.globalCounts.count
      )


  $scope.getSocialCounts()

  $scope.$on 'socialURLUpdated', (event, url) ->
    console.log url
    $scope.socialURL = () ->
      url

  $scope.showCount = (count) ->
    return false if (! count) || (parseInt(count) == 0)
    true

  $scope.displayCount = (count) ->
    count = parseInt(count)
    return count if count < 1000
    String(Math.floor(count / 1000)) + "k"

]
