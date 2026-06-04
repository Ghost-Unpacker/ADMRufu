#!/bin/bash

# Script de Instalación Ghost-Unpacker
module="$(pwd)/module"
rm -rf ${module}
wget -O ${module} "https://raw.githubusercontent.com/Ghost-Unpacker/ADMRufu/main/module/module" &>/dev/null
[[ ! -e ${module} ]] && exit
chmod +x ${module} &>/dev/null
source ${module}

CTRL_C(){
  rm -rf ${module}; exit
}

if [[ ! $(id -u) = 0 ]]; then
  clear
  msg -bar
  print_center -ama "ERROR DE EJECUCION"
  msg -bar
  print_center -ama "DEBE EJECUTAR DESDE EL USUARIO ROOT"
  msg -bar
  CTRL_C
fi

trap "CTRL_C" INT TERM EXIT

ADMRufu="/etc/ADMRufu" && [[ ! -d ${ADMRufu} ]] && mkdir ${ADMRufu}
ADM_inst="${ADMRufu}/install" && [[ ! -d ${ADM_inst} ]] && mkdir ${ADM_inst}
tmp="${ADMRufu}/tmp" && [[ ! -d ${tmp} ]] && mkdir ${tmp}
SCPinstal="$HOME/install" && mkdir -p ${SCPinstal}

cp -f $0 ${ADMRufu}/install.sh

stop_install(){
  title "INSTALACION CANCELADA"
  exit
}

dependencias(){
  # Eliminado 'python' (obsoleto), añadido 'python3'
  soft="sudo bsdmainutils zip unzip ufw curl python3 python3-pip openssl screen cron iptables lsof nano at mlocate gawk grep bc jq curl npm nodejs socat netcat netcat-traditional net-tools cowsay figlet lolcat sqlite3 libsqlite3-dev locales"
  for install in $soft; do
    msg -nazu "      instalando $install..."
    if apt install $install -y &>/dev/null ; then
      msg -verd "INSTALL"
    else
      apt install $install -y &>/dev/null && msg -verd "INSTALL" || msg -verm2 "FAIL"
    fi
  done
}

verificar_arq(){
  unset ARQ
  case $1 in
    menu|menu_inst.sh|tool_extras.sh|chekup.sh|bashrc)ARQ="${ADMRufu}";;
    ADMRufu)ARQ="/usr/bin";;
    message.txt)ARQ="${tmp}";;
    *)ARQ="${ADM_inst}";;
  esac
  mv -f ${SCPinstal}/$1 ${ARQ}/$1
  chmod +x ${ARQ}/$1
}

error_fun(){
  msg -bar3
  print_center -verm "Falla al descargar: $1"
  print_center -ama "Verifica que el archivo exista en tu repo Ghost-Unpacker"
  msg -bar3
  exit
}

install_start(){
  title "INSTALADOR Ghost-Unpacker"
  read -rp "$(msg -verm2 " Desea continuar? [S/N]:") " -e -i S opcion
  [[ "$opcion" != @(s|S) ]] && stop_install
  apt update -y; apt upgrade -y
}

install_continue(){
  title "INSTALADOR Ghost-Unpacker"
  dependencias
  apt autoremove -y &>/dev/null
}

source /etc/os-release; export PRETTY_NAME

case $1 in
  -s|--start)install_start; /etc/ADMRufu/install.sh --continue;;
  -c|--continue)install_continue;;
  -u|--update)install_start; install_continue;;
  *)exit;;
esac

cd $HOME
arch='ADMRufu bashrc budp.sh cert.sh chekup.sh chekuser.sh confDNS.sh domain.sh filebrowser.sh limitador.sh menu menu_inst.sh openvpn.sh PDirect.py PGet.py POpen.py PPriv.py PPub.py sockspy.sh squid.sh swapfile.sh tcpbbr.sh tool_extras.sh userHWID userSSH userTOKEN userV2ray.sh userWG.sh v2ray.sh wireguard.sh ws-cdn.sh WS-Proxy.js'
# Apuntando a la raíz de tu repo
lisArq="https://raw.githubusercontent.com/Ghost-Unpacker/ADMRufu/main"

for arqx in $arch; do
  wget -O ${SCPinstal}/${arqx} ${lisArq}/${arqx} &>/dev/null && verificar_arq "${arqx}" || error_fun "${arqx}"
done

url='https://github.com/Ghost-Unpacker/ADMRufu/raw/main/Utils'
autoStart="${ADMRufu}/bin" && mkdir -p $autoStart
varEntorno="${ADMRufu}/sbin" && mkdir -p $varEntorno

# Descarga de herramientas
wget -O $autoStart/autoStart "$url/autoStart/autoStart" &>/dev/null; chmod +x $autoStart/autoStart
wget -O $autoStart/auto-update "$url/auto-update/auto-update" &>/dev/null; chmod +x $autoStart/auto-update
wget -O ${ADMRufu}/install/udp-custom "$url/udp-custom/udp-custom" &>/dev/null; chmod +x ${ADMRufu}/install/udp-custom
wget -O ${varEntorno}/dropBear "$url/dropBear/dropBear" &>/dev/null; chmod +x ${varEntorno}/dropBear
wget -O ${varEntorno}/protocolsUDP "$url/protocolsUDP/protocolsUDP" &>/dev/null; chmod +x ${varEntorno}/protocolsUDP 
wget -O ${varEntorno}/udprequest "$url/protocolsUDP/udprequest/udprequest" &>/dev/null; chmod +x ${varEntorno}/udprequest
wget -O ${varEntorno}/udpcustom "$url/protocolsUDP/udpcustom/udpcustom" &>/dev/null; chmod +x ${varEntorno}/udpcustom
wget -O ${varEntorno}/udp-udpmod "$url/protocolsUDP/udpmod/udp-udpmod" &>/dev/null; chmod +x ${varEntorno}/udp-udpmod
wget -O ${varEntorno}/Stunnel "$url/Stunnel/Stunnel" &>/dev/null; chmod +x ${varEntorno}/Stunnel
wget -O ${varEntorno}/Slowdns "$url/SlowDNS/Slowdns" &>/dev/null; chmod +x ${varEntorno}/Slowdns
wget -O ${varEntorno}/cmd "$url/mine_port/cmd" &>/dev/null; chmod +x ${varEntorno}/cmd

for i in $(ls ${varEntorno}); do ln -sf ${varEntorno}/$i /usr/bin/$i; done

clear
echo "-- Ghost-Unpacker INSTALADO CON EXITO --"
mv -f ${module} /etc/ADMRufu/module

