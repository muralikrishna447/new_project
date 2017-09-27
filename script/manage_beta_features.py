import boto3
from boto3.dynamodb.conditions import Key, Attr
import csv
import sys
import argparse

def add_users_to_groups(table, args):

    user_groups = []
    with open(args.group_csv, 'r') as f:
        reader = csv.reader(f)
        for row in reader:
            user_id = int(row[0])
            row[0] = user_id
            user_groups.append(row)
            print(row)

    answer = input('\nAdd the above groups [yes/no]? ')
    if answer != 'yes':
        sys.exit(0)

    for user_id, group, *other in user_groups:
        print("Adding %s %s to %s group" % (user_id, other, group))
        table.put_item(
            Item={
                'user_id' : user_id,
                'group_name' : group,
            }
        )

def delete_group(table, args):
    print("Deleting group [%s]" % args.group_name)
    resp =table.scan(
        FilterExpression=Attr('group_name').eq(args.group_name)
    )
    items = resp['Items']

    if len(items) == 0:
        print("No users in group..")
        return

    for item in items:
        print(item)

    answer = input('\nDelete the above user-group associations [yes/no]? ')
    if answer != 'yes':
        sys.exit(0)

    for item in items:
        table.delete_item(
            Key={
                'user_id' : item['user_id'],
                'group_name' : item['group_name'],
            }
        )

def show_user_group_information(table, args):
    resp =table.scan(
        FilterExpression=Attr('group_name').eq(args.group_name)
    )
    items = resp['Items']

    for item in items:
        print(item)

    print("Group %s has %i members" % (args.group_name, len(items)))


if __name__ == '__main__':
    description='Update beta user groups'
    epilog = '''

Example: deleting all users from the group 'foo' on staging

    $ python manage_beta_features.py staging del foo

Example: adding a bunch of users to groups on production from
         the CSV file, my_users.csv

    $ python manage_beta_features.py production add my_users.csv

    csv file format:
        user_id, group_name, <other_metadata>...
    '''
    parser = argparse.ArgumentParser(description=description, epilog=epilog,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('env', help='The environment',
                        choices=['production', 'staging', 'staging2'])

    subparsers = parser.add_subparsers(dest='cmd')

    add_cmd = subparsers.add_parser('add', help='Add users to groups from csv')
    del_cmd = subparsers.add_parser('del', help='Delete a user group')
    inf_cmd = subparsers.add_parser('info', help='Show user group information')

    add_cmd.add_argument('group_csv', help='csv file with user info')
    del_cmd.add_argument('group_name', help='Group name to delete')
    inf_cmd.add_argument('group_name', help='Group name to get info for')

    args = parser.parse_args()

    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('beta-feature-group-associations-%s' % args.env)

    if args.cmd == 'del':
        delete_group(table, args)
    elif args.cmd == 'add':
        add_users_to_groups(table, args)
    elif args.cmd == 'info':
        show_user_group_information(table, args)
