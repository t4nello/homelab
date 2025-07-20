
# HomeLab

Set of docker-compose files for my home environment.

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

## Prerequisites

Before you start, ensure you have the following installed and configured:

- **Docker** and **Docker Compose** (compatible versions)
- **Ansible** (version >= 2.9 recommended)
- Access to the **Portainer API** with a valid API token
- Optional: **Ansible Vault** password stored securely for encrypted variables

## Vars

### all.yml

| Name                | Required? | Allowed Values         | Default Value | Description                                        |
| ------------------- | --------- | ---------------------- | ------------- | -------------------------------------------------- |
| HOST                | YES       | a valid domain address |               | Domain address                                     |
| TRAEFIK_ENTRYPOINT  | NO        | web/websecure          | websecure     | Entrypoint of the services                         |
| TRAEFIK_TLS        | NO        | true/false             | true          | Enable or disable TLS                              |
| DEPLOY_PATH        | YES       | absolute path          |               | deployment files directory                         |
| ENDPOINT_ID        | NO        | integer                | 1             | id of portainer environment (endpoint)             |

### filebrowser.yml

| Name           | Required? | Allowed Values        | Default Value | Description                         |
| -------------- | --------- | --------------------- | ------------- | ----------------------------------- |
| BROWSING_PATH  | YES       | absolute path         |               | Directory exposed for browsing      |
| PUID           | NO        | numeric UNIX user ID  | 1000          | User ID under which container runs  |
| PGID           | NO        | numeric UNIX group ID | 1000          | Group ID under which container runs |

### guacamole.yml

| Name                | Required? | Allowed Values    | Default Value | Description                               |
| ------------------- | --------- | ----------------- | ------------- | ----------------------------------------- |
| GUACAMOLE_DB_NAME   | YES       | valid DB name     |               | Name of the Guacamole database            |
| GUACAMOLE_DB_USER   | YES       | valid DB username |               | Database user with access to Guacamole DB |

### management.yml

| Name                    | Required? | Allowed Values       | Default Value | Description                  |
| ----------------------- | --------- | -------------------- | ------------- | ---------------------------- |
| PORTAINER_EDITION       | NO        | `ce` / `ee`          | ce            | Select Portainer edition     |

### guacamole vault variables

| Name                    | Required? | Description                                    |
| ----------------------- | --------- | ---------------------------------------------- |
| GUACAMOLE_DB_PASSWORD   | YES       | Password for the Guacamole database user       |
| MYSQL_ROOT_PASSWORD     | YES       | Root password for the internal MySQL container |

### management vault variables

| Name                    | Required?   | Description                                           |
| ----------------------- | ----------- | ----------------------------------------------------- |
| TUNNEL_TOKEN            | YES         | Cloudflare Tunnel token for the `cloudflared` service |
| PORTAINER_PASSWORD      | YES         | Admin password for the Portainer web UI               |
| PORTAINER_LICENCE_KEY   | YES (if EE) | License key required for Portainer Enterprise Edition |
| TRAEFIK_USERNAME        | YES         | Username for HTTP Basic Auth used by Traefik          |
| TRAEFIK_PASSWORD        | YES         | Password for HTTP Basic Auth used by Traefik          |

### Pi-hole vars

| Name                | Required? | Allowed Values | Default Value    | Description                   |
| ------------------- | --------- | -------------- | ---------------- | -----------------------------|
| TZ                  | NO        | valid timezone | Europe/Warsaw    | Timezone for Pi-hole logs     |
| PIHOLEWEBPASSWORD   | YES       | string         |                  | Admin password for Pi-hole UI |

### qBittorrent vars

| Name            | Required? | Allowed Values | Default Value | Description                         |
| --------------- | --------- | -------------- | ------------- | ----------------------------------- |
| DOWNLOADS_PATH  | YES       | absolute path  |               | Directory where downloads are saved |
| PUID            | NO        | numeric ID     | 1000          | User ID for qBittorrent process     |
| PGID            | NO        | numeric ID     | 1000          | Group ID for qBittorrent process    |

---

## Vault

Encrypt each vault file before deployment with:

```bash
ansible-vault encrypt group_vars/vault/management.yml -J
```

You will be prompted for a vault password. You can also use `--vault-password-file` for automation.

---

## Deployment

### 1. Clone the repository

```bash
git clone <repo_url>
```

### 2. Navigate to the project directory

```bash
cd homelab/
```

### 3. Deploy management stack first

```bash
ansible-playbook playbooks/deploy-management.yml --ask-become-pass -J
```

### 4. Deploy other stacks

You can deploy individual stacks by running:

```bash
ansible-playbook playbooks/deploy-<stack-name>.yml --ask-become-pass -J
```

Replace `<stack-name>` with one of: efk, filebrowser, guacamole, pihole, torrent, monitoring.

---

## Recommended deployment order

Due to service dependencies, deploy stacks in this order:

1. Management (Traefik, Portainer, Cloudflared)
2. EFK (logging stack)
3. Filebrowser
4. Guacamole
5. Pi-hole
6. Torrent
7. Monitoring

---

## Updating stacks

To update an existing stack, simply re-run the relevant playbook. Ansible will detect changes and redeploy the stack accordingly.

---

## Troubleshooting

- Verify your Portainer API token and endpoint ID if deployment fails.
- Ensure all required environment variables and Vault secrets are correctly set.
- Check Docker container logs for application-specific errors.
- Use verbose mode with Ansible for debugging:

```bash
ansible-playbook playbooks/deploy-management.yml -vvv --ask-become-pass -J
```

---

## Contributing

Contributions, issues, and feature requests are welcome! Feel free to open issues or pull requests to improve this project.

---

