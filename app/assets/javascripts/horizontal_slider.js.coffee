$ ->
  $('.horizontal-slider').each ->
    slider = $(this)
    slider_wrap = slider.find('.horizontal-slider-wrap')
    number_of_objects = slider_wrap.children().length
    object_width = 380
    slider_wrap_width = object_width*number_of_objects
    slider_wrap.width(slider_wrap_width)
    num_objects_to_slide = Math.floor(slider.width()/object_width)
    distance_to_slide = num_objects_to_slide*object_width

    direction = $(this).data('direction')

    if direction == 'right'
      btn_right = slider.find('.horizontal-slider-btn-right')
      slider.active = false
      btn_right.click ->
        if !slider.active
          slider.active = true
          objects_to_slide = slider_wrap.children().slice(0,num_objects_to_slide)
          slider_wrap.children().animate {left: '-=' + distance_to_slide}, 600, 'easeOutExpo', ->
            objects_to_slide.remove()
            slider_wrap.append objects_to_slide
            slider_wrap.children().css 'left', '0'
            slider.active = false

    if direction == 'left'
      btn_left = slider.find('.horizontal-slider-btn-left')
      slider_start_left = slider_wrap_width - slider.parent().width()
      slider_wrap.children().css 'left', '-' + slider_start_left
      slider.active = false
      btn_left.click ->
        if !slider.active
          slider.active = true
          objects_to_slide = slider_wrap.children().slice(number_of_objects - num_objects_to_slide, number_of_objects)
          slider_wrap.children().animate {left: '+=' + distance_to_slide}, 600, 'easeOutExpo', ->
            objects_to_slide.remove()
            slider_wrap.prepend objects_to_slide
            slider_wrap.children().css 'left', '-' + slider_start_left
            slider.active = false
          
