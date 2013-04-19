$ ->
  $('.horizontal-swiper').each ->
    swiper = $(this)
    swiper_wrap = swiper.find('.horizontal-swiper-wrap')
    number_of_objects = swiper_wrap.children().length
    object_width = 340
    swiper_wrap.width(object_width*number_of_objects)

    btn_right = swiper.find('.horizontal-swiper-btn-right')
    btn_right.click ->
      # swiper_wrap.animate {left: '-=340'}, 200, ->
      #   first_object = swiper_wrap.children().first()
      #   first_object.remove()
      first_object = swiper_wrap.children().first()
      swiper_wrap.children().animate {left: '-=340'}, 300, ->
        first_object.remove()
        swiper_wrap.children().css 'left', '0'
        swiper_wrap.append first_object
