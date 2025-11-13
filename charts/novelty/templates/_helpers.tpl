{{/*
Expand the name of the chart.
*/}}
{{- define "novelty.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "novelty.fullname" -}}
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
{{- define "novelty.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "novelty.labels" -}}
helm.sh/chart: {{ include "novelty.chart" . }}
{{ include "novelty.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "novelty.selectorLabels" -}}
app.kubernetes.io/name: {{ include "novelty.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
License Configuration Section
*/}}
{{- define "novelty.licenseConfiguration" -}}
{{- if .Values.licenseKey }}
-Dthatdot.novelty.license-key={{ .Values.licenseKey }}
{{- else }}
{{- fail "licenseKey is required. Please provide a valid license key from thatDot." }}
{{- end }}
{{- end }}

{{/*
OIDC Configuration Section
*/}}
{{- define "novelty.oidcConfiguration" -}}
{{- if .Values.oidc.enabled }}
{{- if not .Values.oidc.provider.locationUrl }}
{{- fail "oidc.provider.locationUrl is required when oidc.enabled is true" }}
{{- end }}
{{- if not .Values.oidc.provider.authorizationUrl }}
{{- fail "oidc.provider.authorizationUrl is required when oidc.enabled is true" }}
{{- end }}
{{- if not .Values.oidc.provider.tokenUrl }}
{{- fail "oidc.provider.tokenUrl is required when oidc.enabled is true" }}
{{- end }}
{{- if not .Values.oidc.provider.loginPath }}
{{- fail "oidc.provider.loginPath is required when oidc.enabled is true" }}
{{- end }}
{{- if not .Values.oidc.client.existingSecret.name }}
{{- fail "oidc.client.existingSecret.name is required when oidc.enabled is true" }}
{{- end }}
{{- if not .Values.oidc.session.autoGenerate }}
{{- if not .Values.oidc.session.existingSecret.name }}
{{- fail "oidc.session.existingSecret.name is required when oidc.enabled is true and autoGenerate is false" }}
{{- end }}
{{- if not .Values.oidc.session.existingSecret.key }}
{{- fail "oidc.session.existingSecret.key is required when oidc.enabled is true and autoGenerate is false" }}
{{- end }}
{{- end }}
-Dthatdot.novelty.auth.oidc.full.provider.location-url="{{ .Values.oidc.provider.locationUrl }}"
-Dthatdot.novelty.auth.oidc.full.provider.authorization-url="{{ .Values.oidc.provider.authorizationUrl }}"
-Dthatdot.novelty.auth.oidc.full.provider.token-url="{{ .Values.oidc.provider.tokenUrl }}"
-Dthatdot.novelty.auth.oidc.full.provider.login-path="{{ .Values.oidc.provider.loginPath }}"
-Dthatdot.novelty.auth.session.expiration-seconds={{ .Values.oidc.session.expirationSeconds }}
-Dthatdot.novelty.auth.session.secure-cookies={{ .Values.oidc.session.secureCookies }}
{{- end }}
{{- end }}

{{/*
Log Level Configuration Section
*/}}
{{- define "novelty.logLevelConfiguration" -}}
{{- if .Values.thatdot.logLevel }}
-Dthatdot.loglevel={{ .Values.thatdot.logLevel }}
{{- end }}
{{- end }}
