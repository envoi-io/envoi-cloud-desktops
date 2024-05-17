from envoi.cli import CliCommand
from envoi.aws.aws_cloud_formation_helper import AwsCloudFormationHelper

COMMON_CFN_PARAMS = {
    "stack-name": {
        'help': 'Name of the CloudFormation stack',
        'required': True
    },
}

COMMON_PARAMS = {

}

COMMON_EC2_LAUNCH_PARAMS = {
    "ami-id": {
        'help': 'AMI ID',
        'default': None
    },
    "instance-profile-arn": {
        'help': 'Instance Profile ARN',
        'default': None
    },
    "instance-type": {
        'help': 'Instance Type',
        'default': None
    },
    "key-pair-name": {
        'help': 'Key Pair Name',
        'default': None
    },
    "security-group-id": {
        'help': 'Security Group ID',
        'default': None
    },
}


class LaunchUsingCloudFormationCliCommand(CliCommand):

    def run(self, opts=None):
        if opts is None:
            opts = self.opts

        template_params = {}
        if getattr(opts, 'instance-type-size'):
            template_params['InstanceTypeSize'] = getattr(opts, 'instance_type')

        helper = AwsCloudFormationHelper()
        helper.create_stack(
            stack_name=getattr(opts, 'stack_name'),
            template_url=getattr(opts, 'template_url'),
            template_parameters=template_params
        )