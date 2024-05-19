import boto3
import time


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


def envoi_dev_mac_os_command_handler(opts=None):
    ami_id = opts.ami_id or 'ami-031445a67a8e9b092'
    dedicated_host = DedicatedHost(host_id=opts.host_id, host_availability_zone=opts.host_availability_zone)
    if not dedicated_host.host_id:
        dedicated_host.launch(instance_type=opts.instance_type)
    instance_type = dedicated_host.instance_type()
    dedicated_host.wait()

    instance = Ec2Instance(instance_id=opts.instance_id)
    if not instance.instance_id:
        launch_args = {
            'ami_id': ami_id,
            'host_id': dedicated_host.host_id,
            'instance_type': instance_type,
            'key_name': opts.key_pair_name,
            'instance_iam_role_id': opts.instance_iam_role_id,
            'instance_name': opts.instance_name,
            'subnet_id': opts.subnet_id
        }
        instance.launch(**launch_args)
    instance.wait()
    print("Connection command: ", instance.connection_string())


class DedicatedHost:
    ec2 = boto3.client('ec2')

    def __init__(self, **kwargs):
        self.host_id = kwargs.get('host_id')
        if self._host_id:
            self.host = self.describe()

    @property
    def host_id(self):
        return self._host_id

    @host_id.setter
    def host_id(self, value):
        self._host_id = value
        self.host = self.describe()

    def instance_type(self):
        return self.host['HostProperties']['InstanceType']

    def describe(self):
        response = self.ec2.describe_hosts(HostIds=[self.host_id])
        hosts = response['Hosts']
        return hosts[0]

    def launch(self, **kwargs):
        instance_type = kwargs.get('instance_type', 'mac2-m2pro.metal')
        availability_zone = kwargs.get('availability_zone', 'us-east-1a')

        response = self.ec2.allocate_hosts(
            InstanceType=instance_type,
            Quantity=1,
            AvailabilityZone=availability_zone,
            AutoPlacement='on'
        )
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

        if self.instance_id:
            self.instance = self.describe()

    def describe(self):
        response = self.ec2.describe_instances(InstanceIds=[self.instance_id])
        instances = response['Reservations'][0]['Instances']
        return instances[0]

    def launch(self, **kwargs):
        ami_id = kwargs.get('ami_id')
        host_id = kwargs.get('host_id')
        instance_name = kwargs.get('instance_name')
        instance_iam_role_id = kwargs.get('instance_iam_role_id')
        instance_type = kwargs.get('instance_type')
        key_name = kwargs.get('key_name')
        security_group_id = kwargs.get('security_group_id')
        subnet_id = kwargs.get('subnet_id')
        tags = kwargs.get('tags', [])
        user_data = kwargs.get('user_data')

        run_instance_args = {
            'ImageId': ami_id,
            'InstanceType': instance_type,
            'MaxCount': 1,
            'MinCount': 1
        }
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

        if security_group_id:
            security_group_ids = security_group_id.split(',')
            run_instance_args['SecurityGroupIds'] = security_group_ids

        if subnet_id:
            run_instance_args['SubnetId'] = subnet_id

        if user_data:
            run_instance_args['UserData'] = user_data

        run_instance_args['TagSpecifications'] = [
            {'ResourceType': 'instance', 'Tags': tags}
        ]
        response = self.ec2.run_instances(**run_instance_args)
        self.instance = response['Instances'][0]
        self.instance_id = self.instance['InstanceId']

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

    def connection_string(self):
        public_dns_name = self.instance['PublicDnsName']
        key_name = self.instance['KeyName']
        return f"ssh -i {key_name} ec2-user@{public_dns_name}"
