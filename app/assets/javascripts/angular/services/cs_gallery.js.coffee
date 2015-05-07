@app.service 'csGalleryService',  ->

  this.itemImageURL = (item, width) ->
    fpfile = $scope.itemImageFpfile(item)
    height = width * 9.0 / 16.0
    return (window.cdnURL(fpfile.url) + "/convert?fit=crop&w=#{width}&h=#{height}&quality=70&cache=true") if (fpfile? && fpfile.url?)
    $scope.placeHolderImage

  this