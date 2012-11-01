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

  def admin_button(text, url, options={})
    options.merge!(class: 'admin-button')
    link_to text, url, options
  end

  def sortable_table(id, &block)
    content_tag(:table, id: id, class: ['nested-records', 'sortable'], &block)
  end

  def section(name, form, &block)
    form.inputs(name: name, class: ['inputs', 'no-background'], &block)
  end
end
