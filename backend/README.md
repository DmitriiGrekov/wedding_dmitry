# Wedding Guest Management - Backend

API для управления списком гостей на свадьбе.

## Технологии

- Django 5.2.7
- Django REST Framework 3.16.1
- django-cors-headers 4.9.0
- SQLite (база данных)

## Установка

1. Создайте и активируйте виртуальное окружение:
```bash
cd wedding_dmitry
python3 -m venv env
source env/bin/activate
```

2. Установите зависимости:
```bash
cd backend
pip install -r requirements.txt
```

3. Примените миграции:
```bash
python manage.py migrate
```

4. (Опционально) Создайте суперпользователя для доступа к админке:
```bash
python manage.py createsuperuser
```

5. Запустите сервер:
```bash
python manage.py runserver
```

Сервер будет доступен по адресу: http://localhost:8000

## API Endpoints

### Гости

- `GET /api/guests/` - Получить список всех гостей
- `POST /api/guests/` - Создать нового гостя
- `GET /api/guests/{id}/` - Получить информацию о конкретном госте
- `PUT /api/guests/{id}/` - Обновить информацию о госте
- `DELETE /api/guests/{id}/` - Удалить гостя

### Django Admin

Административная панель Django доступна по адресу: http://localhost:8000/admin/

## Примеры использования

### Создать гостя
```bash
curl -X POST http://localhost:8000/api/guests/ \
  -H "Content-Type: application/json" \
  -d '{"first_name": "Иван", "last_name": "Иванов"}'
```

### Получить список гостей
```bash
curl http://localhost:8000/api/guests/
```

### Обновить гостя
```bash
curl -X PUT http://localhost:8000/api/guests/1/ \
  -H "Content-Type: application/json" \
  -d '{"first_name": "Иван", "last_name": "Сидоров"}'
```

### Удалить гостя
```bash
curl -X DELETE http://localhost:8000/api/guests/1/
```

## Структура проекта

```
backend/
├── backend/           # Настройки проекта
│   ├── settings.py   # Основные настройки
│   └── urls.py       # Главный URL конфиг
├── guests/           # Приложение для управления гостями
│   ├── models.py     # Модель Guest
│   ├── serializers.py # Сериализатор для API
│   ├── views.py      # API views
│   ├── urls.py       # URL роуты
│   └── admin.py      # Настройки админки
├── manage.py
├── requirements.txt
└── API_DOCS.md       # Подробная документация API
```

## CORS настройки

В файле `settings.py` настроены следующие разрешенные источники для CORS:
- http://localhost:5173 (Vite default port)
- http://localhost:3000
- http://127.0.0.1:5173
- http://127.0.0.1:3000

При необходимости добавьте дополнительные домены в `CORS_ALLOWED_ORIGINS`.

## Модель Guest

```python
class Guest(models.Model):
    first_name = models.CharField(max_length=255)
    last_name = models.CharField(max_length=255)
```

## Формат данных API

### Создание/обновление гостя
```json
{
    "first_name": "Иван",
    "last_name": "Иванов"
}
```

### Ответ
```json
{
    "id": 1,
    "first_name": "Иван",
    "last_name": "Иванов"
}
```

### Список гостей (с пагинацией)
```json
{
    "count": 3,
    "next": null,
    "previous": null,
    "results": [
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
}
```

## Дополнительная информация

Подробную документацию по API смотрите в файле [API_DOCS.md](./API_DOCS.md)

