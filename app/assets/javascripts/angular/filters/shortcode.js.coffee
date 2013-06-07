convertCtoF = (c) ->
  (Math.round(parseFloat(c * 1.8)) + 32)

convertFtoC = (f) ->
  (Math.round(parseFloat(f - 32) / 1.8))

angular.module('ChefStepsApp').filter "shortcode", ->
  (input) ->

    if input
      input.replace /\[(\w+)\s+([^\]]*)\]/g, (orig, shortcode, contents) ->
        switch shortcode
          when 'c' then "<span class='temperature'>#{convertCtoF(contents)} &deg;F / #{contents} &deg;C</span>"
          when 'f' then "<span class='temperature'>#{contents} &deg;F / #{convertFtoC(contents)} &deg;C</span>"
          when 'cm' then "<a class='length-group'><span class='length' data-orig-value='#{contents}'>#{contents} cm</span></a>"
          when 'mm' then "<a class='length-group'><span class='length' data-orig-value='#{contents / 10.0}'>#{contents} mm</span></a>"
          when 'g' then "<span class='text-quantity-group'><span class='quantity-group qtyfade'><span class='lbs-qty'></span> <span class='lbs-label'></span> <span class='main-qty' data-orig-value='#{contents}'}}>#{contents}</span></span> <span class='unit qtyfade'>g</span></span>"
          when 'ea' then "<span class='text-quantity-group'><span class='quantity-group qtyfade'><span class='lbs-qty'></span> <span class='lbs-label'></span> <span class='main-qty'>#{contents}</span></span> <span class='unit qtyfade alwayshidden'>ea</span></span>"
          when 'amzn'
            s = contents.match(/([^\s]*)\s(.*)/)
            if s && s.length == 3
              asin = s[1]
              anchor_text = s[2]
              "<a href='http://www.amazon.com/dp/#{asin}/?tag=delvkitc-20' target='_blank'>#{anchor_text}</a>"
            else
              orig

          else orig
    else
      ""