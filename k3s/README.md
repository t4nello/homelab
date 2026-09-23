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
