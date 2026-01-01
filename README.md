
# HomeLab

Set of docker-compose files for my home environment.
See `ansible` branch for deployment with ansible

## Stacks and Applications

* **Management**
  * cloudflared (tunnel)
  * Traefik
  * Portainer

* **Monitoring**
  * cAdvisor
  * Alloy
  * Loki
  * Prometheus
  * Grafana

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

* **Stirling**
  * Stirling-PDF



## Deployment Notes: Handling Relative Paths

This project uses relative paths in Docker Compose files. Depending on whether you are using Portainer **Business Edition (EE)** or **Community Edition (CE)**, follow the instructions below to ensure volumes are mapped correctly.

### Portainer Business Edition (EE)
Portainer EE supports relative paths natively via the **Enable relative path volumes** feature.

1. When deploying stacks such as `monitoring`, `filebrowser`, or `guacamole`, ensure you toggle **Enable relative path volumes** to **On**.
2. Provide the absolute path to the stack's folder in the **Local filesystem path** field.
   * *Example for monitoring:* `/home/username/homelab/stack-monitoring/`

### Portainer Community Edition (CE)
Portainer CE does not have a native toggle for relative paths. To handle this, the Compose files use the `${CONFIG_PATH:-.}` variable. You must manually define this variable during deployment.

1. In the Portainer Stack deployment screen, go to the **Environment variables** section.
2. Add a variable named `CONFIG_PATH`.
3. Set the value to the absolute path of your stack's configuration files.
   * *Example for monitoring:* `/home/username/homelab/stack-monitoring/`

---

> [!TIP]
> Using the `${CONFIG_PATH:-.}` syntax ensures that if you run these stacks via CLI (`docker compose up`), they will default to the current directory (`.`), maintaining compatibility across different environments.
## Environment Variables

### Management

| Name                    | Required?                          | Allowed Values                   | Default Value | Description                                                 |
| ----------------------- | ---------------------------------- | -------------------------------- | ------------- | ----------------------------------------------------------- |
| TUNNEL\_TOKEN           | YES                                | String                           |               | Token provided by Cloudflare Zero Trust Zone                |
| HOST                    | YES                                | A valid domain address           |               | Domain address                                              |
| PORTAINER\_EDITION      | NO                                 | ce/ee                            | ce            | Determines the community or enterprise version of Portainer |
| PORTAINER\_LICENCE\_KEY | if PORTAINER\_EDITION is set to ee | String                           |               | Portainer EE licence key                                    |

### Monitoring

| Name                | Required?                               | Allowed Values         | Default Value  | Description                                                                                          |
| ------------------- | ---------                               | ---------------------- | -------------- | -------------------------------------------------------------------------------                      |
| HOST                | YES                                     | a valid domain address |                | Domain address                                                                                       |
| DOCKER_DATA_PATH    | NO                                      | an absolute path       |/var/lib/docker | location of docker data (if changed in the /etc/docker/daemon.json config file)                      |
| CONFIG_PATH         | YES IF PORTAINER_EDITION IS SET TO "CE" | an absolute path       |.               | Absolute path to cloned monitoring-stack config files (eg: /home/username/homelab/stack-monitoring/) |

### Filebrowser

| Name                | Required?                               | Allowed Values             | Default Value | Description                                                                                          |
| ------------------- | ---------                               | -------------------------- | ------------- | --------------------------------------------------------------------                                 |
| PUID                | NO                                      | valid user ID              | 1000          | User ID                                                                                              |
| GUID                | NO                                      | valid group ID             | 1000          | Group ID                                                                                             |
| BROWSING\_PATH      | YES                                     | absolute path to directory |               | Path to directory                                                                                    |
| CONFIG_PATH         | YES IF PORTAINER_EDITION IS SET TO "CE" | an absolute path           |.              | Absolute path to cloned guacamole-stack config files (eg: /home/username/homelab/stack-guacamole/) |
| HOST                | YES                                     | a valid domain address     |               | Domain address                                                                                       |

### Guacamole

| Name                     | Required?                               | Allowed Values            | Default Value | Description                                                                                          |
| ---------------------    | ---------                               | ------------------------- | ------------- | -----------------------------------------------------------                                          |
| GUACD\_PORT              | NO                                      | 0-65535                   | 4822          | Guacd port                                                                                           |
| MYSQL\_PORT              | NO                                      | 0-65535                   | 3306          | MySQL database port                                                                                  |
| MYSQL\_USER              | NO                                      | string                    | admin         | MySQL username                                                                                       |
| MYSQL\_PASSWORD          | YES                                     | string                    |               | MySQL password for user                                                                              |
| MYSQL\_ROOT\_PASSWORD    | YES                                     | string                    |               | MySQL password for root                                                                              |
| HOST                     | YES                                     | a valid domain address    |               | Domain address                                                                                       |
| GUACAMOLE_VERSION        | NO                                      | a valid version           |               | Version of deployed guacamole. WoL works on 1.5.5                                                    |
| GUACAMOLE_RECORDING_PATH | YES                                     |absolute path to directory |               | Path where session recordings and typescript will be saved                                           |
| CONFIG_PATH              | YES IF PORTAINER_EDITION IS SET TO "CE" | an absolute path          |.              | Absolute path to cloned guacamole-stack config files (eg: /home/username/homelab/stack-guacamole/) |

### Pi-hole

| Name                | Required? | Allowed Values         | Default Value | Description                        |
| ------------------- | --------- | ---------------------- | ------------- | ---------------------------------- |
| TZ                  | NO        | IANA Time Zone         | Europe/Warsaw | Timezone for Pi-hole               |
| HOST                | YES       | a valid domain address |               | Domain address                     |

### qBittorrent

