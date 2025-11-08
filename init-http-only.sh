#!/bin/bash

# Скрипт для развертывания приложения БЕЗ SSL (только HTTP)
# Использование: ./init-http-only.sh

set -e  # Останавливаться при ошибках

echo "🚀 Развертывание приложения (HTTP-only, без SSL)"
echo "================================================"

# Проверка наличия .env.prod
if [ ! -f .env.prod ]; then
    echo "❌ Ошибка: файл .env.prod не найден!"
    echo "   Создайте файл .env.prod из примера:"
    echo "   cp env.prod.example .env.prod"
    echo "   И заполните необходимые переменные"
    exit 1
fi

# Загружаем переменные окружения
export $(cat .env.prod | grep -v '^#' | xargs)

# Определяем IP адрес сервера
SERVER_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || curl -s ifconfig.me 2>/dev/null || echo "unknown")

# Проверка обязательных переменных
if [ -z "$DOMAIN" ]; then
    echo "⚠️  Переменная DOMAIN не установлена"
    if [ "$SERVER_IP" != "unknown" ]; then
        DOMAIN="$SERVER_IP"
        echo "✅ Использую IP адрес: $DOMAIN"
    else
        DOMAIN="localhost"
        echo "✅ Использую: localhost"
    fi
else
    echo "✅ Домен: $DOMAIN"
fi

echo "✅ IP адрес сервера: $SERVER_IP"
echo "⚠️  Режим: HTTP только (без SSL)"
echo ""

# Останавливаем существующие контейнеры
echo "🛑 Остановка существующих контейнеров..."
docker compose -f docker-compose.prod.yml down 2>/dev/null || true

# Создаем директории
echo "📁 Создание директорий..."
mkdir -p nginx

# Создаем HTTP-only nginx конфигурацию
echo "🔧 Создание HTTP-only nginx конфигурации..."
cat > nginx/nginx.http-only.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent"';
    
    access_log /var/log/nginx/access.log main;
    
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 100M;

    upstream backend {
        server backend:8000;
    }

    upstream frontend {
        server frontend:80;
    }

    server {
        listen 80;
        server_name _;

        # Frontend - React приложение
        location / {
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # WebSocket support
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        # Backend API
        location /api/ {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_redirect off;
        }

        # Django Admin
        location /admin/ {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_redirect off;
        }

        # Статические файлы Django
        location /static/ {
            alias /app/staticfiles/;
            expires 30d;
            add_header Cache-Control "public, immutable";
        }

        # Медиа файлы Django
        location /media/ {
            alias /app/media/;
            expires 30d;
            add_header Cache-Control "public, immutable";
        }
    }
}
EOF

# Создаем docker-compose.http-only.yml
echo "🔧 Создание docker-compose конфигурации..."
cat > docker-compose.http-only.yml << EOF
version: '3.8'

services:
  # База данных PostgreSQL
  db:
    image: postgres:16-alpine
    container_name: wedding_db_http
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=\${POSTGRES_DB}
      - POSTGRES_USER=\${POSTGRES_USER}
      - POSTGRES_PASSWORD=\${POSTGRES_PASSWORD}
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U \${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - wedding_network

  # Backend Django
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: wedding_backend_http
    command: sh -c "python manage.py migrate && python manage.py collectstatic --noinput && gunicorn backend.wsgi:application --bind 0.0.0.0:8000 --workers 4 --timeout 120"
    volumes:
      - static_volume:/app/staticfiles
      - media_volume:/app/media
    expose:
      - "8000"
    environment:
      - DEBUG=False
      - SECRET_KEY=\${SECRET_KEY}
      - ALLOWED_HOSTS=\${DOMAIN},localhost,127.0.0.1
      - DATABASE_URL=postgresql://\${POSTGRES_USER}:\${POSTGRES_PASSWORD}@db:5432/\${POSTGRES_DB}
      - POSTGRES_DB=\${POSTGRES_DB}
      - POSTGRES_USER=\${POSTGRES_USER}
      - POSTGRES_PASSWORD=\${POSTGRES_PASSWORD}
      - POSTGRES_HOST=db
      - POSTGRES_PORT=5432
      - CORS_ALLOWED_ORIGINS=http://\${DOMAIN},http://localhost,http://127.0.0.1
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped
    networks:
      - wedding_network

  # Frontend React/Vite
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.prod
      args:
        - VITE_API_URL=http://\${DOMAIN}/api
    container_name: wedding_frontend_http
    expose:
      - "80"
    restart: unless-stopped
    networks:
      - wedding_network

  # Nginx Reverse Proxy (HTTP only)
  nginx:
    image: nginx:alpine
    container_name: wedding_nginx_http
    ports:
      - "80:80"
    volumes:
      - ./nginx/nginx.http-only.conf:/etc/nginx/nginx.conf:ro
      - static_volume:/app/staticfiles:ro
      - media_volume:/app/media:ro
    depends_on:
      - backend
      - frontend
    restart: unless-stopped
    networks:
      - wedding_network

volumes:
  postgres_data:
    driver: local
  static_volume:
  media_volume:

networks:
  wedding_network:
    driver: bridge
EOF

# Запускаем приложение
echo "🐳 Запуск приложения..."
docker compose -f docker-compose.http-only.yml up -d --build

echo ""
echo "⏳ Ожидание запуска сервисов..."
sleep 10

# Проверяем статус
echo "🔍 Проверка статуса сервисов..."
docker compose -f docker-compose.http-only.yml ps

echo ""
echo "🎉 Готово! Приложение развернуто."
echo "================================================"
echo "✅ Сайт доступен: http://$DOMAIN"
echo "✅ Admin панель: http://$DOMAIN/admin/"
echo "✅ API: http://$DOMAIN/api/"
echo ""
echo "⚠️  ВНИМАНИЕ: Приложение работает без SSL (только HTTP)"
echo "   Не используйте в production без SSL!"
echo ""
echo "🔍 Проверить сервисы:"
echo "   docker compose -f docker-compose.http-only.yml ps"
echo ""
echo "📋 Просмотреть логи:"
echo "   docker compose -f docker-compose.http-only.yml logs -f"
echo ""
echo "🛑 Остановить приложение:"
echo "   docker compose -f docker-compose.http-only.yml down"
echo ""
echo "🔐 Для развертывания с SSL используйте:"
echo "   ./init-letsencrypt.sh"
echo ""

