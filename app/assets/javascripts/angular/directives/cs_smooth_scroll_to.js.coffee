@app.directive 'csSmoothScrollTo', [() ->
  restrict: 'A'
  scope: {     
    csSmoothScrollTo: '@' 
  }

  link: ($scope, $element, $attrs) ->
    $($element).on 'click', ->
      target = $attrs.csSmoothScrollTo
      y = $(target).offset().top - 120
      $('html,body').animate({'scrollTop' : y}, 1000, 'easeInOutExpo') if y
]

