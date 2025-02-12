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
myHome=/home/mjc

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
	if ! command -v docker &> /dev/null; then
		echo -e $red"${noexiste//\$app/$app}"$clr
		curl -fsSL https://get.docker.com -o get-docker.sh
		sh get-docker.sh
		echo -e $green"${instalado//\$app/$app}"$clr
	else
		echo -e $green"${existe//\$app/$app $version}"$clr
	fi
}

function inst_kube() { 
  app="Kubectl"
  version=$(kubectl version --client=true | grep -oP '(?<=GitVersion:"v)\d+\.\d+\.\d+')
  echo -e $blue"${titulo//\$app/$app}"$clr
  if ! command -v kubectl &> /dev/null; then
    echo -e $red"${noexiste//\$app/$app}"$clr
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    echo -e $green"${instalado//\$app/$app}"$clr
  else
    echo -e $green"${existe//\$app/$app $version}"$clr
  fi
}

function inst_minikube() {
  app="Minikube"
  version=$(minikube version --short)
  echo -e $blue"${titulo//\$app/$app}"$clr
  if ! command -v minikube &> /dev/null; then
    echo -e $red"${noexiste//\$app/$app}"$clr
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    install minikube-linux-amd64 /usr/local/bin/minikube
    echo -e $green"${instalado//\$app/$app}"$clr
  else
    echo -e $green"${existe//\$app/$app $version}"$clr
  fi
}

function inst_terra() {
  app="Terraform"
  version=$(terraform version | grep -oP '(?<=Terraform v)\d+\.\d+\.\d+')
  echo -e $blue"${titulo//\$app/$app}"$clr
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
  if ! command -v helm &> /dev/null; then
    echo -e $red"${noexiste//\$app/$app}"$clr
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    rm get_helm.sh -y
    echo -e $green"${instalado//\$app/$app}"$clr
  else
    echo -e $green"${existe//\$app/$app $version}"$clr
  fi
}

function inst_azure() {
  app="Azure"
  version=$(az --version --output table | grep "azure-cli" | awk '{print $2}')
  echo -e $blue"${titulo//\$app/$app}"$clr
  if ! command -v az &> /dev/null; then
    echo -e $red"${noexiste//\$app/$app}"$clr
    mkdir -p /etc/apt/keyrings
    curl -sLS https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    tee /etc/apt/keyrings/microsoft.gpg > /dev/null
    chmod go+r /etc/apt/keyrings/microsoft.gpg
    echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ jammy main" |
    tee /etc/apt/sources.list.d/azure-cli.list
    apt update && apt install -f azure-cli
    echo -e $blue"instalando kubelogin"$clr
    az aks install-cli
    echo -e $green"${instalado//\$app/$app}"$clr
  else
    echo -e $green"${existe//\$app/$app $version}"$clr
  fi
}

function inst_awscli() {
  app="awscli"
  version=$(aws --version | awk '{print $1}')
  echo -e $blue"${titulo//\$app/$app}"$clr
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
  if ! command -v argo &> /dev/null; then
        echo -e $red"${noexiste//\$app/$app}"$clr
        curl -sLO https://github.com/argoproj/argo/releases/latest/download/argo-linux-amd64.gz
        gunzip -f argo-linux-amd64.gz
        mv argo-linux-amd64 /usr/local/bin/argo
        chmod +x /usr/local/bin/argo
        echo -e $green"${instalado//\$app/$app}"$clr
    else
        echo -e $green"${existe//\$app/$app $version}"$clr
    fi
}

# Func aditonal APPS
#function inst_ohmyzsh() {
#  app="OhMyZSH"
#  echo -e $blue"${titulo//\$app/$app}"$clr
#  if [ ! -d "$mjc/.oh-my-zsh" ]; then
#    echo -e $red"${noexiste//\$app/$app}"$clr
#    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#    echo -e $green"${instalado//\$app/$app}"$clr
#  else
#    echo -e $green"${existe//\$app/$app}"$clr
#  fi
#}

function inst_lens() {
  app="Lens Desktop"
  version=$(lens-desktop --version | awk '{print $2}')
  echo -e $blue"${titulo//\$app/$app}"$clr
  if [ -n "$(command -v lens-desktop)" ]; then
    echo -e $green"${existe//\$app/$app $version}"$clr
  else
    echo -e $red"${noexiste//\$app/$app}"$clr
    curl -fsSL https://downloads.k8slens.dev/keys/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/lens-archive-keyring.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/lens-archive-keyring.gpg] https://downloads.k8slens.dev/apt/debian stable main" | tee /etc/apt/sources.list.d/lens.list > /dev/null
    apt update && apt install lens -y
    echo -e $green"${instalado//\$app/$app}"$clr
  fi
}

function inst_code() {
  app="VSCode"
  version=$(code --version | head -1)
  echo -e $blue"${titulo//\$app/$app}"$clr
  if [ -n "$(command -v code)" ]; then
    echo -e $green"${existe//\$app/$app $version}"$clr
  else
    echo -e $red"${noexiste//\$app/$app}"$clr
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
	  install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
	  echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null
	  rm -f packages.microsoft.gpg
	  apt update && apt install code
    echo -e $green"${instalado//\$app/$app}"$clr
  fi
}

