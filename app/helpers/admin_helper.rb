module AdminHelper
  def copy_button(text, target, destination)
    button_tag(text, type: "button", data: {
      behavior: 'copy-element',
      'copy-target' => target,
      'copy-destination' => destination
    }, class: 'btn-small btn-warning')
  end

  def remove_button(target)
    content_tag(:i, '', class: ['icon-remove', 'icon-large'], data: {
        behavior: 'remove-element',
        'remove-target' => target
    })
  end

  def add_activity_to_list_button(text, src_element, dest_list, insert_what)
    button_tag(text, type: "button", data: {
        behavior: 'add_activity_to_list',
        'src-element' => src_element,
        'dest-list' => dest_list,
        'insert_what' => insert_what,
    }, class: 'admin-button')
  end

  def reorder_icon
    content_tag(:i, '', class: ['icon-reorder', 'icon-large'])
  end

  def admin_button(text, url, options={})
    options.merge!(class: 'admin-button')
    link_to text, url, options
  end

  def task_button(text, url, options={})
    options.merge!(method: :post, confirm: 'Are you sure?')
    admin_button text, url, options
  end

  def sortable_table(id, &block)
    content_tag(:table, id: id, class: ['nested-records', 'sortable'], &block)
  end

  def section(name, form, &block)
    form.inputs(name: name, class: ['inputs', 'no-background'], &block)
  end

  def link_to_publishable(model, text=false)
    model_name = model.class.to_s.underscore
    if model.published?
      link_to text || 'public link', send("#{model_name}_path", model), target: '_blank'
    else
      link_to text || 'private link', send("#{model_name}_path", model, token: PrivateToken.token), target: '_blank'
    end
  end
end
