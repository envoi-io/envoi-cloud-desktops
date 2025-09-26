#!/bin/bash

# Define the names of the environment variables to check
ENV_VARS=(
  "AWS_PROFILE"
  "AWS_DEFAULT_REGION"
  "AWS_EC2_SECURITY_GROUP_ID"
  "AWS_EC2_KEY_NAME"
  "AWS_EC2_SUBNET_ID"
  "AWS_INSTANCE_TYPE"
  "FLICS_TARBALL_URL"
  "FLICS_TARBALL_NAME"
  "FLICS_LICENSE_URL"
  "FLICS_LICENSE_NAME"
)

# Set default values for variables if they are not already set
: ${AWS_INSTANCE_TYPE:="t2.micro"}
: ${FLICS_TARBALL_URL:="https://ocean.hiscale.com/f/YOURUNIQUECODE/?dl=1"}
: ${FLICS_TARBALL_NAME:="flicsfull_v3.1.6206-linux-x64.tar.gz"}
: ${FLICS_LICENSE_URL:="https://ocean.hiscale.com/f/YOURUNIQUECODE/?dl=1"}
: ${FLICS_LICENSE_NAME:="flicsfull_v3.1.6206-license"}

# Function to get the latest AMI ID for a given OS and region
function get_latest_ami() {
  local os_name=$1
  local region=$2
  local ami_id=""

  case $os_name in
    "Ubuntu 24.04 LTS")
      ami_id=$(aws ec2 describe-images --region "$region" --owners "099720109477" --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-noble-24.04-amd64-server-*" "Name=virtualization-type,Values=hvm" --query "sort_by(Images, &CreationDate)[-1].ImageId" --output text)
      ;;
    "Ubuntu 22.04 LTS")
      ami_id=$(aws ec2 describe-images --region "$region" --owners "099720109477" --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" "Name=virtualization-type,Values=hvm" --query "sort_by(Images, &CreationDate)[-1].ImageId" --output text)
      ;;
    "Debian 11")
      ami_id=$(aws ec2 describe-images --region "$region" --owners "137112412989" --filters "Name=name,Values=debian-11-amd64-*" "Name=virtualization-type,Values=hvm" --query "sort_by(Images, &CreationDate)[-1].ImageId" --output text)
      ;;
    "Rocky Linux 9")
      ami_id=$(aws ec2 describe-images --region "$region" --owners "358529241908" --filters "Name=name,Values=Rocky-9-EC2-AMI-*" "Name=virtualization-type,Values=hvm" --query "sort_by(Images, &CreationDate)[-1].ImageId" --output text)
      ;;
    "Amazon Linux 2")
      ami_id=$(aws ec2 describe-images --region "$region" --owners "137112412989" --filters "Name=name,Values=amzn2-ami-hvm-2*" "Name=virtualization-type,Values=hvm" --query "sort_by(Images, &CreationDate)[-1].ImageId" --output text)
      ;;
    *)
      echo "Unsupported OS for AMI query."
      return 1
      ;;
  esac

  echo "$ami_id"
}

# Step 1: Prompt for AWS Region selection, unless AWS_DEFAULT_REGION is already set
if [ -z "$AWS_DEFAULT_REGION" ]; then
    clear
    echo "Fetching all available AWS Regions..."
    echo ""
    REGION_LIST_TEXT=$(aws ec2 describe-regions --query "Regions[].{RegionName:RegionName}" --output text)
    if [ -z "$REGION_LIST_TEXT" ]; then
      echo "Failed to retrieve AWS regions. Check your AWS CLI configuration and permissions. Exiting."
      exit 1
    fi
    echo "Please select the AWS Region:"
    i=0
    REGION_CHOICES=()
    while read -r region; do
        REGION_CHOICES[$i]="$region"
        echo "$((i+1))) $region"
        i=$((i+1))
    done <<< "$REGION_LIST_TEXT"
    
    read -p "Your choice: " REGION_CHOICE
    SELECTED_REGION="${REGION_CHOICES[$((REGION_CHOICE-1))]}"
    export AWS_DEFAULT_REGION="$SELECTED_REGION"
    if [ -z "$SELECTED_REGION" ]; then
      echo "Invalid region selection. Exiting."
      exit 1
    fi
    echo "You have selected Region: $SELECTED_REGION"
