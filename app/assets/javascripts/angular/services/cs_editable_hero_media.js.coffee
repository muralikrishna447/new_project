  angular.module('ChefStepsApp').service 'csEditableHeroMediaService',  ->

    # Video/image stuff
    this.hasHeroVideo = ->
      if this.getObject()?.youtube_id || this.getObject()?.vimeo_id
        return true
      else
        return false
    this.hasHeroImage = ->
      this.getObject()?.image_id? && this.getObject().image_id

    this.baseHeroImageURL = ->
      url = ""
      if this.hasHeroImage()
        url = JSON.parse(this.getObject().image_id).url
      url

    this.heroImageURL = (width) ->
      url = this.baseHeroImageURL() + "/convert?fit=max&w=#{width}&cache=true"
      window.cdnURL(url)

    this.heroDisplayType = ->
      return "video" if this.hasHeroVideo()
      return "image" if this.hasHeroImage()
      return "none"

    this
