### Envoi Cloud Desktops (ECD)

Envoi Cloud Desktops (ECD) is a desktop and server virtualization service designed for content creators to run video editing, graphics, visual effects, and machine learning workloads on both **Amazon Web Services (AWS)** and **Google Cloud Platform (GCP)**.

ECD is a part of Envoi's cloud platform that automates creating, managing, and distributing 24x7, live free ad-supported streaming television ("FAST"), Subscription or Pay-Per-View OTT (internet delivered) channels.

In addition, ECD allows users to quickly launch and manage fleets of macOS, Linux, and Windows virtual desktop infrastructures and automates storage provisioning for the AWS FSx, Qumulo, and Weka high-performance filesystems.

-----

### Usage

### macOS M2 Pro Development Workstations

This command provisions an **Apple Mac instance** on AWS, which is essential for developing, building, and running applications on the macOS platform in the cloud. It leverages a dedicated host to provide the underlying hardware.

#### **Command-Line Arguments**

  * `--ami-id AMI_ID`: The unique ID of the Amazon Machine Image (AMI) to use for the instance.
  * `--instance-name INSTANCE_NAME`: A user-defined, human-readable name for the new EC2 instance. The default is `envoi-dev-macos`.
  * `--instance-iam-role-id INSTANCE_IAM_ROLE_ID`: The **IAM Role Name or ARN** to associate with the instance.
  * `--instance-type INSTANCE_TYPE`: Specifies the size and hardware configuration. The default is `mac2-m2pro.metal`.
  * `--key-pair-name KEY_PAIR_NAME`: The name of an existing EC2 Key Pair for SSH access.
  * `--security-group-id SECURITY_GROUP_ID`: A comma-separated list of **Security Group IDs** to attach to the instance.
  * `--subnet-id SUBNET_ID`: The unique ID of the subnet where the instance will be launched.
  * `--instance-id INSTANCE_ID`: The ID of an existing instance for operations like stopping or starting. **Not used for creation.**
  * `--host-id HOST_ID`: The ID of a dedicated host to launch the instance on. This is required for macOS EC2 instances.
  * `--host-availability-zone HOST_AVAILABILITY_ZONE`: The Availability Zone of the dedicated host. The default is `us-east-1a`.
  * `--host-name HOST_NAME`: A name for the dedicated host.

#### **Example Command**

```bash
./envoi-virtual-desktops envoi development-macos \
  --ami-id ami-0abcdef1234567890 \
  --instance-name my-macos-dev-desktop \
  --key-pair-name my-ssh-key \
  --security-group-id sg-0123456789abcdef0 \
  --instance-iam-role-id my-iam-role
```

-----

# AWS EC2 macOS Provisioning Script

This bash script simplifies the process of launching a macOS EC2 instance on a dedicated host in AWS. It interactively guides you through the required steps, from selecting a region and instance type to configuring your network and security settings, to finally allocating a dedicated host and launching the instance.

### Features

  * **Interactive Menus**: Select your AWS Region and Mac Instance Type from a list.
  * **Availability Check**: Automatically checks for available instance offerings in each Availability Zone (AZ).
  * **Guided Setup**: Prompts you for VPC, subnet, and key pair details.
  * **Pre-execution Review**: Displays the exact AWS CLI commands that will be executed before you confirm deployment.
  * **Resource Provisioning**: Handles both the **allocation of a dedicated host** and the **launch of the EC2 instance**.

### Prerequisites

1.  **AWS CLI**: Ensure the AWS Command Line Interface is installed and configured with appropriate credentials. You can download it [here](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).
2.  **IAM Permissions**: Your AWS user or role must have permissions to perform the following actions:
      * `ec2:Describe*`
      * `ec2:AllocateHosts`
      * `ec2:RunInstances`
3.  **Required Tools**: The script relies on standard Linux/macOS command-line tools such as `grep`, `awk`, and `cut`.

### Setup and Usage

1.  **Save the Script**: Save the provided script to a file, for example, `mac-provisioner.sh`.

2.  **Make it Executable**: Give the script execute permissions.

    ```bash
    chmod +x deploy-ec2-mac.sh
    ```

3.  **Update Variables**: Open the script and update the following environment variables at the top of the file with your specific information:

      * `AWS_PROFILE`: Your AWS CLI profile name.
      * `AWS_EC2_SECURITY_GROUP_ID`: The ID of the security group you wish to use.

4.  **Run the Script**: Execute the script from your terminal.

    ```bash
    ./deploy-ec2-mac.sh
    ```

### Interactive Prompts

The script will walk you through a series of prompts. Here's what to expect:

