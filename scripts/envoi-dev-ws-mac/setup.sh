#!/bin/bash

console_blue() {
  echo -e "\033[0;34m$1\033[0m"
}

console() {
  console_blue "[ENVOI SETUP] $1"
}

run_install() {
  /bin/bash -c "$(curl -fsSL  https://raw.githubusercontent.com/envoi-io/envoi-cloud-desktops/main/scripts/envoi-dev-ws-mac/install.sh)"
}

############################################################################################
# Configure the system to allow remote desktop connections
############################################################################################

sudo launchctl enable system/com.apple.screensharing
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist

get_instance_metadata() {
  path_part=$1
  TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
  && curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/$path_part
}

get_instance_id() {
  get_instance_metadata instance-id
}

get_public_ipv4() {
  get_instance_metadata public-ipv4
}

get_public_ipv6() {
  get_instance_metadata public-ipv6
}

console_blue <<EOF
  To connect to the remote desktop, you need to run the following command:

  IPV4: ssh $(whoami)@$(get_public_ipv4) -L 5900:localhost:5900 -i <keyname>
  IPV6: ssh $(whoami)@$(get_public_ipv6) -L 5900:localhost:5900 -i <keyname>
EOF

#instance_id=$(get_instance_id)

# If NONINTERACTIVE is not set then prompt for ec2-user password
#default_password="envoi-${instance_id}"

if [ -z "$NONINTERACTIVE" ]; then
  echo
fi

