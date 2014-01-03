@app.service 'csTagService', [() ->
  # Hmm, debating whether I like this here or maybe in a directive controller
  this.getSelect2Info = (model, ajaxURL) ->
    placeholder: "Add some tags"
    tags: true
    multiple: true
    width: "100%"

    ajax:
      url: ajaxURL,
      data: (term, page) ->
        return {
          q: term
        }

      results: (data, page) ->
        return {results: data}

    formatResult: (tag) ->
      tag.name

    formatSelection: (tag) ->
      tag.name

    createSearchChoice: (term, data) ->
      id: term
      name: term

    initSelection: (element, callback) ->
      callback(model)

  this.indexOfTag = (tagList, tagName) ->
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