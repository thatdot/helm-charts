{{/*
Expand the name of the chart.
*/}}
{{- define "quine-enterprise.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "quine-enterprise.fullname" -}}
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
{{- define "quine-enterprise.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "quine-enterprise.labels" -}}
helm.sh/chart: {{ include "quine-enterprise.chart" . }}
{{ include "quine-enterprise.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "quine-enterprise.selectorLabels" -}}
app.kubernetes.io/name: {{ include "quine-enterprise.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "quine-enterprise.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "quine-enterprise.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Cluster Join Type
*/}}
{{- define "quine-enterprise.clusterJoinTypeConfiguration" -}}
{{- if gt (int .Values.hostCount) 1 }}
-Dquine.cluster.cluster-join.type=dns-entry 
{{- end }}
{{- end }}

{{/* 
Update Strategy
NOTE: A cluster can use a rolling update, but two different single hosts should
not share the persistor.
*/}}
{{- define "quine-enterprise.strategy" -}}
{{ if gt (int .Values.hostCount) 1 }} RollingUpdate
{{- else }} Recreate
{{- end}}
{{- end }}


{{/*
Persistence Config Section
*/}}
{{- define "quine-enterprise.persistenceConfiguration" -}}
-Dquine.persistence.journal-enabled={{ .Values.persistence.journalEnabled }}
-Dquine.persistence.snapshot-schedule={{ .Values.persistence.snapshotSchedule }}
-Dquine.persistence.snapshot-singleton={{ .Values.persistence.snapshotSingleton }}
-Dquine.persistence.standing-query-schedule={{ .Values.persistence.standingQuerySchedule }}
-Dquine.persistence.effect-order={{ .Values.persistence.effectOrder }}
{{- end }}

{{/*
Store Config Section
*/}}
{{- define "quine-enterprise.storeConfiguration" -}}
{{- if .Values.cassandra.enabled }}

-Dquine.store.type=cassandra
-Dquine.store.keyspace={{ .Values.cassandra.keyspace }}
-Dquine.store.should-create-keyspace={{ .Values.cassandra.shouldCreateKeyspace }}
-Dquine.store.should-create-tables={{ .Values.cassandra.shouldCreateTables }}
-Dquine.store.replication-factor={{ .Values.cassandra.replicationFactor }}
-Dquine.store.read-consistency={{ .Values.cassandra.readConsistency }}
-Dquine.store.write-consistency={{ .Values.cassandra.writeConsistency }}
-Dquine.store.local-datacenter={{ .Values.cassandra.localDatacenter }}
-Dquine.store.read-timeout={{ .Values.cassandra.readTimeout }}
-Dquine.store.write-timeout={{ .Values.cassandra.writeTimeout }}

{{- else }}
-Dquine.store.type=empty
{{- end }}
{{- end }}

{{/*
Cassandra Auth Environment
*/}}
{{- define "quine-enterprise.cassandraAuthEnv" -}}
{{- if .Values.cassandra.plaintextAuth.enabled }}
- name: CONFIG_FORCE_datastax__java__driver_advanced_auth__provider_class
  value: PlainTextAuthProvider
- name: CONFIG_FORCE_datastax__java__driver_advanced_auth__provider_username
  value: {{ .Values.cassandra.plaintextAuth.username }}
- name: CONFIG_FORCE_datastax__java__driver_advanced_auth__provider_password
{{- if .Values.cassandra.plaintextAuth.passwordExistingSecret }}
  valueFrom:
    secretKeyRef:
      name: {{ required "If using cassandra.plaintextAuth.passwordExistingSecret, name must be set"
               .Values.cassandra.plaintextAuth.passwordExistingSecret.name }}
      key: {{ required "If using cassandra.plaintextAuth.passwordExistingSecret, key must be set" 
              .Values.cassandra.plaintextAuth.passwordExistingSecret.key }}
{{- else }}
  value: {{ .Values.cassandra.plaintextAuth.password }}
{{- end }}
{{- end }}
{{- end }}

{{/*
NGINX Basic Auth
*/}}
{{- define "quine-enterprise.basicAuth" -}}
{{- if .Values.basicAuth.enabled }}
- name: USE_NGINX
  value: "true"
- name: USE_BASIC_AUTH
  value: "true"
{{- end }}
{{- end }}

{{/*
Basic Auth supporting volumes and volume mounts
*/}}
{{- define "quine-enterprise.basicAuthVolumes" }}
{{- if .Values.basicAuth.enabled }}
- name: credentials-volume
  secret:
    secretName: {{ include "quine-enterprise.fullname" . }}-credentials
{{- end }}
{{- end }}

{{- define "quine-enterprise.basicAuthVolumeMounts" }}
{{- if .Values.basicAuth.enabled }}
- name: credentials-volume
  readOnly: true
  mountPath: /credentials
{{- end }}
{{- end }}

{{/*
Liveness and Readiness Probes
*/}}
{{- define "quine-enterprise.probes" -}}
{{- if not .Values.basicAuth.enabled }}
livenessProbe:
  httpGet:
    path: /api/v1/admin/liveness
    port: 8080
  initialDelaySeconds: 5
  timeoutSeconds: 10
readinessProbe:
  httpGet:
    path: /api/v1/admin/liveness
    port: 8080
  initialDelaySeconds: 5
  timeoutSeconds: 10
{{- else }}
livenessProbe:
  exec:
    command:
    - curl
    - '--silent'
    - '--fail'
    - http://localhost:8081/api/v1/admin/liveness
  initialDelaySeconds: 5
readinessProbe:
  exec:
    command:
    - curl
    - '--silent'
    - '--fail'
    - http://localhost:8081/api/v1/admin/liveness
  initialDelaySeconds: 5
{{- end }}
{{- end }}

{{/*
Metrics Configuration Section
*/}}
{{- define "quine-enterprise.metricsConfiguration" -}}
{{- if .Values.metrics.influx.enabled }}
-Dquine.metrics-reporters.1.type=influxdb
-Dquine.metrics-reporters.1.database={{ .Values.metrics.influx.database }}
-Dquine.metrics-reporters.1.period={{ .Values.metrics.influx.period }}
-Dquine.metrics-reporters.1.scheme={{ .Values.metrics.influx.scheme }}
-Dquine.metrics-reporters.1.host={{ .Values.metrics.influx.host }}
-Dquine.metrics-reporters.1.port={{ .Values.metrics.influx.port }}
{{- end }}
{{- end }}

{{/*
License Configuration Section
*/}}
{{- define "quine-enterprise.licenseConfiguration" -}}
{{- if .Values.licenseKey }}
-Dquine.license-key={{ .Values.licenseKey }}
{{- else }}
{{- fail "licenseKey is required. Please provide a valid license key from thatDot." }}
{{- end }}
{{- end }}

{{/*
OIDC Configuration Section
*/}}
{{- define "quine-enterprise.oidcConfiguration" -}}
{{- if .Values.oidc.enabled }}
{{- if .Values.oidc.provider.locationUrl }}
-Dquine.auth.oidc.full.provider.location-url="{{ .Values.oidc.provider.locationUrl }}"
{{- end }}
{{- if .Values.oidc.provider.authorizationUrl }}
-Dquine.auth.oidc.full.provider.authorization-url="{{ .Values.oidc.provider.authorizationUrl }}"
{{- end }}
{{- if .Values.oidc.provider.tokenUrl }}
-Dquine.auth.oidc.full.provider.token-url="{{ .Values.oidc.provider.tokenUrl }}"
{{- end }}
{{- if .Values.oidc.provider.loginPath }}
-Dquine.auth.oidc.full.provider.login-path="{{ .Values.oidc.provider.loginPath }}"
{{- end }}
{{- if .Values.oidc.client.id }}
-Dquine.auth.oidc.full.client.id="{{ .Values.oidc.client.id }}"
{{- end }}
{{- if .Values.oidc.client.secret }}
-Dquine.auth.oidc.full.client.secret="{{ .Values.oidc.client.secret }}"
{{- end }}
{{- if .Values.oidc.session.autoGenerate }}
-Dquine.auth.session.secret="{{ include "quine-enterprise.generateSessionSecret" . }}"
{{- else if .Values.oidc.session.existingSecret.name }}
-Dquine.auth.session.secret="${OIDC_SESSION_SECRET}"
{{- else if .Values.oidc.session.secret }}
-Dquine.auth.session.secret="{{ .Values.oidc.session.secret }}"
{{- end }}
-Dquine.auth.session.expiration-seconds={{ .Values.oidc.session.expirationSeconds }}
-Dquine.auth.session.secure-cookies={{ .Values.oidc.session.secureCookies }}
{{- end }}
{{- end }}

{{/*
Generate a random alphanumeric session secret (32 characters)
This uses Helm's built-in randAlphaNum function to create a deterministic
random string that will remain constant for the lifetime of the release.
*/}}
{{- define "quine-enterprise.generateSessionSecret" -}}
{{- randAlphaNum 32 }}
{{- end }}
