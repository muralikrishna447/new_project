convertCtoF = (c) ->
  (Math.round(parseFloat(c * 1.8)) + 32)

convertFtoC = (f) ->
  (Math.round(parseFloat(f - 32) / 1.8))

@helpers.filter "shortcode", ->
  (input) ->

    if input
      input.replace /\[(\w+)\s+([^\]]*)\]/g, (orig, shortcode, contents) ->
        arg1 = contents
        arg2 = null
        s = contents.match(/([^\s]*)\s(.*)/)
        if s && s.length == 3
          arg1 = s[1]
          arg2 = s[2]

        switch shortcode
          when 'c' then "<span class='temperature'>#{convertCtoF(contents)}&nbsp;&deg;F / #{contents}&nbsp;&deg;C</span>"
          when 'f' then "<span class='temperature'>#{contents}&nbsp;&deg;F / #{convertFtoC(contents)}&nbsp;&deg;C</span>"
          when 'cm' then "<a class='length-group'><span class='length' data-orig-value='#{contents}'>#{contents}&nbsp;cm</span></a>"
          when 'mm' then "<a class='length-group'><span class='length' data-orig-value='#{contents / 10.0}'>#{contents}&nbsp;mm</span></a>"
          when 'g' then "<span class='text-quantity-group'><span class='quantity-group qtyfade'><span class='lbs-qty'></span> <span class='lbs-label'></span> <span class='main-qty' data-orig-value='#{contents}'}}>#{contents}</span></span> <span class='unit qtyfade'>g</span></span>"
          when 'ea' then "<span class='text-quantity-group'><span class='quantity-group qtyfade'><span class='lbs-qty'></span> <span class='lbs-label'></span> <span class='main-qty'>#{contents}</span></span> <span class='unit qtyfade alwayshidden'>ea</span></span>"
          when 'courseActivity'
            if arg2
              "<a ng-click='loadSubrecipe(#{arg1})'>#{arg2}</a>"
            else
              "<b>Badly formatted courseActivity shortcode<b>"
          when 'link'
            if arg2
              "<a href='#{arg1}' target='_blank'>#{arg2}</a>"
            else
              "<a href='#{arg1}' target='_blank'>#{arg1}</a>"
          when 'amzn'
            if arg2
              asin = arg1
              anchor_text = arg2
              "<a href='http://www.amazon.com/dp/#{asin}/?tag=chefsteps02-20' target='_blank'>#{anchor_text}</a>"
            else
              orig
          when 'view'
           "<a ng-click=\"$parent.showNell('#{arg1}.html')\">#{arg2}</a>"
          when 'fetchIngredient'
            """
             <div cs-fetch='#{arg1}' type='Ingredient' part='#{arg2}' card='_ingredient_embed_card.html'>
              </div>
            """
          when 'fetchActivity'
            """
              <div cs-fetch='#{arg1}' type='Activity' part='#{arg2}' card='_activity_embed_card.html'></div>
            """
          when 'linktocomments'
            "<a href='#comments'>#{contents}</a>"
          when 'quote'
            arg1 = arg1.replace('_', ' ')
            """
              <div class="quote-container">
                <hr/>
                <blockquote>
                  #{arg2}
                </blockquote>
                <div class="quote-source">
                  #{arg1}
                </div>
                <hr/>
              </div>
          """
          when 'fetchTool'
            """
              <div cs-fetch-tool='#{arg1}'></div>
            """
          when 'videoLoop'
            """
              <div cs-looping-video-player video-name='#{arg1}' video-image='#{arg2}'></div>
            """
          when 'followTopic'
            """
              <div cs-follow-topic topic='#{arg1}' text='#{arg2}'></div>
            """
          else orig
    else
      ""
