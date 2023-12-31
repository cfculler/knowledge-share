apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "devops-knowledge-share-ui.fullname" . }}
  labels:
    {{- include "devops-knowledge-share-ui.labels" . | nindent 4 }}
  {{- with .Values.deployment.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "devops-knowledge-share-ui.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with .Values.deployment.pod.annotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{ if .Values.recreatePods }}
      annotations:
        autoUpdateImage: {{ randAlphaNum 5 | quote }}
      {{- end }}
      labels:
        {{- include "devops-knowledge-share-ui.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
        - name: {{ .Chart.Name }}
          image: {{ include "devops-knowledge-share-ui.container" . }}
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          env:
            - name: KNOWLEDGE_SHARE_API
              value: {{ .Values.apiURL }}
            {{ if .Values.featureFlags.enableImageURL }}
            - name: ENABLE_IMAGE_URL
              value: "true"
            {{ end }}
          ports:
            - name: http
              containerPort: 3000
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /api/health
              port: http
            initialDelaySeconds: 5
            periodSeconds: 5
          readinessProbe:
            httpGet:
              path: /api/health
              port: http
            initialDelaySeconds: 1
            periodSeconds: 1
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
