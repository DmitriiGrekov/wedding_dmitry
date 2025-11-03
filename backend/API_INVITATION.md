# API для работы с приглашениями

## Новый endpoint

### Получение приглашения по UUID

**URL:** `/api/guests/invitations/by-uuid/{uuid}/`  
**Метод:** `GET`  
**Описание:** Получение информации о приглашении по его UUID

#### Параметры

- `uuid` (в URL) - UUID приглашения

#### Пример запроса

```bash
GET http://localhost:8000/api/guests/invitations/by-uuid/550e8400-e29b-41d4-a716-446655440000/
```

#### Успешный ответ (200 OK)

```json
{
  "id": 1,
  "uuid": "550e8400-e29b-41d4-a716-446655440000",
  "guest_names": "Иван Иванов",
  "is_plural": false,
  "created_at": "2025-11-03T12:30:00.123456Z"
}
```

#### Ошибка - приглашение не найдено (404 Not Found)

```json
{
  "error": "Приглашение с таким UUID не найдено"
}
```

## Примеры использования

### cURL

```bash
# Одиночное приглашение
curl http://localhost:8000/api/guests/invitations/by-uuid/550e8400-e29b-41d4-a716-446655440000/

# С проверкой ошибок
curl -w "\n%{http_code}\n" http://localhost:8000/api/guests/invitations/by-uuid/550e8400-e29b-41d4-a716-446655440000/
```

### JavaScript (Fetch API)

```javascript
// Получение UUID из URL
const urlParams = new URLSearchParams(window.location.search);
const uuid = urlParams.get('uuid');

if (uuid) {
  fetch(`http://localhost:8000/api/guests/invitations/by-uuid/${uuid}/`)
    .then(response => {
      if (!response.ok) {
        throw new Error('Приглашение не найдено');
      }
      return response.json();
    })
    .then(data => {
      console.log('Имена гостей:', data.guest_names);
      console.log('Множественное число:', data.is_plural);
      
      const greeting = data.is_plural ? 'Дорогие' : 'Дорогой';
      console.log(`${greeting} ${data.guest_names}!`);
    })
    .catch(error => {
      console.error('Ошибка:', error);
    });
}
```

### Python (requests)

```python
import requests

uuid = "550e8400-e29b-41d4-a716-446655440000"
url = f"http://localhost:8000/api/guests/invitations/by-uuid/{uuid}/"

response = requests.get(url)

if response.status_code == 200:
    data = response.json()
    greeting = "Дорогие" if data['is_plural'] else "Дорогой"
    print(f"{greeting} {data['guest_names']}!")
else:
    print("Приглашение не найдено")
```

## Интеграция с фронтендом

Компонент `EventInfo.jsx` автоматически:

1. Извлекает UUID из URL параметра `?uuid=...`
2. Отправляет запрос на API
3. Отображает персонализированное приветствие

### Пример URL для гостей

```
http://localhost:5173/?uuid=550e8400-e29b-41d4-a716-446655440000
http://yourdomain.com/?uuid=550e8400-e29b-41d4-a716-446655440000
```

## Тестирование

### Создание тестового приглашения через Django Shell

```bash
cd backend
python manage.py shell
```

```python
from guests.models import Invitation

# Одиночное приглашение
invitation1 = Invitation.objects.create(
    guest_names="Иван Петров",
    is_plural=False
)
print(f"UUID: {invitation1.uuid}")
print(f"Ссылка: http://localhost:5173/?uuid={invitation1.uuid}")

# Множественное приглашение
invitation2 = Invitation.objects.create(
    guest_names="Иван и Мария Петровы",
    is_plural=True
)
print(f"UUID: {invitation2.uuid}")
print(f"Ссылка: http://localhost:5173/?uuid={invitation2.uuid}")
```

### Тестирование через браузер

1. Создайте приглашение в Django Admin
2. Скопируйте UUID
3. Откройте: `http://localhost:5173/?uuid=<ваш-uuid>`
4. Проверьте, что отображается правильное приветствие

## CORS

Убедитесь, что в `backend/backend/settings.py` настроен CORS для фронтенда:

```python
CORS_ALLOWED_ORIGINS = [
    "http://localhost:5173",
    "http://localhost:3000",
]
```

