@app.service 'csPermissions', [ "csAuthentication", (csAuthentication) ->
  this.auth = csAuthentication

  permissionsList = {
    'admin': {
      gifts: [
        'sendFree'
      ]
    }
    'collaborator': {
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
    if user
      role = permissionsList[user.role]
      if role
        _.contains(role[value2], value1)
      else
        false
    else
      false


  this
]