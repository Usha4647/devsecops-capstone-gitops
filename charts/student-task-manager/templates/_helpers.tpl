{{- define "stm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "stm.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "stm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "stm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "stm.labels" -}}
{{ include "stm.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: devsecops-capstone
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "stm.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}{{ include "stm.fullname" . }}{{- else -}}default{{- end -}}
{{- end -}}

{{/* Guard rails: fail rendering early with a clear message instead of a broken rollout. */}}
{{- define "stm.validate" -}}
{{- $tag := toString .Values.image.tag -}}
{{- if or (eq $tag "") (eq $tag "latest") -}}
{{- fail "image.tag must be an immutable tag (e.g. the 7-char commit SHA); empty and 'latest' are not allowed" -}}
{{- end -}}
{{- if eq $tag "replace-with-commit-sha" -}}
{{- fail "image.tag is still the placeholder: push to main in the app repo so CI publishes an image and updates this value" -}}
{{- end -}}
{{- if and .Values.autoscaling.enabled .Values.keda.enabled -}}
{{- fail "enable either autoscaling (HPA) or keda, not both: they would fight over replicas" -}}
{{- end -}}
{{- if and .Values.postgres.enabled (not .Values.postgres.existingSecret) -}}
{{- fail "postgres.enabled requires postgres.existingSecret (passwords never live in Git)" -}}
{{- end -}}
{{- end -}}

{{- define "stm.postgresName" -}}
{{- printf "%s-postgres" (include "stm.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
