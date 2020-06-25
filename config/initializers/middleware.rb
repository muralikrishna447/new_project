# https://ieftimov.com/post/writing-rails-middleware/
Rails.application.config.middleware.insert_before Delve::Application.middleware_to_insert_before, CatalogProxy
Rails.application.config.middleware.insert_before Delve::Application.middleware_to_insert_before, FreshStepsProxy

middleware_conf = {
    staging: {
        enforcer: [[/^\/loaderio/, /^\/api/, /^\/users/, /^\/assets/, /^\/logout/, /^\/sign_out/, /^\/sign_in/, /^\/stripe_webhooks/, /^\/password/, /^\/sso/, /^\/guides/, /^\/\.well-known/, /^\/admin\/slack_display\.json/]],
        redirect: {'chocolateyshatner.com' => 'www.chocolateyshatner.com'}
    },
    staging2: {
        enforcer: [[/^\/loaderio/, /^\/api/, /^\/users/, /^\/assets/, /^\/logout/, /^\/sign_out/, /^\/sign_in/, /^\/stripe_webhooks/, /^\/password/, /^\/sso/, /^\/guides/, /^\/\.well-known/, /^\/admin\/slack_display\.json/]],
        redirect: {'vanillanimoy.com' => 'www.vanillanimoy.com'}
    },
    production: {
        enforcer: [[/.*/], [/^\/playground/,/^\/users\/set_location/]],
        redirect: {'chefsteps.com' => 'www.chefsteps.com' }
    }
}[Rails.env.to_sym]

if middleware_conf
  Rails.application.config.middleware.insert_before(Rack::Prerender, PreauthEnforcer, *middleware_conf[:enforcer])
  Rails.application.config.middleware.insert_before(PreauthEnforcer, Rack::HostRedirect, middleware_conf[:redirect])
end