else
    echo "Using AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION"
    SELECTED_REGION="$AWS_DEFAULT_REGION"
fi

# Step 2: Select Linux OS
# Using an indexed array instead of an associative array for broader Bash compatibility
declare -a OS_OPTIONS=("Ubuntu 24.04 LTS" "Ubuntu 22.04 LTS" "Debian 11" "Rocky Linux 9" "Amazon Linux 2")
declare -a SCRIPT_OPTIONS=("prepare-machine-ubuntu24.sh" "prepare-machine-ubuntu22.sh" "prepare-machine-debian11.sh" "prepare-machine-rocky9.sh" "prepare-machine-aws2.sh")

echo ""
echo "Please select the Linux Operating System:"
for i in "${!OS_OPTIONS[@]}"; do
    echo "$((i+1))) ${OS_OPTIONS[$i]}"
done
read -p "Your choice: " OS_CHOICE

if [ "$OS_CHOICE" -ge 1 ] && [ "$OS_CHOICE" -le "${#OS_OPTIONS[@]}" ]; then
    SELECTED_OS_NAME="${OS_OPTIONS[$((OS_CHOICE-1))]}"
    PREPARE_SCRIPT="${SCRIPT_OPTIONS[$((OS_CHOICE-1))]}"
else
    echo "Invalid OS selection. Exiting."
    exit 1
fi

SELECTED_OS_AMI=$(get_latest_ami "$SELECTED_OS_NAME" "$SELECTED_REGION")
if [ -z "$SELECTED_OS_AMI" ]; then
  echo "Could not find a valid AMI for '$SELECTED_OS_NAME' in region '$SELECTED_REGION'. Exiting."
  exit 1
fi
echo "Found latest AMI for $SELECTED_OS_NAME: $SELECTED_OS_AMI"

# Use AWS_INSTANCE_TYPE if it's set; otherwise, prompt for input with the default value.
if [ -z "$AWS_INSTANCE_TYPE" ]; then
    echo ""
    read -p "Enter the desired EC2 instance type (default: t2.micro): " USER_INSTANCE_TYPE_INPUT
    if [ -n "$USER_INSTANCE_TYPE_INPUT" ]; then
      AWS_INSTANCE_TYPE="$USER_INSTANCE_TYPE_INPUT"
    fi
else
    echo "Using AWS_INSTANCE_TYPE: $AWS_INSTANCE_TYPE"
fi

# Step 3: Select VPC, unless AWS_EC2_VPC_ID is already set
if [ -z "$AWS_EC2_VPC_ID" ]; then
    echo ""
    echo "Fetching available VPCs..."
    VPC_IDS=$(aws ec2 describe-vpcs --region "$SELECTED_REGION" --query "Vpcs[*].[VpcId, Tags[?Key=='Name'].Value|[0]]" --output text)
    if [ -z "$VPC_IDS" ]; then
      echo "No VPCs found. Exiting."
      exit 1
    fi
    echo "Available VPCs:"
    echo "$VPC_IDS" | nl
    read -p "Please select a VPC ID by number: " VPC_CHOICE
    AWS_EC2_VPC_ID=$(echo "$VPC_IDS" | sed -n "${VPC_CHOICE}p" | awk '{print $1}')
    if [ -z "$AWS_EC2_VPC_ID" ]; then
      echo "Invalid VPC selection. Exiting."
      exit 1
    fi
else
    echo "Using AWS_EC2_VPC_ID: $AWS_EC2_VPC_ID"
fi

