{{/*
Prometheus Metrics Reporter Configuration
*/}}
{{- define "novelty.prometheusJdkOptions" -}}
{{- if .Values.metrics.prometheus.enabled }}
-javaagent:jmx_prometheus_javaagent.jar={{ .Values.metrics.prometheus.port }}:/exporter.yaml
{{- end }}
{{- if .Values.metrics.csv.enabled }}
-Dthatdot.novelty.metrics-reporters.0.type=csv
-Dthatdot.novelty.metrics-reporters.0.period={{ .Values.metrics.csv.period }}
-Dthatdot.novelty.metrics-reporters.0.log-directory={{ .Values.metrics.csv.log-directory }}
{{- end }}
{{- end }}

{{/*
Prometheus Annotations
*/}}
{{- define "novelty.prometheusAnnotations" -}}
{{- if .Values.metrics.prometheus.enabled -}}
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "{{ .Values.metrics.prometheus.port }}"
  prometheus.io/path: "/metrics"
{{- end }}
{{- end }}