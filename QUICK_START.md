# 🚀 Быстрая шпаргалка - Wedding Guest Management

## Первый запуск

```bash
# Автоматическая инициализация
./init.sh

# Или вручную
cp .env.example .env
docker-compose up -d
docker-compose exec backend python manage.py migrate
docker-compose exec backend python manage.py createsuperuser
```

## Доступ к приложению

- **Frontend**: http://localhost
- **API**: http://localhost/api/guests/
- **Admin**: http://localhost/admin/

## Основные команды

### Docker
```bash
make up           # Запустить
make down         # Остановить
make logs         # Логи
make restart      # Перезапустить
make build        # Пересобрать образы
make clean        # Удалить все (включая БД!)
```

### Django
```bash
make migrate              # Применить миграции
make makemigrations       # Создать миграции
make createsuperuser      # Создать админа
make shell                # Django shell
make bash                 # Bash в контейнере
```

### База данных
```bash
make db-shell             # PostgreSQL shell
make backup               # Создать backup
make restore FILE=...     # Восстановить backup
```

## API Примеры

### Создать гостя
```bash
curl -X POST http://localhost/api/guests/ \
  -H "Content-Type: application/json" \
  -d '{"first_name": "Иван", "last_name": "Иванов"}'
```

### Получить список
```bash
curl http://localhost/api/guests/
```

### Обновить гостя
```bash
curl -X PUT http://localhost/api/guests/1/ \
  -H "Content-Type: application/json" \
  -d '{"first_name": "Иван", "last_name": "Петров"}'
```

### Удалить гостя
```bash
curl -X DELETE http://localhost/api/guests/1/
```

## Структура проекта

```
wedding_dmitry/
├── docker-compose.yml    # Docker конфигурация
├── .env                  # Переменные окружения
├── init.sh               # Скрипт инициализации
├── Makefile              # Команды для управления
│
├── backend/              # Django Backend
│   ├── Dockerfile
│   ├── requirements.txt
│   └── guests/           # Приложение гостей
│
├── frontend/             # React Frontend
│   ├── Dockerfile
│   └── src/
│
└── nginx/                # Reverse Proxy
    ├── Dockerfile
    └── nginx.conf
```

## Разработка

### Backend локально
```bash
make dev-backend          # Запустить только БД
cd backend
source ../env/bin/activate
export POSTGRES_HOST=localhost
python manage.py runserver
```

### Frontend локально
```bash
cd frontend
npm install
npm run dev               # http://localhost:5173
```

## Troubleshooting

### Порт занят
```yaml
# docker-compose.yml
nginx:
  ports:
    - "8080:80"  # Вместо 80:80
```

### Пересоздать БД
```bash
make clean
make up
make migrate
```

### Проблемы с контейнерами
```bash
docker-compose ps         # Статус
docker-compose logs -f    # Все логи
docker-compose logs backend  # Логи backend
docker system prune -a    # Очистить Docker
```

## Документация

- [README.md](./README.md) - Основная документация
- [DOCKER_GUIDE.md](./DOCKER_GUIDE.md) - Подробное руководство по Docker
- [backend/README.md](./backend/README.md) - Backend документация
- [backend/API_DOCS.md](./backend/API_DOCS.md) - API документация

## Полезные ссылки

- Django Admin: http://localhost/admin/
- API Root: http://localhost/api/
- PostgreSQL: localhost:5432
- Frontend Dev: http://localhost:5173

## Переменные окружения (.env)

```env
DEBUG=True
SECRET_KEY=your-secret-key
POSTGRES_DB=wedding_db
POSTGRES_USER=wedding_user
POSTGRES_PASSWORD=wedding_password
VITE_API_URL=http://localhost/api
```

---

📚 Для полной документации: `make help` или читайте [DOCKER_GUIDE.md](./DOCKER_GUIDE.md)

