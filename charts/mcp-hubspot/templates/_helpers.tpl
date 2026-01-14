{{/*
MCP Hubspot labels
*/}}
{{- define "mcp-hubspot.labels" -}}
app.kubernetes.io/name: mcp-hubspot
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end }}

{{/*
MCP Hubspot selector labels
*/}}
{{- define "mcp-hubspot.selectorLabels" -}}
app.kubernetes.io/name: mcp-hubspot
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "mcp-hubspot.image.repository" -}}
{{- default "kamalberrybytes/mcp-hubspot" .Values.deployment.image.repository }}
{{- end }}

{{- define "mcp-hubspot.image.tag" -}}
{{- default "latest" .Values.deployment.image.tag }}
{{- end }}

{{- define "mcp-hubspot.image.pullPolicy" -}}
{{- default "Always" .Values.deployment.image.pullPolicy }}
{{- end }}