ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  action_item do
    link_to "Styleguide", "/styleguide"
  end
  action_item do
    link_to "Publish Updates", admin_version_path(Version.first), method: :put, confirm: 'Are you sure?'
  end

  content title: proc{ I18n.t("active_admin.dashboard") } do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        span "Welcome to the ChefSteps admin area."
        small "More instructions coming soon..."
      end
    end
  end
end
