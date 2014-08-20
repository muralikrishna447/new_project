@app.service 'csStripe', ['csAuthentication', '$http', '$q', (csAuthentication, $http, $q) ->

  this.getCurrentCustomer = ->
    
    customer_id = csAuthentication.currentUser().stripe_id
    promise = $http.get("/stripe/current_customer").then (response) ->
      console.log "response: "
      console.log response
      return response.data
    console.log "promise: "
    console.log promise
    return promise

  this
]
