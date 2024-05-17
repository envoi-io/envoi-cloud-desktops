#!/bin/bash
if ! command -v brew &> /dev/null
  brew update
then
  NONINTERACTIVE=1 /bin/bash -c \
     "$(curl -fsSL \
        https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/ec2-user/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

brew install wget
brew install mas
brew install asdf
. /opt/homebrew/opt/asdf/libexec/asdf.sh

asdf plugin add awscli
asdf install awscli latest:2
asdf global awscli latest:2

asdf plugin add aws-sam-cli
asdf install aws-sam-cli latest:1
asdf global aws-sam-cli latest:1

brew install azure-cli
#asdf plugin-add azure-cli https://github.com/itspngu/asdf-azure-cli
#asdf install azure-cli latest
#asdf global azure-cli latest

asdf plugin add carthage
asdf install carthage latest:0
asdf global carthage latest:0

asdf plugin add gcloud https://github.com/jthegedus/asdf-gcloud
asdf install gcloud latest
asdf global gcloud latest

asdf plugin add nodejs
asdf install nodejs latest:20
asdf global nodejs latest:20

asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf install ruby latest:3
asdf global ruby latest:3

brew install --cask android-studio
brew install --cask betterdisplay
brew install --cask docker
brew install --cask git-credential-manager
brew install --cask mongodb-compass
brew install --cask nosql-workbench
brew install --cask visual-studio-code

brew install --cask obs
brew install --cask streamlabs
brew install --cask github
brew install --cask royal-tsx
brew install --cask dcv-viewer
brew install --cask mysqlworkbench
#   PostgreSQL
brew install --cask mongodb-compass

wget --no-check-certificate \
https://download.tizen.org/sdk/Installer/tizen-studio_5.6/web-ide_Tizen_Studio_5.6_macos-64.dmg \
/home/ec2-user/Downloads/

brew install ffmpeg

# Aspera CLI - @TODO - Update to not use system Ruby
sudo gem install aspera-cli

sudo mkdir -p /opt/envoi
sudo chown ec2-user:staff /opt/envoi

cd "/opt/envoi"

# Envoi Transfer Service
git clone https://github.com/envoi-io/envoi-transfer-service.git

# Envoi Cloud Storage CLI
git clone https://github.com/envoi-io/envoi-cloud-storage.git

# Cloud Desktops Project
git clone https://github.com/envoi-io/envoi-cloud-desktops.git

# Envoi Transcode
git clone https://github.com/envoi-io/envoi-cloud-transcode.git

# Mig
git clone https://github.com/envoi-io/envoi-mig.git

# Envoi S3 Client
git clone https://github.com/envoi-io/envoi-s3-client.git

brew install carthage
brew install gradle

npm install -g cordova
npm install -g @ionic/cli

# Enable Screen Sharing
sudo launchctl enable system/com.apple.screensharing
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist

# Modify macOS screen resolution on Mac instances
#   https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/connect-to-mac-instance.html#mac-screen-resolution
#   Install displayplacer - utility to change display settings
brew tap jakehilborn/jakehilborn && brew install displayplacer

#RES="2560x1600"
#SCREEN_ID=$(displayplacer list | grep "Persistent screen id:" | awk '{print $4}')
#displayplacer "id:${SCREEN_ID} res:${RES} scaling:off origin:(0,0) degree:0"

# Configure for System Updates
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/mac-instance-updates.html
# sudo /usr/bin/dscl . -passwd /Users/ec2-user

