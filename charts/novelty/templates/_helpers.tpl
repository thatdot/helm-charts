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
{{- with .Values.oidc.provider.accessTokenAudience }}
-Dthatdot.novelty.auth.oidc.full.provider.access-token-audience="{{ . }}"
{{- end }}
{{- with .Values.oidc.provider.resourceUri }}
-Dthatdot.novelty.auth.oidc.full.provider.resource-uri="{{ . }}"
{{- end }}
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
{{- with .Values.thatdot.auditLogLevel }}
-Dthatdot.audit.loglevel={{ . }}
{{- end }}
{{- end }}

{{/*
Store Config Section
When cassandra is disabled nothing is set, leaving Novelty on its default store.
*/}}
{{- define "novelty.storeConfiguration" -}}
{{- if .Values.cassandra.enabled }}
-Dthatdot.novelty.store.type=cassandra
-Dthatdot.novelty.store.keyspace={{ .Values.cassandra.keyspace }}
-Dthatdot.novelty.store.should-create-keyspace={{ .Values.cassandra.shouldCreateKeyspace }}
-Dthatdot.novelty.store.should-create-tables={{ .Values.cassandra.shouldCreateTables }}
-Dthatdot.novelty.store.replication-factor={{ .Values.cassandra.replicationFactor }}
-Dthatdot.novelty.store.read-consistency={{ .Values.cassandra.readConsistency }}
-Dthatdot.novelty.store.write-consistency={{ .Values.cassandra.writeConsistency }}
-Dthatdot.novelty.store.local-datacenter={{ .Values.cassandra.localDatacenter }}
-Dthatdot.novelty.store.read-timeout={{ .Values.cassandra.readTimeout }}
-Dthatdot.novelty.store.write-timeout={{ .Values.cassandra.writeTimeout }}
{{- end }}
{{- end }}

{{/*
Cassandra Environment: endpoints and, if enabled, plaintext auth
*/}}
{{- define "novelty.cassandraEnv" -}}
{{- if .Values.cassandra.enabled }}
- name: CASSANDRA_ENDPOINTS
  value: {{ required "cassandra.endpoints is required when cassandra.enabled is true" .Values.cassandra.endpoints | quote }}
{{- if .Values.cassandra.plaintextAuth.enabled }}
- name: CONFIG_FORCE_datastax__java__driver_advanced_auth__provider_class
  value: PlainTextAuthProvider
- name: CONFIG_FORCE_datastax__java__driver_advanced_auth__provider_username
  value: {{ .Values.cassandra.plaintextAuth.username | quote }}
- name: CONFIG_FORCE_datastax__java__driver_advanced_auth__provider_password
{{- if .Values.cassandra.plaintextAuth.passwordExistingSecret }}
  valueFrom:
    secretKeyRef:
      name: {{ required "If using cassandra.plaintextAuth.passwordExistingSecret, name must be set"
               .Values.cassandra.plaintextAuth.passwordExistingSecret.name }}
      key: {{ required "If using cassandra.plaintextAuth.passwordExistingSecret, key must be set"
              .Values.cassandra.plaintextAuth.passwordExistingSecret.key }}
{{- else }}
  value: {{ .Values.cassandra.plaintextAuth.password | quote }}
{{- end }}
{{- end }}
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
