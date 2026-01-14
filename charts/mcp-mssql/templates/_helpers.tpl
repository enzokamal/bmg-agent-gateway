{{/*
MCP MSSQL labels
*/}}
{{- define "mcp-mssql.labels" -}}
app.kubernetes.io/name: mcp-mssql
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end }}

{{/*
MCP MSSQL selector labels
*/}}
{{- define "mcp-mssql.selectorLabels" -}}
app.kubernetes.io/name: mcp-mssql
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
MCP MSSQL required values
*/}}
{{- define "mcp-mssql.mssqlServer" -}}
{{- required "mssqlServer is required in values.yaml" .Values.deployment.env.mssqlServer -}}
{{- end }}

{{- define "mcp-mssql.mssqlDatabase" -}}
{{- required "mssqlDatabase is required in values.yaml" .Values.deployment.env.mssqlDatabase -}}
{{- end }}

{{- define "mcp-mssql.mssqlPort" -}}
{{- required "mssqlPort is required in values.yaml" (.Values.deployment.env.mssqlPort | toString) -}}
{{- end }}

{{- define "mcp-mssql.mssqlUser" -}}
{{- required "mssqlUser is required in values.yaml" .Values.deployment.env.mssqlUser -}}
{{- end }}

{{- define "mcp-mssql.mssqlPassword" -}}
{{- required "mssqlPassword is required in values.yaml" .Values.deployment.env.mssqlPassword -}}
{{- end }}

{{- define "mcp-mssql.image.repository" -}}
{{- default "kamalberrybytes/mssql-mcp" .Values.deployment.image.repository }}
{{- end }}

{{- define "mcp-mssql.image.tag" -}}
{{- default "latest" .Values.deployment.image.tag }}
{{- end }}

{{- define "mcp-mssql.image.pullPolicy" -}}
{{- default "Always" .Values.deployment.image.pullPolicy }}
{{- end }}