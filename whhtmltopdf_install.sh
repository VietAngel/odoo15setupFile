#!/bin/bash

sudo apt update
sudo apt install gvfs colord glew-utils libvisual-0.4-plugins gstreamer1.0-tools opus-tools qt5-image-formats-plugins \
  qtwayland5 qt5-qmltooling-plugins librsvg2-bin lm-sensors -y

sudo apt-get install -y software-properties-common &&
  sudo apt-add-repository -y "deb http://security.ubuntu.com/ubuntu focal-security main" &&
  sudo apt-get -yq update &&
  sudo apt-get install -y libxrender1 libfontconfig1 libx11-dev libjpeg62 libxtst6 \
    fontconfig xfonts-75dpi xfonts-base

#https://github.com/wkhtmltopdf/packaging/releases/download/0.12.1.4-2/wkhtmltox_0.12.1.4-2.bionic_amd64.deb
wkhtmltopdf_dir=0.12.6-1
wkhtmltopdf_ver="wkhtmltox_$wkhtmltopdf_dir.bionic_amd64.deb"
sudo wget https://github.com/wkhtmltopdf/packaging/releases/download/$wkhtmltopdf_dir/$wkhtmltopdf_ver

sudo add-apt-repository -y ppa:linuxuprising/libpng12 &&
  sudo apt -yq update &&
  sudo apt-get install -y libpng12-0

sudo dpkg -i $wkhtmltopdf_ver
sudo apt --fix-broken install
sudo dpkg -i $wkhtmltopdf_ver &&
  sudo apt-get -f install

sudo cp /usr/local/bin/wkhtmltopdf /usr/bin/ && sudo cp /usr/local/bin/wkhtmltoimage /usr/bin/
