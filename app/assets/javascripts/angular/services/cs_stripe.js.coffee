@app.service 'csStripe', ['csAuthentication', '$http', (csAuthentication, $http) ->
  this.getCustomer = ->
    customer_id = csAuthentication.currentUser().stripe_id
    Stripe.setPublishableKey('sk_test_vbGt58BNlwRrgjEvq9QtYf0G:')
    $http.get("https://api.stripe.com/v1/customers/#{customer_id}").then (response) ->
      console.log response
  this
]