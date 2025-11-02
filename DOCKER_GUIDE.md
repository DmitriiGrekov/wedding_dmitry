# Docker Deployment Guide

Полная инструкция по развертыванию проекта Wedding Guest Management с использованием Docker, PostgreSQL и Nginx.

## Архитектура

Проект состоит из следующих сервисов:

1. **PostgreSQL** (база данных) - порт 5432
2. **Django Backend** (REST API) - порт 8000
3. **React Frontend** (Vite) - порт 5173 (внутри контейнера порт 80)
4. **Nginx** (reverse proxy) - порт 80

```
┌─────────────────────────────────────────────┐
│            Nginx (Port 80)                   │
│         Reverse Proxy & Static Files        │
└────────┬──────────────────────┬──────────────┘
         │                      │
         ▼                      ▼
┌────────────────┐    ┌────────────────────┐
│    Frontend    │    │     Backend        │
│  React + Vite  │    │   Django + DRF     │
│   (Port 5173)  │    │    (Port 8000)     │
└────────────────┘    └─────────┬──────────┘
                                │
                                ▼
                      ┌────────────────────┐
                      │    PostgreSQL      │
                      │    (Port 5432)     │
                      └────────────────────┘
```

## Быстрый старт

### 1. Создайте файл .env

Скопируйте `.env.example` в `.env`:

```bash
cp .env.example .env
```

Отредактируйте `.env` файл при необходимости:

```env
# Django settings
DEBUG=True
SECRET_KEY=django-insecure-change-this-in-production-please

# Database settings
POSTGRES_DB=wedding_db
POSTGRES_USER=wedding_user
POSTGRES_PASSWORD=wedding_password

# API URL для frontend
VITE_API_URL=http://localhost/api
```

### 2. Запустите контейнеры

```bash
docker-compose up -d
```

Или для разработки с логами:

```bash
docker-compose up
```

### 3. Примените миграции и создайте суперпользователя

```bash
# Миграции применяются автоматически при запуске backend контейнера
# Но вы можете запустить их вручную:
docker-compose exec backend python manage.py migrate

# Создайте суперпользователя для доступа к админке
docker-compose exec backend python manage.py createsuperuser
```

### 4. Откройте приложение

- **Frontend**: http://localhost
- **Backend API**: http://localhost/api/guests/
- **Django Admin**: http://localhost/admin/
- **Backend напрямую**: http://localhost:8000/api/guests/

## Структура проекта

```
wedding_dmitry/
├── docker-compose.yml          # Главная конфигурация Docker
├── .env                        # Переменные окружения (не в git)
├── .env.example                # Пример переменных окружения
│
├── backend/
│   ├── Dockerfile              # Образ для Django
│   ├── .dockerignore           # Исключения для Docker
│   ├── requirements.txt        # Python зависимости
│   ├── manage.py
│   └── backend/
│       ├── settings.py         # Настройки (с поддержкой PostgreSQL)
│       └── urls.py
│
├── frontend/
│   ├── Dockerfile              # Образ для React (multi-stage)
│   ├── .dockerignore           # Исключения для Docker
│   ├── package.json
│   └── src/
│
└── nginx/
    ├── Dockerfile              # Образ для Nginx
    └── nginx.conf              # Конфигурация прокси
```

## Управление контейнерами

### Запуск

```bash
# Запуск всех сервисов
docker-compose up -d

# Запуск конкретного сервиса
docker-compose up -d backend

# Запуск с пересборкой образов
docker-compose up -d --build
```

### Остановка

```bash
# Остановить все сервисы
docker-compose stop

# Остановить и удалить контейнеры
docker-compose down

# Остановить и удалить контейнеры + volumes (БД будет удалена!)
docker-compose down -v
```

### Просмотр логов

```bash
# Логи всех сервисов
docker-compose logs -f

# Логи конкретного сервиса
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f db
docker-compose logs -f nginx
```

### Выполнение команд

```bash
# Django команды
docker-compose exec backend python manage.py migrate
docker-compose exec backend python manage.py createsuperuser
docker-compose exec backend python manage.py collectstatic

# Доступ к shell
docker-compose exec backend python manage.py shell
docker-compose exec backend bash

# Доступ к PostgreSQL
docker-compose exec db psql -U wedding_user -d wedding_db
```

### Пересборка образов

```bash
# Пересобрать все образы
docker-compose build

# Пересобрать конкретный сервис
docker-compose build backend

# Пересобрать без кеша
docker-compose build --no-cache
```

## Volumes (Хранилище данных)

Docker Compose создает следующие volumes:

