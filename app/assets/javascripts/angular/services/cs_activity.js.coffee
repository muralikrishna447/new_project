@app.factory 'Activity', ['$resource', ($resource) ->
  Activity = $resource( "/activities/:id/as_json",
                    {id:  $('#activity-body').data("activity-id") || 1},
                    {
                      update: {method: "PUT"},
                      startedit: {method: "PUT", url: "/activities/:id/notify_start_edit"},
                      endedit: {method: "PUT", url: "/activities/:id/notify_end_edit"}
                      index_as_json: {method: "GET", url: "/gallery/index_as_json.json", isArray: true}
                    }
                  )
  angular.extend Activity::,
    placeHolderImage = ->
      "https://s3.amazonaws.com/chefsteps-production-assets/assets/img_placeholder.jpg"

]