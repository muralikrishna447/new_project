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

@components.service 'componentItem', [ ->
  @types = [
    {
      name: 'Hero A'
      className: 'hero.hero-a'
      attrs: ['title', 'image', 'buttonMessage', 'url']
      templateUrl: '/client_views/component_item_hero_a.html'
      formTemplateUrl: '/client_views/component_item_hero_a.html'
    }
    {
      name: 'Square A'
      className: 'square.square-a'
      attrs: ['title', 'image', 'buttonMessage', 'url']
      templateUrl: '/client_views/component_item_square_a.html'
      formTemplateUrl: '/client_views/component_item_square_a_form.html'
    }
    {
      name: 'Circle'
      attrs: ['title', 'image', 'buttonMessage', 'url']
    }
  ]
  return this
]
