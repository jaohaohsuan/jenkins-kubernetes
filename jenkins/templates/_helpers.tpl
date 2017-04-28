{{/* vim: set filetype=mustache: */}}
{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "jenkins.service.name" -}}
{{ printf "%s-%s" .Chart.Name .Release.Name | trunc 63 }}
{{- end -}}
