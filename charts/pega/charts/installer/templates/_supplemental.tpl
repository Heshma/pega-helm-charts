{{- /*
deploymentName
pegaRegistrySecret
imagePullSecrets
pegaVolumeCredentials
customArtifactorySSLVerificationEnabled
performDeployment
performInstallAndDeployment
performUpgradeAndDeployment
pega-db-secret-name
pega-hz-secret-name
deployDBSecret
deployNonExtDBSecret
secretResolver are copied from pega/templates/_helpers.tpl because helm lint requires
charts to render standalone. See: https://github.com/helm/helm/issues/11260 for more details.
*/}}


{{- define "deploymentName" }}{{ $deploymentNamePrefix := "pega" }}{{ if (.Values.global.deployment) }}{{ if (.Values.global.deployment.name) }}{{ $deploymentNamePrefix = .Values.global.deployment.name }}{{ end }}{{ end }}{{ $deploymentNamePrefix }}{{- end }}

{{- define "pegaVolumeCredentials" }}pega-volume-credentials{{- end }}

{{- define "initContainerResources" }}
  resources:
    # Resources requests/limits for initContainers
    requests:
      cpu: 50m
      memory: 64Mi
    limits:
      cpu: 50m
      memory: 64Mi
{{- end }}

{{- define "customArtifactorySSLVerificationEnabled" }}
{{- if (.Values.global.customArtifactory) }}
{{- if (.Values.global.customArtifactory.enableSSLVerification) }}
{{- if (eq .Values.global.customArtifactory.enableSSLVerification true) -}}
true
{{- else -}}
false
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "pegaRegistrySecret" }}
{{- $depName := printf "%s" (include "deploymentName" $) -}}
{{- $depName -}}-registry-secret
{{- end }}

{{- define "imagePullSecrets" }}
{{- if .Values.global.docker.registry }}
- name: {{ template "pegaRegistrySecret" $ }}
{{- end }}
{{- if (.Values.global.docker.imagePullSecretNames) }}
{{- range .Values.global.docker.imagePullSecretNames }}
- name: {{ . }}
{{- end -}}
{{- end -}}
{{- end -}}


{{- define "performDeployment" }}
  {{- if or (eq .Values.global.actions.execute "deploy") (eq .Values.global.actions.execute "install-deploy") (eq .Values.global.actions.execute "upgrade-deploy") -}}
    true
  {{- else -}}
    false
  {{- end -}}
{{- end }}

{{- define "performInstallAndDeployment" }}
  {{- if (eq .Values.global.actions.execute "install-deploy") -}}
    true
  {{- else -}}
    false
  {{- end -}}
{{- end }}

{{- define "performUpgradeAndDeployment" }}
  {{- if (eq .Values.global.actions.execute "upgrade-deploy") -}}
    true
  {{- else -}}
    false
  {{- end -}}
{{- end }}

{{- define "pega-db-secret-name" }}
{{- $depName := printf "%s" (include "deploymentName" $) -}}
{{- $depName -}}-db-secret
{{- end -}}

{{- define "pega-hz-secret-name" }}
{{- $depName := printf "%s" (include "deploymentName" $) -}}
{{- $depName -}}-hz-secret
{{- end -}}

{{- define "deployDBSecret" -}} 
true
{{- end }}

{{- define "deployNonExtDBSecret" }}
{{- if and (eq (include "deployDBSecret" .) "true") (not (.Values.global.jdbc).external_secret_name) -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{- define "deployArtifactorySecret" }}
{{- if or (eq (include "useBasicAuthForCustomArtifactory" .) "true") (eq (include "useApiKeyForCustomArtifactory" .) "true") (.Values.global.customArtifactory.authentication.external_secret_name) -}}
true
{{- else -}}
false
{{- end -}}
{{- end }}

{{- define "deployNonExtArtifactorySecret" }}
{{- if and (eq (include "deployArtifactorySecret" .) "true") (not (.Values.global.customArtifactory.authentication).external_secret_name) -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{- define "pega-custom-artifactory-secret-name" }}
{{- $depName := printf "%s" (include "deploymentName" $) -}}
{{- $depName -}}-artifactory-secret
{{- end -}}

{{- define "secretResolver" }}
{{- if (eq (include .deploySecret .context) "true") }}
- secret:
{{- if (eq (include .deployNonExtsecret .context) "true") }}
    name: {{ include .nonExtSecretName .context}}
{{- else }}
    name: {{ .extSecretName }}
{{- end -}}
{{- end -}}
{{- end  -}}