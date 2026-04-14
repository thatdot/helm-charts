{{/*
OIDC credentials secret for bundled keycloak mode.
Creates a K8s Secret with the client-id and client-secret that match the bundled realm JSON.

Usage in product chart template (e.g., templates/oidc-credentials-secret.yaml):
  {{ include "thatdot-common.oidcCredentialsSecret" (dict "root" . "fullname" (include "quine-enterprise.fullname" .) "labels" (include "quine-enterprise.labels" .) "clientId" "quine-enterprise-client" "clientSecret" "bundled-eval-only-secret") }}

Parameters:
  root         - root context (.)
  fullname     - chart fullname for secret naming
  labels       - chart labels (pre-rendered string)
  clientId     - OIDC client ID matching the realm JSON
  clientSecret - OIDC client secret matching the realm JSON
*/}}
{{- define "thatdot-common.oidcCredentialsSecret" -}}
{{- if and .root.Values.keycloak .root.Values.keycloak.bundled }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ .fullname }}-oidc-credentials
  labels:
    {{- .labels | nindent 4 }}
type: Opaque
data:
  client-id: {{ .clientId | b64enc | quote }}
  client-secret: {{ .clientSecret | b64enc | quote }}
{{- end }}
{{- end }}
