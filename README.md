
# HomeLab

Home-lab deployment configurations for Docker Compose and Kubernetes (k3s).

This repository contains two deployment paths. The Compose stacks and k3s manifests are maintained separately and do not provide identical services or configuration. Choose one path and follow its deployment instructions.

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

* **Database**
  * MySQL

* **AdGuard**
  * AdGuard

* **Torrent**
  * qBittorrent

* **Stirling**
  * Stirling-PDF

* **Wiki**
  * Bookstack

## Table of Contents

- [Stacks and Applications](#stacks-and-applications)
- [Docker Compose](#docker-compose)
  - [Relative paths](#docker-compose-relative-paths)
  - [Environment variables](#docker-compose-environment-variables)
  - [Deployment](#docker-compose-deployment)
  - [Additional stack notes](#docker-compose-additional-stack-notes)
- [Kubernetes with k3s](#kubernetes-with-k3s)
  - [Cluster prerequisites](#k3s-prerequisites)
  - [Repository layout](#k3s-repository-layout)
  - [Secrets and configuration](#k3s-secrets-and-configuration)
  - [Deploying the manifests](#deploying-the-k3s-manifests)
- [Post-deployment and maintenance](#post-deployment-and-maintenance)
- [Access to services](#access-to-services)
- [Network architecture](#network-architecture)
- [Disclaimer](#disclaimer)

## Docker Compose

### Docker Compose: Relative Paths

Several Compose files mount configuration files using relative paths or `${CONFIG_PATH:-.}`. Resolve these paths relative to the stack directory when deploying each stack.

### Portainer Business Edition (EE)
Portainer EE supports relative paths natively via the **Enable relative path volumes** feature.

1. When deploying a stack that uses relative paths, enable **Enable relative path volumes**.
2. Provide the absolute path to that stack's directory in the **Local filesystem path** field.
   * *Example for monitoring:* `/home/username/homelab/compose/stack-monitoring/`

### Portainer Community Edition (CE)
For each stack that uses `${CONFIG_PATH:-.}`, set `CONFIG_PATH` to the absolute path of that stack's directory. Portainer environment variables are configured per stack.

1. In the Portainer Stack deployment screen, go to the **Environment variables** section.
2. Add a variable named `CONFIG_PATH`.
3. Set it to the absolute path of the stack directory, not the `config` subdirectory.
   * *Example for monitoring:* `/home/username/homelab/compose/stack-monitoring/`

---

[!TIP]
> From a stack directory, `${CONFIG_PATH:-.}` defaults to that directory when run with Docker Compose CLI. Set `CONFIG_PATH` explicitly in Portainer if its stack working directory does not point to the stack directory.
### Docker Compose Environment Variables

[!IMPORTANT]
> Set variables for each stack in Portainer, or provide an `.env` file when using Docker Compose from the CLI. MySQL creates separate application accounts for Guacamole and BookStack, each restricted to its own database. Use different usernames and passwords for the two applications, and use the same account name and password in the database stack and the corresponding application stack. Never commit `.env` files, tunnel tokens, passwords, or license keys to source control.

### Management

| Name                    | Required?                          | Allowed Values                   | Default Value | Description                                                 |
| ----------------------- | ---------------------------------- | -------------------------------- | ------------- | ----------------------------------------------------------- |
| TUNNEL\_TOKEN           | YES                                | String                           |               | Token provided by Cloudflare Zero Trust Zone                |
| HOST                    | YES                                | A valid domain address           |               | Domain address                                              |
| PORTAINER\_EDITION      | NO                                 | ce/ee                            | ce            | Determines the community or enterprise version of Portainer |
| PORTAINER\_LICENSE\_KEY | Only for EE                | String                           |               | Portainer EE licence key                                    |

### Monitoring

| Name                | Required?                               | Allowed Values         | Default Value  | Description                                                                                          |
| ------------------- | ---------                               | ---------------------- | -------------- | -------------------------------------------------------------------------------                      |
| HOST                | YES     | A domain name |              | Domain used for service URLs |
| DOCKER_DATA_PATH    | NO      | Absolute path | `/var/lib/docker` | Host Docker data directory mounted into cAdvisor and Alloy |
| CONFIG_PATH         | NO*     | Absolute path | `.` | Monitoring stack directory containing `config/` |

### Filebrowser

| Name                | Required?                               | Allowed Values             | Default Value | Description                                                                                          |
| ------------------- | ---------                               | -------------------------- | ------------- | --------------------------------------------------------------------                                 |
| PUID           | NO  | Numeric user ID | `1000` | UID used to run Filebrowser |
| GUID           | NO  | Numeric group ID | `1000` | Group ID used by the container |
| BROWSING\_PATH | YES | Absolute path | — | Host directory exposed as Filebrowser's files |
| CONFIG_PATH    | NO* | Absolute path | `.` | Filebrowser stack directory containing `config/config.json` |
| HOST           | YES | Domain name | — | Domain used for service URLs |

### Database

| Name | Required? | Allowed Values | Default Value | Description |
| --- | --- | --- | --- | --- |
| MYSQL\_ROOT\_PASSWORD | YES | String | — | MySQL root password |
| GUACAMOLE\_DB\_USER | NO | Letters, numbers, underscores | `guacamole` | MySQL account created for Guacamole; set the same value in the Guacamole stack. Must differ from the BookStack account |
| GUACAMOLE\_DB\_PASSWORD | YES | String | — | Password for the Guacamole MySQL account |
| BOOKSTACK\_DB\_USER | NO | Letters, numbers, underscores | `bookstack` | MySQL account created for BookStack; set the same value in the BookStack stack. Must differ from the Guacamole account |
| BOOKSTACK\_DB\_PASSWORD | YES | String | — | Password for the BookStack MySQL account |
| CONFIG\_PATH | NO* | Absolute path | `.` | Database stack directory containing `mysql/schema/` |


### Guacamole

| Name | Required? | Allowed Values | Default Value | Description |
| --- | --- | --- | --- | --- |
| HOST | YES | Domain name | — | Domain used for Guacamole URL |
| GUACAMOLE\_RECORDING\_PATH | YES | Absolute path | — | Host directory for session recordings |
| GUACAMOLE\_DB\_USER | NO | Letters, numbers, underscores | `guacamole` | MySQL account; must match the database stack and differ from BookStack's account |
| GUACAMOLE\_DB\_PASSWORD | YES | String | — | Password for the Guacamole MySQL account; must match the database stack |
| LOG\_LEVEL | NO | Guacamole log level | `debug` | Log level for Guacamole and guacd |                                                                       |

### qBittorrent

| Name | Required? | Allowed Values | Default Value | Description |
| --- | --- | --- | --- | --- |
| HOST | YES | Domain name | — | Domain used for service URLs |
| DOWNLOAD\_PATH | YES | Absolute path | — | Host directory for downloaded files |
| PUID | YES | Numeric user ID | — | User ID used by qBittorrent |
| PGID | YES | Numeric group ID | — | Group ID used by qBittorrent |
| TZ | NO | IANA time zone | `Europe/Warsaw` | Time zone |

### Stirling-PDF

| Name | Required? | Allowed Values | Default Value | Description |
| --- | --- | --- | --- | --- |
| LOCALE | NO | Locale code | `pl-PL` | Application locale |
| HOST | YES | Domain name | — | Domain used for service URLs |

### AdGuard

| Name | Required? | Allowed Values | Default Value | Description |
| --- | --- | --- | --- | --- |
| HOST | YES | Domain name | — | Domain used for service URLs |

### BookStack

| Name | Required? | Allowed Values | Default Value | Description |
| --- | --- | --- | --- | --- |
| APP\_KEY | YES | Key generated by the BookStack image | — | Encryption key for sessions and user data |
| HOST | YES | Domain name | — | Domain used for the BookStack URL |
| TZ | NO | IANA time zone | `Europe/Warsaw` | Time zone |
| DB\_HOST | NO | Host name | `mysql` | MySQL container host |
| BOOKSTACK\_DB\_USER | NO | Letters, numbers, underscores | `bookstack` | MySQL account; must match the database stack and differ from Guacamole's account |
| BOOKSTACK\_DB\_PASSWORD | YES | String | — | Password for the BookStack MySQL account; must match the database stack |

`*` `CONFIG_PATH` defaults to the current directory in Compose. For Portainer, set it to the absolute path of the relevant stack directory if relative paths are not resolved from that directory.

---

### Docker Compose Deployment

### 1. Clone the repository

```bash
git clone https://github.com/t4nello/homelab.git
```

### 2. Navigate to the management stack directory

```bash
cd homelab/compose/stack-management
```

### 3. Create the Docker networks

Create these networks once on the Docker host. Skip any network that already exists:

```bash
docker network create --opt com.docker.network.bridge.name=management management
docker network create --opt com.docker.network.bridge.name=monitoring monitoring
docker network create --opt com.docker.network.bridge.name=applications applications
docker network create --opt com.docker.network.bridge.name=guacd guacd
docker network create --opt com.docker.network.bridge.name=database database
```

### 4. Create a `.env` file

Create a `.env` file in `compose/stack-management` with the variables needed by this stack. Add real credentials locally; do not use the example values below as secrets.

```env
HOST=example.com
TUNNEL_TOKEN=<your-cloudflare-tunnel-token>
PORTAINER_EDITION=ce
```

If using Portainer EE, set `PORTAINER_EDITION=ee` and provide `PORTAINER_LICENSE_KEY`. Create the Basic Auth password file used by Traefik:

```bash
sudo apt install apache2-utils
htpasswd -Bc -C 6 usersfile <username>
```

### 5. Deploy the management stack

```bash
docker compose up -d
```

### 6. Log in to Portainer

Open in browser:

```
https://portainer.${HOST}
```

### 7. Deploy additional stacks

Deploy each remaining stack from its own directory under `compose/` (for example, `compose/stack-monitoring`). In Portainer, add that directory's Compose file and configure the variables listed above for that stack. Set `CONFIG_PATH` to the absolute path of the stack directory for monitoring, database, and Filebrowser if Portainer does not resolve relative paths from it. Deploy the database before Guacamole and BookStack; they both depend on its MySQL service and database initialization scripts. Provide each app's matching `*_DB_USER` and `*_DB_PASSWORD` values in both the database stack and the application stack.

### Docker Compose: Additional Stack Notes

### Guacamole
#### Wake-on-LAN (WoL) setup

Because Guacamole uses a bridge network, WoL packets need a host-side relay to reach the LAN. The included script uses the `guacd` Docker bridge and broadcast address `192.168.0.255`; adjust these values in the script if your network differs.

##### Steps:
1. Install `socat`:
```bash
sudo apt install socat
```
2. Copy the script and service from the repository's `compose/stack-guacamole/wol-scripts/` directory:

```bash
sudo cp <repo>/compose/stack-guacamole/wol-scripts/wol-relay.sh /usr/bin/wol-relay.sh
sudo chmod +x /usr/bin/wol-relay.sh
sudo cp <repo>/compose/stack-guacamole/wol-scripts/wol-relay.service /etc/systemd/system/
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
##### Connecting to Windows with a Microsoft account

1. Enable Remote Desktop on the computer you want to access.
2. On that computer, open **Run** (`Windows` + `R`) and run:

```
runas /u:MicrosoftAccount\your@email.com cmd.exe
```
3. Enter the current Microsoft account password in the Command Prompt. You can then connect to the computer via Remote Desktop.

#### Session recording directory

Create the host directory configured by `GUACAMOLE_RECORDING_PATH` and set its ownership and permissions so Guacamole can write recordings:

```bash
sudo chown -R 1000:1001 /path/to/recordings
sudo chmod -R 2750 /path/to/recordings
```

### AdGuard setup

AdGuard publishes DNS on host port 53. If another resolver (such as `systemd-resolved`) already owns that port, configure the host's resolver appropriately before starting AdGuard. Disabling the system resolver and overwriting `/etc/resolv.conf` can disrupt DNS on the host; use your distribution's network configuration and keep a way to restore the previous resolver settings.

#### 1. Check for port 53 conflicts

Check whether another service is listening on host port 53 before starting the stack. Do not disable `systemd-resolved` or replace `/etc/resolv.conf` blindly; use your distribution's documented network settings and make sure you can restore the existing resolver configuration.

#### 2. Keep an external resolver available during setup

Until AdGuard is configured, ensure the host can still resolve external names using its current DNS settings or another resolver configured through your network manager. Cloudflare's `1.1.1.1` and Google's `8.8.8.8` are examples of public resolvers.

#### 3. Deploy the AdGuard stack

Deploy `compose/stack-adguard/docker-compose.yml`. The Compose file publishes DNS on host ports 53/TCP and 53/UDP. The setup wizard is routed through Traefik on port 3000 during initial setup, while the normal web interface is served on port 80 after setup. Keep the corresponding ports in the AdGuard setup wizard consistent with the Traefik routes.

#### 4. AdGuard Home installer endpoints

During the first launch, AdGuard Home's setup wizard runs on port 3000 and is available at:

`https://adguard.${HOST}/install`

The setup routes also forward the installer API:

| Endpoint | Purpose | Container port |
| --- | --- | --- |
| `/install/*` | Installer UI | 3000 |
| `/control/install/*` | Installer API | 3000 |

After installation, the main interface is served on port 80; the setup wizard routes are no longer needed. Do not change the setup ports unless you also update the Traefik routing labels.

#### 5. Optionally use AdGuard as the host DNS resolver

Only after confirming that AdGuard is running and listening on port 53, configure your host's network settings to use it. Avoid replacing `/etc/resolv.conf` directly unless your distribution specifically documents that approach; preserve the previous DNS configuration so you can restore it.

### BookStack
#### Database Initialization & Shared Instance

BookStack and Guacamole use the same MySQL server to reduce resource use, but each has a separate database and a dedicated MySQL account with access limited to that database.

* **Automatic Schema Migration:** You do not need to provide any SQL schema for BookStack. The application handles migrations automatically upon first boot, provided that an empty database (`bookstack_db`) has been pre-created via `001-create-databases.sql`.
* **Generating `APP_KEY`:** Before deploying, generate the key with the BookStack image and set it in the stack's environment:
```bash
docker run -it --rm --entrypoint /bin/bash lscr.io/linuxserver/bookstack:latest appkey
```

The MySQL initialization scripts, including `004-create-app-users.sh`, only run when the MySQL data directory is first initialized. For an existing installation, create the two scoped accounts manually before changing the application stack credentials:

Open a MySQL session as an administrator:

```bash
docker exec -it mysql mysql -uroot -p
```

Then run the following statements, replacing the account names if customized and substituting the passwords. Escape any single quotes in SQL string values by doubling them.

```sql
CREATE USER 'guacamole'@'%' IDENTIFIED BY '<GUACAMOLE_DB_PASSWORD>';
GRANT ALL PRIVILEGES ON guacamole_db.* TO 'guacamole'@'%';
CREATE USER 'bookstack'@'%' IDENTIFIED BY '<BOOKSTACK_DB_PASSWORD>';
GRANT ALL PRIVILEGES ON bookstack_db.* TO 'bookstack'@'%';
```

Run the statements as a MySQL administrator, replacing the account names if `GUACAMOLE_DB_USER` or `BOOKSTACK_DB_USER` has been customized. Use passwords matching the application stack variables. After verifying that both applications connect successfully, remove the old shared `sqadmin` account if it is no longer needed.

## Kubernetes with k3s

The `k3s/` directory contains Kubernetes manifests assembled with Kustomize. This is a separate deployment from the Docker Compose setup above: it contains a different selection of services and has its own configuration, secrets, storage, and ingress requirements.

### k3s prerequisites

- A reachable k3s cluster and a `kubectl` context with permission to create namespaces, workloads, storage, and secrets.
- The k3s Traefik ingress controller enabled. The repository configures the bundled controller; it does not install Traefik itself.
- A default StorageClass or the `local-path` provisioner for PVCs that request it.
- A node named `ubuntu-server` with the expected local disk path and at least the requested capacity for the qBittorrent local PersistentVolume, or matching updates to its storage manifest.
- Hostnames and external DNS/tunnel routing configured for your environment.

Check the active cluster before applying anything:

```bash
kubectl config current-context
kubectl get nodes
kubectl get storageclass
```

### k3s repository layout

| Directory | Namespace / contents |
| --- | --- |
| `k3s/database/` | MySQL database, service, and persistent volume claim |
| `k3s/management/` | Cloudflare Tunnel and configuration for the k3s-managed Traefik dashboard |
| `k3s/dns/adguard/` | AdGuard Home, ingress, services, and persistent storage |
| `k3s/monitoring/` | Alloy, Loki, Prometheus, Grafana, and kube-state-metrics |
| `k3s/applications/` | BookStack and qBittorrent |

There is no root-level Kustomize entry point, so apply each component separately from the repository root.

### k3s secrets and configuration

Kustomize generators read component-specific environment files and turn them into Kubernetes Secrets or ConfigMaps. Review each `kustomization.yaml` to identify its source files and required variable names before deploying. These files are input to the manifests, not encrypted secret storage; Kubernetes Secret values are not protected merely because they are stored in a Secret resource.

The repository's `.gitignore` excludes untracked files matching `**/envs`; ignored files present on one workstation will not be included in a fresh clone. The rule does not remove files already tracked by Git. Create the local inputs required by the Kustomizations before building:

| Component | Local environment files to provide | Variables expected by the manifests |
| --- | --- | --- |
| Database | `k3s/database/envs/mysql-secrets.env` | `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD` |
| Management | `k3s/management/envs/.api_keys.env`, `k3s/management/envs/hosts.env` | `CLOUDFLARED_TUNNEL_TOKEN`, `TRAEFIK_HOST` |
| AdGuard | `k3s/dns/adguard/host.env` | `ADGUARD_HOST` |
| Grafana | `k3s/monitoring/grafana/envs/values.env` | `HOST` |
| qBittorrent | `k3s/applications/qbittorrent/envs/values.env` | `HOST`, `STORAGE_PATH`, `TZ` |
| BookStack | `k3s/applications/bookstack/envs/secrets.env`, `k3s/applications/bookstack/envs/values.env` | `APP_KEY`, `DB_USERNAME`, `DB_DATABASE`, `DB_PASSWORD`, `DB_HOST`, `APP_HOST`, `APP_URL`, `TZ` |

In particular, the BookStack, qBittorrent, and Grafana environment files listed above are local inputs and must be recreated on a new checkout. Do not copy real credentials into tracked files.

> **Credential hygiene:** Audit tracked files such as `k3s/database/envs/mysql-secrets.env` and `k3s/management/envs/.api_keys.env` before sharing or deploying this repository. If real credentials have been committed, rotate them and remove the secrets from the repository history; adding an ignore rule does not remove a file that is already tracked.

Do not commit real passwords, API tokens, or other credentials in environment files. Keep local secret files out of version control and use an encrypted secret-management workflow for shared deployments. Check that every file referenced by a generator exists before building or applying its component; a missing generator source prevents the Kustomize build.

Configure service hostnames, storage paths, and credentials in the inputs referenced by each component's Kustomization. In particular, qBittorrent's local PV is node- and path-specific, and BookStack requires both application and database configuration. Cloudflare Tunnel is started with a token, but this repository does not contain its public-hostname ingress rules; configure those in the Cloudflare side separately.
The k3s database uses its own `MYSQL_*` inputs and secret generation; do not assume it uses the Docker Compose database account variables.

### Deploying the k3s manifests

Run commands from the repository root. Apply the database first, then the ingress/tunnel configuration, DNS, monitoring, and applications:

```bash
kubectl apply -k k3s/database
kubectl -n database rollout status deployment/mysql --timeout=180s

kubectl apply -k k3s/management
kubectl apply -k k3s/dns/adguard
kubectl apply -k k3s/monitoring
kubectl apply -k k3s/applications
```

The readiness check is a useful gate before applying dependent applications. `kubectl apply -k` creates or updates resources, but it does not wait for dependencies across these separate Kustomizations; inspect pod and event status if a workload is not ready:

```bash
kubectl get pods -A
kubectl get events -A --sort-by=.metadata.creationTimestamp
```

Validate each component's rendered manifests before applying it. Check that generated ingress hosts and the qBittorrent PV path have been replaced with values for your cluster:

```bash
kubectl kustomize k3s/database
kubectl kustomize k3s/applications
```

Replace the component paths with others to validate those components. Ingress resources in this repository do not by themselves configure TLS. Confirm the Traefik and Cloudflare Tunnel routing and TLS behavior for your deployment before exposing services externally.

## Post-deployment and maintenance

### Permission Issues
If you encounter permission issues with volumes (especially in Monitoring or Guacamole stacks), ensure the directories on your host have the correct ownership. Many containers use UID `1000`.

### Database Backups
Back up the MySQL data volume, other named volumes, and host directories containing application data or configuration. This includes the configured Guacamole recordings directory and the Filebrowser directory mounted at `BROWSING_PATH`. The current Compose setup uses a Cloudflare Tunnel and does not configure Let's Encrypt or an `acme.json` file.

### Credentials and updates

Change default or first-login credentials before exposing services. In particular, replace the default Guacamole credentials immediately, and change the initial credentials for Grafana, Filebrowser, qBittorrent, and BookStack. Do not expose the AdGuard setup wizard publicly for longer than needed. Review image updates before deploying them; the Compose files use `latest` tags for several services.

##  Access to Services

Once all stacks are up, you can access your services at the following addresses. 
*Note: Replace `${HOST}` with your actual domain (e.g., example.com).*

| Service | URL | Credentials / notes |
| :--- | :--- | :--- |
| **Portainer** | `https://portainer.${HOST}` | Set during first login |
| **Traefik** | `https://traefik.${HOST}` | Protected by the `usersfile` Basic Auth file |
| **Grafana** | `https://grafana.${HOST}` | Change the initial admin password |
| **Prometheus** | `https://prometheus.${HOST}` | Protected by the `usersfile` Basic Auth file |
| **Alloy** | `https://alloy.${HOST}` | Protected by the `usersfile` Basic Auth file |
| **Filebrowser** | `https://fb.${HOST}` | Change the initial admin password |
| **Guacamole** | `https://guacamole.${HOST}` | Initial login: `guacadmin` / `guacadmin`; change it immediately |
| **AdGuard** | `https://adguard.${HOST}` | Create credentials during setup |
| **qBittorrent** | `https://qb.${HOST}` | Check container logs for the initial password |
| **Stirling-PDF** | `https://stirling.${HOST}` | No authentication is configured in this Compose file |
| **BookStack (Wiki)** | `https://wiki.${HOST}` | Change the default account password after first login |

To look for an initial password in a container's logs:

```bash
docker logs <container_name> 2>&1 | grep -i password
```

---

## Network Architecture

1. **Cloudflared Tunnel** provides an external entry point without requiring inbound web ports to be opened on the router.
2. **Traefik** acts as a reverse proxy and routes requests to containers by hostname.
3. **Docker networks** (`management`, `monitoring`, `applications`, `database`, and `guacd`) connect the services that need to communicate. Some services are attached to more than one network; these networks should not be described as fully isolated from one another.

---

## Disclaimer

This project is for **educational and personal home lab use only**. 
* **Use at your own risk:** I am not responsible for any data loss, hardware damage, or security breaches resulting from the use of these configurations.
* **Security:** Always review the Docker Compose files and scripts before deployment. Ensure your firewall and network settings are properly configured.
* **No Warranty:** This software is provided "as is", without warranty of any kind, express or implied.
