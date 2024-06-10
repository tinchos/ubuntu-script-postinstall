#!/bin/bash

# Load Variables
if [[ -f .env ]]; then
  source .env
fi

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

# warning
if [ "$(whoami)" != "root" ]; then
  echo -e $red"**Advertencia!!!**"$clr
  echo -e $red"Este script debe ejecutarse con privilegios de administrador (sudo)."$clr
  echo -e $red"Ejecútelo de nuevo con el comando 'sudo bash postinstall.sh'"$clr
  sleep 5
  exit 1
fi

# Func apps DEVOPS
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

function inst_terra() {
  app="Terraform"
  version=$(terraform version | grep -oP '(?<=Terraform v)\d+\.\d+\.\d+')
  echo -e $blue"${titulo//\$app/$app}"$clr
  go_tmp
  if ! command -v terraform &> /dev/null; then
    echo -e $red"${noexiste//\$app/$app}"$clr
    curl "https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip" -o terra_1.6.0.zip
    unzip terra_1.6.0.zip && sudo mv terraform /usr/local/bin/ && rm -f terra_1.6.0.zip
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

function inst_azure() {
  app="Azure"
  version=$(az --version --output table | grep "azure-cli" | awk '{print $2}')
  echo -e $blue"${titulo//\$app/$app}"$clr
  go_tmp
  if ! command -v az &> /dev/null; then
    echo -e $red"${noexiste//\$app/$app}"$clr
    sudo mkdir -p /etc/apt/keyrings
    curl -sLS https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
    sudo chmod go+r /etc/apt/keyrings/microsoft.gpg
    echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ jammy main" |
    sudo tee /etc/apt/sources.list.d/azure-cli.list
    sudo apt-get update
    sudo apt-get install azure-cli
    echo -e $green"${instalado//\$app/$app}"$clr
  else
    echo -e $green"${existe//\$app/$app $version}"$clr
  fi
}

function inst_kubelogin() {
  app="KubeLogin"
  version=$(kubelogin --version | awk '{print $3}')
  echo -e $blue"${titulo//\$app/$app}"$clr
  go_tmp
  if ! command -v kubelogin &> /dev/null; then
    echo -e $red"${noexiste//\$app/$app}"$clr
    curl -LO https://github.com/int128/kubelogin/releases/latest/download/kubelogin_linux_amd64.zip
    unzip kubelogin_linux_amd64.zip
    sudo mv kubelogin /usr/local/bin/kubelogin
    sudo chmod +x /usr/local/bin/kubelogin
    echo -e $green"${instalado//\$app/$app}"$clr
  else
    echo -e $green"${existe//\$app/$app $version}"$clr
  fi
}

function inst_awscli() {
  app="awscli"
  version=$(aws --version | awk '{print $1}')
  echo -e $blue"${titulo//\$app/$app}"$clr
  go_tmp
  if ! command -v aws &> /dev/null; then
    echo -e $red"${noexiste//\$app/$app}"$clr
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip && sudo ./aws/install
    rm -rf ./aws && rm -f awscliv2.zip
    echo -e $green"${instalado//\$app/$app}"$clr
  else
    echo -e $green"${existe//\$app/$app $version}"$clr
  fi
}

function inst_argo() {
  app="ArgoCD"
  version=$(argo version --short)
  echo -e $blue"${titulo//\$app/$app}"$clr
  go_tmp
  if ! command -v argo &> /dev/null; then
        echo -e $red"${noexiste//\$app/$app}"$clr
        sudo curl -sLO https://github.com/argoproj/argo/releases/latest/download/argo-linux-amd64.gz
        sudo gunzip -f argo-linux-amd64.gz
        sudo mv argo-linux-amd64 /usr/local/bin/argo
        sudo chmod +x /usr/local/bin/argo
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

function inst_brave() {
  app="Brave Browser"
  version=$(brave-browser --version | awk '{print $2}')
  echo -e $blue"${titulo//\$app/$app}"$clr
  go_tmp
  if [ -n "$(command -v brave-browser)" ]; then
    echo -e $green"${existe//\$app/$app $version}"$clr
  else
    echo -e $red"${noexiste//\$app/$app}"$clr
    curl -sS https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
    echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update && apt install brave-browser -y
    echo -e $green"${instalado//\$app/$app}"$clr
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

# Func inst APPS
function inst_coreapps() {
  echo -ne "$(Colorgreen '# # # # ')$(Colorblue 'Preparando el listado de aplicaciones CORE')$(Colorgreen ' # # # #')"
  sleep 3
  local script_dir="$(dirname "$0")"
  
  if [ -n "$(command -v gnome-shell)" ]; then
    echo -e "${blue}Entorno de escritorio encontrado ${green}GNOME ${clr}"
    sleep 5
    #local script_dir="$(dirname "$0")"
    local file_path="$PWD/apps_source/g-programs_core.src"
    echo $file_path
    sleep 10
    programs=($(cat $file_path))
    for program in "${programs[@]}"
    do
        if dpkg -s "$program" &> /dev/null; then
          echo -e "${blue}El programa '$program' ya esta instalado ${clr}"
        else
          sudo apt install -y "$program"
          echo -e "${green}'$program' Se instalo satisfactoriamente ${clr}"
        fi
    done
  elif [ -n "$(command -v kwin)" ]; then
    echo -e "${blue}Entorno de escritorio encontrado ${green}KDE ${clr}"
    sleep 5
    local file_path="$PWD/apps_source/k-programs_core.src"
    echo $file_path
    sleep 5
    programs=($(cat "$file_path"))
    for program in "${programs[@]}"
    do
        if dpkg -s "$program" &> /dev/null; then
            echo -e "${blue}El programa '$program' ya esta instalado ${clr}"
        else
            sudo apt install -y "$program"
            echo -e "${green}'$program' Se instalo satisfactoriamente ${clr}"
        fi
    done
  else
      echo "No se pudo detectar un entorno de escritorio compatible."
  fi
}

function inst_apps() {
  echo -ne "$(Colorgreen '# # # # ')$(Colorblue 'Preparando el listado de aplicaciones')$(Colorgreen ' # # # #')"
  sleep 3
  
  if [ -n "$(command -v gnome-shell)" ]; then
    echo -e "${blue}Entorno de escritorio encontrado ${green}GNOME ${clr}"
    sleep 5
    local file_path="$PWD/apps_source/g-programs.src"
    echo $file_path
    sleep 5
    programs=($(cat $file_path))
    for program in "${programs[@]}"
    do
        if dpkg -s "$program" &> /dev/null; then
          echo -e "${blue}El programa '$program' ya esta instalado ${clr}"
        else
          sudo apt install -y "$program"
          echo -e "${green}'$program' Se instalo satisfactoriamente ${clr}"
        fi
    done
  elif [ -n "$(command -v kwin)" ]; then
    echo -e "${blue}Entorno de escritorio encontrado ${green}KDE ${clr}"
    sleep 5
    local file_path="$PWD/apps_source/k-programs.src"
    echo $file_path
    sleep 5
    programs=($(cat "$file_path"))
    for program in "${programs[@]}"
    do
        if dpkg -s "$program" &> /dev/null; then
            echo -e "${blue}El programa '$program' ya esta instalado ${clr}"
        else
            sudo apt install -y "$program"
            echo -e "${green}'$program' Se instalo satisfactoriamente ${clr}"
        fi
    done
  else
      echo "No se pudo detectar un entorno de escritorio compatible."
  fi
}

function inst_snap() {
  echo -ne " $line $(Colorgreen '###') $(Colorblue 'Preparando repositorios SNAP') $(Colorgreen '###') $line "
  sleep 3
  local snap_path="$PWD/apps_source/snap.src"
  echo $file_path
  sleep 5
  programs=($(cat "$snap_path"))
  for program in "${programs[@]}"
  do
    if dpkg -s "$program" &> /dev/null; then
      echo -e "${blue}El programa '$program' ya esta instalado ${clr}"
    else
      sudo snap install "$program"
      echo -e "${green}'$program' Se instalo satisfactoriamente ${clr}"
    fi
  done
}

function inst_server() {
  echo -ne " $line $(Colorgreen '###') $(Colorblue 'Instalando SNAP Apps') $(Colorgreen '##') $line "
  local script_dir="$(dirname "$0")"  # Directorio raiz del script
  local file_path="$script_dir/apps_source/server.src"
  sleep 3
  programs=($(cat $script_dir))
  for program in "${programs[@]}"
    do
        if dpkg -s "$program" &> /dev/null; then
            echo -e "${blue}El programa '$program' ya esta instalado ${clr}"
        else
            sudo apt install -y "$program"
            echo -e "${green}'$program' Se instalo satisfactoriamente ${clr}"
        fi
    done
}

# Funciones SYS
function os_upgrade() {
  echo -ne "$(Colorgreen '###') $(Colorblue 'Actualizando Ubuntu') $(Colorgreen '###')"
  sleep 3
  sudo apt -y update && sudo apt install --fix-missing -y && sudo apt -y upgrade

  echo -ne "$(Colorgreen '###') $(Colorblue 'Limpiando Ubuntu') $(Colorgreen '###')"
  sleep 3
  sudo apt install -f && sudo apt autoremove -y && sudo apt autoclean && sudo apt clean

}

function test_func() {
  app="Minikube"
  version=$(minikube version --short)
  echo -e $blue"${titulo//\$app/$app}"$clr
  go_tmp
  if ! command -v minikube &> /dev/null; then
    echo -e "${noexiste//\$app/$app}"
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    echo -e "${instalado//\$app/$app}"
  else
    echo -e $green"${existe//\$app/$app $version}"$clr
  fi
}

# Menu Opciones

menu_ubuntu() {
echo -ne "
Menu Gnome
$(Colorgreen '1)') Configuracion Post Instalacion (repita ejecucion hasta que todo quede instalado)
$(Colorgreen '2)') Instalacion de Devops Tools
$(Colorgreen '3)') Instalacion de Aplicaciones para Desktop
$(Colorgreen '4)') Instalacion de aplicaciones para Server
$(Colorred '5)') EMPTY
$(Colorred '6)') EMPTY
$(Colorgreen '7)') funcion test
$(Colorgreen '9)') Actualizar y Limpiar
$(Colorgreen '0)') Exit
$(Colorblue 'Choose an option:') "
        read a
        case $a in
                1) inst_coreapps ; inst_ohmyzsh ; inst_antigen ; os_upgrade ; menu_ubuntu ;;
                2) inst_docker ; inst_kube ; inst_minikube ; inst_terra ; inst_helm ; inst_azure ; inst_kubelogin ; inst_awscli ; inst_argo ; inst_lens ; menu_ubuntu ;;
                3) inst_apps ; inst_snap ; menu_ubuntu ;;
                4) inst_server ; menu_ubuntu ;;
#               5)  ; menu_ubuntu ;;
#               6)  ; menu_ubuntu ;;
                7) test_func ; menu_ubuntu ;;
                9) os_upgrade ; menu_ubuntu ;;
                0) exit 0 ;;
                *) echo -e $red"Wrong option."$clr; WrongCommand;;
        esac
        clear
}

# Call the menu function
menu_ubuntu