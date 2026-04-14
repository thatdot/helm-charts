{{/*
Returns "true" if OIDC is active (explicit or via bundled keycloak).
Usage: {{- if include "thatdot-common.oidcActive" . }}
*/}}
{{- define "thatdot-common.oidcActive" -}}
{{- if or .Values.oidc.enabled (and .Values.keycloak .Values.keycloak.bundled) -}}true{{- end -}}
{{- end }}

{{/*
Validate OIDC + bundled keycloak configuration.
Call this from product chart templates to fail fast on invalid config.
Usage: {{ include "thatdot-common.oidcValidation" . }}
*/}}
{{- define "thatdot-common.oidcValidation" -}}
{{- $keycloakBundled := and .Values.keycloak .Values.keycloak.bundled }}
{{- $oidcActive := or .Values.oidc.enabled $keycloakBundled }}
{{- if and $oidcActive (not $keycloakBundled) }}
{{- if not .Values.oidc.provider.locationUrl }}
{{- fail "oidc.provider.locationUrl is required when oidc.enabled is true" }}
{{- end }}
{{- if not .Values.oidc.provider.authorizationUrl }}
{{- fail "oidc.provider.authorizationUrl is required when oidc.enabled is true" }}
{{- end }}
{{- if not .Values.oidc.provider.tokenUrl }}
{{- fail "oidc.provider.tokenUrl is required when oidc.enabled is true" }}
{{- end }}
{{- if not .Values.oidc.provider.loginPath }}
{{- fail "oidc.provider.loginPath is required when oidc.enabled is true" }}
{{- end }}
{{- if not .Values.oidc.client.existingSecret.name }}
{{- fail "oidc.client.existingSecret.name is required when oidc.enabled is true and keycloak.bundled is false" }}
{{- end }}
{{- if not .Values.oidc.session.autoGenerate }}
{{- if not .Values.oidc.session.existingSecret.name }}
{{- fail "oidc.session.existingSecret.name is required when oidc.enabled is true and autoGenerate is false" }}
{{- end }}
{{- if not .Values.oidc.session.existingSecret.key }}
{{- fail "oidc.session.existingSecret.key is required when oidc.enabled is true and autoGenerate is false" }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Generate OIDC JDK args. Auto-wires URLs when keycloak is bundled, otherwise uses user-provided values.

Usage: {{ include "thatdot-common.oidcJdkArgs" (dict "root" . "jvmPrefix" "quine.auth" "realmName" "quine-enterprise") }}

Parameters:
  root      - root context (.)
  jvmPrefix - JVM property prefix (e.g. "quine.auth" or "thatdot.novelty.auth")
  realmName - Keycloak realm name (e.g. "quine-enterprise" or "novelty")
*/}}
{{- define "thatdot-common.oidcJdkArgs" -}}
{{- $root := .root }}
{{- $jvmPrefix := .jvmPrefix }}
{{- $realmName := .realmName }}
{{- $keycloakBundled := and $root.Values.keycloak $root.Values.keycloak.bundled }}
{{- $oidcActive := or $root.Values.oidc.enabled $keycloakBundled }}
{{- if $oidcActive }}
{{- if $keycloakBundled }}
-D{{ $jvmPrefix }}.oidc.full.provider.location-url="https://{{ $root.Release.Name }}-keycloak:8443/realms/{{ $realmName }}"
-D{{ $jvmPrefix }}.oidc.full.provider.authorization-url="https://{{ $root.Release.Name }}-keycloak:8443/realms/{{ $realmName }}/protocol/openid-connect"
-D{{ $jvmPrefix }}.oidc.full.provider.token-url="https://{{ $root.Release.Name }}-keycloak:8443/realms/{{ $realmName }}/protocol/openid-connect/token"
-D{{ $jvmPrefix }}.oidc.full.provider.login-path="auth"
{{- else }}
-D{{ $jvmPrefix }}.oidc.full.provider.location-url="{{ $root.Values.oidc.provider.locationUrl }}"
-D{{ $jvmPrefix }}.oidc.full.provider.authorization-url="{{ $root.Values.oidc.provider.authorizationUrl }}"
-D{{ $jvmPrefix }}.oidc.full.provider.token-url="{{ $root.Values.oidc.provider.tokenUrl }}"
-D{{ $jvmPrefix }}.oidc.full.provider.login-path="{{ $root.Values.oidc.provider.loginPath }}"
{{- end }}
-D{{ $jvmPrefix }}.session.expiration-seconds={{ $root.Values.oidc.session.expirationSeconds }}
-D{{ $jvmPrefix }}.session.secure-cookies={{ $root.Values.oidc.session.secureCookies }}
{{- end }}
{{- end }}

{{/*
Generate OIDC environment variables for the deployment container.
Handles both bundled (auto-generated secret) and manual (existingSecret) modes.

Usage: {{ include "thatdot-common.oidcEnvVars" (dict "root" . "envPrefix" "quine_auth" "fullname" (include "quine-enterprise.fullname" .)) }}

Parameters:
  root      - root context (.)
  envPrefix - env var prefix (e.g. "quine_auth" or "thatdot_novelty_auth")
  fullname  - chart fullname for auto-generated secret naming
*/}}
{{- define "thatdot-common.oidcEnvVars" -}}
{{- $root := .root }}
{{- $envPrefix := .envPrefix }}
{{- $fullname := .fullname }}
{{- $keycloakBundled := and $root.Values.keycloak $root.Values.keycloak.bundled }}
{{- $oidcActive := or $root.Values.oidc.enabled $keycloakBundled }}
{{- if $oidcActive }}
{{- if $keycloakBundled }}
- name: CONFIG_FORCE_{{ $envPrefix }}_oidc_full_client_id
  valueFrom:
    secretKeyRef:
      name: {{ $fullname }}-oidc-credentials
      key: client-id
- name: CONFIG_FORCE_{{ $envPrefix }}_oidc_full_client_secret
  valueFrom:
    secretKeyRef:
      name: {{ $fullname }}-oidc-credentials
      key: client-secret
{{- else if $root.Values.oidc.client.existingSecret.name }}
- name: CONFIG_FORCE_{{ $envPrefix }}_oidc_full_client_id
  valueFrom:
    secretKeyRef:
      name: {{ $root.Values.oidc.client.existingSecret.name }}
      key: {{ $root.Values.oidc.client.existingSecret.secretKeys.clientIdKey }}
- name: CONFIG_FORCE_{{ $envPrefix }}_oidc_full_client_secret
  valueFrom:
    secretKeyRef:
      name: {{ $root.Values.oidc.client.existingSecret.name }}
      key: {{ $root.Values.oidc.client.existingSecret.secretKeys.clientSecretKey }}
{{- end }}
{{- if $root.Values.oidc.session.autoGenerate }}
- name: CONFIG_FORCE_{{ $envPrefix }}_session_secret
  valueFrom:
    secretKeyRef:
      name: {{ $fullname }}-session-secret
      key: secret
{{- else if $root.Values.oidc.session.existingSecret.name }}
- name: CONFIG_FORCE_{{ $envPrefix }}_session_secret
  valueFrom:
    secretKeyRef:
      name: {{ $root.Values.oidc.session.existingSecret.name }}
      key: {{ $root.Values.oidc.session.existingSecret.key }}
{{- end }}
{{- end }}
{{- end }}
