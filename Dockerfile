# Stage 1: Build - Python para tests y compilación
FROM python:3.11-slim as builder

LABEL maintainer="devops-academia"
LABEL description="App calculadora - Curso DevOps"

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Ejecutar tests durante el build
RUN pytest tests/ -v

# Stage 2: Runtime - Nginx
FROM nginx:1.25-alpine

LABEL maintainer="devops-academia"
LABEL description="App calculadora - Nginx runtime"

# Crear usuario no root
RUN adduser -D -u 1000 appuser

# Copiar archivo de configuración de nginx si existe
COPY --chown=appuser:appuser nginx.conf /etc/nginx/nginx.conf || true

# Copiar contenido de la app si necesitas servir HTML/JS
COPY --from=builder --chown=appuser:appuser /app /usr/share/nginx/html

EXPOSE 80

USER appuser

CMD ["nginx", "-g", "daemon off;"]
