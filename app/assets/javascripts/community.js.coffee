$ ->
  $('.community-toggle').click ->
    community = $(this).closest('.community')
    community.toggleClass 'community-open', 500
    $(this).toggleClass 'community-toggle-open', 500