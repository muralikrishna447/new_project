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

  this.addTag = (tagList, tagName) ->
    tagList.push({name: tagName, id: tagName}) unless this.hasTag(tagList, tagName)

  this.hasTag = (tagList, tagName) ->
    _.find(tagList, (x) -> x.name == tagName)


]