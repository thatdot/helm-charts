{{/*
Wait-for-keycloak init container. Polls the realm's OIDC discovery endpoint until it returns 200,
which means Keycloak is running AND the realm has been imported by keycloakConfigCli.
Only used when keycloak.bundled is true.

Usage: {{ include "thatdot-common.waitForKeycloakInitContainer" (dict "root" . "realmName" "novelty") | nindent 8 }}

Parameters:
  root      - root context (.)
  realmName - Keycloak realm name to wait for
*/}}
{{- define "thatdot-common.waitForKeycloakInitContainer" -}}
{{- $root := .root }}
{{- $realmName := .realmName }}
{{- if and $root.Values.keycloak $root.Values.keycloak.bundled }}
- name: wait-for-keycloak
  image: busybox:1.36
  command: ['sh', '-c']
  args:
    - |
      echo "Waiting for Keycloak realm '{{ $realmName }}' to be ready..."
      until wget -q --spider --no-check-certificate \
        "https://{{ $root.Release.Name }}-keycloak:8443/realms/{{ $realmName }}/.well-known/openid-configuration" 2>/dev/null; do
        echo "Keycloak not ready yet, retrying in 5s..."
        sleep 5
      done
      echo "Keycloak realm '{{ $realmName }}' is ready!"
{{- end }}
{{- end }}

{{/*
Truststore init container. Builds a Java truststore containing the bundled Keycloak's self-signed TLS cert.
Only used when keycloak.bundled is true.

Usage: {{ include "thatdot-common.truststoreInitContainer" . | nindent 8 }}
*/}}
{{- define "thatdot-common.truststoreInitContainer" -}}
{{- if and .Values.keycloak .Values.keycloak.bundled }}
- name: build-truststore
  image: eclipse-temurin:17-jdk
  command: ['sh', '-c']
  args:
    - |
      cp $JAVA_HOME/lib/security/cacerts /truststore/cacerts
      keytool -import -alias keycloak-tls \
        -file /certs/tls.crt \
        -keystore /truststore/cacerts \
        -storepass changeit -noprompt
  volumeMounts:
    - name: keycloak-cert
      mountPath: /certs
      readOnly: true
    - name: truststore
      mountPath: /truststore
{{- end }}
{{- end }}

{{/*
Truststore volumes. Mounts the bundled Keycloak's TLS cert secret and an emptyDir for the built truststore.
Only used when keycloak.bundled is true.

Usage: {{ include "thatdot-common.truststoreVolumes" . | nindent 8 }}
*/}}
{{- define "thatdot-common.truststoreVolumes" -}}
{{- if and .Values.keycloak .Values.keycloak.bundled }}
- name: keycloak-cert
  secret:
    secretName: {{ .Release.Name }}-keycloak-crt
    items:
      - key: tls.crt
        path: tls.crt
- name: truststore
  emptyDir: {}
{{- end }}
{{- end }}

{{/*
Truststore volumeMounts for the main container.
Only used when keycloak.bundled is true.

Usage: {{ include "thatdot-common.truststoreVolumeMounts" . | nindent 12 }}
*/}}
{{- define "thatdot-common.truststoreVolumeMounts" -}}
{{- if and .Values.keycloak .Values.keycloak.bundled }}
- name: truststore
  mountPath: /opt/custom-truststore
  readOnly: true
{{- end }}
{{- end }}

{{/*
Truststore JDK args for javax.net.ssl configuration.
Only emitted when keycloak.bundled is true.

Usage: {{ include "thatdot-common.truststoreJdkArgs" . }}
*/}}
{{- define "thatdot-common.truststoreJdkArgs" -}}
{{- if and .Values.keycloak .Values.keycloak.bundled }}
-Djavax.net.ssl.trustStore=/opt/custom-truststore/cacerts
-Djavax.net.ssl.trustStorePassword=changeit
-Djavax.net.ssl.trustStoreType=JKS
{{- end }}
{{- end }}