1.  **Region Selection**: Choose the AWS region where you want to deploy the macOS instance.
2.  **Instance Type**: Select the Mac instance type (e.g., `mac1.metal`, `mac2.metal`).
3.  **Availability Zone**: The script will list available AZs and prompt you to choose one.
4.  **VPC and Subnet**: A list of available VPCs and their associated subnets will be displayed. You must choose a VPC and a subnet for the instance.
5.  **Key Pair**: Select an existing EC2 Key Pair to use for SSH access to the instance.
6.  **User Data (Optional)**: Provide an optional user data file path for instance initialization.

After completing the prompts, the script will echo the `aws ec2 allocate-hosts` and `aws ec2 run-instances` commands for your review before asking for final confirmation to proceed with the deployment.

-----

### DaVinci Resolve Linux Development Workstations

This command launches a Linux-based virtual desktop optimized for **DaVinci Resolve**, a professional video editing application. It uses a **CloudFormation stack** for streamlined deployment.

#### **Command-Line Arguments**

  * `--stack-name STACK_NAME`: **(Required)** The unique name for the CloudFormation stack.
  * `--ami-id AMI_ID`: The AMI ID to be used, which should be a pre-baked Linux image with DaVinci Resolve and NVIDIA drivers.
  * `--instance-name INSTANCE_NAME`: A name for the virtual desktop instance.
  * `--instance-iam-role-id INSTANCE_IAM_ROLE_ID`: The IAM role for the instance.
  * `--instance-type INSTANCE_TYPE`: The EC2 instance type, typically a GPU-enabled instance like a `g4dn.xlarge`.
  * `--key-pair-name KEY_PAIR_NAME`: The SSH Key Pair for secure access.
  * `--security-group-id SECURITY_GROUP_ID`: The security groups to apply.
  * `--subnet-id SUBNET_ID`: The subnet where the instance will be deployed.

#### **Example Command**

```bash
./envoi-virtual-desktops envoi development-linux \
  --stack-name resolve-linux-desktop \
  --ami-id ami-0abcdef1234567890 \
  --instance-name resolve-workstation-1 \
  --instance-type g4dn.xlarge \
  --key-pair-name my-linux-ssh-key \
  --security-group-id sg-0123456789abcdef0 \
  --subnet-id subnet-0123456789abcdef0
```

-----

### Windows Server Development Workstations

This command deploys a **Windows-based virtual desktop** using the same CloudFormation stack-based deployment as the Linux desktops.

#### **Command-Line Arguments**

  * `--stack-name STACK_NAME`: **(Required)** The name for the CloudFormation stack.
  * `--ami-id AMI_ID`: The AMI ID for the Windows Server.
  * `--instance-name INSTANCE_NAME`: The name for the instance.
  * `--instance-iam-role-id INSTANCE_IAM_ROLE_ID`: The IAM role for the instance.
  * `--instance-type INSTANCE_TYPE`: The instance type to use.
  * `--key-pair-name KEY_PAIR_NAME`: The SSH Key Pair.
  * `--security-group-id SECURITY_GROUP_ID`: The security group to apply.
  * `--subnet-id SUBNET_ID`: The subnet for deployment.

#### **Example Command**

```bash
./envoi-virtual-desktops envoi development-windows \
  --stack-name windows-dev-desktop \
  --ami-id ami-01234567890abcdef \
  --instance-name windows-desktop-1 \
  --instance-type g4dn.xlarge \
  --key-pair-name my-windows-key \
  --security-group-id sg-0123456789abcdef0 \
  --subnet-id subnet-0123456789abcdef0
```

-----

### DaVinci Resolve Windows Server 2025 for NVIDIA with HP Anyware

This command deploys a highly specialized virtual desktop using **HP Anyware** for high-performance remote access. It is built on a Windows Server with NVIDIA GPUs and is optimized for graphically intensive tasks.

#### **Command-Line Arguments**

  * `--stack-name STACK_NAME`: **(Required)** A unique name for the CloudFormation stack.
  * `--instance-type-size INSTANCE_TYPE_SIZE`: The specific EC2 instance type, typically a GPU instance.
  * `--vpc-cidr VPC_CIDR`: The CIDR block for the new Virtual Private Cloud (VPC) to be created.
  * `--subnet-cidr SUBNET_CIDR`: The CIDR block for the new subnet.
  * `--allow-admin-cidr ALLOW_ADMIN_CIDR`: The CIDR block for the IP range of administrators who need SSH access.
  * `--allow-client-cidr ALLOW_CLIENT_CIDR`: The CIDR block for the IP range of remote clients who will connect using HP Anyware.
  * `--template-url TEMPLATE_URL`: The URL of the CloudFormation template to use.

#### **Example Command**

```bash
./envoi-virtual-desktops hp-anyware windows-2019-nvidia \
  --stack-name resolve-windows-anyware \
  --instance-type-size g4dn.2xlarge \
  --vpc-cidr 10.0.0.0/16 \
  --subnet-cidr 10.0.1.0/24 \
  --allow-admin-cidr 203.0.113.0/24 \
  --allow-client-cidr 198.51.100.0/24
```

