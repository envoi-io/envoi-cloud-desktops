#!/bin/bash
NONINTERACTIVE=1 /bin/bash -c \
   "$(curl -fsSL \
      https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/ec2-user/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

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

asdf plugin add nodejs
asdf install nodejs latest:20
asdf global nodejs latest:20

asdf plugin add carthage
asdf install carthage latest:0
asdf global carthage latest:0

brew install --cask android-studio
brew install --cask betterdisplay
brew install --cask docker
brew install --cask git-credential-manager
brew install --cask mongodb-compass
brew install --cask visual-studio-code

brew install carthage

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
# sudo /usr/bin/dscl . -passwd /Users/ec2-user