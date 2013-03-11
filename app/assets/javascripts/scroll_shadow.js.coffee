# $.fn.scrollBottom = function() { 
#   return $(document).height() - this.scrollTop() - this.height(); 
# };

# $.fn.scrollBottom = () ->
#   $(document).height() - this.scrollTop() - this.height()

$ ->
  $('.scroll-shadow').each ->
    scrollable = $(this)
    total_height = scrollable.find('.scroll-shadow-content').height()
    window_height = $(this).height()
    bottom = total_height - window_height
    bottom_low = bottom - 5
    bottom_high = bottom + 5
    scrollable.scroll ->
      y = $(this).scrollTop()
      $('#scrollable-y').text(y)
      $('#scrollable-window-height').text(window_height)
      $('#scrollable-total-height').text(total_height)
      if bottom_low > y > 0
        # $(this).css 'background', 'blue'
      else if bottom_low < y < bottom_high
        # $(this).css 'background', 'red'
      else
        # $(this).css 'background', 'gray'