-----

### Linux workstations with Nice DCV

This command deploys a Linux virtual desktop using **Nice DCV** for high-performance remote access.

#### **Command-Line Arguments**

  * `--stack-name STACK_NAME`: **(Required)** A unique name for the CloudFormation stack.
  * `--instance-type-size INSTANCE_TYPE_SIZE`: The EC2 instance type to launch.
  * `--vpc-cidr VPC_CIDR`: The CIDR block for the VPC.
  * `--subnet-cidr SUBNET_CIDR`: The CIDR block for the subnet.
  * `--allow-admin-cidr ALLOW_ADMIN_CIDR`: The CIDR block for administrator access.
  * `--allow-client-cidr ALLOW_CLIENT_CIDR`: The CIDR block for remote client connections.
  * `--template-url TEMPLATE_URL`: The URL of the CloudFormation template.

#### **Example Command**

```bash
./envoi-virtual-desktops nice-dcv centos-7 \
  --stack-name dcv-linux-desktop \
  --instance-type-size g4dn.2xlarge \
  --vpc-cidr 10.0.0.0/16 \
  --subnet-cidr 10.0.1.0/24 \
  --allow-admin-cidr 203.0.113.0/24 \
  --allow-client-cidr 198.51.100.0/24 \
  --template-url https://envoi-prod-files-public.s3.amazonaws.com/aws/cloud-formation/templates/nice-dcv/nice-dcv-centos-7.template
```

-----

### Unreal Engine 5 Windows Server 2025 with Nice DCV

This command provisions a virtual desktop tailored for **Unreal Engine 5** on a Windows Server using **Nice DCV**.

#### **Command-Line Arguments**

  * `--stack-name STACK_NAME`: **(Required)** A unique name for the CloudFormation stack.
  * `--instance-type-size INSTANCE_TYPE_SIZE`: The EC2 instance type to launch, typically a high-end GPU instance.
  * `--vpc-cidr VPC_CIDR`: The CIDR block for the VPC.
  * `--subnet-cidr SUBNET_CIDR`: The CIDR block for the subnet.
  * `--allow-admin-cidr ALLOW_ADMIN_CIDR`: The CIDR block for administrator access.
  * `--allow-client-cidr ALLOW_CLIENT_CIDR`: The CIDR block for remote client connections.
  * `--template-url TEMPLATE_URL`: The URL of the CloudFormation template.

#### **Example Command**

```bash
./envoi-virtual-desktops nice-dcv unreal-engine-5 \
  --stack-name unreal-engine-dcv-desktop \
  --instance-type-size g4dn.2xlarge \
  --vpc-cidr 10.0.0.0/16 \
  --subnet-cidr 10.0.1.0/24 \
  --allow-admin-cidr 203.0.113.0/24 \
  --allow-client-cidr 198.51.100.0/24 \
  --template-url https://envoi-prod-files-public.s3.amazonaws.com/aws/cloud-formation/templates/nice-dcv/nice-dcv-unreal-engine-5.template
```

-----

### Windows Server 2025 NVIDIA with Nice DCV

This command provisions a standard Windows virtual desktop with NVIDIA GPU drivers and **Nice DCV** for remote access.

#### **Command-Line Arguments**

  * `--stack-name STACK_NAME`: **(Required)** A unique name for the CloudFormation stack.
  * `--instance-type-size INSTANCE_TYPE_SIZE`: The EC2 instance type to launch.
  * `--vpc-cidr VPC_CIDR`: The CIDR block for the VPC.
  * `--subnet-cidr SUBNET_CIDR`: The CIDR block for the subnet.
  * `--allow-admin-cidr ALLOW_ADMIN_CIDR`: The CIDR block for administrator access.
  * `--allow-client-cidr ALLOW_CLIENT_CDR`: The CIDR block for remote client connections.
  * `--template-url TEMPLATE_URL`: The URL of the CloudFormation template.

#### **Example Command**

```bash
./envoi-virtual-desktops nice-dcv windows-2019-nvidia \
  --stack-name dcv-windows-desktop \
  --instance-type-size g4dn.2xlarge \
  --vpc-cidr 10.0.0.0/16 \
  --subnet-cidr 10.0.1.0/24 \
  --allow-admin-cidr 203.0.113.0/24 \
  --allow-client-cidr 198.51.100.0/24 \
  --template-url https://envoi-prod-files-public.s3.amazonaws.com/aws/cloud-formation/templates/nice-dcv/nice-dcv-windows-2019-nvidia.template
```

To create a `README.md` for this script, you'll want to include a clear title, a brief description, instructions for installation and setup, and a usage example. I'll also add sections for the script's features and an explanation of the user prompts.
