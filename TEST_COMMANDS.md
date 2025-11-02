# 🧪 Тестовые команды для проверки Wedding Guest Management

## 1. Проверка готовности системы

```bash
# Проверить статус контейнеров
docker-compose ps

# Ожидаемый результат:
# wedding_backend     running
# wedding_frontend    running  
# wedding_db          running (healthy)
# wedding_nginx       running
```

## 2. Проверка базы данных

```bash
# Проверить подключение к PostgreSQL
docker-compose exec db pg_isready -U wedding_user

# Ожидаемый результат:
# /var/run/postgresql:5432 - accepting connections
```

```bash
# Проверить таблицы
docker-compose exec db psql -U wedding_user -d wedding_db -c "\dt"

# Должна быть таблица guests_guest
```

## 3. Проверка Backend API

```bash
# Тест 1: Создать гостя
curl -X POST http://localhost/api/guests/ \
  -H "Content-Type: application/json" \
  -d '{"first_name": "Тест", "last_name": "Тестов"}'

# Ожидаемый результат:
# {"id":1,"first_name":"Тест","last_name":"Тестов"}
```

```bash
# Тест 2: Получить список гостей
curl http://localhost/api/guests/

# Ожидаемый результат:
# {"count":1,"next":null,"previous":null,"results":[{"id":1,"first_name":"Тест","last_name":"Тестов"}]}
```

```bash
# Тест 3: Получить конкретного гостя
curl http://localhost/api/guests/1/

# Ожидаемый результат:
# {"id":1,"first_name":"Тест","last_name":"Тестов"}
```

```bash
# Тест 4: Обновить гостя
curl -X PUT http://localhost/api/guests/1/ \
  -H "Content-Type: application/json" \
  -d '{"first_name": "Иван", "last_name": "Иванов"}'

# Ожидаемый результат:
# {"id":1,"first_name":"Иван","last_name":"Иванов"}
```

```bash
# Тест 5: Удалить гостя
curl -X DELETE http://localhost/api/guests/1/

# Ожидаемый результат:
# HTTP 204 No Content
```

## 4. Проверка Frontend

```bash
# Открыть в браузере
open http://localhost

# Или
curl -I http://localhost
# Ожидаемый результат: HTTP/1.1 200 OK
```

## 5. Проверка Django Admin

```bash
# Открыть в браузере
open http://localhost/admin/

# Или
curl -I http://localhost/admin/
# Ожидаемый результат: HTTP/1.1 302 Found (редирект на логин)
```

## 6. Проверка логов

```bash
# Логи всех сервисов
docker-compose logs --tail=50

# Логи backend
docker-compose logs backend --tail=50

# Логи nginx
docker-compose logs nginx --tail=50

# Логи БД
docker-compose logs db --tail=50
```

## 7. Проверка volumes

```bash
# Проверить volumes
docker volume ls | grep wedding

# Ожидаемый результат:
# wedding_dmitry_postgres_data
# wedding_dmitry_static_volume
# wedding_dmitry_media_volume
```

## 8. Полный интеграционный тест

```bash
#!/bin/bash

echo "🧪 Запуск интеграционных тестов..."

# Создать тестовых гостей
echo "1. Создание гостей..."
curl -s -X POST http://localhost/api/guests/ \
  -H "Content-Type: application/json" \
  -d '{"first_name":"Иван","last_name":"Иванов"}' | jq

curl -s -X POST http://localhost/api/guests/ \
  -H "Content-Type: application/json" \
  -d '{"first_name":"Мария","last_name":"Петрова"}' | jq

curl -s -X POST http://localhost/api/guests/ \
  -H "Content-Type: application/json" \
  -d '{"first_name":"Алексей","last_name":"Сидоров"}' | jq

# Получить список
echo "2. Получение списка гостей..."
curl -s http://localhost/api/guests/ | jq '.results'

# Обновить гостя
echo "3. Обновление гостя..."
curl -s -X PUT http://localhost/api/guests/1/ \
  -H "Content-Type: application/json" \
  -d '{"first_name":"Иван","last_name":"Иванович"}' | jq

# Проверить обновление
echo "4. Проверка обновления..."
curl -s http://localhost/api/guests/1/ | jq

echo "✅ Все тесты пройдены!"
```

## 9. Проверка производительности

```bash
# Простой stress test
ab -n 100 -c 10 http://localhost/api/guests/

# Ожидаемый результат: успешное выполнение 100 запросов
```

## 10. Проверка резервного копирования

```bash
# Создать backup
make backup

# Проверить наличие backup файла
ls -lh backups/

# Восстановить из backup (осторожно!)
# make restore FILE=backups/backup-YYYYMMDD-HHMMSS.sql
```

## 11. Health Check

```bash
# Проверить health всех сервисов
docker-compose ps | grep healthy

# Ожидаемый результат: db должен быть healthy
```

## 12. Проверка CORS

```bash
# Проверить CORS headers
curl -I -X OPTIONS http://localhost/api/guests/ \
  -H "Origin: http://localhost:5173" \
  -H "Access-Control-Request-Method: GET"

# Должны быть заголовки:
# Access-Control-Allow-Origin: ...
# Access-Control-Allow-Methods: ...
```

## 13. Проверка миграций

```bash
# Проверить статус миграций
docker-compose exec backend python manage.py showmigrations

# Все миграции должны быть [X] applied
```

## 14. Проверка Django shell

```bash
# Открыть shell
docker-compose exec backend python manage.py shell

# В shell:
from guests.models import Guest
Guest.objects.count()
Guest.objects.all()
exit()
```

## 15. Финальная проверка

```bash
# Полная проверка системы
echo "🔍 Финальная проверка системы..."

echo "1. Статус контейнеров:"
docker-compose ps

echo "2. Проверка API:"
curl -s http://localhost/api/guests/ | jq '.count'

echo "3. Проверка frontend:"
curl -I http://localhost | grep "200 OK"

echo "4. Проверка admin:"
curl -I http://localhost/admin/ | grep "302 Found"

echo "5. Проверка БД:"
docker-compose exec db pg_isready -U wedding_user

echo "✅ Все проверки пройдены!"
```

## Troubleshooting

### Если контейнер не запускается

```bash
# Проверить логи
docker-compose logs [service_name]

# Пересоздать контейнер
docker-compose up -d --force-recreate [service_name]
```

### Если БД недоступна

```bash
# Проверить health
docker-compose ps db

# Перезапустить БД
docker-compose restart db

# Удалить и пересоздать
docker-compose down -v
docker-compose up -d
```

### Если API не отвечает

```bash
# Проверить логи backend
docker-compose logs backend

# Перезапустить backend
docker-compose restart backend

# Войти в контейнер
docker-compose exec backend bash
```

### Если nginx не работает

```bash
# Проверить конфигурацию
docker-compose exec nginx nginx -t

# Перезагрузить конфигурацию
docker-compose exec nginx nginx -s reload
```

## Мониторинг

```bash
# Использование ресурсов
docker stats

# Использование дискового пространства
docker system df

# Логи в реальном времени
docker-compose logs -f
```

---

**Примечание**: Некоторые команды требуют `jq` для форматирования JSON. Установите: `brew install jq` (macOS) или `apt-get install jq` (Linux).
