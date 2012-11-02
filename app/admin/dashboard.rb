ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  action_item do
    link_to "Styleguide", "/styleguide"
  end
  action_item do
    link_to "Publish Updates", admin_version_path(Version.first), method: :put, confirm: 'Are you sure?'
  end

  content title: proc{ I18n.t("active_admin.dashboard") } do
    h1 "Welcome to the ChefSteps admin area."
  end
end
