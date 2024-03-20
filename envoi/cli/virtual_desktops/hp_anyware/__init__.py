from envoi.cli import CliCommand
from envoi.aws.aws_cloud_formation_helper import AwsCloudFormationHelper

COMMON_PARAMS = {
    "stack-name": {
        'help': 'Name of the CloudFormation stack',
        'required': True
    },
    "instance-type-size": {
        'help': 'Instance Type',
        'default': None
    },
    "vpc-cidr": {
        'help': 'VPC CIDR',
        'default': None
    },
    "subnet-cidr": {
        'help': 'Subnet CIDR',
        'default': None
    },
    "allow-admin-cidr": {
        'help': 'Allow Admin CIDR',
        'default': None
    },
    "allow-client-cidr": {
        'help': 'Allow Client CIDR',
        'default': None
    }
}


class HpAnywareLaunchTemplateCliCommand(CliCommand):

    def run(self, opts=None):
        if opts is None:
            opts = self.opts

        template_params = {}
        if getattr(opts, 'vpc-cidr'):
            template_params['VpcCIDR'] = getattr(opts, 'vpc_cidr')
        if getattr(opts, 'subnet-cidr'):
            template_params['SubnetCIDR'] = getattr(opts, 'subnet_cidr')
        if getattr(opts, 'allow-admin-cidr'):
            template_params['AllowAdminCIDR'] = getattr(opts, 'allow_admin_cidr')
        if getattr(opts, 'allow-client-cidr'):
            template_params['AllowClientCIDR'] = getattr(opts, 'allow_client_cidr')
        if getattr(opts, 'instance-type-size'):
            template_params['InstanceTypeSize'] = getattr(opts, 'instance_type_size')

        helper = AwsCloudFormationHelper()
        helper.create_stack(
            stack_name=getattr(opts, 'stack_name'),
            template_url=getattr(opts, 'template_url'),
            template_parameters=template_params
        )


class HpAnywareCentOs7Command(HpAnywareLaunchTemplateCliCommand):
    DESCRIPTION = "HP Anyware - CentOS 7"
    PARAMS = {
        **COMMON_PARAMS,
        "template-url": {
            'help': 'Path to the CloudFormation template',
            'required': False,
            'default': 'https://envoi-prod-files-public.s3.amazonaws.com/aws/cloud-formation/templates/hp-anyware/'
                       'hp-anyware-centos-7-23.12.2.template'
        }
    }


class HpAnywareUnrealEngine5Command(HpAnywareLaunchTemplateCliCommand):
    DESCRIPTION = "HP Anyware - Unreal Engine 5"
    PARAMS = {
        **COMMON_PARAMS,
        "template-url": {
            'help': 'Path to the CloudFormation template',
            'required': False,
            'default': 'https://envoi-prod-files-public.s3.amazonaws.com/aws/cloud-formation/templates/hp-anyware/'
                       'hp-anyware-unreal-engine-5-23.12.2.template'
        }

    }


class HpAnywareWindows2019NvidiaCommand(HpAnywareLaunchTemplateCliCommand):
    DESCRIPTION = "HP Anyware - Windows 2019 NVIDIA"
    PARAMS = {
        **COMMON_PARAMS,
        "template-url": {
            'help': 'Path to the CloudFormation template',
            'required': False,
            'default': 'https://envoi-prod-files-public.s3.amazonaws.com/aws/cloud-formation/templates/hp-anyware/'
                       'hp-anyware-windows-2019-nvidia-23.12.2.template'
        }
    }


class HpAnywareCommand(CliCommand):
    DESCRIPTION = "HP Anyware"
    SUBCOMMANDS = {
        "centos-7": HpAnywareCentOs7Command,
        "unreal-engine-5": HpAnywareUnrealEngine5Command,
        "windows-2019-nvidia": HpAnywareWindows2019NvidiaCommand
    }
