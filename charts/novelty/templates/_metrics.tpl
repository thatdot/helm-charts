{{/*
Prometheus Metrics Reporter Configuration
*/}}
{{- define "novelty.metricsJdkOptions" -}}
{{- if .Values.metrics.prometheus.enabled }}
-javaagent:jmx_prometheus_javaagent.jar={{ .Values.metrics.prometheus.port }}:/exporter.yaml
{{- end }}
{{- if .Values.metrics.csv.enabled }}
-Dthatdot.novelty.metrics-reporters.0.type=csv
-Dthatdot.novelty.metrics-reporters.0.period={{ .Values.metrics.csv.period }}
-Dthatdot.novelty.metrics-reporters.0.log-directory={{ .Values.metrics.csv.logDirectory }}
{{- end }}
{{- if .Values.metrics.influx.enabled }}
-Dthatdot.novelty.metrics-reporters.1.type=influxdb
-Dthatdot.novelty.metrics-reporters.1.database={{ .Values.metrics.influx.database }}
-Dthatdot.novelty.metrics-reporters.1.period={{ .Values.metrics.influx.period }}
-Dthatdot.novelty.metrics-reporters.1.scheme={{ .Values.metrics.influx.scheme }}
-Dthatdot.novelty.metrics-reporters.1.host={{ .Values.metrics.influx.host }}
-Dthatdot.novelty.metrics-reporters.1.port={{ .Values.metrics.influx.port }}
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