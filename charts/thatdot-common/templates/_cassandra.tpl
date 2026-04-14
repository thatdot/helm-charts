{{/*
Returns the Cassandra endpoints — auto-wired to the bundled instance or user-provided.
When bundled, points to the cassandra-db subchart service.

Usage: {{ include "thatdot-common.cassandraEndpoints" . }}
*/}}
{{- define "thatdot-common.cassandraEndpoints" -}}
{{- if and .Values.cassandra .Values.cassandra.bundled -}}
{{ .Release.Name }}-cassandra-db:9042
{{- else -}}
{{ .Values.cassandra.endpoints }}
{{- end -}}
{{- end }}

{{/*
Cassandra auth environment variables.
Auto-enables plaintext auth when cassandra is bundled.

Usage: {{ include "thatdot-common.cassandraAuthEnv" . | nindent 10 }}
*/}}
{{- define "thatdot-common.cassandraAuthEnv" -}}
{{- $bundled := and .Values.cassandra .Values.cassandra.bundled }}
{{- $plaintextEnabled := or .Values.cassandra.plaintextAuth.enabled $bundled }}
{{- if $plaintextEnabled }}
- name: CONFIG_FORCE_datastax__java__driver_advanced_auth__provider_class
  value: PlainTextAuthProvider
- name: CONFIG_FORCE_datastax__java__driver_advanced_auth__provider_username
  value: {{ .Values.cassandra.plaintextAuth.username }}
- name: CONFIG_FORCE_datastax__java__driver_advanced_auth__provider_password
{{- if and (not $bundled) .Values.cassandra.plaintextAuth.passwordExistingSecret }}
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
