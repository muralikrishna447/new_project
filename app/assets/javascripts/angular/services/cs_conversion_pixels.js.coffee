@app.service 'csAdwords', [ ->

  this.track = (google_conversion_id, google_conversion_label) ->
    image = new Image(1,1)
    image.src = "http://www.googleadservices.com/pagead/conversion/" + google_conversion_id + "/?label=" + google_conversion_label + "&script=0"
  this

]

@app.service 'csFacebookConversion', [ ->

  this.track = (fb_pixel, fb_value) ->
    # image = new Image(1,1)
    # image.src = "//www.facebook.com/offsite_event.php?id=" + fb_pixel + "&amp;value=" + fb_value + "&amp;currency=USD"
    window._fbq.push(['track', fb_pixel, {'value':fb_value,'currency':'USD'}])
  this

]