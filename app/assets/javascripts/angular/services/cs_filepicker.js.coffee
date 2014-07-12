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

  this.fitURL = (fpObject,width,height) ->
    fitURL = this.cdnURL(fpObject)
    fitURL = fitURL + '/convert?' + $.param({w:width, h:height, cache: true})
    console.log 'This is the fitURL: ', fitURL
    fitURL

  this
]