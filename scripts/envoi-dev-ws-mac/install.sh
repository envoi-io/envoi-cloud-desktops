#!/bin/bash

exec > >(tee /tmp/envoi-install.log) 2>&1

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
  git clone "$repo_url"
  console "Finished cloning $app_name."
}

asdf_install_plugin() {
  plugin=$1
  version=$2
  description=${3:-$1}
  source=${4}

  console "Installing $description"
  asdf plugin add "$plugin" "$source"
  asdf install "$plugin" "$version"
  asdf global "$plugin" "$version"
  console "Finished installing $description"
}

install_app() {
  command=$1
  app_name=${2:-$1}
  console "Installing $app_name..."
  eval "$command"
  console "Finished installing $app_name."
}

install_dmg_app() {
  name=$1
  dmg_file=$2
  volume_name=${3:-$name}
  app_file_name=${3:-"$name.app"}

  console "Installing $name"
  hdiutil attach "$dmg_file" -nobrowse
  cp -R "/Volumes/${volume_name}/${app_file_name}" /Applications/
  hdiutil detach "/Volumes/${volume_name}"
  console "Finished installing $name"
}

install_dmg_pkg() {
  name=$1
  dmg_file=$2
  volume_name=${3:-$name}
  pkg_file_name=${4:-"$name.pkg"}
  console "Installing $name"
  hdiutil attach "$dmg_file" -nobrowse
  installer -pkg "/Volumes/${volume_name}/${pkg_file_name}" -target /
  hdiutil detach "/Volumes/${volume_name}"
  console "Finished installing $name"
}

download_file() {
  name=$1
  url=$2
  output=${3:-"$HOME/Downloads/"}
  console "Downloading $name ($url) to $output"
  curl "$url" -o "$output"
  console "Finished downloading $name"
}

download_and_install_dmg() {
  name=$1
  url=$2
  volume_name=${3:-$name}
  app_file_name=${4:-"$name.app"}
  download_file "$name" "$url"
  file_name=$(basename "$url")
  install_dmg_app "$name" "$HOME/Downloads/$file_name" "$volume_name" "$app_file_name"
}

