{{- define "bookstack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "bookstack.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "bookstack.name" . -}}
{{- end -}}
{{- end -}}

{{- define "bookstack.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "bookstack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "bookstack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "bookstack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "bookstack.ingressHost" -}}
{{- if .Values.ingress.host -}}
{{- .Values.ingress.host -}}
{{- else -}}
{{- printf "%s.%s" .Values.ingress.subdomain .Values.ingress.domain -}}
{{- end -}}
{{- end -}}

{{- define "bookstack.secretName" -}}
{{- if .Values.secret.existingSecret -}}
{{- .Values.secret.existingSecret -}}
{{- else -}}
{{- .Values.secret.name -}}
{{- end -}}
{{- end -}}

{{- define "bookstack.claimName" -}}
{{- if .Values.persistence.existingClaim -}}
{{- .Values.persistence.existingClaim -}}
{{- else -}}
{{- .Values.persistence.claimName -}}
{{- end -}}
{{- end -}}

{{- define "bookstack.appUrl" -}}
{{- if .Values.env.APP_URL -}}
{{- .Values.env.APP_URL -}}
{{- else -}}
{{- printf "https://%s" (include "bookstack.ingressHost" .) -}}
{{- end -}}
{{- end -}}
