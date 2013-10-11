This is the best place to learn about setting up SSL for use on heroku: https://devcenter.heroku.com/articles/ssl-endpoint

For rails integration, we use https://github.com/tobmatth/rack-ssl-enforcer

All of the certificate files are in this directory, but just for archiving purposes - they have been uploaded to heroku for
actual use. Order details here: https://www.digicert.com/custsupport/order-details.php?order_id=00442970 . It will need to be renewed in 1 year.

The commands I used for provisioning the certificates were:

heroku addons:add ssl:endpoint --app staging-chefsteps
heroku certs:add star_chefsteps_com.pem server.key --app staging-chefsteps

(same for production)

Our SSL endpoints are:

staging: gifu-8809.herokussl.com
production: akita-7087.herokussl.com

Those are both set in Hover DNS.

We do not have SSL working on our root domain. The certificate will cover it, but Hover doesn't have the right kind of support for ALIAS/ANAME at
the apex. (https://devcenter.heroku.com/articles/apex-domains, section on SSL.) We'd need to switch to DNSimple or DNS Made Easy for that to work (https://devcenter.heroku.com/articles/custom-domains#root-domain). This will only be a problem if people try to go to https://chefsteps.com/courses/foobar/landing, which I don't expect to be an issue since
there is no reason someone would have that as a link.




