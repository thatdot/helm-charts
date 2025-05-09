{{/*
Ingress Annotations
*/}}
{{- define "quine-enterprise.ingressAnnotations" -}}
{{- if .Values.ingress.enabled -}}
{{ toYaml .Values.ingress.annotations }}
{{- end -}}
{{- end }}