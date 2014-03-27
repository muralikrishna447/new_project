@app.service 'csAdwords', [ ->

  this.track = (google_conversion_id, google_conversion_label) ->
    image = new Image(1,1)
    image.src = "http://www.googleadservices.com/pagead/conversion/" + google_conversion_id + "/?label=" + google_conversion_label + "&script=0"
  this

]