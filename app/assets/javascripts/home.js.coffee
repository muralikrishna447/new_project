areCookiesEnabled = ->
  document.cookie = "__verify=1"
  supportsCookies = document.cookie.length > 1 && document.cookie.indexOf("__verify=1") > -1
  thePast = new Date(1976, 8, 16)
  document.cookie = "__verify=1;expires=" + thePast.toUTCString()
  return supportsCookies

$ ->
  # Hero Swiper
  window.heroSwipe = Swipe(document.getElementById('hero-swiper'),{
    stopPropagation: false,
    continuous: true,
    auto: 6000,
    speed: 600,
    transitionEnd: (index, elem) ->
      $('.hero-indicator-btn').removeClass 'indicator-active'
      id = '#hero-swipe-indicator-' + index
      $(id).addClass 'indicator-active'
    })

  $('.hero-indicator-btn').each ->
    $(this).click ->
      index = $(this).data('slide-to-index')
      window.heroSwipe.slide(index, 300)

  $('.hero-swiper-next').click ->
    window.heroSwipe.next()

  # Content Swiper
  window.mySwipe = Swipe(document.getElementById('swiper'),{
    stopPropagation: true,
    continuous: true,
    transitionEnd: (index, elem) ->
      $('.content-indicator-btn').removeClass 'indicator-active'
      id = '#swipe-indicator-' + index
      $(id).addClass 'indicator-active'
    })

  $('.content-indicator-btn').each ->
    $(this).click ->
      index = $(this).data('slide-to-index')
      window.mySwipe.slide(index, 300)

  window.recipeSwipe = Swipe(document.getElementById('recipe-swiper'),{
    stopPropagation: true,
    continuous: true
    })

  window.recipeSwipe = Swipe(document.getElementById('technique-swiper'),{
    stopPropagation: true,
    continuous: true
    })

  window.recipeSwipe = Swipe(document.getElementById('knowledge-swiper'),{
    stopPropagation: true,
    continuous: true
    })

  if $('#discussion').is('*')
    $.getJSON '/discussion', (data) ->
      discussion = data
      name = discussion['name']
      body = $('<div>' + discussion['body'] + '</div>').text()
      shortbody = $.trim(body).substring(0, 300).trim(this) + "..."
      author = discussion['first_name']
      link = discussion['url'].replace('https://chefsteps.vanillaforums.com','http://forum.chefsteps.com')
      target = $('#discussion')
      target.find('.discussion-name').text(name)
      target.find('.discussion-body').text(shortbody)
      target.find('.discussion-author').text(author)
      target.find('.discussion-link').attr('href', link)

  $('.nav-search-toggle').mouseenter ->
    $(this).closest('.nav-search').addClass('nav-search-show', 300)
    $('#nav-search-field').focus()

  $('.nav-search-hide').click ->
    $('.nav-search').removeClass('nav-search-show', 300)

  unless areCookiesEnabled()
    $(".cookies-disabled").show()


