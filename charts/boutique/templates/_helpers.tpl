{{- define "boutique.labels" -}}
app: {{ .svc.name }}
app.kubernetes.io/part-of: boutique
{{- end -}}
