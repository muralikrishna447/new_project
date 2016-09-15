require 'set'
module BetaFeature
  class DynamoBetaFeatureService
    def initialize(dynamo_client, table_config)
      @client = dynamo_client
      @table_config = table_config
    end

    def user_has_feature(user, feature_name)
      groups = Set.new(get_groups_for_user(user))
      feature_groups = get_feature_groups_by_feature_name(feature_name)

      # Filter out any groups that the user is not associated with
      feature_groups = feature_groups.select {|fg|
        groups.include? fg['group_name']
      }

      is_enabled = false
      if feature_groups.length > 0
        # Group rules take precedence.  If any group says the feature
        # is enabled, then enable it.
        for fg in feature_groups
          if fg['is_enabled'] == true
            Rails.logger.debug "Feature #{feature_name} is enabled through group #{fg['group_name']}"
            is_enabled = true
            break
          end
        end
      else
        # If there are no group rules for this feature, then take the
        # default rule (if there is one)
        feature_info = get_feature_info(feature_name)
        if feature_info
          default_enabled = feature_info['default_enabled']
          is_enabled = default_enabled
          Rails.logger.debug "Feature #{feature_name} has a default rule of enabled=#{default_enabled}"
        end
      end

      return is_enabled
    end

    # Mocking out DynamoDB is kind of a pain.  Instead, abstract the
    # data accessors behind functions, and stub them as necessary.
    # Kinda gross... but.


    # Fetches information about a given feature.  Format:
    #  {'feature_name' => <name>, 'default_enabled' => <true|false>}
    #
    #
    def get_feature_info(feature_name)
      response = @client.get_item(
        table_name: @table_config[:features_table],
        key: {
          'feature_name' => feature_name
        }
      )
      return response.item
    end

    # Fetches all the feature/group info objects for a given
    # feature_name.
    def get_feature_groups_by_feature_name(feature_name)
      response = @client.query(
        table_name: @table_config[:group_features_table],
        select: "ALL_ATTRIBUTES",
        key_condition_expression: 'feature_name = :feature_name',
        expression_attribute_values: {
          ':feature_name' => feature_name
        }
      )
      items = response.items.map {|i|
        {
          'group_name' => i['group_name'],
          'feature_name' => i['feature_name'],
          'is_enabled' => i['is_enabled'],
        }
      }
      return items
    end

    # Fetches and returns a list of groups for a given user.  Returns
    # an empty list if a user is not associated to any groups
    def get_groups_for_user(user)
      response = @client.query(
        table_name: @table_config[:group_associations_table],
        select: "ALL_ATTRIBUTES",
        limit: 100,
        key_condition_expression: 'user_id = :user_id',
        expression_attribute_values: {
          ':user_id' => user.id
        }
      )
      groups = response.items.map {|i| i['group_name']}
      return groups
    end

  end
end
