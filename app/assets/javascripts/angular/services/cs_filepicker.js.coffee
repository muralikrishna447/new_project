# This service helps DRY up a lot of filepicker converting and cropping

@app.service 'csFilepickerMethods', [ ->

  baseURL = null
  cdnURL = null

  this.getBaseURL = (fpObject) ->
    baseURL = JSON.parse(fpObject).url
    # console.log 'This is the baseURL: ', baseURL
    baseURL

  this.cdnURL = (fpObject) ->
    cdnURL = this.getBaseURL(fpObject).replace("www.filepicker.io", "d3awvtnmmsvyot.cloudfront.net")
    console.log 'This is the cdnRUL: ', cdnURL
    cdnURL

  # To convert a Filepicker Object to a width of 600, defaults to 16:9
  # csFilepickerMethods.convert(FilePickerObject, 600)
  #
  # To convert a Filepicker Object to a width of 800 and height of 600
  # csFilepickerMethods.convert(FilePickerObject, 800, 600)
  #
  # You can also replace height with an aspect ratio
  # csFilepickerMethods.convert(FilePickerObject, 800, "16:9")
  this.convert = (fpObject,width,height) ->
    # Sets default height to have an aspect ratio of 16:9
    height = (if typeof height isnt 'undefined' then height else "16:9")

    # Get the CDN URL
    convertURL = this.cdnURL(fpObject)

    # If an aspect ratio is defined instead of height, crop the image to fit
    aspect = height.toString().split(':')
    if aspect.length == 2
      aspectWidth = aspect[0]
      aspectHeight = aspect[1]
      height = width*aspectHeight/aspectWidth
      fit = 'crop'
    else
      fit = 'max'

    convertURL = convertURL + '/convert?' + $.param({fit: fit, w:width, h:height, cache: true})
    convertURL

  this
]