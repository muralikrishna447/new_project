module AdminHelper
  def copy_button(text, target, destination)
    button_tag(text, data: {
      behavior: 'copy-element',
      'copy-target' => target,
      'copy-destination' => destination
    })
  end

  def remove_button(text, target)
    button_tag(text, data: {
      behavior: 'remove-element',
      'remove-target' => target
    })
  end
end
