{{- define "qbittorrent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "qbittorrent.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "qbittorrent.name" . -}}
{{- end -}}
{{- end -}}

{{- define "qbittorrent.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "qbittorrent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "qbittorrent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "qbittorrent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "qbittorrent.ingressHost" -}}
{{- if .Values.ingress.host -}}
{{- .Values.ingress.host -}}
{{- else -}}
{{- printf "%s.%s" .Values.ingress.subdomain .Values.ingress.domain -}}
{{- end -}}
{{- end -}}

{{- define "qbittorrent.configClaimName" -}}
{{- if .Values.persistence.config.existingClaim -}}
{{- .Values.persistence.config.existingClaim -}}
{{- else -}}
{{- .Values.persistence.config.claimName -}}
{{- end -}}
{{- end -}}

{{- define "qbittorrent.downloadsClaimName" -}}
{{- if .Values.persistence.downloads.existingClaim -}}
{{- .Values.persistence.downloads.existingClaim -}}
{{- else -}}
{{- .Values.persistence.downloads.claimName -}}
{{- end -}}
{{- end -}}
