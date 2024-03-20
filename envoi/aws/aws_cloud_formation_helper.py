from types import SimpleNamespace

import boto3


def add_from_namespace_to_dict_if_not_none(source_obj, source_key, target_obj, target_key):
    if hasattr(source_obj, source_key):
        value = getattr(source_obj, source_key)
        if value is not None:
            target_obj[target_key] = value


class AwsCloudFormationHelper:

    @classmethod
    def client_from_opts(cls, cfn_client_args=None, opts=None):
        if cfn_client_args is None:
            cfn_client_args = {}

        if opts is None:
            opts = SimpleNamespace()

        session_args = {}
        add_from_namespace_to_dict_if_not_none(opts, 'aws_profile', session_args, 'profile_name')
        add_from_namespace_to_dict_if_not_none(opts, 'aws_region', cfn_client_args, 'region_name')

        if len(session_args) != 0:
            client_parent = boto3.Session(**session_args)
        else:
            client_parent = boto3

        return client_parent.client('cloudformation', **cfn_client_args)

    @classmethod
    def create_stack(cls, stack_name, template_url, cfn_role_arn=None, template_parameters=None, client=None,
                     cfn_client_args=None):
        if client is None:
            if cfn_client_args is None:
                cfn_client_args = {}
            client = boto3.client('cloudformation', **cfn_client_args)

        cfn_create_stack_args = {
            'StackName': stack_name,
            'TemplateURL': template_url
        }

        if template_parameters is not None:
            cfn_create_stack_args['Parameters'] = template_parameters

        if cfn_role_arn is not None:
            cfn_create_stack_args['RoleARN'] = cfn_role_arn

        return client.create_stack(**cfn_create_stack_args)

    @classmethod
    def populate_template_parameters_from_opts(cls, template_parameters, opts, field_map):
        for opts_param_name, template_param_name in field_map.items():
            value = getattr(opts, opts_param_name, None)
            if value is not None:
                template_parameters.append({
                    "ParameterKey": template_param_name,
                    "ParameterValue": value
                })

        return template_parameters

