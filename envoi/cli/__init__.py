import argparse
import datetime
import uuid
import json
import logging
import os
import sys

LOG = logging.getLogger(__name__)

DEFAULT_PARAMS = {
    "help": {
        "action": "help",
        "help": "Show this help message and exit."
    }
}


class CustomFormatter(argparse.RawDescriptionHelpFormatter, argparse.ArgumentDefaultsHelpFormatter):

    def _split_lines(self, text, width):
        return text.splitlines()


class CliArgParser(argparse.ArgumentParser):

    def to_dict(self):
        # noinspection PyProtectedMember
        return {a.dest: a.default for a in self._actions if isinstance(a, argparse._StoreAction)}


def json_argument(arg):
    if arg.startswith('file://'):
        file_path = arg[7:]
        if os.path.exists(file_path):
            with open(file_path, 'r') as f:
                return json.load(f)
        else:
            raise argparse.ArgumentTypeError(f"File {file_path} does not exist")
    # elif arg.startswith('http://') or arg.startswith('https://'):
    #     response = requests.get(arg)
    #     try:
    #         return response.json()
    #     except json.JSONDecodeError:
    #         raise argparse.ArgumentTypeError(f"Invalid JSON from URL: {arg}")
    else:
        try:
            return json.loads(arg)
        except json.JSONDecodeError:
            raise argparse.ArgumentTypeError(f"Invalid JSON: {arg}")


class CliCommand:
    DESCRIPTION = ""
    PARAMS = {}
    SUBCOMMANDS = {}
    FORMATTER_CLASS = CustomFormatter

    def __init__(self, opts=None, auto_exec=True):
        self.opts = opts or {}
        if auto_exec:
            self.run()

    @classmethod
    def init_parser(cls, command_name=None, parent_parsers=None, subparsers=None, formatter_class=None):
        if formatter_class is None:
            formatter_class = cls.FORMATTER_CLASS

        common_args = {
            'formatter_class': formatter_class,
            'parents': parent_parsers or []
        }

        if subparsers is None:
            parser = CliArgParser(description=cls.DESCRIPTION, **common_args)
        else:
            parser = subparsers.add_parser(command_name or cls.__name__.lower(), help=cls.DESCRIPTION, **common_args)

        parser.set_defaults(handler=cls)

        cls.parse_params(parser)

        if cls.SUBCOMMANDS:
            cls.process_subcommands(parser=parser, parent_parsers=parent_parsers, subcommands=cls.SUBCOMMANDS)

        return parser

    @classmethod
    def parse_params(cls, parser, params=None):
        if params is None:
            params = cls.PARAMS

        if params is not None:
            for param_name, param_settings in params.items():
                if param_settings is None:
                    continue
                _param_settings = param_settings.copy()
                if 'flags' in _param_settings:
                    flags = _param_settings.pop('flags')
                else:
                    flags = None

                if flags is None or len(flags) == 0:
                    flags = [f"--{param_name.replace('_', '-')}"]

                parser.add_argument(*flags, **_param_settings)

    @classmethod
    def process_subcommands(cls, parser, parent_parsers, subcommands, dest=None, add_subparser_args=None):
        subcommand_parsers = {}
        if add_subparser_args is None:
            add_subparser_args = {}
        if dest is not None:
            add_subparser_args['dest'] = dest
        subparsers = parser.add_subparsers(**add_subparser_args)

        for subcommand_name, subcommand_info in subcommands.items():
            if not isinstance(subcommand_info, dict):
                subcommand_info = {"handler": subcommand_info}
            subcommand_handler = subcommand_info.get("handler", None)
            if subcommand_handler is None:
                continue
            if isinstance(subcommand_handler, str):
                subcommand_handler = globals()[subcommand_handler]

            subcommand_parser = subcommand_handler.init_parser(command_name=subcommand_name,
                                                               parent_parsers=parent_parsers,
                                                               subparsers=subparsers)
            subcommand_parser.required = subcommand_info.get("required", True)
            subcommand_parsers[subcommand_name] = subcommand_parser

        return parser

    def run(self):
        pass
        # if len(sys.argv) == 1:
        #     parser.print_help()
        #     return 1


class ArgumentParser(argparse.ArgumentParser):

    def to_dict(self):
        # noinspection PyProtectedMember
        return {a.dest: a.default for a in self._actions if isinstance(a, argparse._StoreAction)}


class CustomJsonEncoder(json.JSONEncoder):

    def default(self, o):
        if isinstance(o, datetime.datetime):
            return o.isoformat()
        if isinstance(o, uuid.UUID):
            return str(o)
        return json.JSONEncoder.default(self, o)


class CliApp(CliCommand):
    DESCRIPTION = ""
    PARAMS = {}
    SUBCOMMANDS = {}

    @classmethod
    def parse_command_line(cls, cli_args=None, env_vars=None):
        if cli_args is None:
            cli_args = sys.argv[1:]
        if env_vars is None:
            env_vars = os.environ.copy()
        # print(f"cli_args: {cli_args}")
        parent_parser = ArgumentParser(add_help=False)

        # main parser
        parser = cls.init_parser(parent_parsers=[parent_parser])

        (opts, unknown_args) = parser.parse_known_args(cli_args)
        return opts, unknown_args, env_vars, parser

    def parse_known_args(self):
        pass

    @classmethod
    def run(cls, cli_args=None, env_vars=None):
        opts, _unhandled_args, env_vars, parser = cls.parse_command_line(cli_args, env_vars)

        ch = logging.StreamHandler()
        ch.setLevel(opts.log_level.upper())
        LOG.addHandler(ch)

        try:
            # If 'handler' is in args, run the correct handler
            if hasattr(opts, 'handler'):
                if opts.handler is not cls:
                    opts.handler(opts)
                elif len(sys.argv) == 1:
                    parser.print_help()
                    return 1
            else:
                parser.print_help()
                return 1

            return 0
        except Exception as e:
            if LOG.isEnabledFor(logging.DEBUG):
                LOG.exception(e)  # Log full exception with stack trace in debug mode
            else:
                LOG.error(e.args if hasattr(e, 'args') else e)  # Log only the error message in non-debug mode
            return 1
