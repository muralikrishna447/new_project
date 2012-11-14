module TabHelper
  def tab(text, content_id)
    content_tag(:li, class: ('active' if is_active(content_id))) do
      link_to text, "##{content_id}", data: { toggle: 'tab' }
    end
  end

  def tab_pane(id, &block)
    content_tag(:div, id: id, class: ['tab-pane', ('active' if is_active(id))], &block)
  end

  private
  def is_active(id)
    active_tab == id
  end
end

