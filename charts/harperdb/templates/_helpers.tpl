{{/*
Expand the name of the chart.
*/}}
{{- define "harperdb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "harperdb.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "harperdb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "harperdb.labels" -}}
helm.sh/chart: {{ include "harperdb.chart" . }}
{{ include "harperdb.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "harperdb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "harperdb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "harperdb.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- .Values.serviceAccount.name | default (include "harperdb.fullname" . ) | quote }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create usernames and passwords for secretRef for Operations API access if needed
*/}}
{{- define "harperdb.secrets.ref" -}}
{{- .Values.existingSecretRef | default (include "harperdb.fullname" . ) }}
{{- end }}

{{- define "harperdb.secrets.username" -}}
{{ if and (.Release.IsInstall) (empty .Values.existingSecretRef) }}
{{- .Values.username | default (randAlpha 8) }}
{{- else }}
{{ with lookup "v1" "Secret" .Release.Namespace (include "harperdb.secrets.ref" . ) }}
{{ trim .data.HDB_ADMIN_USERNAME | b64dec | trim }}
{{- else }}
{{ default (randAlpha 8) }}
{{- end }}
{{- end }}
{{- end }}

{{- define "harperdb.secrets.password" -}}
{{- if and (.Release.IsInstall) (empty .Values.existingSecretRef) }}
{{- .Values.password | default (randAlphaNum 32) }}
{{- else }}
{{ with lookup "v1" "Secret" .Release.Namespace (include "harperdb.secrets.ref" . ) }}
{{ trim .data.HDB_ADMIN_PASSWORD | b64dec | trim }}
{{- else }}
{{ default (randAlpha 32) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create usernames and passwords for secretRef for Clustering if needed
*/}}
{{- define "harperdb.secrets.clustering.ref" -}}
{{- .Values.clustering.existingSecretRef | default (include "harperdb.fullname" . ) }}
{{- end }}

{{- define "harperdb.secrets.clustering.username" -}}
{{- if and (.Release.IsInstall) (empty .Values.clustering.existingSecretRef) }}
{{- .Values.clustering.username | default (randAlpha 8) }}
{{- else }}
{{- if empty .Values.clustering.existingSecretRef }}
{{ randAlpha 8 }}
{{- else }}
{{ with lookup "v1" "Secret" .Release.Namespace (include "harperdb.secrets.clustering.ref" . ) }}
{{ trim .data.CLUSTERING_USER | b64dec | trim }}
{{- else }}
{{ default (randAlpha 8) }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "harperdb.secrets.clustering.password" -}}
{{- if and (.Release.IsInstall) (empty .Values.clustering.existingSecretRef) }}
{{- .Values.clustering.password | default (randAlphaNum 32) }}
{{- else }}
{{- if empty .Values.clustering.existingSecretRef }}
{{ randAlphaNum 32 }}
{{- else }}
{{ with lookup "v1" "Secret" .Release.Namespace (include "harperdb.secrets.clustering.ref" . ) }}
{{ trim .data.CLUSTERING_PASSWORD | b64dec | trim }}
{{- else }}
{{ default (randAlpha 32) }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}