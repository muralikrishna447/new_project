module AdminHelper
  def copy_button(text, target, destination)
    button_tag(text, data: {
      behavior: 'copy-element',
      'copy-target' => target,
      'copy-destination' => destination
    }, class: 'admin-button')
  end

  def remove_button(target)
    button_tag(data: {
      behavior: 'remove-element',
      'remove-target' => target
    }) do
      content_tag(:i, '', class: ['icon-remove'])
    end
  end

  def reorder_icon
    content_tag(:i, '', class: ['icon-reorder', 'icon-large'])
  end
end

