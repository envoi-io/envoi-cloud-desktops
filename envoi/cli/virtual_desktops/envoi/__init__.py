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
    DESCRIPTION = "Envoi Development MacOS Command"
    PARAMS = {
        **COMMON_CFN_PARAMS,
        **COMMON_PARAMS,
        **COMMON_EC2_LAUNCH_PARAMS,
        "instance-name": {
            'help': 'Instance Name',
            'default': 'envoi-dev-macos'
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
