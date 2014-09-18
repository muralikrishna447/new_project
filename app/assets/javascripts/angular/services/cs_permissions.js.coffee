@app.service 'csPermissions', [ "csAuthentication", (csAuthentication) ->
  this.auth = csAuthentication

  this.sendFreeGift = ->
    user = this.auth.currentUser()
    if user
      switch user.role
        when 'admin' then true
        when 'collaborator' then true
    else
      false

  permissionsList = {
    'admin': {
      gifts: [
        'sendFree'
      ]
    }
  }

  this.check = (value) ->
    user = this.auth.currentUser()
    valueSplit = value.split(' ')
    value1 = valueSplit[0]
    value2 = valueSplit[1]
    if _.contains(permissionsList[user.role][value2], value1)
      true
    else
      false


  this
]