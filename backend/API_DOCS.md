# API Documentation для Wedding Guest Management

## Установка и запуск

### Backend
```bash
cd backend
source ../env/bin/activate
pip install djangorestframework django-cors-headers
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser  # Создайте админ аккаунт
python manage.py runserver
```

## API Endpoints

### 1. Получить список всех гостей
**GET** `/api/guests/`

**Response:**
```json
[
    {
        "id": 1,
        "first_name": "Иван",
        "last_name": "Иванов"
    },
    {
        "id": 2,
        "first_name": "Мария",
        "last_name": "Петрова"
    }
]
```

### 2. Создать нового гостя
**POST** `/api/guests/`

**Request Body:**
```json
{
    "first_name": "Иван",
    "last_name": "Иванов"
}
```

**Response:**
```json
{
    "id": 1,
    "first_name": "Иван",
    "last_name": "Иванов"
}
```

### 3. Получить информацию о конкретном госте
**GET** `/api/guests/{id}/`

**Response:**
```json
{
    "id": 1,
    "first_name": "Иван",
    "last_name": "Иванов"
}
```

### 4. Обновить информацию о госте
**PUT** `/api/guests/{id}/`

**Request Body:**
```json
{
    "first_name": "Иван",
    "last_name": "Сидоров"
}
```

### 5. Удалить гостя
**DELETE** `/api/guests/{id}/`

**Response:** `204 No Content`

## Django Admin

Доступ к админке Django: `http://localhost:8000/admin/`

Функции админки:
- Просмотр списка всех гостей
- Поиск по имени и фамилии
- Фильтрация по фамилии
- Добавление/редактирование/удаление гостей

## Примеры использования (curl)

### Создать гостя:
```bash
curl -X POST http://localhost:8000/api/guests/ \
  -H "Content-Type: application/json" \
  -d '{"first_name": "Иван", "last_name": "Иванов"}'
```

### Получить список гостей:
```bash
curl http://localhost:8000/api/guests/
```

### Получить информацию о конкретном госте:
```bash
curl http://localhost:8000/api/guests/1/
```

### Обновить гостя:
```bash
curl -X PUT http://localhost:8000/api/guests/1/ \
  -H "Content-Type: application/json" \
  -d '{"first_name": "Иван", "last_name": "Сидоров"}'
```

### Удалить гостя:
```bash
curl -X DELETE http://localhost:8000/api/guests/1/
```

## Настройки CORS

В `settings.py` настроены следующие разрешенные источники:
- http://localhost:5173 (Vite default)
- http://localhost:3000
- http://127.0.0.1:5173
- http://127.0.0.1:3000

При необходимости добавьте дополнительные домены в `CORS_ALLOWED_ORIGINS`.

## Структура проекта

```
backend/
├── backend/
│   ├── settings.py      # Основные настройки
│   └── urls.py          # Главный URL конфиг
├── guests/
│   ├── models.py        # Модель Guest
│   ├── serializers.py   # Сериализатор для API
│   ├── views.py         # API views
│   ├── urls.py          # URL роуты для guests
│   └── admin.py         # Настройки Django Admin
└── manage.py
```

