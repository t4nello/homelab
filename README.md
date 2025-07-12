
# HomeLab

Set of docker-compose files for my home environment
## Stacks and applications
 -  EFK
	- ElasticSearch
	- FluentD
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
| Name               | Required? | Allowed Values             | Default Value | Description                                                          |
|--------------------|-----------|----------------------------|---------------|----------------------------------------------------------------------|
| PUID               | NO        | valid user ID              | 1000          | User ID                                                              |
| GUID               | NO        | valid group ID             | 1000          | Group ID                                                             |
| BROWSING_PATH      | YES       | absolute path to directory | ------        | Path to directory                                                    |
| CONFIG_PATH        | YES       | absolute path to config    | ------        | Path to config directory with config.json and empty database.db file |
| TRAEFIK_ENTRYPOINT | NO        | web/websecure              | websecure     | Entrypoint of the services                                           |
| HOST               | YES       | valid domain address       | ------------  | Domain address                                                       |
| TRAEFIK_TLS        | NO        | true/false                 | true          | Enable or disable TLS                                                |
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
 


## Deployment

### 1. Clone the repository

```bash
git clone <repo_url>
```

### 2. Navigate to the management stack directory

```bash
cd homelab/stack-management
```

### 3. Create necessary Docker networks

```bash
docker network create --opt com.docker.network.bridge.name=management management
docker network create --opt com.docker.network.bridge.name=monitoring monitoring
docker network create --opt com.docker.network.bridge.name=torrent torrent
docker network create --opt com.docker.network.bridge.name=guacd guacd
```

### 4. Create a `.env` file

Create a `.env` file in the `stack-management` directory and define the required environment variables.
example:
```bash
HOST=example.com
TRAEFIK_TLS=true
TRAEFIK_ENTRYPOINT=websecure
```

### 5. Install `apache2-utils` to generate password file for Traefik/Prometheus

```bash
sudo apt install apache2-utils
htpasswd -Bc -C 6 <path/to/management/compose>/usersfile <username>
```

### 6. Deploy the management stack

```bash
docker-compose -f docker-compose-management.yml -p management up -d
```

### 7. Log in to Portainer

Navigate to:

```
portainer.<your-domain>
```

and log in.

### 8. Deploy additional stacks

Use Portainer to deploy other stacks. Refer to the **"Additional Info for stacks"** section for details.

## Additional Info for stacks

### File Browser
You should create a directory that includes files `config.json` with example value:
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
Then pass the absolute path to that directory into the `CONFIG_PATH` environment variable

### Guacamole
first you need to create image of MySQL image with scripts to create proper database schema and creating 1st user with login `guacadmin` and password `guacadmin`. Iinit scripts and dockerfile content are in the stack-guacamole directory. 
You can build image via previously deployed portainer or via CLI 
` docker build -t mysql/guacamole -f mysql.Dockerfile .`
#### Wake-on-LAN (WoL) Setup for Guacamole (version 1.5.5)
**Note:** As of 12.07.2025, it is recommended to use Guacamole version **1.5.5** for WoL functionality because version **1.6.0** has uknown issues preventing WoL from working.
Since the stack uses a **bridge network**, WoL packets need to be properly routed to your home LAN.
To achieve this, you must place the scripts from the `homelab/stack-guacamole/wolscripts` directory into appropriate locations on the host machine.
Root privileges are required.

---
##### Steps:
1.  **Move the `wol-relay.sh` script** to `/usr/bin/` and make it executable:
	```bash
	sudo mv <path/to/cloned/repo>/stack-guacamole/wol-relay.sh /usr/bin/wol-relay.sh
	sudo chmod +x /usr/bin/wol-relay.sh
	```
2.  **Move the `wol-relay.service` file** to the systemd directory:
	```bash 
	sudo mv <path/to/cloned/repo>/stack-guacamole/wol-relay.service /etc/systemd/system/
	```
3.  **Enable and start the service:**
	```bash
	sudo systemctl enable wol-relay.service
	sudo systemctl start wol-relay.service
	```
4.  **Check the service status:**
	```bash
	sudo systemctl status wol-relay.service
	```
---
### EFK
To generate passwords for kibana and fluend you have to:
1. `docker exec -it <elastic_container_id> /bin/sh`
2. `bash bin/elasticsearch-setup-passwords auto`
3. Passwords will generate, fill them in stack envs
