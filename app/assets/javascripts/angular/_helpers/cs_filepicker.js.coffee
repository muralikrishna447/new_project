# This service helps DRY up a lot of filepicker converting and cropping

@helpers.service 'csFilepickerMethods', ['$q', ($q) ->

  baseURL = null
  cdnURL = null

  this.csLog = (variableName, variable) ->
    console.log "***************************************"
    console.log "This is the value of #{variableName}:"
    console.log variable
    console.log "***************************************"

  this.getBaseURL = (fpObject) ->
    try
      parsed = JSON.parse(fpObject)
      baseURL = parsed.url
    catch e
      baseURL = fpObject
    baseURL

  this.cdnURL = (fpObject) ->
    cdnURL = this.getBaseURL(fpObject).replace("www.filepicker.io", "d3awvtnmmsvyot.cloudfront.net")
    cdnURL

  # Below is a universal Filepicker image conversion
  # A filepicker object is required
  # It accepts options for width, height, and aspect
  #
  # Use cases:
  #
  # To convert an image and provide only width, it will preserve the natural aspect
  # csFilepickerMethods.convert(FilepickerObject, {width: 600})    note: {w: 600} also works
  #
  # To convert an image and provide width and an aspect ratio, it will calculate height based on that aspect
  # csFilepickerMethods.convert(FilepickerObject, {width: 600, aspect: "16:9"})    note: {w: 600, a: "16:9"} also works
  #
  # To convert an image and provide only height, it will also preserve the natural aspect
  # csFilepickerMethods.convert(FilepickerObject, {height: 600})    note: {h: 600} also works
  #
  # To convert an image and provide height and an aspect ratio, it will calculate height based on that aspect
  # csFilepickerMethods.convert(FilepickerObject, {height: 600, aspect: "16:9"})    note: {h: 600, a: "16:9"} also works
  #
  # Providing both width and height, it will ignore aspect ratio and provide an image cropped to the specified dimensions
  # csFilepickerMethods.convert(FilepickerObject, {height: 400, width: 300})

  this.convert = (fpObjectOrImageUrl, options = {}) ->

    # Accept both verbose and shorthand
    width = options.w || options.width
    height = options.h || options.height
    aspect = options.a || options.aspect
    quality = options.quality || 90

    # Moved try catch to getBaseURL where we're trying to parse the FilepickerObject
    convertURL = this.cdnURL(fpObjectOrImageUrl)

    return "" if (! convertURL) || (convertURL.length == 0)

    if aspect
      aspectArray = aspect.split(':')
      aspectWidth = aspectArray[0]
      aspectHeight = aspectArray[1]

    # Only width is provided
    if width &&  ! height
      if aspect
        newHeight = width * aspectHeight / aspectWidth
        convertURL = convertURL + "/convert?fit=crop&w=#{width}&h=#{newHeight}&quality=#{quality}&cache=true&rotate=exif"
      else
        convertURL = convertURL + "/convert?fit=max&w=#{width}&quality=#{quality}&cache=true&rotate=exif"

    # Only height is provided
    if ! width && height
      if aspect
        newWidth = height * aspectWidth / aspectHeight
        convertURL = convertURL + "/convert?fit=crop&w=#{newWidth}&h=#{height}&quality=#{quality}&cache=true&rotate=exif"
      else
        convertURL = convertURL + "/convert?fit=max&h=#{height}&quality=#{quality}&cache=true&rotate=exif"

    # Both width and height provided
    if width && height
      convertURL = convertURL + "/convert?fit=crop&w=#{width}&h=#{height}&quality=#{quality}&cache=true&rotate=exif"

    convertURL

  this
]
