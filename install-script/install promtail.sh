#!/bin/bash
red='\033[31m'
green='\033[32m'
blue='\033[34m'
nc='\033[0m'
helpFunction()
{
   echo ""
   echo "Utilisation: $0 -s http://10.0.0.5:9100 -l /usr/local/bin/"
   echo ""
   echo ""
   echo -e "\t-h Afficher l'aide"
   echo -e "\t-s IP du serveur Loki"
   echo -e "\t-l [FACULTATIF] Repertoire d'installation de promtail, par default : /usr/local/bin/"
   exit 1
}

while getopts "s:l:h:" opt
do
   case "$opt" in
      s ) parametreIP="$OPTARG" ;;
      l ) parametreLOC="$OPTARG" ;;
      h ) helpFunction ;;
   esac
done

if [ -z "$parametreIP" ]
then
    echo -e "\033[31m Le serveur Loki n'est pas renseigné \033[0m";
   helpFunction
fi
if [ -z "$parametreLOC" ]
then
   parametreLOC="/usr/local/bin";
fi


echo "Installation de wget et unzip"
sudo apt-get install wget unzip  -y
echo "Installation terminé"
echo "Installation de Promtail pour une remonté vers" $parametreIP

sleep 2

sudo mkdir ${parametreLOC}/promtail ${parametreLOC}/promtail/tmp
cd ${parametreLOC}/promtail/
sudo wget https://github.com/grafana/loki/releases/download/v2.8.2/promtail-linux-amd64.zip
sudo unzip promtail*
sudo rm *.zip
sudo mv promtail* promtail
sudo cat <<EOF >config-promtail.yml

server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: ${parametreLOC}/promtail/tmp/positions.yaml

clients:
  - url: ${parametreIP}/loki/api/v1/push

scrape_configs:
 - job_name: system
   pipeline_stages:
   static_configs:
   - targets:
      - localhost
     labels:
      job: testscript-varlogs
      __path__: /var/log/*.log
      __path_exclude__: /var/log/vmware*.log #Exclusion des logs de VMWare pour les VM

EOF

sudo useradd -s /sbin/nologin promtail
sudo usermod -a -G adm promtail
sudo chown promtail:promtail ${parametreLOC}/promtail -R
sudo chmod 755 ${parametreLOC}/promtail -R
sudo cat <<EOF >/etc/systemd/system/promtail.service

[Unit]
Description=Promtail service
After=network.target

[Service]
Type=simple
User=promtail
ExecStart=/bin/bash -c '${parametreLOC}/promtail/promtail --client.external-labels=hostname=$(hostname) -config.file ${parametreLOC}/promtail/config-promtail.yml'

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start promtail
sudo systemctl enable promtail



echo -e "${green}Promtail es installé dans : ${parametreLOC} et pointe le serveur Loki à l'addresse ${parametreIP}";
echo -e "Fichier de configuration crée sous : ${red}${parametreLOC}/config-promtail.yml${green}";
echo -e "Service crée sous : ${red}/etc/systemd/system/promtail.service${green}";
sleep 2
echo -e "Utilisation :";
echo -e "systemctl start promtail";
echo -e "systemctl stop promtail${nc}";
sleep 5