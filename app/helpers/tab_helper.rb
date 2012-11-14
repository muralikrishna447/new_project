module TabHelper
  def tab(text, link, active = false)
    content_tag(:li, class: ('active' if active)) do
      link_to text, link, data: { toggle: 'tab' }
    end
  end

  def tab_pane(id, active = false, &block)
    content_tag(:div, id: id, class: ['tab-pane', ('active' if active)], &block)
  end
end

