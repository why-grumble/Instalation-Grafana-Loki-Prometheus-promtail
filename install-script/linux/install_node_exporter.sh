#!/bin/bash
sudo apt-get install wget -y
cd /usr/local/bin
sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar xvfz node_exporter-*.*-amd64.tar.gz
mv node_exporter-* node_exporter
sudo useradd -s /sbin/nologin node_exporter
sudo chown node_exporter: /usr/local/bin/node_exporter -R
sudo chmod 755 /usr/local/bin/node_exporter -R

sudo cat <<EOF >/etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter/node_exporter

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
