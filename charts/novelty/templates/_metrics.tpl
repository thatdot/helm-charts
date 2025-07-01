{{/*
Prometheus Metrics Reporter Configuration
*/}}
{{- define "novelty.metricsJdkOptions" -}}
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
{{- if or .Values.metrics.jmx.enabled .Values.metrics.prometheus.enabled }}
-Dthatdot.novelty.metrics-reporters.2.type=jmx
{{- end }}
{{- end }}

{{/*
JMX Remote Settings
*/}}
{{- define "novelty.jmxJdkOptions" -}}
{{- if .Values.jmxRemote.enabled }}
-Dcom.sun.management.jmxremote
-Dcom.sun.management.jmxremote.port={{ .Values.jmxRemote.port }}
-Dcom.sun.management.jmxremote.rmi.port={{ .Values.jmxRemote.rmiPort }}
-Dcom.sun.management.jmxremote.local.only={{ .Values.jmxRemote.localOnly }}
-Dcom.sun.management.jmxremote.authenticate={{ .Values.jmxRemote.authenticate }}
-Dcom.sun.management.jmxremote.ssl={{ .Values.jmxRemote.ssl }}
-Djava.rmi.server.hostname={{ .Values.jmxRemote.rmiHostname }}
{{- end }}
{{- end }}