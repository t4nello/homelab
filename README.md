# HomeLab

Set of docker-compose files for my home environment
## Stacks and applications
 -  EFK
	- ElasticSearch
	- Fluent-Bit
	- Kibana
 -  Management
	 - cloudflared (tunnel)
	 - cloudflared (proxy-DNS for DoH)
	 -  traefik
	 - portainer
 - Monitoring
	 - Node-Exporter
	 - Prometheus
	 - Grafana
	 - CAdvisor
 - Filebrowser
	 - Filebrowser
 - Guacamole
	 - Guacamole
	 - Guacd
	 - MySQL
 - PiHole
	 - PiHole
 - Torrent
	 - QbitTorrent

## Environment Variables

### EFK
| Name               | Required? | Allowed Values       | Default Value | Description                                   								   |
|--------------------|-----------|----------------------|---------------|----------------------------------------------------------------------------------|
| TRAEFIK_ENTRYPOINT | NO        | web/websecure        | websecure     | Entrypoint of the services                    								   |
| HOST               | YES       | valid domain address | ------------  | Domain address                                								   |
| TRAEFIK_TLS        | NO        | true/false           | true          | Enable or disable TLS                          								   |
| ES_PASSWORD        | YES       | string               | ------------  | ElasticSearch password generated from command, see: (Additional Info for stacks) |
| KIBANA_PASSWORD    | YES       | string               | ------------  | Kibana password generated from command, see: (Additional Info for stacks)        |
---
### Management
| Name               | Required? | Allowed Values       | Default Value | Description                                  |
|--------------------|-----------|----------------------|---------------|----------------------------------------------|
| TUNNEL_TOKEN       | YES       | Valid token          | ------------  | Token provided by cloudflare Zero Trust Zone |
| TRAEFIK_ENTRYPOINT | NO        | web/websecure        | websecure     | Entrypoint of the services                   |
| HOST               | YES       | valid domain address | ------------  | Domain address                               |
| TRAEFIK_TLS        | NO        | true/false           | true          | Enable or disable TLS                        |
---
### Monitoring
| Name               | Required? | Allowed Values       | Default Value | Description                |
|--------------------|-----------|----------------------|---------------|----------------------------|
| TRAEFIK_ENTRYPOINT | NO        | web/websecure        | websecure     | Entrypoint of the services |
| HOST               | YES       | valid domain address | ------------  | Domain address             |
| TRAEFIK_TLS        | NO        | true/false           | true          | Enable or disable TLS      |
---
### Filebrowser
| Name               | Required? | Allowed Values             | Default Value | Description                                                    |
|--------------------|-----------|----------------------------|---------------|----------------------------------------------------------------|
| PUID               | NO        | valid user ID              | 1000          | User ID                                                        |
| GUID               | NO        | valid group ID             | 1000          | Group ID                                                       |
| BROWSING_PATH      | YES       | absloute path to directory | ------        | Path to directory                                              |
| CONFIG_PATH        | YES       | absloute path to config    | ------        | Path to config dir with config.json and empty database.db file |
| TRAEFIK_ENTRYPOINT | NO        | web/websecure              | websecure     | Entrypoint of the services                                     |
| HOST               | YES       | valid domain address       | ------------  | Domain address                                                 |
| TRAEFIK_TLS        | NO        | true/false                 | true          | Enable or disable TLS                                          |
---
### Guacamole
| Name                | Required? | Allowed Values       | Default Value | Description                |
|---------------------|-----------|----------------------|---------------|----------------------------|
| GUACD_PORT          | NO        | 0-65535              | 4822          | Guacd port                 |
| MYSQL_PORT          | NO        | 0-65535              | 3306          | MySQL database port        |
| MYSQL_USER          | No        | string               | admin         | MySQL username             |
| MYSQL_PASSWORD      | yes       | string               | ------------  | MySQL password for user    |
| MYSQL_ROOT_PASSWORD | yes       | string               | ------------  | MySQL password for root    |
| TRAEFIK_ENTRYPOINT  | NO        | web/websecure        | websecure     | Entrypoint of the services |
| HOST                | YES       | valid domain address | ------------  | Domain address             |
| TRAEFIK_TLS         | NO        | true/false           | true          | Enable or disable TLS      |
---
### PiHole
| Name               | Required? | Allowed Values       | Default Value | Description                 |
|--------------------|-----------|----------------------|---------------|-----------------------------|
| TZ                 | NO        | IANA Time Zone       | Europe/Warsaw | Timezone for PiHole         |
| PIHOLEWEBPASSWORD  | YES       | String               | -----------   | Password for PiHole webAPI  |
| TRAEFIK_ENTRYPOINT | NO        | web/websecure        | websecure     | Entrypoint of the services  |
| HOST               | YES       | valid domain address | ------------  | Domain address              |
| TRAEFIK_TLS        | NO        | true/false           | true          | Enable or disable TLS       |
---
### QbitTorrent
| Name               | Required? | Allowed Values       | Default Value | Description                                  |
|--------------------|-----------|----------------------|---------------|----------------------------------------------|
| CONFIG_PATH        | YES       | absolute path        | -----------   | Path to config directory of Qbittorrent      |
| DOWNLOAD_PATH      | YES       | absolute path        | -----------   | Path where downloaded files should be stored |
| TRAEFIK_ENTRYPOINT | NO        | web/websecure        | websecure     | Entrypoint of the services                   |
| HOST               | YES       | valid domain address | ------------  | Domain address                               |
| TRAEFIK_TLS        | NO        | true/false           | true          | Enable or disable TLS      
 |
  ---
## Additional Info for stacks
First stack to be deployed is management, then the of deployment doesn't matter
### Management
Install ```apache2-utils``` package to generate password for Traefik/Prometheus
```bash
htpasswd -Bc -C 6 <path/to/managament/compose>/usersfile <username>
```
After that you can deploy this stack by using 
```bash 
docker-compose -f docker-compose-management.yml -p management up -d 
```
### File Browser
You should create directory that includes files `config.json` with expample value:
```bash
{
    "port": 80,
    "baseURL": "",
    "address": "",
    "log": "stdout",
    "database": "/database.db",
    "root": "/srv"
  }
```
and empty `database.db`	file
Then pass the absoluthe path to that directory into the `CONFIG_PATH` environment variable

### Guacamole
first you need to create image of MySQL image with scripts to create proper database schema and creating 1st user with login `guacadmin` and password `guacadmin`. Iinit scripts and dockerfile content are in the stack-guacamole directory. 
You can build image via previously deployed portainer or via CLI 
` docker build -t mysql/guacamole -f mysql.Dockerfile .`

### EFK
To generate passwords for kibana and fluend you have to:
1. `docker exec -it <elastic_container_id> /bin/sh`
2. `bash bin/elasticsearch-setup-passwords auto`
3. Passwords will generate, fill them in stack envs