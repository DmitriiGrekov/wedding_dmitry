# Wedding Guest Management System

Система управления гостями на свадьбе с веб-интерфейсом и REST API.

## 🚀 Технологии

- **Backend**: Django 5.2.7 + Django REST Framework
- **Frontend**: React 18 + Vite
- **Database**: PostgreSQL 16
- **Reverse Proxy**: Nginx
- **Containerization**: Docker + Docker Compose

## 📋 Быстрый старт

### Вариант 1: Docker (рекомендуется)

```bash
# 1. Клонируйте репозиторий
git clone <repository-url>
cd wedding_dmitry

# 2. Создайте .env файл
cp .env.example .env

# 3. Запустите контейнеры
docker-compose up -d

# 4. Создайте суперпользователя
docker-compose exec backend python manage.py createsuperuser

# 5. Откройте браузер
# Frontend: http://localhost
# Admin: http://localhost/admin
# API: http://localhost/api/guests/
```

### Вариант 2: Локальная разработка

#### Backend

```bash
cd wedding_dmitry
python3 -m venv env
source env/bin/activate
cd backend
pip install -r requirements.txt
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

Backend будет доступен на http://localhost:8000

#### Frontend

```bash
cd wedding_dmitry/frontend
npm install
npm run dev
```

Frontend будет доступен на http://localhost:5173

## 📁 Структура проекта

```
wedding_dmitry/
├── docker-compose.yml          # Docker Compose конфигурация
├── .env.example                # Пример переменных окружения
├── DOCKER_GUIDE.md             # Подробная документация по Docker
│
├── backend/                    # Django Backend
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── README.md               # Backend документация
│   ├── API_DOCS.md             # API документация
│   ├── backend/
│   │   ├── settings.py
│   │   └── urls.py
│   └── guests/
│       ├── models.py
│       ├── serializers.py
│       ├── views.py
│       ├── urls.py
│       └── admin.py
│
├── frontend/                   # React Frontend
│   ├── Dockerfile
│   ├── package.json
│   ├── vite.config.js
│   └── src/
│       ├── App.jsx
│       ├── main.jsx
│       └── components/
│
└── nginx/                      # Nginx Reverse Proxy
    ├── Dockerfile
    └── nginx.conf
```

## 🔌 API Endpoints

### Гости

- `GET /api/guests/` - Получить список всех гостей
- `POST /api/guests/` - Создать нового гостя
- `GET /api/guests/{id}/` - Получить информацию о госте
- `PUT /api/guests/{id}/` - Обновить информацию о госте
- `DELETE /api/guests/{id}/` - Удалить гостя

**Пример запроса:**

```bash
curl -X POST http://localhost/api/guests/ \
  -H "Content-Type: application/json" \
  -d '{"first_name": "Иван", "last_name": "Иванов"}'
```

**Пример ответа:**

```json
{
  "id": 1,
  "first_name": "Иван",
  "last_name": "Иванов"
}
```

## 🐳 Docker команды

```bash
# Запуск
docker-compose up -d

# Остановка
docker-compose down

# Просмотр логов
docker-compose logs -f

# Пересборка образов
docker-compose up -d --build

# Выполнение команд Django
docker-compose exec backend python manage.py migrate
docker-compose exec backend python manage.py createsuperuser

# Доступ к базе данных
docker-compose exec db psql -U wedding_user -d wedding_db

# Создание backup БД
docker-compose exec db pg_dump -U wedding_user wedding_db > backup.sql
```

## 🔧 Конфигурация

### Переменные окружения (.env)

```env
# Django
DEBUG=True
SECRET_KEY=your-secret-key

# PostgreSQL
POSTGRES_DB=wedding_db
POSTGRES_USER=wedding_user
POSTGRES_PASSWORD=wedding_password

# Frontend
VITE_API_URL=http://localhost/api
```

### Архитектура с Nginx

```
Browser
   │
   ▼
Nginx (Port 80)
   ├── / → Frontend (React)
   ├── /api/ → Backend (Django)
   ├── /admin/ → Django Admin
   ├── /static/ → Django Static Files
   └── /media/ → Django Media Files
```

## 📖 Документация

- [Backend README](./backend/README.md) - Django Backend документация
- [API Documentation](./backend/API_DOCS.md) - Подробная API документация
- [Docker Guide](./DOCKER_GUIDE.md) - Полное руководство по Docker

## 🔍 Особенности

- ✅ REST API с Django REST Framework
- ✅ PostgreSQL база данных
- ✅ Docker containerization
- ✅ Nginx reverse proxy
- ✅ CORS настроен
- ✅ Django Admin панель
- ✅ React frontend с Vite
- ✅ Поддержка SQLite для локальной разработки
- ✅ Автоматические миграции при запуске

## 🛠 Разработка

### Backend разработка

```bash
# Запустите только БД в Docker
docker-compose up -d db

# Активируйте виртуальное окружение
source env/bin/activate

# Настройте переменные окружения
export POSTGRES_HOST=localhost
export POSTGRES_USER=wedding_user
export POSTGRES_PASSWORD=wedding_password
export POSTGRES_DB=wedding_db

# Запустите backend
cd backend
python manage.py runserver
```

### Frontend разработка

```bash
cd frontend
npm install
npm run dev
```

## 🚨 Troubleshooting

### Проблемы с БД

```bash
# Удалите volumes и начните заново
docker-compose down -v
docker-compose up -d
```

### Проблемы с миграциями

```bash
docker-compose exec backend python manage.py migrate --fake-initial
```

### Порт уже занят

Измените порты в `docker-compose.yml`:

```yaml
nginx:
  ports:
    - "8080:80"  # Вместо 80:80
```

## 📝 TODO

- [ ] Добавить поддержку загрузки фотографий гостей
- [ ] Добавить email уведомления
- [ ] Добавить export в Excel/CSV
- [ ] Добавить поиск и фильтрацию гостей
- [ ] Добавить CI/CD pipeline

## 📄 Лицензия

MIT

## 👨‍💻 Автор

Dmitrii Grekov

