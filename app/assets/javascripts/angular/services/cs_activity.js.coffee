@app.factory 'Activity', ['$resource', ($resource) ->

  return $resource( "/activities/:id/as_json",
                    {id:  $('#activity-body').data("activity-id") || 1},
                    {
                      update: {method: "PUT"},
                      startedit: {method: "PUT", url: "/activities/:id/notify_start_edit"},
                      endedit: {method: "PUT", url: "/activities/:id/notify_end_edit"}
                      get_as_json: {url: "/activities/:id/as_json", method: "GET"}
                    }
                  )


]

# This can't be the best way to do this, but I can't figure out how to get the objects return from
# $resource above to be Activities, not just Resources, so I can add these methods to the protoype.
@app.service 'ActivityMethods', ["Activity", (Activity) ->

  this.placeHolderImage = ->
    "https://s3.amazonaws.com/chefsteps-production-assets/assets/img_placeholder.jpg"

  # Must match logic in has_Activity#featurable_image !!
  this.itemImageFpfile = (activity, priority) ->
    if activity?
      if priority == 'hero'
        if activity.image_id
          return JSON.parse(activity.image_id)
        else if activity.featured_image_id
          return JSON.parse(activity.featured_image_id)
        else
          if activity.steps?
            images = activity.steps.map (step) -> step.image_id
            image_fpfile = images[images.length - 1]
            return JSON.parse(image_fpfile) if (image_fpfile? && (image_fpfile != ""))
      else
        if activity.featured_image_id
          return JSON.parse(activity.featured_image_id)
        else if activity.image_id
          return JSON.parse(activity.image_id)
        else
          if activity.steps?
            images = activity.steps.map (step) -> step.image_id
            image_fpfile = images[images.length - 1]
            return JSON.parse(image_fpfile) if (image_fpfile? && (image_fpfile != ""))

  this

]