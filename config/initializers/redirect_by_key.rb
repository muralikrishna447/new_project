Rails.configuration.redirect_by_key = {
  'cantConnectToWifi' => "https://#{ENV['ZENDESK_DOMAIN']}/hc/en-us/articles/223021308--Why-can-t-I-connect-Joule-to-WiFi-",
  'cantSignIn' => "https://#{ENV['ZENDESK_DOMAIN']}/hc/en-us/articles/223020748-Why-can-t-I-sign-in-",
  'resetPassword' => "https://#{ENV['ZENDESK_DOMAIN']}/hc/en-us/articles/235391727-How-do-I-reset-my-password-",
  'cantPair' => "https://#{ENV['ZENDESK_DOMAIN']}/hc/en-us/articles/223021408-I-can-t-pair-with-Joule-",
  'pairedButCantConnect' => "https://#{ENV['ZENDESK_DOMAIN']}/hc/en-us/articles/223021468-I-ve-paired-with-Joule-but-I-can-t-connect-",
  'noOwnerNoWifi' => "https://#{ENV['ZENDESK_DOMAIN']}/hc/en-us/articles/223020788-What-does-it-mean-to-be-Joule-s-owner-",
  'dfuProblems' => "https://#{ENV['ZENDESK_DOMAIN']}/hc/en-us/articles/225107367-My-firmware-update-keeps-failing-A-little-help-",
  'maximumTemperature' => "https://#{ENV['ZENDESK_DOMAIN']}/hc/en-us/articles/214790827-What-is-the-maximum-temperature-Joule-will-reach-",
  'jouleTroubleshooting' => "https://#{ENV['ZENDESK_DOMAIN']}/hc/en-us/sections/205090928-Joule-App",
  'newSupportRequest' => "https://#{ENV['ZENDESK_DOMAIN']}/hc/en-us/requests/new",
  'mySupportRequests' => "https://#{ENV['ZENDESK_DOMAIN']}/hc/en-us/requests",
  'ledTrouble' => "https://#{ENV['ZENDESK_DOMAIN']}/hc/en-us/articles/223021708-The-LED-cute-little-light-thingy-on-my-Joule-is-blinking-Why-",
  'voiceControl' => "https://#{ENV['ZENDESK_DOMAIN']}/hc/en-us/articles/231824567-Can-I-use-voice-control-with-Joule-How-do-I-connect-it-to-an-Amazon-Echo-or-Dot-",
  'hardwareTroubleshooting' => "https://#{ENV['ZENDESK_DOMAIN']}/hc/en-us/sections/203206487-Hardware-Specs",
  'knownIssues' => "https://#{ENV['ZENDESK_DOMAIN']}/hc/en-us/articles/115006043508",
  'factoryReset' => "https://#{ENV['ZENDESK_DOMAIN']}/hc/en-us/articles/222979667-What-is-a-factory-reset-and-how-do-I-perform-one-",
  'jouleReadyLearnMore' => "#{Rails.application.config.shared_config[:spree_endpoint]}/collections/joule-ready",
  # if an unrecognized key is provided, we return this fallback url
  # if we use redirect_by_key for anything beyond support, rethink this fallback strategy
  'fallback' => "https://#{ENV['ZENDESK_DOMAIN']}/hc/en-us/"
}
