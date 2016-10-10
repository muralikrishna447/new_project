if Rails.env.production?
  Rails.configuration.redirect_by_key = {
    'cantConnectToWifi'=> 'https://support.chefsteps.com/hc/en-us/articles/223021308--Why-can-t-I-connect-Joule-to-WiFi-'
  }
else
  Rails.configuration.redirect_by_key = {
    'cantConnectToWifi'=> 'https://chefsteps-staging.zendesk.com/hc/en-us/articles/223021308--Why-can-t-I-connect-Joule-to-WiFi-'
  }
end
