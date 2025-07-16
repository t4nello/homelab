
# HomeLab Deployment with Ansible

This repository manages a modular HomeLab infrastructure using Ansible, Docker, and Portainer. It supports deploying multiple services such as monitoring, logging, file sharing, and remote access.

----------

##  Directory Structure

```
.
├── ansible.cfg
├── inventories
│   └── homelab
│       ├── group_vars
│       │   ├── common.yml
│       │   ├── ....
│		├── secrets
│       │   ├── management.yml
│       │   ├── ....
│       └── hosts
├── playbooks
│   ├── efk.yml
│   ├── ...
├── roles
│   ├── efk
│   ├── ...
├── secrets
│   ├── common.yml
│   ├── ---
```

----------

## Stack Overview

### 1. `efk` — Elasticsearch, Fluentd, Kibana

-   Collects and visualizes logs.
    
-   Requires Portainer Endpoint ID and deploy path.
    

### 2. `monitoring` — Grafana, Prometheus, Node Exporters

-   Monitors CPU, memory, disk, and container status.
    
-   Uses `GF_USER` variable (Grafana user).
    

### 3. `filebrowser` — File management UI

-   PUID, GUID, browsing and config paths defined.
    

### 4. `guacamole` — Remote Desktop Gateway

-   Exposes RDP/VNC via web UI.
    
-   Uses MySQL internally.
    

### 5. `pihole` — Network-wide DNS sinkhole

-   Timezone and optional DNS variables.
    

### 6. `torrent` — qBittorrent stack

-   Provides download interface.
    
-   Customizable config/download paths.
    

### 7. `management` — Portainer and other admin tools

-   Handles base configuration and stack bootstrapping.
    

----------

## Variable Files

### common.yml
| Name                  | Required? | Allowed Values           | Default Value | Description                                              |
|-----------------------|-----------|--------------------------|---------------|----------------------------------------------------------|
| HOST                  | YES       | valid domain or IP       |               | Domain or IP address of the host                         |
| TRAEFIK_ENTRYPOINT    | NO        | web / websecure          | websecure     | Entrypoint for the services                              |
| TRAEFIK_TLS           | NO        | true / false             | true          | Enable or disable TLS                                    |
| DEPLOY_PATH           | YES       | absolute filesystem path |               | Path where generated files from templates will be stored |
| PORTAINER_ENDPOINT_ID | NO        | integer                  | 1             | Portainer environment (endpoint) identifier              |
---
### management.yml
| Name               | Required? | Allowed Values | Default Value | Description                                                 |
|--------------------|-----------|----------------|---------------|-------------------------------------------------------------|
| PORTAINER\_EDITION | NO        | ce/ee          | ce            | Determines the community or enterprise version of Portainer | 
---

---

## Secrets
To generate secres you 

##  Deployment Instructions

###  Step-by-Step Stack Deployment

Each stack can be deployed individually:

```bash
ansible-playbook -i inventories/homelab playbooks/management.yml
ansible-playbook -i inventories/homelab playbooks/efk.yml
ansible-playbook -i inventories/homelab playbooks/monitoring.yml
ansible-playbook -i inventories/homelab playbooks/filebrowser.yml
ansible-playbook -i inventories/homelab playbooks/guacamole.yml
ansible-playbook -i inventories/homelab playbooks/pihole.yml
ansible-playbook -i inventories/homelab playbooks/torrent.yml

```

### Full Deployment Order (All Stacks)

```bash
# 1. Portainer and management tools
ansible-playbook -i inventories/homelab playbooks/management.yml

# 2. Logging and core services
ansible-playbook -i inventories/homelab playbooks/efk.yml

# 3. Monitoring stack
ansible-playbook -i inventories/homelab playbooks/monitoring.yml

# 4. Remaining application stacks
ansible-playbook -i inventories/homelab playbooks/filebrowser.yml
ansible-playbook -i inventories/homelab playbooks/guacamole.yml
ansible-playbook -i inventories/homelab playbooks/pihole.yml
ansible-playbook -i inventories/homelab playbooks/torrent.yml

```

You can also combine them in a shell script or makefile for automation.

----------

##  Notes

-   The `.env` files are templated using Ansible variables and injected dynamically before deploying to Portainer.
    
-   Each `docker-compose.yml` is rendered from a Jinja2 template stored in the role's `templates/` folder.
    
-   `portainer-auth` role handles dynamic token retrieval for secure stack deployments.
    
-   Elasticsearch and Kibana passwords are automatically reset and extracted after container boot.
    

----------

## Secrets Management

Secrets are stored in `secrets/*.yml` and imported in Ansible tasks with `lookup('file', ...)` or `vars_files`. Ensure these files are excluded in `.gitignore`.

----------

## Example Environment Variables

Example from `group_vars/efk.yml`:

```yaml
ENDPOINT_ID: 1

```

Example from `group_vars/filebrowser.yml`:

```yaml
PUID: 1000
GUID: 1000
BROWSING_PATH: /srv/files
CONFIG_PATH: /srv/filebrowser/config

```

For full variable reference, see [VARIABLES.md](https://chatgpt.com/c/VARIABLES.md) (optional split file).

----------

##  Support

This structure is maintained manually. For questions, raise an issue or contact the repository maintainer.