# Step 4: Select Subnet ID, unless AWS_EC2_SUBNET_ID is already set
if [ -z "$AWS_EC2_SUBNET_ID" ]; then
    echo ""
    echo "Fetching available Subnets in VPC $AWS_EC2_VPC_ID..."
    SUBNETS=$(aws ec2 describe-subnets --region "$SELECTED_REGION" --filters "Name=vpc-id,Values=$AWS_EC2_VPC_ID" --query "Subnets[*].[SubnetId,AvailabilityZone]" --output text)
    if [ -z "$SUBNETS" ]; then
      echo "No subnets found for the selected VPC. Exiting."
      exit 1
    fi
    echo "Available Subnets:"
    SUBNET_INFO=()
    while read -r SUBNET_ID AZ; do
        ROUTE_TABLE_ID=$(aws ec2 describe-route-tables --region "$SELECTED_REGION" --filters "Name=association.subnet-id,Values=$SUBNET_ID" --query "RouteTables[0].RouteTableId" --output text)
        if [ "$ROUTE_TABLE_ID" == "None" ]; then
            ROUTE_TABLE_ID=$(aws ec2 describe-route-tables --region "$SELECTED_REGION" --filters "Name=association.main,Values=true" "Name=vpc-id,Values=$AWS_EC2_VPC_ID" --query "RouteTables[0].RouteTableId" --output text)
        fi
        IS_PUBLIC="Private"
        if [ -n "$ROUTE_TABLE_ID" ]; then
            HAS_IGW=$(aws ec2 describe-route-tables --region "$SELECTED_REGION" --route-table-ids "$ROUTE_TABLE_ID" --query "RouteTables[0].Routes[?GatewayId!=null].GatewayId" --output text | grep -c "igw-")
            if [ "$HAS_IGW" -gt 0 ]; then
                IS_PUBLIC="Public"
            fi
        fi
        SUBNET_INFO+=("$SUBNET_ID $AZ ($IS_PUBLIC)")
    done <<< "$SUBNETS"
    for i in "${!SUBNET_INFO[@]}"; do
      printf "%d) %s\n" $((i+1)) "${SUBNET_INFO[$i]}"
    done
    
    read -p "Please select a Subnet ID by number: " SUBNET_CHOICE
    AWS_EC2_SUBNET_ID=$(echo "${SUBNET_INFO[$((SUBNET_CHOICE-1))]}" | awk '{print $1}')
    if [ -z "$AWS_EC2_SUBNET_ID" ]; then
      echo "Invalid Subnet selection. Exiting."
      exit 1
    fi
else
    echo "Using AWS_EC2_SUBNET_ID: $AWS_EC2_SUBNET_ID"
fi

# Step 5: Select Security Group, unless AWS_EC2_SECURITY_GROUP_ID is already set
if [ -z "$AWS_EC2_SECURITY_GROUP_ID" ]; then
    echo ""
    echo "Fetching available Security Groups in VPC $AWS_EC2_VPC_ID..."
    SECURITY_GROUPS=$(aws ec2 describe-security-groups --region "$SELECTED_REGION" --filters "Name=vpc-id,Values=$AWS_EC2_VPC_ID" --query "SecurityGroups[*].[GroupId,GroupName]" --output text)
    if [ -z "$SECURITY_GROUPS" ]; then
      echo "No Security Groups found. Exiting."
      exit 1
    fi
    echo "Available Security Groups:"
    echo "$SECURITY_GROUPS" | nl
    read -p "Please select a Security Group ID by number: " SG_CHOICE
    AWS_EC2_SECURITY_GROUP_ID=$(echo "$SECURITY_GROUPS" | sed -n "${SG_CHOICE}p" | awk '{print $1}')
    if [ -z "$AWS_EC2_SECURITY_GROUP_ID" ]; then
      echo "Invalid Security Group selection. Exiting."
      exit 1
    fi
else
    echo "Using AWS_EC2_SECURITY_GROUP_ID: $AWS_EC2_SECURITY_GROUP_ID"
fi

# Step 6: Select Key Pair, unless AWS_EC2_KEY_NAME is already set
if [ -z "$AWS_EC2_KEY_NAME" ]; then
    echo ""
    echo "Fetching available EC2 Key Pairs..."
    KEY_PAIRS_TEXT=$(aws ec2 describe-key-pairs --region "$SELECTED_REGION" --query "KeyPairs[*].KeyName" --output text)
    if [ -z "$KEY_PAIRS_TEXT" ]; then
      echo "No Key Pairs found. Exiting."
      exit 1
    fi
    echo "Available Key Pairs:"
    IFS=$'\t' read -r -a KEY_PAIR_ARRAY <<< "$KEY_PAIRS_TEXT"
    for i in "${!KEY_PAIR_ARRAY[@]}"; do
        printf "%d) %s\n" $((i+1)) "${KEY_PAIR_ARRAY[$i]}"
    done
    read -p "Please select a Key Pair by number: " KEY_CHOICE
    AWS_EC2_KEY_NAME=${KEY_PAIR_ARRAY[$((KEY_CHOICE-1))]}
    if [ -z "$AWS_EC2_KEY_NAME" ]; then
      echo "Invalid Key Pair selection. Exiting."
      exit 1
    fi
