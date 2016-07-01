module BetaFeature
  class DynamoBetaFeatureService
    def initialize(dynamo_client, table_name)
      @client = dynamo_client
      @table_name = table_name
    end

    def user_has_feature(email, feature_name)
      resp = @client.get_item(
        table_name: @table_name,
        key: {
          'email' => email,
          'feature_name' => feature_name
        }
      )
      return resp.item != nil
    end
  end

  class MockBetaFeatureService
    def initialize
      @items = []
    end

    def add(email, feature_name)
      @items.push([email, feature_name])
      puts @items
    end

    def user_has_feature(email, feature_name)
      return true
    end
  end
end