# Install or update Homebrew
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
  # shellcheck disable=SC2016
  (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/ec2-user/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
  console "Finished installing Homebrew"
fi

# Install asdf and configure it to run on shell startup
install_app "brew install asdf" "asdf"
# Configure adsf to run on shell startup
asdf_exec_path="$(brew --prefix asdf)/libexec/asdf.sh"
echo -e "\n. ${asdf_exec_path}" >> "${ZDOTDIR:-~}/.zshrc"
# shellcheck disable=SC1090
. "${asdf_exec_path}"

# Programming Languages - These need to be installed before other applications (except Homebrew and asdf)
asdf_install_plugin nodejs latest:20 "Node.js"
asdf_install_plugin ruby latest:3 "Ruby" "https://github.com/asdf-vm/asdf-ruby.git"

#asdf_install_plugin aws-sam-cli latest:1 "AWS SAM CLI"
#asdf_install_plugin carthage latest:0 "Carthage"

# CLI Applications
install_app "brew install aria2" "aria2"
install_app "gem install aspera-cli" "Aspera CLI"
asdf_install_plugin awscli latest:2 "AWS CLI"
download_and_install_dmg "AWS Deadline Cloud Monitor" \
"https://d2ev1rdnjzhmnr.cloudfront.net/Deadline%20Cloud%20Monitor%201.1.1%20aarch64.dmg" \
"Deadline Cloud Monitor" \
"Deadline Cloud Monitor.app"

install_app "brew install aws-sam-cli" "AWS SAM CLI"
install_app "brew install azure-cli" "Azure CLI"
install_app "brew install oci-cli" "Oracle Cloud CLI"
install_app "brew install cassandra" "Cassandra"
install_app "brew install carthage" "Carthage"
install_app "brew install cocoapods" "Cocoapods"
install_app "brew tap jakehilborn/jakehilborn && brew install displayplacer" "Displayplacer"
install_app "brew install dropbox" "Dropbox"
install_app "brew tap weaveworks/tap && brew install weaveworks/tap/eksctl" "eksctl"
install_app "brew tap elastic/tap && brew install elastic/tap/elasticsearch-full" "Elasticsearch"
install_app "brew install exiftool" "ExifTool"
install_app "brew install ffmpeg" "FFMPEG"
asdf_install_plugin gcloud latest "Google Cloud SDK" "https://github.com/jthegedus/asdf-gcloud"
install_app "brew install google-drive" "Google Drive"
install_app "brew install gradle" "Gradle"
install_app "brew install gum" "Gum"
install_app "brew install htop" "htop"
install_app "brew install jq" "jq"
install_app "brew install kops" "Kops"
install_app "brew install libmagic" "libmagic"
install_app "brew install mariadb" "MariaDB"
install_app "brew install mas" "mas"
install_app "brew install mongodb-atlas" "MongoDB Atlas CLI"
install_app "brew tap mongodb/brew && brew install mongodb-community" "MongoDB"
install_app "brew install postgresql" "PostgreSQL"
install_app "brew install rclone" "rclone"
install_app "brew install wget" "wget"

# GUI Applications
install_app "brew install --cask android-studio" "Android Studio"
install_app "brew install --cask betterdisplay" "BetterDisplay"
install_app "brew install --cask chatgpt" "ChatGPT"
install_app "brew install --cask cord" "CoRD"
install_app "brew install --cask coteditor" "CotEditor"
install_app "brew install --cask cyberduck" "Cyberduck"
install_app "brew install --cask dbvisualizer"
install_app "brew install --cask dcv-viewer" "DCV Viewer"
install_app "brew install --cask docker" "Docker"
install_app "brew install --cask dynamodb-local" "DynamoDB Local"
install_app "brew install --cask firefox" "Firefox"
install_app "brew install --cask git-credential-manager" "Git Credential Manager"
install_app "brew install --cask github" "GitHub"
install_app "brew install --cask google-chrome" "Google Chrome"
install_app "brew install --cask iterm2" "iTerm2"
install_app "brew_install --cask kops" "Kops"
install_app "brew install --cask mediainfo" "MediaInfo"
install_app "brew install --cask microsoft-edge" "Microsoft Edge"
install_app "brew install --cask mongodb-compass" "MongoDB Compass"
install_app "brew install --cask mysqlworkbench" "MySQL Workbench"
install_app "brew install --cask nosql-workbench" "NoSQL Workbench"
install_app "brew install --cask obs" "OBS"
install_app "brew install --cask pgadmin4" "pgAdmin"
install_app "brew install --cask postman" "Postman"
install_app "brew install --cask rectangle" "Rectangle"
install_app "brew install --cask royal-tsx" "Royal TSX"
install_app "brew install --cask snowflake-snowsql" "Snowflake SnowSQL"
install_app "brew install --cask sourcetree" "SourceTree"
install_app "brew install --cask sqlpro-for-postgres" "SQLPro for Postgres"
install_app "brew install --cask streamlabs" "Streamlabs"
install_app "brew install --cask temurin" "OpenJDK"
install_app "brew install --cask terraform"
install_app "brew install --cask textmate" "TextMate"
install_app "brew install --cask utm" "UTM"
install_app "brew install --cask visual-studio-code" "Visual Studio Code"
install_app "brew install --cask vlc" "VLC"
install_app "brew install --cask vmware-fusion"
install_app "brew install --cask warp" "Warp"
install_app "brew install --cask xcodes" "Xcodes"
install_app "brew install --cask zed"


# File Downloads
download_file "Aspera Desktop Client" "https://ak-delivery04-mul.dhe.ibm.com/sar/CMA/OSA/0c4zi/0/IBMAsperaDesktopClient-4.4.4.1293-mac-11.0-armv8-release.dmg"
#download_file "AWS Deadline Cloud Monitor" "https://d2ev1rdnjzhmnr.cloudfront.net/Deadline%20Cloud%20Monitor%201.1.1%20aarch64.dmg"
download_file "Tizen Studio" "https://download.tizen.org/sdk/Installer/tizen-studio_5.6/web-ide_Tizen_Studio_5.6_macos-64.dmg"

# Envoi Applications
install_envoi_apps() {
  export ENVOI_APP_TARGET_DIR="/opt/envoi"
  sudo mkdir -p "${ENVOI_APP_TARGET_DIR}"
  sudo chown ec2-user:staff "${ENVOI_APP_TARGET_DIR}"
  cd "${ENVOI_APP_TARGET_DIR}" || return

  clone_repo "https://github.com/envoi-io/envoi-transfer-service.git" "Envoi Transfer Service"
  clone_repo "https://github.com/envoi-io/envoi-cloud-storage.git" "Envoi Cloud Storage CLI"
  clone_repo "https://github.com/envoi-io/envoi-cloud-desktops.git" "Envoi Cloud Desktops CLI"
  clone_repo "https://github.com/envoi-io/envoi-cloud-transcode.git" "Envoi Cloud Transcode CLI"
  clone_repo "https://github.com/envoi-io/envoi-mig.git" "Envoi MIG CLI"
  install_app "cd ${ENVOI_APP_TARGET_DIR}/envoi-mig && bundle install" "Envoi MIG CLI"

  clone_repo "https://github.com/envoi-io/envoi-s3-client.git" "Envoi S3 Client CLI"
}
install_envoi_apps
