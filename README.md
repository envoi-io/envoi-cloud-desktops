# Envoi Virtual Desktops

Envoi Virtual Desktops (EVD) is a desktop and server virtualization service designed for content creators looking to run video editing, graphics, visual effects, and machine learning workloads on both Amazon Web Services (AWS) and Google Cloud Platform (GCP)

EVD is a part of Envoi's cloud platform that automates creating, managing, and distributing 24x7, live free ad-supported streaming television "FAST", Subscription or Pay-Per-View OTT (internet delivered) channels.

In addition, EVD allows users to quickly launch and manage fleets of Mac OS, Linux, and Windows virtual desktop infrastructures and automates storage provisioning for the AWS FSx, Qumulo and Weka high performance filesystems. 


## Usage

### Linux workstations with HP Anyware

```text
./envoi-virtual-desktops hp-anyware centos-7 --help
usage: envoi-virtual-desktops hp-anyware centos-7 [-h] --stack-name STACK_NAME [--instance-type-size INSTANCE_TYPE_SIZE] [--vpc-cidr VPC_CIDR] [--subnet-cidr SUBNET_CIDR]
                                                  [--allow-admin-cidr ALLOW_ADMIN_CIDR] [--allow-client-cidr ALLOW_CLIENT_CIDR] [--template-url TEMPLATE_URL]

options:
  -h, --help            show this help message and exit
  --stack-name STACK_NAME
                        Name of the CloudFormation stack (default: None)
  --instance-type-size INSTANCE_TYPE_SIZE
                        Instance Type (default: None)
  --vpc-cidr VPC_CIDR   VPC CIDR (default: None)
  --subnet-cidr SUBNET_CIDR
                        Subnet CIDR (default: None)
  --allow-admin-cidr ALLOW_ADMIN_CIDR
                        Allow Admin CIDR (default: None)
  --allow-client-cidr ALLOW_CLIENT_CIDR
                        Allow Client CIDR (default: None)
  --template-url TEMPLATE_URL
                        Path to the CloudFormation template (default: https://envoi-prod-files-public.s3.amazonaws.com/aws/cloud-formation/templates/hp-anyware/hp-anyware-centos-7-23.12.2.template)

```

```shell
./envoi-virtual-desktops hp-anyware centos-7 --stack-name STACK_NAME --instance-type-size INSTANCE_TYPE_SIZE --vpc-cidr VPC_CIDR --subnet-cidr SUBNET_CIDR --allow-admin-cidr ALLOW_ADMIN_CIDR --allow-client-cidr ALLOW_CLIENT_CIDR --template-url TEMPLATE_URL

```

### Unreal Engine 5 Windows 2019 with HP Anyware


```text

./envoi-virtual-desktops hp-anyware unreal-engine-5 --help 
usage: envoi-virtual-desktops hp-anyware unreal-engine-5 [-h] --stack-name STACK_NAME [--instance-type-size INSTANCE_TYPE_SIZE] [--vpc-cidr VPC_CIDR] [--subnet-cidr SUBNET_CIDR]
                                                         [--allow-admin-cidr ALLOW_ADMIN_CIDR] [--allow-client-cidr ALLOW_CLIENT_CIDR] [--template-url TEMPLATE_URL]

options:
  -h, --help            show this help message and exit
  --stack-name STACK_NAME
                        Name of the CloudFormation stack (default: None)
  --instance-type-size INSTANCE_TYPE_SIZE
                        Instance Type (default: None)
  --vpc-cidr VPC_CIDR   VPC CIDR (default: None)
  --subnet-cidr SUBNET_CIDR
                        Subnet CIDR (default: None)
  --allow-admin-cidr ALLOW_ADMIN_CIDR
                        Allow Admin CIDR (default: None)
  --allow-client-cidr ALLOW_CLIENT_CIDR
                        Allow Client CIDR (default: None)
  --template-url TEMPLATE_URL
                        Path to the CloudFormation template (default: https://envoi-prod-files-public.s3.amazonaws.com/aws/cloud-formation/templates/hp-anyware/hp-anyware-unreal-engine-5-23.12.2.template


```

