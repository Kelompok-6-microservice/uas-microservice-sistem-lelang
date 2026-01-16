FROM python:3.10-slim

# Set environment variables agar Python tidak membuat file .pyc
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

# Install dependencies sistem jika perlu (misal untuk postgres)
RUN apt-get update && apt-get install -y libpq-dev gcc

# Copy requirements dahulu agar build lebih cepat (caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

# Menjalankan FastAPI menggunakan Uvicorn
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]