else
    echo "Using AWS_EC2_KEY_NAME: $AWS_EC2_KEY_NAME"
fi

# Step 7: Confirm and Deploy
echo ""
echo "You have chosen to deploy a Linux EC2 instance with the following settings:"
echo "Region: $SELECTED_REGION"
echo "Operating System: $SELECTED_OS_NAME (AMI: $SELECTED_OS_AMI)"
echo "Instance Type: $AWS_INSTANCE_TYPE"
echo "VPC ID: $AWS_EC2_VPC_ID"
echo "Subnet ID: $AWS_EC2_SUBNET_ID"
echo "Security Group ID: $AWS_EC2_SECURITY_GROUP_ID"
echo "Key Pair Name: $AWS_EC2_KEY_NAME"
echo "FLICS Tarball URL: $FLICS_TARBALL_URL"
echo "FLICS License URL: $FLICS_LICENSE_URL"
echo ""

read -p "Would you like to proceed with the deployment? (y/n): " CONFIRM_DEPLOY
if [[ ! "$CONFIRM_DEPLOY" =~ ^[yY]$ ]]; then
  echo "Deployment canceled by user. Exiting."
  exit 0
fi

# Step 8: Create and launch with User Data
echo "Creating User Data script for FLICS installation..."
USER_DATA_SCRIPT=$(cat <<EOF
#!/bin/bash
# Check for Debian-based OS and install prerequisites
if [ -f /etc/debian_version ]; then
  sudo apt-get update
  sudo apt-get install -y wget nano
  # Create flics user on Debian/Ubuntu
  sudo useradd -s /bin/bash -m -d /home/flics flics -G sudo
  
# Check for Red Hat-based OS and install prerequisites
elif [ -f /etc/redhat-release ]; then
  sudo yum update
  sudo yum install -y wget nano
  # Create flics user on Rocky Linux/AWS Linux
  sudo useradd -s /bin/bash -m -d /home/flics flics -G wheel
fi

# Common steps for all OS
sudo passwd flics <<EOD
flics
flics
EOD

# Disable IPv6 lookup
sudo sed -i 's/^::1/#::1/' /etc/hosts

# Switch to flics user, generate SSH key, and download FLICS files
su - flics <<'EOS'
  # Generate SSH key
  ssh-keygen -t RSA -f /home/flics/.ssh/id_rsa -N ""

  # Ensure SSH pubkey authentication is enabled
  sudo sed -i '/^#PubkeyAuthentication yes/cPubkeyAuthentication yes' /etc/ssh/sshd_config
  
  # Download and extract FLICS files using environment variables
  wget -O $FLICS_TARBALL_NAME '$FLICS_TARBALL_URL'
  wget -O $FLICS_LICENSE_NAME '$FLICS_LICENSE_URL'
  tar -xzf $FLICS_TARBALL_NAME
  
  # Change to hiscale directory and run the prepare script
  cd hiscale
  ./$PREPARE_SCRIPT
EOS
EOF
)

# Launch the EC2 instance with the User Data script
echo "Launching the EC2 instance..."
INSTANCE_ID=$(aws ec2 run-instances \
  --region "$SELECTED_REGION" \
  --instance-type "$AWS_INSTANCE_TYPE" \
  --subnet-id "$AWS_EC2_SUBNET_ID" \
  --security-group-ids "$AWS_EC2_SECURITY_GROUP_ID" \
  --image-id "$SELECTED_OS_AMI" \
  --key-name "$AWS_EC2_KEY_NAME" \
  --user-data "$USER_DATA_SCRIPT" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=Hiscale-FLICS-Node}]" \
  --query 'Instances[0].InstanceId' --output text)

if [ -z "$INSTANCE_ID" ]; then
  echo "Failed to launch the EC2 instance. Exiting."
  exit 1
fi

echo "EC2 Instance launched with ID: $INSTANCE_ID"
echo "The instance is being provisioned. The FLICS prerequisites are being installed automatically via User Data."
echo "Once the instance is in the 'running' state, you can connect to it."

***

Would you like me to walk you through a step-by-step example of how to set up and use the new environment variables for an automated deployment?
