$ ->
  $('.community-toggle').click ->
    community = $(this).closest('.community')
    community.toggleClass 'community-open', 500