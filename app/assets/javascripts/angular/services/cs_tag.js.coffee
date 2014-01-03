@app.service 'csTagService', [() ->

  this.indexOfTag = (tagList, tagName) ->
    if tagList
      for tag, index in tagList
        return index if tag.name.toUpperCase() == tagName.toUpperCase()
    -1

  this.hasTag = (tagList, tagName) ->
    this.indexOfTag(tagList, tagName) >= 0

  this.addTag = (tagList, tagName) ->
    tagList.push({name: tagName, id: tagName}) unless this.hasTag(tagList, tagName)

  this.removeTag = (tagList, tagName) ->
    tagList.splice(this.indexOfTag(tagList, tagName), 1)

  this.toggleTag = (tagList, tagName) ->
    if this.hasTag(tagList, tagName)
      this.removeTag(tagList, tagName)
    else
      this.addTag(tagList, tagName)


]