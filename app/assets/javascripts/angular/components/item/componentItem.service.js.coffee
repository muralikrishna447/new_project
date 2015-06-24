# Configuration service for different components

# Usage:
# name: Name of the item
# className: The class name to attach to the item
# attrs: Attributes for item
# templateUrl
# formTemplateUrl

# To create a new component:
# * Add a configuration hash in @types
# * Create the template and the form template
# * Add file for css

@components.service 'componentItemService', [ ->
  @types = [
    {
      id: 1
      name: 'Hero'
      attrs: ['title', 'image', 'buttonMessage', 'url']
      templateUrl: '/client_views/component_item_hero.html'
    }
    {
      id: 2
      name: 'List'
      attrs: ['title', 'image', 'description', 'url']
      templateUrl: '/client_views/component_item_list.html'
    }
    {
      id: 3
      name: 'Media'
      attrs: ['title', 'image', 'description', 'url']
      templateUrl: '/client_views/component_item_media.html'
    }
    {
      id: 4
      name: 'Square'
      attrs: ['title', 'image', 'buttonMessage', 'url']
      templateUrl: '/client_views/component_item_square.html'
    }
    {
      id: 5
      name: 'Header'
      attrs: ['header', 'subheader']
      templateUrl: '/client_views/component_item_header.html'
    }
  ]

  @get = (name) =>
    _.where(@types, {name: name})[0]

  @getStruct = (name) =>
    itemType = @get(name)
    struct = {}
    if itemType
      for attr in itemType.attrs
        struct[attr] = ''
    return struct


  return this
]
