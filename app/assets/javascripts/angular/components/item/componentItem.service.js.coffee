@components.service 'componentItem', [ ->
  @types = [
    {
      name: 'Square A'
      className: 'square.square-a'
      attrs: ['title', 'image', 'buttonMessage', 'url']
      templateUrl: '/client_views/component_matrix_item_square_a.html'
      formTemplateUrl: '/client_views/component_matrix_item_square_a_form.html'
    }
    {
      name: 'Circle'
      attrs: ['title', 'image', 'buttonMessage', 'url']
    }
  ]
  return this
]
