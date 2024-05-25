import os

import boto3
import time

def envoi_dev_mac_os_command_handler(opts=None):
    ami_id = opts.ami_id or 'ami-0cc2f298aa1a495a1'  # ami-038e1d574f3140013

    if opts.security_group_id:
        security_group_ids = opts.security_group_id
    else:
        if opts.no_default_security_group:
            security_group_ids = []
        else:
            security_group_ids = create_default_security_group(opts.default_security_group_inbound_cidr,
                                                               opts.default_security_group_protocols)

    dedicated_host = DedicatedHost(host_id=opts.host_id)
    if not dedicated_host.host_id:
        dedicated_host.launch(instance_type=opts.instance_type, availability_zone=opts.host_availability_zone,
                              name=opts.host_name)
    instance_type = dedicated_host.instance_type()
    dedicated_host.wait()

    instance = Ec2Instance(instance_id=opts.instance_id)
    if not instance.instance_id:
        launch_args = {
            'ami_id': ami_id,
            'elastic_network_interface_ids': opts.instance_eni_id,
            'host_id': dedicated_host.host_id,
            'instance_eni_ids': opts.instance_eni_id,
            'instance_iam_role_id': opts.instance_iam_role_id,
            'instance_name': opts.instance_name,
            'instance_type': instance_type,
            'key_name': opts.key_pair_name,
            'security_group_ids': security_group_ids,
            'subnet_id': opts.subnet_id
        }
        instance.launch(**launch_args)
    instance.wait()
    connection_string = instance.connection_string(dns=False)
    response = f"""
    Envoi Development MacOS instance launched successfully.
    
    To connect to the instance please use the following command:
    
        {connection_string}
    
    """
    print(response)


class DedicatedHost:
    ec2 = boto3.client('ec2')

    def __init__(self, host_id=None):
        self.host_id = host_id

    @property
    def host_id(self):
        return self._host_id

    @host_id.setter
    def host_id(self, value):
        self._host_id = value
        if value:
            self.details = self.describe()

    def instance_type(self):
        return self.details['HostProperties']['InstanceType']

    def describe(self):
        response = self.ec2.describe_hosts(HostIds=[self.host_id])
        hosts = response['Hosts']
        return hosts[0]

    def launch(self, instance_type='mac2-m2pro.metal', availability_zone='us-east-1a', name=None):
        launch_args = {
            'InstanceType': instance_type,
            'Quantity': 1,
            'AvailabilityZone': availability_zone,
            'AutoPlacement': 'on'
        }
        tags = []
        if name:
            tags.append({'Key': 'Name', 'Value': name})

        if tags:
            launch_args['TagSpecifications'] = [
                {'ResourceType': 'host', 'Tags': tags}
            ]
        response = self.ec2.allocate_hosts(**launch_args)
        self.host_id = response['HostIds'][0]
        return response

    def wait(self):
        while True:
            response = self.ec2.describe_hosts(HostIds=[self.host_id])
            state = response['Hosts'][0]['State']
            if state == 'available':
                break
            elif state == 'failed':
                raise Exception('Failed to allocate host')
            time.sleep(15)  # wait


