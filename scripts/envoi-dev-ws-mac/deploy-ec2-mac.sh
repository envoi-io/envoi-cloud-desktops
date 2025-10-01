#!/bin/bash

# Define environment variables (default values)
export AWS_DEFAULT_REGION="us-east-1" 
export AWS_PROFILE="" 
export AWS_EC2_SECURITY_GROUP_ID="sg-xxxxxxxxxxxxxxxxx"
export AWS_EC2_KEY_NAME=""
export AWS_EC2_SUBNET_ID=""
export AWS_EC2_VPC_ID=""
export USER_DATA_FILE_PATH=""

# Define the AWS regions
declare -A REGIONS
REGIONS[1]="US East (N. Virginia)|us-east-1"
REGIONS[2]="US West (Oregon)|us-west-2"
REGIONS[3]="Europe (Frankfurt)|eu-central-1"

# Define the Mac instance types
declare -A INSTANCE_TYPES
INSTANCE_TYPES[1]="mac1.metal"
INSTANCE_TYPES[2]="mac2.metal"
INSTANCE_TYPES[3]="mac2-m1ultra.metal"
INSTANCE_TYPES[4]="mac2-m2.metal"
INSTANCE_TYPES[5]="mac2-m2pro.metal"
INSTANCE_TYPES[6]="mac-m4.metal"
INSTANCE_TYPES[7]="mac-m4pro.metal"

# Function to display the region menu
function show_region_menu() {
  clear
  echo "Please select the AWS Region:"
  for i in "${!REGIONS[@]}"; do
    REGION_NAME=$(echo "${REGIONS[$i]}" | cut -d'|' -f1)
    echo "$i) $REGION_NAME"
  done
  echo "Enter the number of your choice:"
}

# Function to display the instance type menu
function show_instance_menu() {
  clear
  echo "Please select the Mac Instance Type:"
  echo "1) mac1.metal (2018 Mac mini, 6-core Intel Core i7, 64GB RAM)"
  echo "2) mac2.metal (2020 Mac mini, Apple silicon M1, 16 GiB unified memory)"
  echo "3) mac2-m1ultra.metal (2022 Mac Studio, Apple silicon M1 Ultra, 128 GiB unified memory)"
  echo "4) mac2-m2.metal (2023 Mac mini, Apple silicon M2, 24 GiB unified memory)"
  echo "5) mac2-m2pro.metal (2023 Mac mini, Apple silicon M2 Pro, 32 GiB unified memory)"
  echo "6) mac-m4.metal (2024 Mac mini, Apple silicon M4, 10‑core GPU, 24GB unified memory, and 16‑core Neural Engine)"
  echo "7) mac-m4pro.metal (2024 Mac mini, Apple silicon M4, 20‑core GPU, 48GB unified memory, and 16‑core Neural Engine)"
  echo "Enter the number of your choice:"
}

# Step 1: Prompt for AWS Region selection
show_region_menu
read -p "Your choice: " REGION_CHOICE
SELECTED_REGION=$(echo "${REGIONS[$REGION_CHOICE]}" | cut -d'|' -f2)

# Step 2: Prompt for Mac Instance Type selection
show_instance_menu
read -p "Your choice: " INSTANCE_CHOICE
SELECTED_INSTANCE_TYPE=${INSTANCE_TYPES[$INSTANCE_CHOICE]}

if [ -z "$SELECTED_REGION" ] || [ -z "$SELECTED_INSTANCE_TYPE" ]; then
  echo "Invalid selections. Exiting."
  exit 1
fi

echo "You have selected Region: $SELECTED_REGION and Instance Type: $SELECTED_INSTANCE_TYPE"

# Step 3: Check Instance Type Offerings
echo ""
echo "Checking available Instance Type Offerings for $SELECTED_INSTANCE_TYPE in $SELECTED_REGION..."
echo ""
echo "Submitting the following command:"
echo "aws ec2 describe-instance-type-offerings --region $SELECTED_REGION --location-type availability-zone --filters \"Name=instance-type,Values=$SELECTED_INSTANCE_TYPE\" --output text"
echo ""

