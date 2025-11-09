
# HomeLab

Set of docker-compose files for my home environment.
See `ansible` branch for deployment with ansible

## Stacks and Applications

* **EFK**

  * Elasticsearch
  * FluentD
  * Kibana
* **Management**

  * cloudflared (tunnel)
  * cloudflared (proxy-DNS for DoH)
  * Traefik
  * Portainer
* **Monitoring**

  * Node Exporter
  * Prometheus
  * Grafana
  * cAdvisor
* **Filebrowser**

  * Filebrowser
* **Guacamole**

  * Guacamole
  * Guacd
  * MySQL
* **Pi-hole**

  * Pi-hole
* **Torrent**

  * qBittorrent

## Environment Variables

### EFK

| Name                | Required? | Allowed Values         | Default Value | Description                                        |
| ------------------- | --------- | ---------------------- | ------------- | -------------------------------------------------- |
| TRAEFIK\_ENTRYPOINT | NO        | web/websecure          | websecure     | Entrypoint of the services                         |
| HOST                | YES       | a valid domain address |               | Domain address                                     |
| TRAEFIK\_TLS        | NO        | true/false             | true          | Enable or disable TLS                              |
| ES\_PASSWORD        | YES       | string                 |               | Elasticsearch password (see additional info below) |
| KIBANA\_PASSWORD    | YES       | string                 |               | Kibana password (see additional info below)        |

### Management

| Name                    | Required?                          | Allowed Values                   | Default Value | Description                                                 |
| ----------------------- | ---------------------------------- | -------------------------------- | ------------- | ----------------------------------------------------------- |
| TUNNEL\_TOKEN           | YES                                | String                           |               | Token provided by Cloudflare Zero Trust Zone                |
| TRAEFIK\_ENTRYPOINT     | NO                                 | web/websecure                    | websecure     | Entrypoint of the services                                  | 
| HOST                    | YES                                | A valid domain address           |               | Domain address                                              |
| TRAEFIK\_TLS            | NO                                 | true/false                       | true          | Enable or disable TLS                                       |
| PORTAINER\_EDITION      | NO                                 | ce/ee                            | ce            | Determines the community or enterprise version of Portainer |
| PORTAINER\_PASSWORD     | YES                                | String                           |               | Password for portainer WebGui password                      |
| PORTAINER\_LICENCE\_KEY | if PORTAINER\_EDITION is set to ee | String                           |               | Portainer EE licence key                                    |

### Monitoring

| Name                | Required? | Allowed Values         | Default Value | Description                |
| ------------------- | --------- | ---------------------- | ------------- | -------------------------- |
| TRAEFIK\_ENTRYPOINT | NO        | web/websecure          | websecure     | Entrypoint of the services |
| HOST                | YES       | a valid domain address |               | Domain address             |
| TRAEFIK\_TLS        | NO        | true/false             | true          | Enable or disable TLS      |

### Filebrowser

| Name                | Required? | Allowed Values             | Default Value | Description                                                          |
| ------------------- | --------- | -------------------------- | ------------- | -------------------------------------------------------------------- |
| PUID                | NO        | valid user ID              | 1000          | User ID                                                              |
| GUID                | NO        | valid group ID             | 1000          | Group ID                                                             |
| BROWSING\_PATH      | YES       | absolute path to directory |               | Path to directory                                                    |
| CONFIG\_PATH        | YES       | absolute path to config    |               | Path to config directory with config.json and empty database.db file |
| TRAEFIK\_ENTRYPOINT | NO        | web/websecure              | websecure     | Entrypoint of the services                                           |
| HOST                | YES       | a valid domain address     |               | Domain address                                                       |
| TRAEFIK\_TLS        | NO        | true/false                 | true          | Enable or disable TLS                                                |

### Guacamole

| Name                  | Required? | Allowed Values         | Default Value | Description                |
| --------------------- | --------- | ---------------------- | ------------- | -------------------------- |
| GUACD\_PORT           | NO        | 0-65535                | 4822          | Guacd port                 |
| MYSQL\_PORT           | NO        | 0-65535                | 3306          | MySQL database port        |
| MYSQL\_USER           | NO        | string                 | admin         | MySQL username             |
| MYSQL\_PASSWORD       | YES       | string                 |               | MySQL password for user    |
| MYSQL\_ROOT\_PASSWORD | YES       | string                 |               | MySQL password for root    |
| TRAEFIK\_ENTRYPOINT   | NO        | web/websecure          | websecure     | Entrypoint of the services |
| HOST                  | YES       | a valid domain address |               | Domain address             |
| TRAEFIK\_TLS          | NO        | true/false             | true          | Enable or disable TLS      |

### Pi-hole

| Name                | Required? | Allowed Values         | Default Value | Description                        |
| ------------------- | --------- | ---------------------- | ------------- | ---------------------------------- |
| TZ                  | NO        | IANA Time Zone         | Europe/Warsaw | Timezone for Pi-hole               |
| TRAEFIK\_ENTRYPOINT | NO        | web/websecure          | websecure     | Entrypoint of the services         |
| HOST                | YES       | a valid domain address |               | Domain address                     |
| TRAEFIK\_TLS        | NO        | true/false             | true          | Enable or disable TLS              |