class Ec2Instance:

    def __init__(self, **kwargs):
        self.ec2 = boto3.client('ec2')
        self.instance_id = kwargs.get('instance_id')

    @property
    def instance_id(self):
        return self._instance_id

    @instance_id.setter
    def instance_id(self, value):
        self._instance_id = value
        if value:
            self.details = self.describe()

    def describe(self):
        response = self.ec2.describe_instances(InstanceIds=[self.instance_id])
        instances = response['Reservations'][0]['Instances']
        return instances[0]

    def launch(self,
               ami_id=None,
               elastic_network_interface_ids=None,
               host_id=None,
               instance_name=None,
               instance_iam_role_id=None,
               instance_type=None,
               key_name=None,
               security_group_ids=None,
               subnet_id=None,
               tags=None,
               user_data=None,
               ):
        tags = tags or []
        elastic_network_interface_ids = elastic_network_interface_ids or []
        security_group_ids = security_group_ids or []

        run_instance_args = {
            'ImageId': ami_id,
            'InstanceType': instance_type,
            'MaxCount': 1,
            'MinCount': 1
        }

        if elastic_network_interface_ids:
            if isinstance(elastic_network_interface_ids, str):
                elastic_network_interface_ids = elastic_network_interface_ids.split(',')

            for eni_id in elastic_network_interface_ids:
                run_instance_args['NetworkInterfaces'] = [{'NetworkInterfaceId': eni_id}]

        if host_id:
            run_instance_args['Placement'] = {'HostId': host_id}

        if instance_iam_role_id:
            if instance_iam_role_id.startswith('arn:aws:iam::'):
                instance_iam_role_id_key_name = 'Arn'
            else:
                instance_iam_role_id_key_name = 'Name'
            run_instance_args['IamInstanceProfile'] = {
                instance_iam_role_id_key_name: instance_iam_role_id
            }

        if instance_name:
            tags.append({'Key': 'Name', 'Value': instance_name})

        if key_name:
            run_instance_args['KeyName'] = key_name

        if security_group_ids:
            if isinstance(security_group_ids, str):
                security_group_ids = security_group_ids.split(',')

            run_instance_args['SecurityGroupIds'] = security_group_ids

        if subnet_id:
            run_instance_args['SubnetId'] = subnet_id

        if user_data:
            run_instance_args['UserData'] = user_data

        if tags:
            run_instance_args['TagSpecifications'] = [
                {'ResourceType': 'instance', 'Tags': tags}
            ]

        response = self.ec2.run_instances(**run_instance_args)
        instance_details = response['Instances'][0]
        self.instance_id = instance_details['InstanceId']

        return response

    def wait(self):
        waiter = self.ec2.get_waiter('instance_running')
        waiter.wait(InstanceIds=[self.instance_id])
        # while True:
        #     response = self.ec2.describe_instances(InstanceIds=[self.instance_id])
        #     state = response['Reservations'][0]['Instances'][0]['State']['Name']
        #     if state == 'running':
        #         break
        #     time.sleep(15)

    def connection_string(self, dns=True):
        address_field_name = 'PublicDnsName' if dns else 'PublicIpAddress'
        address = self.details[address_field_name]

        key_name = self.details['KeyName']
        return f"ssh -i {key_name}.pem ec2-user@{address}"


def create_default_security_group(name='envoi-dev-macos', vpc_id=None, inbound_ip_ranges=None, protocols=None):
    """
    Create a default security group for a macOS instance
    :param inbound_ip_ranges:
    :param vpc_id:
    :param name:
    :param protocols:
    :return:
    """
    ec2 = boto3.client('ec2')
    create_security_group_args = {
        'Description': 'Default Security Group',
        'GroupName': name
    }
    if vpc_id:
        create_security_group_args['VpcId'] = vpc_id

    if inbound_ip_ranges is None:
        inbound_ip_ranges = [{'CidrIp': '0.0.0.0/0'}]

    ip_permissions = []

    if protocols is None:
        protocols = ['ssh']
    else:
        if isinstance(protocols, str):
            protocols = protocols.split(',')
    for protocol in protocols:
        if protocol == 'ssh':
            ip_permissions.append({
                'IpProtocol': 'tcp',
                'FromPort': 22,
                'ToPort': 22,
                'IpRanges': inbound_ip_ranges,
                'Description': 'SSH'
            })
        elif protocol == 'vnc':
            ip_permissions.append({
                'IpProtocol': 'tcp',
                'FromPort': 5900,
                'ToPort': 5900,
                'IpRanges': inbound_ip_ranges,
                'Description': 'VNC Port'
            })
        elif protocol == 'ard':
            ip_permissions.append({
                'IpProtocol': 'tcp',
                'FromPort': 3283,
                'ToPort': 3283,
                'IpRanges': inbound_ip_ranges,
                'Description': 'Apple Remote Desktop'
            })

    response = ec2.create_security_group(**create_security_group_args)
    security_group_id = response['GroupId']
    ec2.authorize_security_group_ingress(GroupId=security_group_id, IpPermissions=ip_permissions)
    return security_group_id


def determine_latest_macos_ami():
    ec2 = boto3.client('ec2')
    response = ec2.describe_images(
        Filters=[
            {
                'Name': 'name',
                'Values': ['envoi-dev-mac-*']
            },
            {
                'Name': 'state',
                'Values': ['available']
            }
        ]
    )
    images = response['Images']
    images.sort(key=lambda x: x['CreationDate'], reverse=True)
    return images[0]
