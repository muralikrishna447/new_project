"""
Just an example script of how to programatically create a set of
tables for all our environments.

TODO: use argparse to read in table definitions from JSON

"""

import boto3
import botocore

envs = [
    'development',
    'staging',
    'staging2',
    'production',
]

# http://boto3.readthedocs.io/en/latest/guide/dynamodb.html
tables = [
    {
        'table_name_prefix' : 'beta-feature-info',
        'KeySchema' : [
            {
                'AttributeName' : 'feature_name',
                'KeyType' : 'HASH'
            },
        ],
        'AttributeDefinitions' : [
            {
                'AttributeName' : 'feature_name',
                'AttributeType' : 'S'
            },
        ],
        'ProvisionedThroughput' : {
            'ReadCapacityUnits': 5,
            'WriteCapacityUnits': 1,
        }
    },
    {
        'table_name_prefix' : 'beta-feature-group-features',
        'KeySchema' : [
            {
                'AttributeName' : 'feature_name',
                'KeyType' : 'HASH'
            },
            {
                'AttributeName' : 'group_name',
                'KeyType' : 'RANGE'
            },
        ],
        'AttributeDefinitions' : [
            {
                'AttributeName' : 'group_name',
                'AttributeType' : 'S'
            },
            {
                'AttributeName' : 'feature_name',
                'AttributeType' : 'S'
            },
        ],
        'ProvisionedThroughput' : {
            'ReadCapacityUnits': 5,
            'WriteCapacityUnits': 1,
        }
    },
    {
        'table_name_prefix' : 'beta-feature-group-associations',
        'KeySchema' : [
            {
                'AttributeName' : 'user_id',
                'KeyType' : 'HASH'
            },
            {
                'AttributeName' : 'group_name',
                'KeyType' : 'RANGE'
            },
        ],
        'AttributeDefinitions' : [
            {
                'AttributeName' : 'user_id',
                'AttributeType' : 'N'
            },
            {
                'AttributeName' : 'group_name',
                'AttributeType' : 'S'
            },
        ],
        'ProvisionedThroughput' : {
            'ReadCapacityUnits': 5,
            'WriteCapacityUnits': 1,
        }
    }
]

def create_tables_for_env(client, env):
    for table_def in tables:
        table_name = '%s-%s' % (table_def['table_name_prefix'], env)
        print("Creating %s" % table_name)

        try:
            table = client.create_table(
                TableName=table_name,
                KeySchema=table_def['KeySchema'],
                AttributeDefinitions=table_def['AttributeDefinitions'],
                ProvisionedThroughput=table_def['ProvisionedThroughput'],
            )
        except botocore.exceptions.ClientError:
            print("  ...table exists")


if __name__ == '__main__':
    client = boto3.resource('dynamodb')
    for env in envs:
        create_tables_for_env(client, env)
