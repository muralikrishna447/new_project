require 'beta_feature_service'
if Rails.env.test?
  BetaFeatureService = BetaFeature::MockBetaFeatureService.new()
else
  BetaFeatureService = BetaFeature::DynamoBetaFeatureService.new(
    Aws::DynamoDB::Client.new(region: 'us-east-1'),
    Rails.configuration.dynamodb.beta_features_table_name
  )
end
