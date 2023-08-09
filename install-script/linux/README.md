
## Installation

Sous Linux

```bash
git clone https://github.com/why-grumble/Instalation-Grafana-Loki-Prometheus-promtail_Linux
```
Chaque service va s'installer avec leur port par défaut, si vous souhaitez le changer libre à vous de modifier le script.
## install-grafana-loki-prometheus.sh

#### Installation

```bash
./install-grafana-loki-prometheus.sh -s 10.0.0.5 -l /usr/local/bin/
```

| Paramètre | Description                |
| :-------- | :------------------------- |
| `-s` | **Requis** IP ou nom d'hote du serveur |
| `-l` | Repertoire d'installation, par default : /usr/local/bin/ |


## install-grafana-loki.sh

#### Installation

```bash
./install-grafana-loki.sh -s 10.0.0.5 -l /usr/local/bin/
```

| Paramètre | Description                |
| :-------- | :------------------------- |
| `-s` | **Requis** IP ou nom d'hote du serveur |
| `-l` | Repertoire d'installation, par default : /usr/local/bin/ |

## install-promtail.sh

#### Installation

```bash
./install-promtail.sh -s 10.0.0.5 -l /usr/local/bin/
```

| Paramètre | Description                |
| :-------- | :------------------------- |
| `-s` | **Requis** IP ou nom d'hote du serveur |
| `-l` | Repertoire d'installation, par default : /usr/local/bin/ |

