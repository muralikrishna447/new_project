$ heroku run --app production-chefsteps rails c
$ o = Shopify::Utils.order_by_name('#205107610417')
$ f = o.fulfillments.select { |f| !f.line_items.select { |li| li.id == 10808846356 }.empty? && f.status == 'open' }.first
$ f.cancel
