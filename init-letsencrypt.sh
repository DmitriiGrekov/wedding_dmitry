#!/bin/bash

# Скрипт для первоначальной настройки Let's Encrypt SSL сертификатов
# Использование: ./init-letsencrypt.sh

set -e  # Останавливаться при ошибках

echo "🔐 Инициализация SSL сертификатов Let's Encrypt"
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

# Проверка обязательных переменных
if [ -z "$DOMAIN" ]; then
    echo "❌ Ошибка: переменная DOMAIN не установлена в .env.prod"
    exit 1
fi

if [ -z "$EMAIL" ]; then
    echo "❌ Ошибка: переменная EMAIL не установлена в .env.prod"
    exit 1
fi

echo "✅ Домен: $DOMAIN"
echo "✅ Email: $EMAIL"
echo ""

# Staging режим для тестирования (раскомментируйте для теста)
# STAGING_ARG="--staging"
STAGING_ARG=""

# Создаем директории для certbot
echo "📁 Создание директорий..."
mkdir -p nginx
mkdir -p certbot/conf
mkdir -p certbot/www

# Проверяем существующий сертификат
if [ -d "certbot/conf/live/$DOMAIN" ]; then
    echo "⚠️  Сертификат уже существует для $DOMAIN"
    read -p "   Заменить существующий сертификат? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "ℹ️  Отменено. Использую существующий сертификат."
        # Создаем финальную конфигурацию и перезапускаем
        sed "s/\${DOMAIN}/$DOMAIN/g" nginx/nginx.prod.conf > nginx/nginx.final.conf
        docker compose -f docker-compose.prod.yml down 2>/dev/null || true
        docker compose -f docker-compose.prod.yml up -d
        exit 0
    fi
    echo "🗑️  Удаление старого сертификата..."
fi

# Создаем временную nginx конфигурацию без SSL
echo "🔧 Создание временной nginx конфигурации..."
cat > nginx/nginx.temp.conf << EOF
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
    
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent"';
    
    access_log /var/log/nginx/access.log main;

    server {
        listen 80;
        server_name $DOMAIN www.$DOMAIN;
        
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }

        location / {
            return 200 'Certbot validation endpoint ready\n';
            add_header Content-Type text/plain;
        }
    }
}
EOF

# Временный docker-compose для получения сертификата
echo "🐳 Запуск временного nginx для валидации..."
docker compose -f docker-compose.prod.yml down 2>/dev/null || true

# Запускаем только nginx с временной конфигурацией
docker run -d \
    --name temp_nginx \
    -p 80:80 \
    -v "$(pwd)/nginx/nginx.temp.conf:/etc/nginx/nginx.conf:ro" \
    -v "$(pwd)/certbot/www:/var/www/certbot:ro" \
    nginx:alpine

echo "⏳ Ожидание запуска nginx..."
sleep 5

# Получаем сертификат
echo "🔐 Получение SSL сертификата от Let's Encrypt..."
docker run --rm \
    -v "$(pwd)/certbot/conf:/etc/letsencrypt" \
    -v "$(pwd)/certbot/www:/var/www/certbot" \
    certbot/certbot \
    certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    $STAGING_ARG \
    -d $DOMAIN \
    -d www.$DOMAIN

CERTBOT_EXIT_CODE=$?

# Останавливаем временный nginx
echo "🧹 Очистка временного контейнера..."
docker stop temp_nginx >/dev/null 2>&1 || true
docker rm temp_nginx >/dev/null 2>&1 || true

if [ $CERTBOT_EXIT_CODE -ne 0 ]; then
    echo "❌ Ошибка получения сертификата!"
    echo "   Проверьте:"
    echo "   1. DNS записи указывают на этот сервер"
    echo "   2. Порт 80 открыт в firewall"
    echo "   3. Домен доступен из интернета"
    exit 1
fi

echo "✅ Сертификат успешно получен!"

# Создаем финальную nginx конфигурацию с SSL
echo "🔧 Создание финальной nginx конфигурации..."
sed "s/\${DOMAIN}/$DOMAIN/g" nginx/nginx.prod.conf > nginx/nginx.final.conf

# Обновляем docker-compose для использования финальной конфигурации
echo "🐳 Запуск production сервисов..."
docker compose -f docker-compose.prod.yml up -d

echo ""
echo "🎉 Готово! SSL сертификаты установлены."
echo "================================================"
echo "✅ Сайт доступен: https://$DOMAIN"
echo "✅ Admin панель: https://$DOMAIN/admin/"
echo "✅ API: https://$DOMAIN/api/"
echo ""
echo "📝 Сертификаты будут автоматически обновляться каждые 12 часов"
echo ""
echo "🔍 Проверить сервисы:"
echo "   docker compose -f docker-compose.prod.yml ps"
echo ""
echo "📋 Просмотреть логи:"
echo "   docker compose -f docker-compose.prod.yml logs -f"

