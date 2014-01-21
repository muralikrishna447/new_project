@app.service 'csUtilities', [ ()  ->

  this.formatTime = (t, showSeconds = true) ->

    h = Math.floor(t / 3600)
    t = t - (h * 3600)
    m = Math.floor(t / 60)
    t = t - (m * 60)
    s = Math.floor(t)
    m += 1 if (s >= 30) && (! showSeconds)

    # Three cases:
    #
    # (1) 6h 1m
    if h > 0
      result = "#{h}h #{m}m"

    # (2) 7m 2s
    else if showSeconds
      # Force a non-zero second so user knows we need precision
      s = 1 if s == 0       
      result = "#{m}m #{s}s"

    # (3) 43 mins
    else
      result = "#{m} min"

    result

  this.cToF = (temp) ->
    Math.round(temp * 9 / 5) + 32

  this.formatTemp = (temp, units) ->
    return "#{temp} &deg;C" if units == 'c'
    "#{this.cToF(temp)} &deg;F"

]
