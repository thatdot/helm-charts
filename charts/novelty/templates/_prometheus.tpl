{{/*
Prometheus Metrics Reporter Configuration
*/}}
{{- define "novelty.prometheusJdkOptions" -}}
{{- if .Values.metrics.prometheus.enabled }}
-javaagent:jmx_prometheus_javaagent.jar={{ .Values.metrics.prometheus.port }}:/exporter.yaml
{{- end }}
{{- end }}

{{/*
Prometheus Annotations
*/}}
{{- define "novelty.prometheusAnnotations" -}}
{{- if .Values.metrics.prometheus.enabled -}}
prometheus.io/scrape: "true"
prometheus.io/port: "{{ .Values.metrics.prometheus.port }}"
prometheus.io/path: "/metrics"
{{- end }}
{{- end }}