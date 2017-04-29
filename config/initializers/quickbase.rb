if ENV["QUICKBASE_USERNAME"].present? && ENV["QUICKBASE_PASSWORD"].present?
  require 'quickbase_client'

  QuickbaseClient = QuickBase::Client.init(
    {
      "username" => (ENV["QUICKBASE_USERNAME"]),
      "password" => (ENV["QUICKBASE_PASSWORD"]),
      "appname" => (Rails.env.production? ? "ChefSteps" : "ChefSteps Staging"),
      "org" => "chefsteps-8265"
    }
  )

  if Rails.env.production?
    QuickbaseOptions = {
      units_id: "bmg4hpb6i",
      units_query_id: "10"
    }
  else
    QuickbaseOptions = {
      units_id: "bmq3andqx",
      units_query_id: "10"
    }
  end


  # QuickbaseClient.getTableNames("bmg4hpbkr")
  # results = QuickbaseClient.getAllValuesForFields("bmg4hpb6i", ["serial_number"], nil, "10")
  # results = QuickbaseClient.getFieldNames("bmg4hpb6i")
  # QuickbaseClient.getSchema("bmg4hpb6i")
  # QuickbaseClient.getColumnListForQuery("bmg4hpb6i",'Unit Investigation report')
end
