$ ->
  $('.horizontal-slider').each ->
    slider = $(this)
    slider_wrap = slider.find('.horizontal-slider-wrap')
    number_of_objects = slider_wrap.children().length
    object_width = 340
    slider_wrap_width = object_width*number_of_objects
    slider_wrap.width(slider_wrap_width)

    direction = $(this).data('direction')

    if direction == 'right'
      btn_right = slider.find('.horizontal-slider-btn-right')
      btn_right.click ->
        first_object = slider_wrap.children().first()
        slider_wrap.children().animate {left: '-=340'}, 600, 'easeOutExpo', ->
          first_object.remove()
          slider_wrap.children().css 'left', '0'
          slider_wrap.append first_object

    if direction == 'left'
      btn_left = slider.find('.horizontal-slider-btn-left')
      slider_start_left = slider_wrap_width - object_width
      slider_wrap.children().animate {left: '-=' + object_width*4}
      btn_left.click ->
        first_object = slider_wrap.children().first()
        slider_wrap.children().animate {left: '-=340'}, 600, 'easeOutExpo', ->
          first_object.remove()
          slider_wrap.children().css 'left', '0'
          slider_wrap.append first_object
