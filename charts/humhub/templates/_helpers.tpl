{{/*
Expand the name of the chart.
*/}}
{{- define "humhub.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "humhub.pvcName" -}}
{{- default .Values.pvc.name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "humhub.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "humhub.env" -}}
- name: TZ
  value: {{ .Values.tz }}

# HTTP
- name: HUMHUB_PROTO
  value: {{ .Values.proto }}
- name: HUMHUB_HOST
  value: "{{ .Values.host }}"

# NGINX
- name: NGINX_CLIENT_MAX_BODY_SIZE
  value: {{ .Values.nginx.clientMaxBodySize | quote }}
- name: NGINX_KEEPALIVE_TIMEOUT
  value: {{ .Values.nginx.keepaliveTimeout | quote }}

# PHP
- name: PHP_POST_MAX_SIZE
  value: {{ .Values.php.postMaxSize | quote }}
- name: PHP_UPLOAD_MAX_FILESIZE
  value: {{ .Values.php.uploadMaxFilesize | quote }}
- name: PHP_MAX_EXECUTION_TIME
  value: {{ .Values.php.maxExecutionTime | quote }}
- name: PHP_MEMORY_LIMIT
  value: {{ .Values.php.memoryLimit | quote }}

# Database
- name: HUMHUB_DB_HOST
  value: {{ .Values.db.host | quote }}
- name: HUMHUB_DB_USER
  value: {{ .Values.db.user | quote }}
- name: HUMHUB_DB_PORT
  value: {{ .Values.db.port | quote }}
- name: HUMHUB_DB_NAME
  value: {{ .Values.db.name | quote }}
- name: HUMHUB_DB_PASSWORD
  valueFrom:
      secretKeyRef:
          key: {{ .Values.db.password.secretKey }}
          name: {{ .Values.db.password.secretName }}

# Redis
{{ if .Values.redis.enabled }}
- name: HUMHUB_CACHE_CLASS
  value: yii\redis\Cache
- name: HUMHUB_QUEUE_CLASS
  value: humhub\modules\queue\driver\Redis
- name: HUMHUB_REDIS_HOSTNAME
  value: {{ .Values.redis.host | quote }}
- name: HUMHUB_REDIS_PORT
  value: {{ .Values.redis.port | quote }}
- name: HUMHUB_REDIS_PASSWORD
  value: {{ .Values.redis.password | quote }}
{{ end }}

# todo: move it to an optional cronjob
- name: HUMHUB_INTEGRITY_CHECK
  value: "false"

- name: HUMHUB_REVERSEPROXY_WHITELIST
  value: '{{ join ";" .Values.reverseProxyAllowList }}'

- name: HUMHUB_CACHE_EXPIRE_TIME
  value: {{ .Values.cache.expireTime | quote }}

# Custom environment variables
{{ range $env := .Values.env }}
- {{ toJson $env }}
{{ end }}
{{ end }}

{{- define "humhub.mounts" -}}
{{- range $name, $path := .Values.defaults.mounts }}
{{- if $path }}
- mountPath: /var/www/localhost/htdocs/{{ $path }}
  name: data
  subPath: {{ $path }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "humhub.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "humhub.labels" -}}
helm.sh/chart: {{ include "humhub.chart" . }}
{{ include "humhub.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "humhub.selectorLabels" -}}
app.kubernetes.io/name: {{ include "humhub.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
