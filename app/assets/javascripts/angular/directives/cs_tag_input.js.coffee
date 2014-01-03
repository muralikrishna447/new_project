@app.directive 'cstaginput', [() ->
  restrict: 'E',
  scope: { ngModel: "=", ajaxPath: "="},
  templateUrl: '/client_views/_cs_tag_input'
  priority: 10000

  link: 
    pre: (scope, element, attrs) ->
      scope.getSelect2Info = ->
        placeholder: "Add some tags"
        tags: true
        multiple: true
        width: "100%"

        ajax:
          url: scope.$eval(attrs.ajaxPath),
          data: (term, page) ->
            return {
              q: term
            }

          results: (data, page) ->
            return {results: data}

        formatResult: (tag) ->
          tag.name

        formatSelection: (tag) ->
          tag.name

        createSearchChoice: (term, data) ->
          id: term
          name: term

        initSelection: (element, callback) ->
          callback(scope.$eval(attrs.ngModel))

]