| Name                | Required? | Allowed Values         | Default Value | Description                                |
| ------------------- | --------- | ---------------------- | ------------- | ------------------------------------------ |
| DOWNLOAD\_PATH      | YES       | absolute path          |               | Path where downloaded files will be stored |
| HOST                | YES       | a valid domain address |               | Domain address                             |


### Stirling-PDF

| Name                | Required? | Allowed Values         | Default Value | Description                                       |
| ------------------- | --------- | ---------------------- | ------------- | ------------------------------------------------- |
| LOCALE              | No        | locale code            | pl-PL         | Locale used for language and regional formatting  |
| HOST                | YES       | a valid domain address |               | Domain address                                    |

---

## Deployment

### 1. Clone the repository

```bash
git clone https://github.com/t4nello/homelab.git
```

### 2. Navigate to the management stack directory

```bash
cd homelab/stack-management
```

### 3. Create necessary Docker networks

```bash
docker network create --opt com.docker.network.bridge.name=management management
docker network create --opt com.docker.network.bridge.name=monitoring monitoring
docker network create --opt com.docker.network.bridge.name=applications applications
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
docker-compose -p management up -d
```

### 7. Log in to Portainer

Open in browser:

```
https://portainer.${HOST}
```

### 8. Deploy additional stacks

Use Portainer to deploy other stacks. Refer to the **"Additional Info for stacks"** section for details.

## Additional Info for Stacks

### Guacamole
#### Wake-on-LAN (WoL) Setup for Guacamole (version 1.5.5)

**Important:** Guacamole version **1.5.5** is recommended. Version **1.6.0** has known issues with WoL. https://issues.apache.org/jira/projects/GUACAMOLE/issues/GUACAMOLE-2107?filter=allissues

Since a bridge network is used, WoL packets must be routed to your home LAN with specially prepared script

##### Steps:
1. install socat package
```bash
sudo apt install socat
```
2. Copy the `wol-relay.sh` script to `/usr/bin/` and make it executable:

```bash
sudo cp <repo>/stack-guacamole/wol-scripts/wol-relay.sh /usr/bin/wol-relay.sh
sudo chmod +x /usr/bin/wol-relay.sh
```

2. Copy the `wol-relay.service` file to the systemd directory:

```bash
sudo cp <repo>/stack-guacamole/wol-scripts/wol-relay.service /etc/systemd/system/
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
```
runas /u:MicrosoftAccount\your@email.com cmd.exe
```
3. A Command Prompt will be shown, type your current Microsoft Account password and enter.
Now, you can connect to that computer via Remote Desktop.
You can find the detail here https://nready.net/remote-desktop-on-windows-11-with-microsoft-account-mfa/

##### Storing recording from sessions:
According to documentation, directory where logs will be stored have to be owned by user 1000 and group 1001

```bash
sudo chown -R 1000:1001 {GUACAMOLE_RECORDING_PATH}
sudo chmod -R 2750 {GUACAMOLE_RECORDING_PATH}
```

## Post-Deployment & Maintenance

### Permission Issues
If you encounter permission issues with volumes (especially in Monitoring or Guacamole stacks), ensure the directories on your host have the correct ownership. Many containers use UID `1000`.

### Database Backups
It is highly recommended to regularly back up the following:
* **Guacamole:** MySQL database volume.
* **Pi-hole:** `/etc/pihole` and `/etc/dnsmasq.d`.
* **Traefik:** `acme.json` (if using Let's Encrypt instead of Cloudflare Tunnel).

##  Access to Services

Once all stacks are up, you can access your services at the following addresses. 
*Note: Replace `${HOST}` with your actual domain (e.g., example.com).*

| Service         | URL                           | Default Credentials                 |
| :---            | :---                          | :---                                |
| **Portainer**   | `https://portainer.${HOST}`   | `admin` / (Set at 1st login)        |
| **Traefik**     | `https://traefik.${HOST}`     | Protected by `htpasswd`             |
| **Grafana**     | `https://grafana.${HOST}`     | `admin` / `admin`                   |
| **Prometheus**  | `https://prometheus.${HOST}`  | Protected by `htpasswd`             |
| **Filebrowser** | `https://filebrowser.${HOST}` | `admin` / `admin`                   |
| **Guacamole**   | `https://guacamole.${HOST}`   | `guacadmin` / `guacadmin`           |
| **Pi-hole**     | `https://pihole.${HOST}`      | `admin` / (Check logs for password) |
| **qBittorrent** | `https://qb.${HOST}`          | `admin` / (Check logs for password) |

---

## Network Architecture

Understanding how traffic flows through this homelab setup:



1. **Cloudflared Tunnel** creates a secure entry point without opening ports.
2. **Traefik** acts as a Reverse Proxy, handling SSL and routing traffic to specific containers based on the hostname.
3. **Isolated Networks** (`management`, `monitoring`, `applications`) ensure that containers only communicate with what they need to.


## License & Acknowledgments

### Project License
This project is licensed under the [MIT License](LICENSE).

### Credits
This HomeLab setup is built thanks to the amazing open-source community. Special thanks to:
* **Traefik Proxy** - Cloud-native edge router.
* **Portainer** - Making Docker management easy.
* **The Prometheus & Grafana teams** - For the industry-standard monitoring stack.
* **Apache Guacamole** - For seamless remote access.
* **LinuxServer.io** - For their high-quality Docker images (qBittorrent, Filebrowser).

---

## Disclaimer

This project is for **educational and personal home lab use only**. 
* **Use at your own risk:** I am not responsible for any data loss, hardware damage, or security breaches resulting from the use of these configurations.
* **Security:** Always review the Docker Compose files and scripts before deployment. Ensure your firewall and network settings are properly configured.
* **No Warranty:** This software is provided "as is", without warranty of any kind, express or implied.