OFFERINGS=$(aws ec2 describe-instance-type-offerings \
  --region "$SELECTED_REGION" \
  --location-type availability-zone \
  --filters "Name=instance-type,Values=$SELECTED_INSTANCE_TYPE" \
  --output text)

if [ -z "$OFFERINGS" ]; then
  echo "No offerings found for $SELECTED_INSTANCE_TYPE in $SELECTED_REGION. Exiting."
  exit 1
fi

# Step 4: Inform user of offerings and prompt for AZ choice
echo ""
echo "Instance Type Offerings available by Availability Zone (AZ):"
# This will now correctly parse the output you provided
AZ_OPTIONS=($(echo "$OFFERINGS" | grep "INSTANCETYPEOFFERINGS" | awk '{print $3}'))
if [ ${#AZ_OPTIONS[@]} -eq 0 ]; then
  echo "No AZs found for the selected instance type in this region. Please try a different region or instance type."
  exit 1
fi

for i in "${!AZ_OPTIONS[@]}"; do
    printf "%d. %s (%s)\n" $((i+1)) "$SELECTED_INSTANCE_TYPE" "${AZ_OPTIONS[$i]}"
done
echo ""

read -p "Please enter the number of the Availability Zone you would like to use: " AZ_CHOICE
SELECTED_AZ=${AZ_OPTIONS[$((AZ_CHOICE-1))]}

if [ -z "$SELECTED_AZ" ]; then
  echo "Invalid AZ selection. Exiting."
  exit 1
fi

# --- New Prompts based on AWS SDK Queries ---

# Select VPC
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

# Select Subnet ID
echo ""
echo "Fetching available Subnets in VPC $AWS_EC2_VPC_ID..."
SUBNETS=$(aws ec2 describe-subnets --region "$SELECTED_REGION" --filters "Name=vpc-id,Values=$AWS_EC2_VPC_ID" --query "Subnets[*].[SubnetId,AvailabilityZone]" --output text)
if [ -z "$SUBNETS" ]; then
  echo "No subnets found for the selected VPC. Exiting."
  exit 1
fi

echo "Available Subnets:"
# Iterate through each subnet to determine if it's public or private
SUBNET_INFO=()
while read -r SUBNET_ID AZ; do
    ROUTE_TABLE_ID=$(aws ec2 describe-route-tables --region "$SELECTED_REGION" --filters "Name=association.subnet-id,Values=$SUBNET_ID" --query "RouteTables[0].RouteTableId" --output text)
    if [ "$ROUTE_TABLE_ID" == "None" ]; then
        # Corrected filter format: separate with a space instead of a comma
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

# Select Key Pair
echo ""
echo "Fetching available EC2 Key Pairs..."
KEY_PAIRS_TEXT=$(aws ec2 describe-key-pairs --region "$SELECTED_REGION" --query "KeyPairs[*].KeyName" --output text)
if [ -z "$KEY_PAIRS_TEXT" ]; then
  echo "No Key Pairs found. Exiting."
  exit 1
fi
echo "Available Key Pairs:"
# Split the output by tabs and store into an array
IFS=$'\t' read -r -a KEY_PAIR_ARRAY <<< "$KEY_PAIRS_TEXT"
# Iterate and print each key pair with a number
for i in "${!KEY_PAIR_ARRAY[@]}"; do
    printf "%d) %s\n" $((i+1)) "${KEY_PAIR_ARRAY[$i]}"
done
read -p "Please select a Key Pair by number: " KEY_CHOICE
# Get the selected key name from the array using the user's choice
AWS_EC2_KEY_NAME=${KEY_PAIR_ARRAY[$((KEY_CHOICE-1))]}
if [ -z "$AWS_EC2_KEY_NAME" ]; then
  echo "Invalid Key Pair selection. Exiting."
  exit 1
fi


# Prompt for User Data File Path (Optional)
echo ""
read -p "Enter the local path to your user data file (optional, leave blank to skip): " USER_DATA_FILE_PATH
if [ -n "$USER_DATA_FILE_PATH" ] && [ ! -f "$USER_DATA_FILE_PATH" ]; then
  echo "Warning: The specified user data file does not exist. Proceeding without it."
  USER_DATA_FILE_PATH=""
fi

# --- End of New Prompts ---

# Step 5: Confirm selections and prompt to proceed with deployment
echo ""
echo "You have chosen to deploy a dedicated host with the following settings:"
echo "Region: $SELECTED_REGION"
echo "Availability Zone: $SELECTED_AZ"
echo "Instance Type: $SELECTED_INSTANCE_TYPE"
echo "VPC ID: $AWS_EC2_VPC_ID"
echo "Subnet ID: $AWS_EC2_SUBNET_ID"
echo "Key Pair Name: $AWS_EC2_KEY_NAME"
echo "User Data File: ${USER_DATA_FILE_PATH:-None}"
echo ""

echo "The following commands will be executed upon confirmation:"
echo ""

# Echo the Allocate Host command
echo "1. Allocate Dedicated Host Command:"
echo "aws ec2 allocate-hosts --availability-zone \"$SELECTED_AZ\" --auto-placement \"on\" --host-recovery \"on\" --quantity 1 --instance-type \"$SELECTED_INSTANCE_TYPE\" --tag-specifications 'ResourceType=dedicated-host,Tags={Key=Name,Value=MacHost-$SELECTED_INSTANCE_TYPE}' --profile $AWS_PROFILE"
echo ""

# Echo the Run Instances command
echo "2. Run Instances Command:"
RUN_COMMAND="aws ec2 run-instances --region $SELECTED_REGION --instance-type $SELECTED_INSTANCE_TYPE --placement HostId=YOUR_HOST_ID --subnet-id $AWS_EC2_SUBNET_ID --security-group-ids $AWS_EC2_SECURITY_GROUP_ID --image-id ami-0781a148f2727d309 --key-name $AWS_EC2_KEY_NAME --profile $AWS_PROFILE"
if [ -n "$USER_DATA_FILE_PATH" ]; then
  RUN_COMMAND+=" --user-data file://$USER_DATA_FILE_PATH"
fi
echo "$RUN_COMMAND"
echo ""

read -p "Would you like to proceed with the deployment? (y/n): " CONFIRM_DEPLOY

if [[ ! "$CONFIRM_DEPLOY" =~ ^[yY]$ ]]; then
  echo "Deployment canceled by user. Exiting."
  exit 0
fi

# Allocate the dedicated host
echo ""
echo "Allocating dedicated host..."
ALLOCATED_HOST_ID=$(aws ec2 allocate-hosts \
  --availability-zone "$SELECTED_AZ" \
  --auto-placement "on" \
  --host-recovery "on" \
  --quantity 1 \
  --instance-type "$SELECTED_INSTANCE_TYPE" \
  --tag-specifications "ResourceType=dedicated-host,Tags={Key=Name,Value=MacHost-$SELECTED_INSTANCE_TYPE}" \
  --profile "$AWS_PROFILE" \
  --query 'HostIds[0]' --output text)

if [ -z "$ALLOCATED_HOST_ID" ]; then
  echo "Failed to allocate dedicated host. Exiting."
  exit 1
fi

echo "Dedicated Host allocated with ID: $ALLOCATED_HOST_ID"

# Step 6: Launch the Mac OS instance on the dedicated host
echo ""
echo "Launching Mac OS instance on the dedicated host..."
aws ec2 run-instances \
  --region "$SELECTED_REGION" \
  --instance-type "$SELECTED_INSTANCE_TYPE" \
  --placement HostId="$ALLOCATED_HOST_ID" \
  --subnet-id "$AWS_EC2_SUBNET_ID" \
  --security-group-ids "$AWS_EC2_SECURITY_GROUP_ID" \
  --image-id ami-0781a148f2727d309 \
  --key-name "$AWS_EC2_KEY_NAME" \
  --user-data "file://$USER_DATA_FILE_PATH" \
  --profile "$AWS_PROFILE"

echo ""
echo "Script completed. The Mac OS instance is being launched."
