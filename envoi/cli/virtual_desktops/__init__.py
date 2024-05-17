import sys

from envoi.cli import CliApp
from envoi.cli.virtual_desktops.envoi import EnvoiCommand
from envoi.cli.virtual_desktops.hp_anyware import HpAnywareCommand

import logging

LOG = logging.getLogger(__name__)


class EnvoiVirtualDesktopsCli(CliApp):
    DESCRIPTION = "Envoi Virtual Desktops Command Line Utility"
    PARAMS = {
        "log_level": {
            "flags": ['--log-level'],
            "type": str,
            "default": "INFO",
            "help": "Set the logging level (options: DEBUG, INFO, WARNING, ERROR, CRITICAL)"
        },
    }
    SUBCOMMANDS = {
        'envoi': EnvoiCommand,
        'hp-anyware': HpAnywareCommand
    }


def main():
    cli = EnvoiVirtualDesktopsCli(auto_exec=False)
    return cli.run()


if __name__ == "__main__":
    sys.exit(main())
