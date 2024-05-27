from envoi.cli import CliCommand
from envoi.cli.virtual_desktops.common.launch_using_cloud_formation import \
    LaunchUsingCloudFormationCliCommand, COMMON_CFN_PARAMS, COMMON_PARAMS, COMMON_EC2_LAUNCH_PARAMS

from envoi.cli.virtual_desktops.envoi.envoi_dev_mac_os import envoi_dev_mac_os_command_handler


class EnvoiDevelopmentLinuxCommand(LaunchUsingCloudFormationCliCommand):
    DESCRIPTION = "Envoi Development Amazon Linux 2 Command"
    PARAMS = {
        **COMMON_CFN_PARAMS,
        **COMMON_PARAMS,
        **COMMON_EC2_LAUNCH_PARAMS,
    }


class EnvoiDevelopmentMacOsCommand(CliCommand):
    DESCRIPTION = "Envoi Development macOS Command"
    PARAMS = {
        **COMMON_PARAMS,
        **COMMON_EC2_LAUNCH_PARAMS,
        "instance-id": {
            'help': 'Instance ID',
            'default': None
        },
        "instance-name": {
            'help': 'Instance Name',
            'default': 'envoi-dev-macos'
        },
        "instance-eni-id": {
            "help": "Instance Elastic Network Interface ID. This can be used to attach an existing ENI to the instance.",
            "default": None
        },
        "instance-type": {
            'help': 'Instance Type',
            'default': 'mac2-m2pro.metal'
        },
        "host-id": {
            'help': 'Host ID',
            'default': None
        },
        "host-availability-zone": {
            'help': 'Host Availability Zone',
            'default': 'us-east-1a'
        },
        "host-name": {
            'help': 'Host Name',
            'default': None
        },
        "no-default-security-group": {
            'help': 'If provided then a security group will not be created by default.'
                    ' This only applies when no security group id is provided',
            'default': False,
        },
        "default-security-group-inbound-cidr": {
            'help': 'Sets the default security group inbound CIDR.'
                    ' This is only used when no security group id is provided.',
            'default': '0.0.0.0/0'
        },
        "default-security-group-name": {
            'help': 'Default Security Group Name. This is only used when no security group id is provided.',
            'default': 'envoi-dev-macos'
        },
        "default-security-group-protocols": {
            'help': 'Default Security Group Protocols. Comma separated list of protocols.'
                    ' Can be any combination of ssh,vnc,ard.'
                    ' This is only used when no security group id is provided.',
            'default': 'ssh'
        },
        "default-security-group-allow-overwrite": {
            'help': 'If provided then the default security group will be overwritten.'
                    ' This is only used when no security group id is provided.',
            'default': False
        },
        "vpc-id": {
            'help': 'VPC ID',
            'default': None
        },
    }

    def run(self, opts=None):
        if opts is None:
            opts = self.opts
        return envoi_dev_mac_os_command_handler(opts)


class EnvoiDevelopmentWindowsCommand(LaunchUsingCloudFormationCliCommand):
    DESCRIPTION = "Envoi Development Windows Command"
    PARAMS = {
        **COMMON_CFN_PARAMS,
        **COMMON_PARAMS,
        **COMMON_EC2_LAUNCH_PARAMS,
    }


class EnvoiCommand(CliCommand):
    DESCRIPTION = "Envoi Command"
    SUBCOMMANDS = {
        'development-linux': EnvoiDevelopmentLinuxCommand,
        'development-macos': EnvoiDevelopmentMacOsCommand,
        'development-windows': EnvoiDevelopmentWindowsCommand
    }
