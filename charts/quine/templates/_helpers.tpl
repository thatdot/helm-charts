{{/*
Expand the name of the chart.
*/}}
{{- define "quine.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "quine.fullname" -}}
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
{{- define "quine.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "quine.labels" -}}
helm.sh/chart: {{ include "quine.chart" . }}
{{ include "quine.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "quine.selectorLabels" -}}
app.kubernetes.io/name: {{ include "quine.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "quine.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "quine.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Persistence Config Section
*/}}
{{- define "quine.persistenceConfiguration" -}}
-Dquine.persistence.journal-enabled={{ .Values.persistence.journalEnabled }}
-Dquine.persistence.snapshot-schedule={{ .Values.persistence.snapshotSchedule }}
-Dquine.persistence.snapshot-singleton={{ .Values.persistence.snapshotSingleton }}
-Dquine.persistence.standing-query-schedule={{ .Values.persistence.standingQuerySchedule }}
-Dquine.persistence.effect-order={{ .Values.persistence.effectOrder }}
{{- end }}

{{/*
Store Config Section
*/}}
{{- define "quine.storeConfiguration" -}}
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
-Dquine.store.type=rocks-db
{{- end }}
{{- end }}

{{/*
Cassandra Auth Environment
*/}}
{{- define "quine.cassandraAuthEnv" -}}
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
Liveness and Readiness Probes
*/}}
{{- define "quine.probes" -}}
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
{{- end }}

{{/*
Metrics Configuration Section
*/}}
{{- define "quine.metricsConfiguration" -}}
{{- if .Values.metrics.influx.enabled }}
-Dquine.metrics-reporters.1.type=influxdb
-Dquine.metrics-reporters.1.database={{ .Values.metrics.influx.database }}
-Dquine.metrics-reporters.1.period={{ .Values.metrics.influx.period }}
-Dquine.metrics-reporters.1.scheme={{ .Values.metrics.influx.scheme }}
-Dquine.metrics-reporters.1.host={{ .Values.metrics.influx.host }}
-Dquine.metrics-reporters.1.port={{ .Values.metrics.influx.port }}
{{- end }}
{{- end }}
