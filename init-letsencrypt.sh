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
    -v "$(pwd)/certbot/www:/var/www/certbot" \
    nginx:alpine

echo "⏳ Ожидание запуска nginx..."
sleep 5

# Тестируем доступность nginx и webroot
echo "🧪 Тестирование доступности nginx..."
mkdir -p certbot/www/.well-known/acme-challenge
echo "test" > certbot/www/.well-known/acme-challenge/test.txt

echo "   Проверка доступности тестового файла локально..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/.well-known/acme-challenge/test.txt)
if [ "$RESPONSE" = "200" ]; then
    echo "   ✅ Nginx корректно отдает файлы из webroot (локально)"
else
    echo "   ❌ Nginx не может отдать тестовый файл локально (HTTP $RESPONSE)"
    echo "   Проверяем логи nginx..."
    docker logs temp_nginx 2>&1 | tail -20
    echo ""
    echo "   Проверяем содержимое webroot в контейнере..."
    docker exec temp_nginx ls -la /var/www/certbot/.well-known/acme-challenge/ || echo "Директория не существует"
    docker stop temp_nginx >/dev/null 2>&1 || true
    docker rm temp_nginx >/dev/null 2>&1 || true
    exit 1
fi

echo "   Проверка доступности через публичный домен..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN/.well-known/acme-challenge/test.txt)
if [ "$RESPONSE" = "200" ]; then
    echo "   ✅ Файлы доступны через публичный домен"
else
    echo "   ⚠️  ВНИМАНИЕ: Файлы не доступны через публичный домен (HTTP $RESPONSE)"
    echo "   Это может быть из-за:"
    echo "   - DNS еще не распространились"
    echo "   - Firewall блокирует порт 80"
    echo "   - Домен указывает на другой IP"
    echo ""
    echo "   Проверьте DNS:"
    echo "   $ dig +short $DOMAIN"
    echo ""
    echo "   Certbot скорее всего не сможет получить сертификат, но попробуем..."
fi

rm certbot/www/.well-known/acme-challenge/test.txt

# Получаем сертификат
echo "🔐 Получение SSL сертификата от Let's Encrypt..."
if [ -n "$STAGING_ARG" ]; then
    echo "   ⚠️  STAGING режим включен (тестовый сертификат)"
fi
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
    -v \
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
    echo ""
    echo "🔍 Диагностика:"
    echo "   1. Проверка DNS записей:"
    dig +short $DOMAIN
    dig +short www.$DOMAIN
    echo ""
    echo "   2. Проверка портов:"
    netstat -tuln | grep ':80 ' || ss -tuln | grep ':80 '
    echo ""
    echo "   3. Проверка доступности домена извне:"
    echo "      curl -I http://$DOMAIN"
    echo ""
    echo "   4. Содержимое webroot на хосте:"
    ls -la certbot/www/.well-known/acme-challenge/ 2>/dev/null || echo "      Директория пуста или не существует"
    echo ""
    echo "   5. Лог certbot:"
    if [ -f "certbot/conf/letsencrypt.log" ]; then
        tail -50 certbot/conf/letsencrypt.log
    else
        echo "      Лог не найден"
    fi
    echo ""
    echo "💡 Возможные причины:"
    echo "   • DNS записи не указывают на этот сервер (194.58.112.174)"
    echo "   • Порт 80 закрыт в firewall"
    echo "   • Домен недоступен из интернета"
    echo "   • Уже выпущено слишком много сертификатов (rate limit)"
    echo ""
    echo "🔧 Попробуйте:"
    echo "   • Проверить DNS: dig +short $DOMAIN"
    echo "   • Проверить firewall: sudo ufw status"
    echo "   • Проверить доступность: curl -I http://$DOMAIN"
    echo "   • Использовать staging режим для тестов (раскомментируйте STAGING_ARG в скрипте)"
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

