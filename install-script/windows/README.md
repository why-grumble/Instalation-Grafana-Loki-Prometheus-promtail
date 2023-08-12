# Installation


## WMI (Prometheus) [Dépot](https://github.com/prometheus-community/windows_exporter)

Windows exporter possède un .msi ce qui l'installera en tant que service avec un démarrage automatique, les options voulues ne sont disponible qu'à l'installation, si vous voulez les changer, il vous faudra réinstaller le package.

```bash
msiexec /i \\NOM_OU_IP\soft\windows-exporter.msi --collectors.enabled "[defaults],ad,process" --web.listen-address 1213
```

| Paramètre | Description                |
| :-------- | :------------------------- |
| `--collectors.enabled` | Métriques |
| `--web.listen-address` | Port personalisé |

[Listes des collecteurs](https://github.com/prometheus-community/windows_exporter#collectors)

Fichier de configuration de Prometheus sur le serveur de centralisation
```bash
- job_name: "windows"
    static_configs:
      - targets: ["IP:PORT"]
```

## Promtail

```bash
./promtail --config.file=local-config.yml
```

| Paramètre | Description                |
| :-------- | :------------------------- |
| `--config.file=` | **Requis** Fichier de configuration |

Exemple local-config.yml

```bash
server:
  http_listen_port: 9080
  grpc_listen_port: 0
 
positions:
  filename: ./positions.yaml
 
clients:
  - url: http://SERVEUR LOKI:3100/loki/api/v1/push
 
scrape_configs:
  - job_name: windows-application
    windows_events: 
      eventlog_name: "Application"
      labels:
        logsource: windows-eventlog
      use_incoming_timestamp: true
      exclude_user_data: true
      exclude_event_data: true
      bookmark_path: "./tmp/bookmark-application.xml"
      locale: 0

  - job_name: windows-system
    windows_events: 
      eventlog_name: "System"
      labels:
        logsource: windows-eventlog
      use_incoming_timestamp: true
      exclude_user_data: true
      exclude_event_data: true
      bookmark_path: "./tmp/bookmark-system.xml"
      locale: 0
```

| Paramètre | Description                |
| :-------- | :------------------------- |
| `-s` | **Requis** IP ou nom d'hote du serveur |
| `-l` | Repertoire d'installation, par default : /usr/local/bin/ |
