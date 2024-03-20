from envoi.cli import CliCommand
from envoi.cli.virtual_desktops.common.launch_using_cloud_formation import \
    LaunchUsingCloudFormationCliCommand, COMMON_CFN_PARAMS, COMMON_PARAMS, COMMON_EC2_LAUNCH_PARAMS


class NiceDcvAmazonLinux2Command(LaunchUsingCloudFormationCliCommand):
    DESCRIPTION = "Nice DCV Amazon Linux 2 Command"
    PARAMS = {
        **COMMON_CFN_PARAMS,
        **COMMON_PARAMS,
        **COMMON_EC2_LAUNCH_PARAMS,
        "template-url": {
            'help': 'Path to the CloudFormation template',
            'required': False,
            'default': 'https://envoi-prod-files-public.s3.amazonaws.com/aws/cloud-formation/templates/nice-dcv/'
                       'nice-dcv-amazon-linux-2.template.yaml'
        }
    }


class NiceDcvWindowsServer2019Command(LaunchUsingCloudFormationCliCommand):
    DESCRIPTION = "Nice DCV Windows Server 2019 Command"
    PARAMS = {
        **COMMON_CFN_PARAMS,
        **COMMON_PARAMS,
        **COMMON_EC2_LAUNCH_PARAMS,
        "template-url": {
            'help': 'Path to the CloudFormation template',
            'required': False,
            'default': 'https://envoi-prod-files-public.s3.amazonaws.com/aws/cloud-formation/templates/nice-dcv/'
                       'nice-dcv-windows-server-2019.template.yaml'
        }
    }


class NiceDcvCommand(CliCommand):
    DESCRIPTION = "Nice DCV Commands"
    SUBCOMMANDS = {
        "amazon-linux-2": NiceDcvAmazonLinux2Command,
        "windows-server-2019": NiceDcvWindowsServer2019Command
    }
