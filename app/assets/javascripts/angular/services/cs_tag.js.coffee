@app.service 'csTagService', [() ->

  # Possibly this should be in the db?
  this.ingredientSuggestedTags = [
    {name: "Categories", tags: ["Animal", "Vegetable", "Fruit", "Fungi", "Dairy", "Herb", "Spice", "Modernist", "Beverage", "Pantry"]}
    {name: "More...",  tags: ["Red Meat", "Poultry", "Seafood", "Cheese", "Grain", "Bean", "Nut", "Root", "Condiment"]}
    {name: "Diets",  tags: ["Vegetarian", "Vegan", "Gluten Free", "Kosher", "Paleo"]}
    {name: "Seasons", tags: ["Winter", "Spring", "Summer", "Fall"]}
  ]

  this.activitySuggestedTags = [
    {name: "Primary", tags: ["Sous Vide", "Beef", "Chicken", "Pork", "Seafood", "Pasta", "Chocolate", "Baking", "Salad", "Dessert", "Breakfast", "Cocktail", "Vegetarian"]}
    {name: "Main Ingredient", tags: ["Meat", "Game", "Vegetable", "Poultry", "Cheese", "Fruit", "Grains"]}
    {name: "Diets", tags: ["Vegan", "Gluten Free", "Kosher", "Paleo", "Raw"]}
    {name: "Course", tags: ["Appetizer", "Soup", "Salad", "Main course", "Amuse bouche", "Beverage", "Sauce", "Condiment", "Snack", "Side dish"]}
    {name: "Barriers", tags: ["No Special Equipment", "No Modernist Ingredients"]}
    {name: "Meal", tags: ["Brunch", "Lunch", "Dinner"]}
    {name: "Method", tags: ["Grilling", "Baking", "Pressure Cooker", "Barbeque", "Deep Frying"]}
    {name: "Seasons", tags: ["Winter", "Spring", "Summer", "Fall"]}
    {name: "Misc", tags: ["Holiday", "Quick", "Kid Friendly", "One Pot"]}
  ]

  # I tried creating a directive instead of using ui-select2 directly and setting
  # this up inside the directive but ran into some horror where I couldn't get initSelection
  # to be called. So leaving as is. At least it is factored.
  this.getSelect2Info = (model, ajaxURL) ->
    placeholder: "Add some tags"
    tags: model
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

  this
]