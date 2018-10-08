import argparse
import boto3
import botocore
import json

def create_tables_for_env(client, tables, env):
    # http://boto3.readthedocs.io/en/latest/guide/dynamodb.html
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
        except botocore.exceptions.ClientError as e:
            if e.response['Error']['Code'] == 'ResourceInUseException':
                print "ERROR: Table already exists"
            else:
                print("ERROR: %s" % e)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Utility for creating DynamoDB tables'
    )
    parser.add_argument('table_definition')
    parser.add_argument('--env', dest='env', default='development')
    args = parser.parse_args()

    with open(args.table_definition) as f:
        tables = json.load(f)

    client = boto3.resource('dynamodb')
    create_tables_for_env(client, tables, args.env)
