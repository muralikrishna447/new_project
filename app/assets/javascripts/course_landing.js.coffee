$ ->
  $(".landing-tab-dropdown li a").click ->
    $("#landingTabLabelText").text $(this).text()
    $('li.dropdown.open').removeClass('open')
    true
 