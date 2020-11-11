# /cuts url is proxied to cs-cuts-web application
# by initiating the CutService initial call will happen to cuts application
# stored all urls in memory
CutsService.initiate unless Rails.env.test?