function inst_flatpak() {
  app="flatpak"
  version=$(flatpak --version)
  echo -e $blue"${titulo//\$app/$app}"$clr
  if [ -n "$(command -v flatpak)" ]; then
    echo -e $green"${existe//\$app/$app $version}"$clr
  else
    echo -e $red"${noexiste//\$app/$app}"$clr
    sudo apt install flatpak -y
	sleep 5
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    echo -e $green"${instalado//\$app/$app}"$clr
  fi
}

## Funcion para la instalacion de programas necesarios ##
function inst_coreapps() {
  echo -ne "$(Colorgreen '# # # # ')$(Colorblue 'Preparando el listado de aplicaciones CORE')$(Colorgreen ' # # # #')"
  sleep 3

  install_programs() {
    local file_path="$1"
    echo "$file_path"
    sleep 5
    programs=($(cat "$file_path"))
    for program in "${programs[@]}"; do
      if dpkg -s "$program" &> /dev/null; then
        echo -e "${blue}El programa '$program' ya está instalado ${clr}"
      else
        sudo apt install -y "$program"
        echo -e "${green}'$program' se instaló satisfactoriamente ${clr}"
      fi
    done
  }

  if [ -n "$(command -v gnome-shell)" ]; then
    echo -e "${blue}Entorno de escritorio encontrado ${green}GNOME ${clr}"
    install_programs "$PWD/apps_source/g-programs_core.src"
  elif [ -n "$(command -v kwin)" ]; then
    echo -e "${blue}Entorno de escritorio encontrado ${green}KDE ${clr}"
    install_programs "$PWD/apps_source/k-programs_core.src"
  elif [ -n "$(command -v xfwm4)" ]; then
    echo -e "${blue}Entorno de escritorio encontrado ${green}XFCE ${clr}"
    install_programs "$PWD/apps_source/x-programs_core.src"
  else
    echo "No se pudo detectar un entorno de escritorio compatible."
  fi
}

function inst_apps() {
  echo -ne "$(Colorgreen '# # # # ')$(Colorblue 'Preparando el listado de aplicaciones')$(Colorgreen ' # # # #')"
  sleep 3
  echo $PWD

  install_programs() {
    local file_path="$1"
    echo "$file_path"
    sleep 5
    programs=($(cat "$file_path"))
    for program in "${programs[@]}"; do
      if dpkg -s "$program" &> /dev/null; then
        echo -e "${blue}El programa '$program' ya está instalado ${clr}"
      else
        sudo apt install -y "$program"
        echo -e "${green}'$program' se instaló satisfactoriamente ${clr}"
      fi
    done
  }

  if [ -n "$(command -v gnome-shell)" ]; then
    echo -e "${blue}Entorno de escritorio encontrado ${green}GNOME ${clr}"
    local file_path="$PWD/apps_source/g-programs.src"
    install_programs "$file_path"
  elif [ -n "$(command -v kwin)" ]; then
    echo -e "${blue}Entorno de escritorio encontrado ${green}KDE ${clr}"
    local file_path="$PWD/apps_source/k-programs.src"
    install_programs "$file_path"
  elif [ -n "$(command -v xfwm4)" ]; then
    echo -e "${blue}Entorno de escritorio encontrado ${green}XFCE ${clr}"
    local file_path="$PWD/apps_source/x-programs.src"
    install_programs "$file_path"
  else
    echo "No se pudo detectar un entorno de escritorio compatible."
  fi
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
  apt -y update && apt install --fix-missing -y && apt -y upgrade

  echo -ne "$(Colorgreen '###') $(Colorblue 'Limpiando Ubuntu') $(Colorgreen '###')"
  sleep 3
  apt install -f && apt autoremove -y && apt autoclean && apt clean

}

function test_func() {
  app="EXA"
  echo -e $blue"${titulo//\$app/$app}"$clr
  FILE_EXA=/usr/local/bin/exa
  if [ ! -f "$FILE_EXA" ]; then
    echo -e $red"${noexiste//\$app/$app}"$clr
    cd /tmp && wget https://github.com/ogham/exa/releases/download/v0.10.0/exa-linux-x86_64-v0.10.0.zip
    unzip exa-linux-x86_64-v0.10.0.zip
    rm -f exa-linux-x86_64-v0.10.0.zip
    echo -e $green"${instalado//\$app/$app}"$clr
  else
    echo -e $green"${existe//\$app/$app}"$clr
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
                1) inst_coreapps ; os_upgrade ; menu_ubuntu ;;
                2) inst_docker ; inst_kube ; inst_minikube ; inst_terra ; inst_helm ; inst_azure ; inst_kubelogin ; inst_argo ; inst_lens ; inst_code ; menu_ubuntu ;;
                3) inst_apps ; menu_ubuntu ;;
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
