#!/bin/bash

######
# Variables
Colorgreen() {
	echo -ne $green$1$clr
}
Colorblue() {
	echo -ne $blue$1$clr
}
Colorred() {
	echo -ne $red$1$clr
}

function go_tmp() {
  cd /tmp
}
# get window size
win=$(tput cols)
# fill calcualtion
fill_left=$(( ($win - 10) / 2 + (($win - 10) % 2) ))
fill_right=$(( $win - $fill_left - 10 ))
line=$(Colorgreen '#####')
declare -g titulo="Comprobando si esta instalado \$app..."
declare -g noexiste="\$app no está instalado. Instalando \$app..."
declare -g instalado="\$app se ha instalado correctamente."
declare -g existe="\$app Ya esta instalado."

# ANSI color codes
green='\e[32m'
blue='\e[34m'
clr='\e[0m' # secuencia compatible de escape
red='\e[31m'
######

# Función para instalar paquetes básicos
apps_basic() {
    sudo apt update
    sudo apt install -y \
        zsh \
        vim \
        htop \
        ca-certificates \
        apt-transport-https \
        git \
        curl \
        gnupg \
        lsb-release \
        libssl-dev \
        gnupg-agent \
        tree

}

# Función para instalar paquetes de desarrollo
apps_dev() {
    sudo apt update
    sudo apt install -y \
        python3-pip \
        python3-dev \
        python3-dbus \
        jq \
# en caso de usar LENS (como ejemplo) sera necesario la libreria "mono-devel"
	mono-devel \
        fonts-powerline
}

# Función para instalar herramientas adicionales
apps_tools() {
    sudo apt update
    sudo apt install -y \
        mc \
        neovim
}

function inst_docker() {
  app="Docker"
  version=$(docker version --format '{{.Server.Version}}')
  echo -e $blue"${titulo//\$app/$app}"$clr
  go_tmp
  if ! command -v docker &> /dev/null; then
    echo -e $red"${noexiste//\$app/$app}"$clr
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
		echo -e $green"${instalado//\$app/$app}"$clr
  else
    echo -e $green"${existe//\$app/$app $version}"$clr
  fi
}

function inst_kube() { 
  app="Kubectl"
  version=$(kubectl version --client=true | grep -oP '(?<=GitVersion:"v)\d+\.\d+\.\d+')
  echo -e $blue"${titulo//\$app/$app}"$clr
  go_tmp
  if ! command -v kubectl &> /dev/null; then
    echo -e $red"${noexiste//\$app/$app}"$clr
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    echo -e $green"${instalado//\$app/$app}"$clr
  else
    echo -e $green"${existe//\$app/$app $version}"$clr
  fi
}

function inst_helm() {
  app="Helm"
  version=$(helm version --short)
  echo -e $blue"${titulo//\$app/$app}"$clr
  go_tmp
  if ! command -v helm &> /dev/null; then
    echo -e $red"${noexiste//\$app/$app}"$clr
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    echo -e $green"${instalado//\$app/$app}"$clr
  else
    echo -e $green"${existe//\$app/$app $version}"$clr
  fi
}

function inst_minikube() {
  app="Minikube"
  version=$(minikube version --short)
  echo -e $blue"${titulo//\$app/$app}"$clr
  go_tmp
  if ! command -v minikube &> /dev/null; then
    echo -e $red"${noexiste//\$app/$app}"$clr
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    echo -e $green"${instalado//\$app/$app}"$clr
  else
    echo -e $green"${existe//\$app/$app $version}"$clr
  fi
}

# Func aditonal APPS
function inst_ohmyzsh() {
  app="OhMyZSH"
  echo -e $blue"${titulo//\$app/$app}"$clr
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e $red"${noexiste//\$app/$app}"$clr
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo -e $green"${instalado//\$app/$app}"$clr
  else
    echo -e $green"${existe//\$app/$app}"$clr
  fi
}

function inst_antigen() {
  app="Antigen"
  echo -e $blue"${titulo//\$app/$app}"$clr
  FILE_ANTIGEN=$HOME/.oh-my-zsh/antigen.zsh
  if [ ! -f "$FILE_ANTIGEN" ]; then
    echo -e $red"${noexiste//\$app/$app}"$clr
    curl -L git.io/antigen > $FILE_ANTIGEN
    echo -e $green"${instalado//\$app/$app}"$clr
  else
    echo -e $green"${existe//\$app/$app}"$clr
  fi
}

function inst_lens() {
  app="Lens Desktop"
  version=$(lens-desktop --version | awk '{print $2}')
  echo -e $blue"${titulo//\$app/$app}"$clr
  go_tmp
  if [ -n "$(command -v lens-desktop)" ]; then
    echo -e $green"${existe//\$app/$app $version}"$clr
  else
    echo -e $red"${noexiste//\$app/$app}"$clr
    curl -fsSL https://downloads.k8slens.dev/keys/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/lens-archive-keyring.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/lens-archive-keyring.gpg] https://downloads.k8slens.dev/apt/debian stable main" | sudo tee /etc/apt/sources.list.d/lens.list > /dev/null
    sudo apt update && apt install lens -y
    echo -e $green"${instalado//\$app/$app}"$clr
  fi
}

# Menú de selección de funciones
mostrar_menu() {
    echo "Selecciona una opción:"
    echo "1. Instalar paquetes básicos"
    echo "2. Instalar paquetes de desarrollo"
    echo "3. Instalar herramientas adicionales"
    echo "4. Instalar herramientas devops"
    echo "5. Instalar customizacion"
    echo "6. Salir"

    read -p "Opción: " opcion

    case $opcion in
        1) apps_basic ;;
        2) apps_dev ; inst_lens ;;
        3) apps_tools ;;
    		4) inst_docker ;inst_kube ; inst_minikube ; inst_helm ;;
		    5) inst_ohmyzsh ; inst_antigen ;;
        6) exit ;;
        *) echo "Opción inválida. Inténtalo de nuevo." ;;
    esac
}

# Loop principal del script
while true
do
    mostrar_menu
    echo "Presiona Enter para volver al menú."
    read
    clear
done
