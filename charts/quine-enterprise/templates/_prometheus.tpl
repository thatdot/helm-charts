{{/*
Prometheus Metrics Reporter Configuration
*/}}
{{- define "quine-enterprise.prometheusJdkOptions" -}}
{{- if .Values.metrics.prometheus.enabled }}
-javaagent:jmx_prometheus_javaagent.jar={{ .Values.metrics.prometheus.metricsReporterPort }}:/exporter.yaml
{{- end }}
{{- end }}


{{/*
Prometheus Service Port
*/}}
{{- define "quine-enterprise.prometheusServicePort" -}}
{{- if .Values.metrics.prometheus.enabled }}
- name: prometheus
  protocol: TCP
  port: {{ .Values.metrics.prometheus.metricsReporterPort }}
  targetPort: 9090
{{- end }}
{{- end }}

{{/*
Prometheus Annotations
*/}}
{{- define "quine-enterprise.prometheusAnnotations" -}}
{{- if .Values.metrics.prometheus.enabled -}}
prometheus.io/scrape: "true"
prometheus.io/port: "{{ .Values.metrics.prometheus.metricsReporterPort }}"
prometheus.io/path: "/metrics"
{{- end }}
{{- end }}