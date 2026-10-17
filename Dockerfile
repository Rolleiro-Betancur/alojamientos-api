# Imagen basica de la API (propuesta de laboratorio ME2; no se pudo construir: sin daemon Docker)
FROM python:3.11-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
RUN useradd --create-home appuser && chown -R appuser /app
USER appuser
EXPOSE 5000
# Las variables (SECRET_KEY, DB_*, CORS_ALLOWED_ORIGINS) se inyectan en tiempo de ejecucion; NUNCA se copian en la imagen.
CMD ["flask", "--app", "app:crear_app", "run", "--host", "0.0.0.0", "--port", "5000"]
