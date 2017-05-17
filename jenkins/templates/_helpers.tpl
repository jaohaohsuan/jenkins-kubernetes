{{/* vim: set filetype=mustache: */}}
{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "fullname" -}}
{{ printf "%s-%s" .Chart.Name .Release.Name | trunc 63 }}
{{- end -}}

{{- define "labels" -}}
heritage: {{ .Release.Service }}
release: {{ .Release.Name }}
chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "labels.master" -}}
component: master
app: {{ .Chart.Name }}
release: {{ .Release.Name }} 
{{- end -}}

{{- define "volumes.jobs" -}}
{{ printf "%s-jobs-%s" .Chart.Name .Release.Name | trunc 63 }}
{{- end -}}

{{- define "caches.pvc" -}}
{{- if .enabled }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ .name }} 
  annotations:
  	"helm.sh/resource-policy": keep
    volume.beta.kubernetes.io/storage-class: {{ .storageClass }}
spec:
  accessModes:
  - {{ .accessModes }}
  resources:
    requests:
      storage: {{ .size | quote }}
{{- end }}
{{- end -}}