```shell
envoi-virtual-desktops hp-anyware unreal-engine-5 --stack-name STACK_NAME --instance-type-size INSTANCE_TYPE_SIZE --vpc-cidr VPC_CIDR --subnet-cidr SUBNET_CIDR --allow-admin-cidr ALLOW_ADMIN_CIDR --allow-client-cidr ALLOW_CLIENT_CIDR --template-url TEMPLATE_URL
```


### Windows Server 2019 for NVIDIA with HP Anyware

```text

./envoi-virtual-desktops hp-anyware windows-2019-nvidia --help
usage: envoi-virtual-desktops hp-anyware windows-2019-nvidia [-h] --stack-name STACK_NAME [--instance-type-size INSTANCE_TYPE_SIZE] [--vpc-cidr VPC_CIDR] [--subnet-cidr SUBNET_CIDR]
                                                             [--allow-admin-cidr ALLOW_ADMIN_CIDR] [--allow-client-cidr ALLOW_CLIENT_CIDR] [--template-url TEMPLATE_URL]

options:
  -h, --help            show this help message and exit
  --stack-name STACK_NAME
                        Name of the CloudFormation stack (default: None)
  --instance-type-size INSTANCE_TYPE_SIZE
                        Instance Type (default: None)
  --vpc-cidr VPC_CIDR   VPC CIDR (default: None)
  --subnet-cidr SUBNET_CIDR
                        Subnet CIDR (default: None)
  --allow-admin-cidr ALLOW_ADMIN_CIDR
                        Allow Admin CIDR (default: None)
  --allow-client-cidr ALLOW_CLIENT_CIDR
                        Allow Client CIDR (default: None)
  --template-url TEMPLATE_URL
                        Path to the CloudFormation template (default: https://envoi-prod-files-public.s3.amazonaws.com/aws/cloud-formation/templates/hp-anyware/hp-anyware-windows-2019-nvidia-23.12.2.template)

```

```shell
./envoi-virtual-desktops hp-anyware windows-2019-nvidia --stack-name STACK_NAME --instance-type-size INSTANCE_TYPE_SIZE --vpc-cidr VPC_CIDR --subnet-cidr SUBNET_CIDR
                                                             --allow-admin-cidr ALLOW_ADMIN_CIDR --allow-client-cidr ALLOW_CLIENT_CIDR
```




### Linux workstations with Nice DCV

```text
./envoi-virtual-desktops nice-dcv centos-7 --help
usage: envoi-virtual-desktops hp-anyware centos-7 [-h] --stack-name STACK_NAME [--instance-type-size INSTANCE_TYPE_SIZE] [--vpc-cidr VPC_CIDR] [--subnet-cidr SUBNET_CIDR]
                                                  [--allow-admin-cidr ALLOW_ADMIN_CIDR] [--allow-client-cidr ALLOW_CLIENT_CIDR] [--template-url TEMPLATE_URL]

options:
  -h, --help            show this help message and exit
  --stack-name STACK_NAME
                        Name of the CloudFormation stack (default: None)
  --instance-type-size INSTANCE_TYPE_SIZE
                        Instance Type (default: None)
  --vpc-cidr VPC_CIDR   VPC CIDR (default: None)
  --subnet-cidr SUBNET_CIDR
                        Subnet CIDR (default: None)
  --allow-admin-cidr ALLOW_ADMIN_CIDR
                        Allow Admin CIDR (default: None)
  --allow-client-cidr ALLOW_CLIENT_CIDR
                        Allow Client CIDR (default: None)
  --template-url TEMPLATE_URL
                        Path to the CloudFormation template (default: https://envoi-prod-files-public.s3.amazonaws.com/aws/cloud-formation/templates/hp-anyware/hp-anyware-centos-7-23.12.2.template)

```

