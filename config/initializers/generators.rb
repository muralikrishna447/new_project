Delve::Application.config.generators do |g|
  g.template_engine :haml
  g.controller helper: false, view_specs: false, assets: false, controller_specs: false
end
