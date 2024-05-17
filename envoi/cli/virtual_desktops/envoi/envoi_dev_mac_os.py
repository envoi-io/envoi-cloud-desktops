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

    host_id = opts.host_id
    ami_id = opts.ami_id
    instance_id = opts.instance_id
    instance_type = opts.instance_type
    instance_profile_arn = opts.instance_profile_arn
    key_name = opts.key_pair_name

    if not ami_id:
        # ami = determine_latest_macos_ami()
        # ami_id = ami['ImageId']
        ami_id = 'ami-031445a67a8e9b092'

    dedicated_host = DedicatedHost(host_id=host_id)
    if dedicated_host.host_id:
        instance_type = dedicated_host.instance_type()
    else:
        dedicated_host.launch(instance_type=instance_type)

    dedicated_host.wait()

    instance = Ec2Instance(instance_id=instance_id)
    if not instance.instance_id:
        instance.launch(
            ami_id=ami_id,
            host_id=dedicated_host.host_id,
            instance_profile_arn=instance_profile_arn,
            instance_type=instance_type,
            key_name=key_name
        )
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
        if 'Instances' in self.host and len(self.host['Instances']) > 0:
            return self.host['Instances'][0]['InstanceType']
        else:
            return None

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
        instance_name = kwargs.get('instance_name')
        instance_profile_arn = kwargs.get('instance_profile_arn')
        instance_type = kwargs.get('instance_type')
        key_name = kwargs.get('key_name')

        response = self.ec2.run_instances(
            ImageId=ami_id,
            InstanceType=instance_type,
            KeyName=key_name,
            IamInstanceProfile={
                'Arn': instance_profile_arn
            },
            MaxCount=1,
            MinCount=1
        )
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


class EnvoiDevelopmentMacOsInstanceLauncher:

    def __init__(self):
        pass

    def main(self, **kwargs):
        host_id = kwargs.get('host-id', None)
        instance_id = kwargs.get('instance-id', None)
        instance_type = kwargs.get('instance-type', 'mac2-m2pro.metal')

        instance_profile_arn = kwargs.get('instance-profile-arn', None)
        key_name = kwargs.get('key-name')
        ami_id = kwargs.get('ami-id', deteremine_latest_macos_ami())

        # Dedicated instance specified?
        if host_id:
            dedicated_host = DedicatedHost(host_id=host_id, instance_type=instance_type)
        else:
            dedicated_host = DedicatedHost(instance_type=instance_type)
            dedicated_host.launch()

        # dedicated_instance_description = dedicated_host.describe()

        # Wait for dedicated instance
        dedicated_host.wait()

        # Launch instance onto dedicated instance
        instance = Ec2Instance(instance_id=instance_id)

        instance.launch(
            ami_id=ami_id,
            host_id=dedicated_host.host_id,
            instance_profile_arn=instance_profile_arn,
            key_name=key_name
        )
        instance.wait()