```shell
./envoi-virtual-desktops nice-dcv centos-7 --stack-name STACK_NAME --instance-type-size INSTANCE_TYPE_SIZE --vpc-cidr VPC_CIDR --subnet-cidr SUBNET_CIDR --allow-admin-cidr ALLOW_ADMIN_CIDR --allow-client-cidr ALLOW_CLIENT_CIDR --template-url TEMPLATE_URL

```

### Unreal Engine 5 Windows Server 2019 with Nice DCV


```text

./envoi-virtual-desktops nice-dcv unreal-engine-5 --help 
usage: envoi-virtual-desktops hp-anyware unreal-engine-5 [-h] --stack-name STACK_NAME [--instance-type-size INSTANCE_TYPE_SIZE] [--vpc-cidr VPC_CIDR] [--subnet-cidr SUBNET_CIDR]
                                                         [--allow-admin-cidr ALLOW_ADMIN_CIDR] [--allow-client-cidr ALLOW_CLIENT_CIDR] [--template-url TEMPLATE_URL]

options:
  -h, --help            show this help message and exit
  --stack-name STACK_NAME
                        Name of the CloudFormation stack (default: None)
  --instance-type-size INSTANCE_TYPE_SIZE
                        Instance Type (default: None)
  --vpc-cidr VPC_CIDR   VPC CIDR (default: None)
  --subnet-cidr SUBNET_CIDR
                        Subnet CIDR (default: None)
  --allow-admin-cidr ALLOW_ADMIN_CIDR
                        Allow Admin CIDR (default: None)
  --allow-client-cidr ALLOW_CLIENT_CIDR
                        Allow Client CIDR (default: None)
  --template-url TEMPLATE_URL
                        Path to the CloudFormation template (default: https://envoi-prod-files-public.s3.amazonaws.com/aws/cloud-formation/templates/hp-anyware/hp-anyware-unreal-engine-5-23.12.2.template


```

```shell
envoi-virtual-desktops nice-dcv unreal-engine-5 --stack-name STACK_NAME --instance-type-size INSTANCE_TYPE_SIZE --vpc-cidr VPC_CIDR --subnet-cidr SUBNET_CIDR --allow-admin-cidr ALLOW_ADMIN_CIDR --allow-client-cidr ALLOW_CLIENT_CIDR --template-url TEMPLATE_URL
```


### Windows Server 2019 NVIDIA with Nice DCV

```text

./envoi-virtual-desktops nice-dcv windows-2019-nvidia --help
usage: envoi-virtual-desktops hp-anyware windows-2019-nvidia [-h] --stack-name STACK_NAME [--instance-type-size INSTANCE_TYPE_SIZE] [--vpc-cidr VPC_CIDR] [--subnet-cidr SUBNET_CIDR]
                                                             [--allow-admin-cidr ALLOW_ADMIN_CIDR] [--allow-client-cidr ALLOW_CLIENT_CIDR] [--template-url TEMPLATE_URL]

options:
  -h, --help            show this help message and exit
  --stack-name STACK_NAME
                        Name of the CloudFormation stack (default: None)
  --instance-type-size INSTANCE_TYPE_SIZE
                        Instance Type (default: None)
  --vpc-cidr VPC_CIDR   VPC CIDR (default: None)
  --subnet-cidr SUBNET_CIDR
                        Subnet CIDR (default: None)
  --allow-admin-cidr ALLOW_ADMIN_CIDR
                        Allow Admin CIDR (default: None)
  --allow-client-cidr ALLOW_CLIENT_CIDR
                        Allow Client CIDR (default: None)
  --template-url TEMPLATE_URL
                        Path to the CloudFormation template (default: https://envoi-prod-files-public.s3.amazonaws.com/aws/cloud-formation/templates/hp-anyware/hp-anyware-windows-2019-nvidia-23.12.2.template)

```

```shell
./envoi-virtual-desktops nice-dcv windows-2019-nvidia --stack-name STACK_NAME --instance-type-size INSTANCE_TYPE_SIZE --vpc-cidr VPC_CIDR --subnet-cidr SUBNET_CIDR
                                                             --allow-admin-cidr ALLOW_ADMIN_CIDR --allow-client-cidr ALLOW_CLIENT_CIDR
```


