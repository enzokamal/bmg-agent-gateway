{{/*
Agent labels
*/}}
{{- define "agent.labels" -}}
app.kubernetes.io/name: agent
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end }}

{{/*
Agent selector labels
*/}}
{{- define "agent.selectorLabels" -}}
app.kubernetes.io/name: agent
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Agent config values
*/}}
{{- define "agent.agentMode" -}}
{{- default "api" .Values.configMap.agentMode }}
{{- end }}

{{- define "agent.agentPort" -}}
{{- default "8070" (.Values.configMap.agentPort | toString) }}
{{- end }}

{{- define "agent.agentHost" -}}
{{- default "0.0.0.0" .Values.configMap.agentHost }}
{{- end }}

{{- define "agent.mcpServersJson" -}}
{{- default (printf "[{\"url\":\"http://%s.%s.svc.cluster.local:8080/mcp/mcp-mssql\"}]" "agentgateway-proxy" .Values.namespace 8080) .Values.configMap.mcpServersJson }}
{{- end }}

{{- define "agent.deepseekApiKey" -}}
{{- required "secret.deepseekApiKey is required in values.yaml" .Values.secret.deepseekApiKey -}}
{{- end }}

{{- define "agent.configMap.name" -}}
{{- .Values.configMap.name | default "agent-config" -}}
{{- end }}

{{- define "agent.secret.name" -}}
{{- .Values.secret.name | default "agent-secrets" -}}
{{- end }}

{{- define "agent.image.repository" -}}
{{- default "sawnjordan/multi-agent" .Values.deployment.image.repository }}
{{- end }}

{{- define "agent.image.tag" -}}
{{- default .Chart.AppVersion .Values.deployment.image.tag }}
{{- end }}

{{- define "agent.image.pullPolicy" -}}
{{- default "IfNotPresent" .Values.deployment.image.pullPolicy }}
{{- end }}