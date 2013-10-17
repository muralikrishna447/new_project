$ ->
  $(".landing-tab-dropdown li a").click ->
    $("#landingTabLabelText").text $(this).text()
 