### qBittorrent

| Name                | Required? | Allowed Values         | Default Value | Description                                |
| ------------------- | --------- | ---------------------- | ------------- | ------------------------------------------ |
| CONFIG\_PATH        | YES       | absolute path          |               | Path to config directory                   |
| DOWNLOAD\_PATH      | YES       | absolute path          |               | Path where downloaded files will be stored |
| TRAEFIK\_ENTRYPOINT | NO        | web/websecure          | websecure     | Entrypoint of the services                 |
| HOST                | YES       | a valid domain address |               | Domain address                             |
| TRAEFIK\_TLS        | NO        | true/false             | true          | Enable or disable TLS                      |

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
Example:

```env
HOST=example.com
TRAEFIK_TLS=true
TRAEFIK_ENTRYPOINT=websecure
```

### 5. Install apache2-utils to generate password file for Traefik/Prometheus

```bash
sudo apt install apache2-utils
htpasswd -Bc -C 6 <path/to/management/compose>/usersfile <username>
```

### 6. Deploy the management stack

```bash
docker-compose -f docker-compose-management.yml -p management up -d
```

### 7. Log in to Portainer

Open in browser:

```
https://portainer.<your-domain>
```

### 8. Deploy additional stacks

Use Portainer to deploy other stacks. Refer to the **"Additional Info for stacks"** section for details.

## Additional Info for Stacks

### Filebrowser

Create a directory containing `config.json` and an empty `database.db` file. Example `config.json`:

```json
{
  "port": 80,
  "baseURL": "",
  "address": "",
  "log": "stdout",
  "database": "/database.db",
  "root": "/srv"
}
```

Set `CONFIG_PATH` to the absolute path of this directory.

### Guacamole

You need to build a MySQL image with init scripts to create the proper database schema and an initial user `guacadmin` / `guacadmin`.

Scripts and Dockerfile are located in the `stack-guacamole` directory.
You can build the image via Portainer or CLI:

```bash
docker build -t mysql/guacamole -f mysql.Dockerfile .
```

#### Wake-on-LAN (WoL) Setup for Guacamole (version 1.5.5)

**Important:** Guacamole version **1.5.5** is recommended. Version **1.6.0** has known issues with WoL.

Since a bridge network is used, WoL packets must be routed to your home LAN.

##### Steps:

1. Move the `wol-relay.sh` script to `/usr/bin/` and make it executable:

```bash
sudo mv <repo>/stack-guacamole/wol-scripts/wol-relay.sh /usr/bin/wol-relay.sh
sudo chmod +x /usr/bin/wol-relay.sh
```

2. Move the `wol-relay.service` file to the systemd directory:

```bash
sudo mv <repo>/stack-guacamole/wol-scripts/wol-relay.service /etc/systemd/system/
```
3. Enable and start the service:

```bash
sudo systemctl enable wol-relay.service
sudo systemctl start wol-relay.service
```

4. Check service status:

```bash
sudo systemctl status wol-relay.service
```
##### If you want to login to Windows PC via Microsoft account 
1. Enable Remote Desktop on the Computer that you want to remote.
2.  On that remote computer, Run the following command in the Run… `windows key` + `r`
runas /u:MicrosoftAccount\your@email.com cmd.exe
3. A Command Prompt will be shown, type your current Microsoft Account password and enter.
Now, you can connect to that computer via Remote Desktop.
You can find the detail here https://nready.net/remote-desktop-on-windows-11-with-microsoft-account-mfa/


### EFK

To generate passwords for Kibana and FluentD:

1. Connect to the Elasticsearch container:

```bash
docker exec -it <elastic_container_id> /bin/sh
```

2. Run:

```bash
bash bin/elasticsearch-setup-passwords auto
```

3. Use the generated passwords in your environment variables.

### Pi-hole Setup with Docker

####1. Disable systemd-resolved

To allow Pi-hole to listen on port 53:

```bash
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
```

#### 2. Temporarily set an external DNS

This ensures the host and Docker can resolve domains (e.g., to download packages):

```bash
echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf
```

You can also use `8.8.8.8` instead of Cloudflare.

#### 3. Configure Docker to use the correct DNS

Edit or create `/etc/docker/daemon.json`:

```json
{
  "dns": ["1.1.1.1"]
}
```

#### 4. Restart the Docker engine

```bash
sudo systemctl restart docker
```

#### 5. Deploy the Pi-hole stack

Use your `docker-compose.yml` or stack file. Ports 53 (TCP/UDP) will be mapped to the host, allowing Pi-hole to listen locally.

#### 6. Set the host to use Pi-hole as DNS

After Pi-hole is running, configure your host to point to the local Pi-hole:

```bash
echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf
```
Edit or create `/etc/docker/daemon.json`:

```json
{
  "dns": [127.0.0.1"]
}
```

#### 7. Test the setup

Verify that your host is using Pi-hole:

```bash
dig @127.0.0.1 google.com
```

You should receive an `A` record response, confirming Pi-hole is resolving DNS queries correctly.

