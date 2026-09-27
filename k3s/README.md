Before deploying, create the local (gitignored) files that Kustomize turns into Secrets/ConfigMaps:

For a Polish quick reference covering K3s, kubectl, pods, deployments, logs,
services, and networking, see [SCIAGA.md](./SCIAGA.md).

```bash
# ~/homelab/k3s/management/.env
CLOUDFLARED_TUNNEL_TOKEN=...
PORTAINER_LICENSE_KEY=...
```

```bash
# ~/homelab/k3s/management/host.env
TRAEFIK_HOST=traefik.tanello.site
PORTAINER_HOST=portainer.tanello.site
```

Create the ingress user for Traefik using:

```bash
htpasswd -Bc -C 6 ~/homelab/k3s/management/traefik/usersfile <username>
```

The Kustomization in `management/` automatically generates the `api-keys` Secret from `.env`,
the `traefik-dashboard-auth` Secret from `traefik/usersfile`, and the `host-config` ConfigMap
from `host.env` (and injects the hosts into the Portainer Ingress and Traefik dashboard route).

Deploy the management components using:

```bash
kubectl apply -k ~/homelab/k3s/management/
```

Restrict Traefik's Service to ClusterIP so it is only reachable through the Cloudflare Tunnel
(no LAN/NodePort/LoadBalancer access) using:

```bash
kubectl apply -k ~/homelab/k3s/traefik-config/
```

## Helm charts for applications

The `/home/runner/work/homelab/homelab/k3s/charts/` directory contains Helm charts for:

- `adguard`
- `bookstack`
- `qbittorrent`

Each chart exposes values for:

- environment variables
- ingress domain/subdomain or explicit host
- PV/PVC names, sizes, storage classes, and host paths
- container mount paths for persistent volumes

Examples:

```bash
helm upgrade --install adguard /home/runner/work/homelab/homelab/k3s/charts/adguard   --namespace applications --create-namespace   --set ingress.domain=example.com   --set ingress.subdomain=adguard   --set persistence.hostPath=/srv/k3s/applications/adguard
```

```bash
helm upgrade --install bookstack /home/runner/work/homelab/homelab/k3s/charts/bookstack   --namespace applications --create-namespace   --set ingress.domain=example.com   --set ingress.subdomain=wiki   --set env.DB_HOST=mysql.database.svc.cluster.local   --set persistence.hostPath=/srv/k3s/applications/bookstack   --set secret.values.APP_KEY='<app-key>'   --set secret.values.DB_PASSWORD='<db-password>'
```

```bash
helm upgrade --install qbittorrent /home/runner/work/homelab/homelab/k3s/charts/qbittorrent   --namespace applications --create-namespace   --set ingress.domain=example.com   --set ingress.subdomain=qb   --set persistence.config.hostPath=/srv/k3s/applications/qbittorrent   --set persistence.downloads.hostPath=/srv/samba/torrent
```

You can also create your own values file and override `env`, `ingress`, and `persistence` settings without editing templates.