- `postgres_data` - данные PostgreSQL (сохраняются между перезапусками)
- `static_volume` - статические файлы Django
- `media_volume` - загруженные медиа файлы

### Резервное копирование БД

```bash
# Создать backup
docker-compose exec db pg_dump -U wedding_user wedding_db > backup.sql

# Восстановить из backup
docker-compose exec -T db psql -U wedding_user wedding_db < backup.sql
```

## Конфигурация сервисов

### Backend (Django)

**Переменные окружения:**

- `DEBUG` - режим отладки (True/False)
- `SECRET_KEY` - секретный ключ Django
- `POSTGRES_DB` - имя базы данных
- `POSTGRES_USER` - пользователь БД
- `POSTGRES_PASSWORD` - пароль БД
- `POSTGRES_HOST` - хост БД (обычно `db`)
- `POSTGRES_PORT` - порт БД (обычно `5432`)

### Frontend (React)

**Переменные окружения:**

- `VITE_API_URL` - URL для обращения к API (через Nginx: `http://localhost/api`)

### Nginx

Nginx настроен как reverse proxy:

- `/` → Frontend (React app)
- `/api/` → Backend API
- `/admin/` → Django Admin
- `/static/` → Django статические файлы
- `/media/` → Django медиа файлы

## Production deployment

### 1. Обновите переменные окружения

```env
DEBUG=False
SECRET_KEY=your-super-secret-production-key-here
POSTGRES_PASSWORD=strong-production-password
```

### 2. Настройте HTTPS (опционально)

Добавьте SSL сертификаты в nginx конфигурацию:

```nginx
server {
    listen 443 ssl;
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    # ... остальная конфигурация
}
```

### 3. Используйте production WSGI сервер

Обновите `backend/Dockerfile`:

```dockerfile
# Установите gunicorn
RUN pip install gunicorn

# Измените CMD
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "backend.wsgi:application"]
```

### 4. Настройте автоматический backup БД

Добавьте в `docker-compose.yml`:

```yaml
services:
  backup:
    image: postgres:16-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./backups:/backups
    environment:
      - PGPASSWORD=${POSTGRES_PASSWORD}
    entrypoint: |
      bash -c 'while true; do
        pg_dump -h db -U ${POSTGRES_USER} -d ${POSTGRES_DB} > /backups/backup-$$(date +%Y%m%d-%H%M%S).sql
        sleep 86400
      done'
    depends_on:
      - db
```

## Troubleshooting

### Контейнер не запускается

```bash
# Проверьте логи
docker-compose logs backend

# Проверьте статус контейнеров
docker-compose ps
```

### База данных недоступна

```bash
# Проверьте, что PostgreSQL запустился
docker-compose ps db

# Проверьте логи БД
docker-compose logs db

# Проверьте подключение
docker-compose exec db pg_isready -U wedding_user
```

### Ошибки миграций

```bash
# Удалите базу данных и начните заново
docker-compose down -v
docker-compose up -d
docker-compose exec backend python manage.py migrate
```

### Проблемы с портами

Если порт 80 уже занят:

```yaml
# В docker-compose.yml измените порт nginx:
nginx:
  ports:
    - "8080:80"  # Теперь доступен на http://localhost:8080
```

### Очистка Docker системы

```bash
# Удалить неиспользуемые образы
docker image prune

# Удалить неиспользуемые volumes
docker volume prune

# Полная очистка (осторожно!)
docker system prune -a --volumes
```

## Разработка

### Локальная разработка с hot-reload

Для разработки frontend с hot-reload используйте:

```yaml
# В docker-compose.yml для frontend:
frontend:
  build: ./frontend
  volumes:
    - ./frontend:/app
    - /app/node_modules
  command: npm run dev -- --host
  ports:
    - "5173:5173"
  environment:
    - VITE_API_URL=http://localhost:8000/api
```

### Разработка backend

```bash
# Запустите только БД в Docker
docker-compose up -d db

# Запустите backend локально
cd backend
source ../env/bin/activate
export POSTGRES_HOST=localhost
python manage.py runserver
```

## Полезные команды

```bash
# Проверить использование ресурсов
docker stats

# Очистить старые образы
docker image prune -a

# Посмотреть размер образов
docker images

# Инспектировать контейнер
docker inspect wedding_backend

# Копировать файлы из контейнера
docker cp wedding_backend:/app/logs ./logs
```

## Дополнительные ресурсы

- [Django Documentation](https://docs.djangoproject.com/)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Nginx Documentation](https://nginx.org/en/docs/)

