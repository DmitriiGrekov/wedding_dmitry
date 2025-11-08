# Управление развертыванием приложения

Этот документ описывает два способа развертывания приложения на сервере.

## 🔐 Вариант 1: С SSL сертификатами (Production)

Используйте для production развертывания с HTTPS.

### Требования:
- Домен должен указывать на IP сервера
- Порт 80 должен быть открыт для валидации Let's Encrypt
- Порты 80 и 443 должны быть открыты для работы приложения

### Запуск:
```bash
./init-letsencrypt.sh
```

### Что делает скрипт:
1. ✅ Проверяет переменные окружения (.env.prod)
2. ✅ Создает временный nginx для валидации домена
3. ✅ Тестирует доступность домена
4. ✅ Получает SSL сертификаты от Let's Encrypt
5. ✅ Запускает приложение с HTTPS

### Доступ к приложению:
- Сайт: `https://ваш-домен.ru`
- Admin: `https://ваш-домен.ru/admin/`
- API: `https://ваш-домен.ru/api/`

### Управление:
```bash
# Просмотр статуса
docker compose -f docker-compose.prod.yml ps

# Просмотр логов
docker compose -f docker-compose.prod.yml logs -f

# Перезапуск
docker compose -f docker-compose.prod.yml restart

# Остановка
docker compose -f docker-compose.prod.yml down
```

---

## 🌐 Вариант 2: Без SSL (HTTP only)

Используйте для:
- Тестирования на сервере
- Развертывания в закрытой сети
- Когда SSL не требуется или используется внешний SSL proxy

### Требования:
- Порт 80 должен быть открыт

### Запуск:
```bash
./init-http-only.sh
```

### Что делает скрипт:
1. ✅ Проверяет переменные окружения (.env.prod)
2. ✅ Создает HTTP-only nginx конфигурацию
3. ✅ Создает упрощенный docker-compose файл
4. ✅ Запускает приложение с HTTP

### Доступ к приложению:
- Сайт: `http://ваш-домен.ru` или `http://IP-адрес`
- Admin: `http://ваш-домен.ru/admin/`
- API: `http://ваш-домен.ru/api/`

### Управление:
```bash
# Просмотр статуса
docker compose -f docker-compose.http-only.yml ps

# Просмотр логов
docker compose -f docker-compose.http-only.yml logs -f

# Перезапуск
docker compose -f docker-compose.http-only.yml restart

# Остановка
docker compose -f docker-compose.http-only.yml down
```

---

## 📝 Подготовка перед развертыванием

### 1. Создайте .env.prod файл
```bash
cp env.prod.example .env.prod
nano .env.prod
```

### 2. Заполните обязательные переменные
```env
# Домен
DOMAIN=ваш-домен.ru

# Email для Let's Encrypt (только для SSL)
EMAIL=ваш-email@example.com

# База данных
POSTGRES_DB=wedding_db
POSTGRES_USER=wedding_user
POSTGRES_PASSWORD=ваш_сложный_пароль

# Django
SECRET_KEY=ваш_очень_длинный_и_случайный_ключ
```

### 3. Сгенерируйте SECRET_KEY
```bash
python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
```

---

## 🔄 Переключение между режимами

### Из HTTP на HTTPS:
```bash
# Остановить HTTP версию
docker compose -f docker-compose.http-only.yml down

# Запустить HTTPS версию
./init-letsencrypt.sh
```

### Из HTTPS на HTTP:
```bash
# Остановить HTTPS версию
docker compose -f docker-compose.prod.yml down

# Запустить HTTP версию
./init-http-only.sh
```

---

## 🐛 Устранение неполадок

### Проблема: Порт 80 уже занят
```bash
# Найти процесс, использующий порт
sudo netstat -tuln | grep :80
# или
sudo ss -tuln | grep :80

# Остановить все контейнеры
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.http-only.yml down
```

### Проблема: Let's Encrypt не может получить сертификат
```bash
# Проверить DNS
dig +short ваш-домен.ru

# Проверить доступность
curl -I http://ваш-домен.ru

# Проверить firewall
sudo ufw status

# Использовать staging режим для тестов
# Раскомментируйте в init-letsencrypt.sh:
# STAGING_ARG="--staging"
```

### Проблема: База данных не запускается
```bash
# Проверить логи
docker compose -f docker-compose.prod.yml logs db

# Пересоздать volumes (ВНИМАНИЕ: удалит данные!)
docker compose -f docker-compose.prod.yml down -v
```

---

## 📊 Мониторинг

### Просмотр логов всех сервисов:
```bash
docker compose -f docker-compose.prod.yml logs -f
```

### Просмотр логов конкретного сервиса:
```bash
docker compose -f docker-compose.prod.yml logs -f backend
docker compose -f docker-compose.prod.yml logs -f frontend
docker compose -f docker-compose.prod.yml logs -f nginx
docker compose -f docker-compose.prod.yml logs -f db
```

### Проверка использования ресурсов:
```bash
docker stats
```

---

## 🔒 Безопасность

### Для production обязательно:
- ✅ Используйте HTTPS (init-letsencrypt.sh)
- ✅ Используйте сильный SECRET_KEY
- ✅ Используйте сильный пароль базы данных
- ✅ Регулярно обновляйте образы Docker
- ✅ Настройте firewall (только порты 22, 80, 443)
- ✅ Включите автоматические обновления безопасности

### Настройка firewall (UFW):
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

---

## 📦 Обновление приложения

```bash
# Получить последние изменения
git pull

# Пересобрать и перезапустить (HTTPS)
docker compose -f docker-compose.prod.yml up -d --build

# Пересобрать и перезапустить (HTTP)
docker compose -f docker-compose.http-only.yml up -d --build

# Применить миграции базы данных (если есть)
docker compose -f docker-compose.prod.yml exec backend python manage.py migrate
```

---

## 🆘 Быстрые команды

### Полный перезапуск (HTTPS):
```bash
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml up -d --build
```

### Полный перезапуск (HTTP):
```bash
docker compose -f docker-compose.http-only.yml down
docker compose -f docker-compose.http-only.yml up -d --build
```

### Создание суперпользователя Django:
```bash
docker compose -f docker-compose.prod.yml exec backend python manage.py createsuperuser
```

### Очистка Docker (освобождение места):
```bash
docker system prune -a --volumes
```

**⚠️ ВНИМАНИЕ:** Эта команда удалит все неиспользуемые образы, контейнеры и volumes!

