  angular.module('ChefStepsApp').service 'csEditableHeroMediaService',  ->

    # Video/image stuff
    this.hasHeroVideo = ->
      this.getObject()?.youtube_id? && this.getObject().youtube_id

    this.hasHeroImage = ->
      this.getObject()?.image_id? && this.getObject().image_id

    this.heroVideoURL = ->
      autoplay = "0"
      "//www.youtube.com/embed/#{this.getObject().youtube_id}?wmode=opaque\&rel=0&modestbranding=1\&showinfo=0\&vq=hd720\&autoplay=#{autoplay}"

    this.heroVideoStillURL = ->
      "//img.youtube.com/vi/#{this.getObject().youtube_id}/0.jpg"

    this.heroImageURL = (width) ->
      url = ""
      if this.hasHeroImage()
        url = JSON.parse(this.getObject().image_id).url
        url + "/convert?fit=max&w=#{width}&cache=true"
      window.cdnURL(url)

    this.heroDisplayType = ->
      return "video" if this.hasHeroVideo()
      return "image" if this.hasHeroImage()
      return "none"
