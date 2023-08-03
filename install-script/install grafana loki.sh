#!/bin/bash
red='\033[31m'
green='\033[32m'
blue='\033[34m'
nc='\033[0m'
helpFunction()
{
   echo ""
   echo "Utilisation: $0 -s 10.0.0.5 -l /usr/local/bin/"
   echo ""
   echo ""
   echo -e "\t-h Afficher l'aide"
   echo -e "\t-s IP ou nom d'hote du serveur"
   echo -e "\t-l [FACULTATIF] Repertoire d'installation de Loki, par default : /usr/local/bin/"
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
    echo -e "\033[31m L'addresse du serveur n'es pas renseignée \033[0m";
   helpFunction
fi
if [ -z "$parametreLOC" ]
then
   parametreLOC="/usr/local/bin";
fi


echo "Ajout du dépot grafana et installation de wget, unzip, software-properties-common, apt-transport-https et grafana"
sudo wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install wget unzip software-properties-common apt-transport-https grafana -y
echo "Installation terminé"
echo "Installation de Loki pour une ecoute sur" $parametreIP

sleep 2

sudo mkdir ${parametreLOC}/loki
cd ${parametreLOC}/loki/
sudo wget https://github.com/grafana/loki/releases/download/v2.8.2/loki-linux-amd64.zip
sudo unzip loki-*
sudo rm *.zip
sudo mv loki-* loki
sudo cat <<EOF >config-loki.yml

auth_enabled: false

server:
  http_listen_port: 3100 #Port d’écoute 
  grpc_listen_port: 9096 #Port d’écoute d’alerte

common:
  instance_addr: ${parametreIP} #Addresse d’écoute
  path_prefix: ${parametreLOC}/loki #Emplacement de l’executable
  storage:
    filesystem:
#Deux repertoire pour loki, si on ne les crées pas il faut bien que loki ai les droits sur son repertoire
      chunks_directory: ${parametreLOC}/loki/chunks
      rules_directory: ${parametreLOC}/loki/rules
  replication_factor: 1
  ring:
    kvstore:
      store: inmemory

query_range:
  results_cache:
    cache:
      embedded_cache:
        enabled: true
        max_size_mb: 100

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

ruler:
  alertmanager_url: http://localhost:9093


EOF

sudo useradd -s /sbin/nologin loki
sudo chown loki:loki ${parametreLOC}/loki -R
sudo chmod 755 ${parametreLOC}/loki -R
sudo cat <<EOF >/etc/systemd/system/loki.service

[Unit]
Description=Loki service
After=network.target

[Service]
Type=simple
User=loki
ExecStart=${parametreLOC}/loki/loki -config.file ${parametreLOC}/loki/config-loki.yml

[Install]
WantedBy=multi-user.target

EOF

sudo systemctl daemon-reload
sudo systemctl start loki
sudo systemctl enable loki
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

echo -e "${green}Serveur Loki installé dans : ${parametreLOC}/loki et écoute l'addresse ${parametreIP}";
echo -e "Fichier de configuration crée sous : ${red}${parametreLOC}/loki/config-loki.yml${green}";
echo -e "Service crée sous : ${red}/etc/systemd/system/loki.service${green}";
sleep 1
echo -e "${green}Grafana installé et accessible sur : http://${parametreIP}:3000";
sleep 2
echo -e "Utilisation :";
echo -e "systemctl start loki";
echo -e "systemctl stop loki";
echo -e "systemctl start grafana-server";
echo -e "systemctl stop grafana-server${nc}";
sleep 5