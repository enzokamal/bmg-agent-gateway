{{/*
UI labels
*/}}
{{- define "ui.labels" -}}
app.kubernetes.io/name: ui
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end }}

{{/*
UI selector labels
*/}}
{{- define "ui.selectorLabels" -}}
app.kubernetes.io/name: ui
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
UI config values
*/}}
{{- define "ui.azureClientSecret" -}}
{{- required "secret.azureClientSecret is required in values.yaml" .Values.secret.azureClientSecret }}
{{- end }}

{{- define "ui.secretKey" -}}
{{- required "secret.secretKey is required in values.yaml" .Values.secret.secretKey }}
{{- end }}

{{- define "ui.secret.name" -}}
{{- .Values.secret.name | default "ui-secrets" -}}
{{- end }}

{{- define "ui.azureScopes" -}}
{{- required "deployment.env.azureScopes is required in values.yaml" .Values.deployment.env.azureScopes }}
{{- end }}

{{- define "ui.redirectUri" -}}
{{- required "deployment.env.redirectUri is required in values.yaml" .Values.deployment.env.redirectUri }}
{{- end }}

{{- define "ui.gatewayUrl" -}}
{{- default (printf "http://%s.%s.svc.cluster.local:8080" "agentgateway-proxy" .Values.namespace) .Values.deployment.env.gatewayUrl }}
{{- end }}

{{- define "ui.adkApi" -}}
{{- default (printf "http://%s.%s.svc.cluster.local:8070" "agent-service" .Values.namespace) .Values.deployment.env.adkApi }}
{{- end }}

{{- define "ui.image.repository" -}}
{{- default "kamalberrybytes/adk-web-ui" .Values.deployment.image.repository }}
{{- end }}

{{- define "ui.image.tag" -}}
{{- default "latest" .Values.deployment.image.tag }}
{{- end }}

{{- define "ui.image.pullPolicy" -}}
{{- default "Always" .Values.deployment.image.pullPolicy }}
{{- end }}