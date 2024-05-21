#!/bin/bash

console_blue() {
  echo -e "\033[0;34m$1\033[0m"
}

console() {
  console_blue "[ENVOI SETUP] $1"
}

clone_repo() {
  repo_url=$1
  # App name is the basename without the ext of the URL
  app_name=${2:-$(basename "$repo_url" .git)}
  console "Cloning $app_name..."
  git clone $repo_url
  console "Finished cloning $app_name."
}

install_app() {
  command=$1
  app_name=${2:-$1}
  console "Installing $app_name..."
  eval $command
  console "Finished installing $app_name."
}

asdf_install_plugin() {
  plugin=$1
  version=$2
  description=${3:-$1}
  source=${4}

  console "Installing $description"
  asdf plugin add $plugin $source
  asdf install $plugin $version
  asdf global $plugin $version
  console "Finished installing $description"
}

if command -v brew &> /dev/null
then
  console "Updating Homebrew"
  brew update
  console "Finished updating Homebrew"
else
  verbose "Homebrew is not installed"
  console "Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c \
     "$(curl -fsSL \
        https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/ec2-user/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
  console "Finished installing Homebrew"
fi

install_app "brew install wget" "wget"
install_app "brew install mas" "mas"
install_app "brew install jq" "jq"
install_app "brew install asdf" "asdf"

# Configure adsf to run on shell startup
asdf_exec_path="$(brew --prefix asdf)/libexec/asdf.sh"
echo -e "\n. ${asdf_exec_path}" >> ${ZDOTDIR:-~}/.zshrc
. "${asdf_exec_path}"

asdf_install_plugin  awscli latest:2 "AWS CLI"
asdf_install_plugin  aws-sam-cli latest:1 "AWS SAM CLI"
asdf_install_plugin carthage latest:0 "Carthage"
asdf_install_plugin gcloud latest "Google Cloud SDK" "https://github.com/jthegedus/asdf-gcloud"
asdf_install_plugin nodejs latest:20 "Node.js"
asdf_install_plugin ruby latest:3 "Ruby" "https://github.com/asdf-vm/asdf-ruby.git"

install_app "brew install azure-cli" "Azure CLI"

install_app "brew install --cask android-studio" "Android Studio"
install_app "brew install --cask betterdisplay" "BetterDisplay"
install_app "brew install --cask docker" "Docker"
install_app "brew install --cask git-credential-manager" "Git Credential Manager"
install_app "brew install --cask mongodb-compass" "MongoDB Compass"
install_app "brew install --cask nosql-workbench" "NoSQL Workbench"
install_app "brew install --cask visual-studio-code" "Visual Studio Code"

install_app "brew install --cask dcv-viewer" "DCV Viewer"
install_app "brew install --cask github" "GitHub"
install_app "brew install --cask mongodb-compass" "MongoDB Compass"
install_app "brew install --cask mysqlworkbench" "MySQL Workbench"
install_app "brew install --cask obs" "OBS"
install_app "brew install --cask pgadmin4" "pgAdmin"
install_app "brew install --cask royal-tsx" "Royal TSX"
install_app "brew install --cask streamlabs" "Streamlabs"

# Download Tizen Studio - Web IDE. The certificate does not pass validation so we need to use --no-check-certificate
wget --no-check-certificate \
"https://download.tizen.org/sdk/Installer/tizen-studio_5.6/web-ide_Tizen_Studio_5.6_macos-64.dmg" \
"/home/ec2-user/Downloads/"

install_app "brew install ffmpeg" "FFMPEG"

install_app "gem install aspera-cli" "Aspera CLI"

install_app "sudo mkdir -p /opt/envoi"
install_app "sudo chown ec2-user:staff /opt/envoi"

cd /opt/envoi

clone_repo "https://github.com/envoi-io/envoi-transfer-service.git" "Envoi Transfer Service"
clone_repo "https://github.com/envoi-io/envoi-cloud-storage.git" "Envoi Cloud Storage CLI"
clone_repo "https://github.com/envoi-io/envoi-cloud-desktops.git" "Envoi Cloud Desktops CLI"
clone_repo "https://github.com/envoi-io/envoi-cloud-transcode.git" "Envoi Cloud Transcode CLI"
clone_repo "https://github.com/envoi-io/envoi-mig.git" "Envoi MIG CLI"
clone_repo "https://github.com/envoi-io/envoi-s3-client.git" "Envoi S3 Client CLI"

install_app "brew install carthage" "Carthage"
install_app "brew install gradle" "Gradle"

install_app "npm install -g cordova" "Cordova"
install_app "npm install -g @ionic/cli" "Ionic"

sudo launchctl enable system/com.apple.screensharing
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist

install_app "brew tap jakehilborn/jakehilborn && brew install displayplacer" "Displayplacer"
