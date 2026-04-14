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
License Key Secret Validation Section
*/}}
{{- define "novelty.licenseKeyValidation" -}}
{{- if not .Values.licenseKeySecret.name }}
{{- fail "licenseKeySecret.name is required. Please provide a valid license key secret from thatDot." }}
{{- end }}
{{- if not .Values.licenseKeySecret.key }}
{{- fail "licenseKeySecret.key is required. Please specify the key containing the license key in the secret." }}
{{- end }}
{{- end }}

{{/*
OIDC Configuration Section (delegates to thatdot-common library)
*/}}
{{- define "novelty.oidcConfiguration" -}}
{{ include "thatdot-common.oidcValidation" . }}
{{ include "thatdot-common.oidcJdkArgs" (dict "root" . "jvmPrefix" "thatdot.novelty.auth" "realmName" "novelty") }}
{{- end }}

{{/*
Log Level Configuration Section
*/}}
{{- define "novelty.logLevelConfiguration" -}}
{{- if .Values.thatdot.logLevel }}
-Dthatdot.loglevel={{ .Values.thatdot.logLevel }}
{{- end }}
{{- end }}

{{/*
Webserver Config Section
*/}}
{{- define "novelty.webserverConfiguration" -}}
-Dthatdot.novelty.webserver.enabled={{ .Values.webserver.enabled }}
-Dthatdot.novelty.webserver.address={{ .Values.webserver.address }}
-Dthatdot.novelty.webserver.port={{ .Values.webserver.port }}
-Dthatdot.novelty.webserver.use-tls={{ .Values.webserver.useTls }}
-Dthatdot.novelty.webserver.use-mtls.enabled={{ .Values.webserver.useMTls.enabled }}
{{- if and .Values.webserver.useMTls.trustStore .Values.webserver.useMTls.trustStore.path .Values.webserver.useMTls.trustStore.password }}
-Dthatdot.novelty.webserver.use-mtls.trust-store.path={{ .Values.webserver.useMTls.trustStore.path }}
-Dthatdot.novelty.webserver.use-mtls.trust-store.password={{ .Values.webserver.useMTls.trustStore.password }}
{{- end }}
{{- if .Values.webserver.useMTls.healthEndpoints }}
-Dthatdot.novelty.webserver.use-mtls.health-endpoints.enabled={{ .Values.webserver.useMTls.healthEndpoints.enabled }}
-Dthatdot.novelty.webserver.use-mtls.health-endpoints.port={{ .Values.webserver.useMTls.healthEndpoints.port }}
{{- end }}
{{- end }}

{{/*
Webserver Advertise Config Section
*/}}
{{- define "novelty.webserverAdvertiseConfiguration" -}}
{{- if .Values.webserverAdvertise.enabled }}
{{- if .Values.webserverAdvertise.address }}
-Dthatdot.novelty.webserver-advertise.address={{ .Values.webserverAdvertise.address }}
{{- end }}
{{- if .Values.webserverAdvertise.port }}
-Dthatdot.novelty.webserver-advertise.port={{ .Values.webserverAdvertise.port }}
{{- end }}
{{- end }}
{{- end }}
