#!/bin/bash

module="$(pwd)/module"
rm -rf ${module}
wget -O ${module} "https://raw.githubusercontent.com/rudi9999/Herramientas/main/module/module" &>/dev/null
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
  print_center -ama "DEVE EJECUTAR DESDE EL USUSRIO ROOT"
  msg -bar
  CTRL_C
fi

trap "CTRL_C" INT TERM EXIT

ADMRufu="/etc/ADMRufu" && [[ ! -d ${ADMRufu} ]] && mkdir ${ADMRufu}
ADM_inst="${ADMRufu}/install" && [[ ! -d ${ADM_inst} ]] && mkdir ${ADM_inst}
tmp="${ADMRufu}/tmp" && [[ ! -d ${tmp} ]] && mkdir ${tmp}
SCPinstal="$HOME/install"

cp -f $0 ${ADMRufu}/install.sh
rm $(pwd)/$0 &> /dev/null

stop_install(){
  title "INSTALACION CANCELADA"
  exit
}

time_reboot(){
  print_center -ama "REINICIANDO VPS EN $1 SEGUNDOS"
  REBOOT_TIMEOUT="$1"
  while [ $REBOOT_TIMEOUT -gt 0 ]; do
     print_center -ne "-$REBOOT_TIMEOUT-\r"
     sleep 1
     : $((REBOOT_TIMEOUT--))
  done
  reboot
}

fixDeb12Ubu24(){
  if command -v ldd &>/dev/null; then
    _glibc=$(ldd --version|head -1|grep -o '[0-9]\+\.[0-9]\+'|sed 's/\.//g'|head -1)
    if [[ -n $_glibc && $_glibc -ge 235 ]]; then
      wget -O /root/fix https://github.com/rudi9999/ADMRufu/raw/refs/heads/main/fix && chmod 755 /root/fix && /root/fix
    fi
  fi
}

repo_install(){
  link="https://raw.githubusercontent.com/rudi9999/ADMRufu/main/Repositorios/$VERSION_ID.list"
  case $VERSION_ID in
    8*|9*|10*|11*|16.04*|18.04*|20.04*|20.10*|21.04*|21.10*|22.04*) 
      [[ ! -e /etc/apt/sources.list.back ]] && cp /etc/apt/sources.list /etc/apt/sources.list.back
      wget -O /etc/apt/sources.list ${link} &>/dev/null;;
    12*|24.04*) fixDeb12Ubu24;;
  esac
}

dependencias(){
  soft="sudo bsdmainutils zip unzip ufw curl python python3 python3-pip openssl screen cron iptables lsof nano at mlocate gawk grep bc jq curl npm nodejs socat netcat netcat-traditional net-tools cowsay figlet lolcat sqlite3 libsqlite3-dev locales"
  for install in $soft; do
    msg -nazu "      instalando $install..."
    if apt install $install -y &>/dev/null ; then
      msg -verd "INSTALL"
    else
      dpkg --configure -a &>/dev/null
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
  print_center -verm "Falla al descargar $1"
  print_center -ama "Reportar con el administrador"
  msg -bar3
  [[ -d ${SCPinstal} ]] && rm -rf ${SCPinstal}
  exit
}

install_start(){
  title "INSTALADOR ADMRufu"
  read -rp "$(msg -verm2 " Desea continuar? [S/N]:") " -e -i S opcion
  [[ "$opcion" != @(s|S) ]] && stop_install
  repo_install
  apt update -y; apt upgrade -y
}

install_continue(){
  title "INSTALADOR ADMRufu"
  dependencias
  apt autoremove -y &>/dev/null
}

source /etc/os-release; export PRETTY_NAME

case $1 in
  -s|--start)install_start; /etc/ADMRufu/install.sh --continue;;
  -c|--continue)sed -i '/Rufu/d' /root/.bashrc; install_continue;;
  -u|--update)install_start; rm -rf /etc/ADMRufu/tmp/style; install_continue;;
  -t|--test) ;;
  *)exit;;
esac

cd $HOME
arch='ADMRufu bashrc budp.sh cert.sh chekup.sh chekuser.sh confDNS.sh domain.sh filebrowser.sh limitador.sh menu menu_inst.sh openvpn.sh PDirect.py PGet.py POpen.py PPriv.py PPub.py sockspy.sh squid.sh swapfile.sh tcpbbr.sh tool_extras.sh userHWID userSSH userTOKEN userV2ray.sh userWG.sh v2ray.sh wireguard.sh ws-cdn.sh WS-Proxy.js'
lisArq="https://raw.githubusercontent.com/rudi9999/ADMRufu/refs/heads/main/old"

for arqx in $arch; do
  wget -O ${SCPinstal}/${arqx} ${lisArq}/${arqx} &>/dev/null && verificar_arq "${arqx}" || error_fun "${arqx}"
done

url='https://github.com/rudi9999/ADMRufu/raw/main/Utils'
autoStart="${ADMRufu}/bin" && mkdir -p $autoStart
varEntorno="${ADMRufu}/sbin" && mkdir -p $varEntorno

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

sed -i '/Rufu/d' /etc/bash.bashrc
# echo '[[ -e /etc/ADMRufu/bashrc ]] && source /etc/ADMRufu/bashrc' >> /etc/bash.bashrc
clear
echo "-- ADMRufu INSTALADO CON EXITO --"
mv -f ${module} /etc/ADMRufu/module
reboot
