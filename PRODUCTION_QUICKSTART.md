# 🚀 Быстрый старт Production

## Минимальные шаги для развертывания

### 1. Подготовка сервера

```bash
# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Установка Docker Compose
sudo apt install docker-compose-plugin -y

# Настройка Firewall
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp
sudo ufw enable
```

### 2. Клонирование и настройка

```bash
# Клонируем проект
git clone <your-repo-url> wedding
cd wedding

# Создаем конфигурацию
cp env.prod.example .env.prod
nano .env.prod
```

**Обязательно заполните:**
- `DOMAIN=your-domain.com`
- `EMAIL=your-email@example.com`
- `SECRET_KEY=` (сгенерируйте новый!)
- `POSTGRES_PASSWORD=` (надежный пароль)

### 3. Запуск

```bash
# Делаем скрипт исполняемым
chmod +x init-letsencrypt.sh

# Запускаем инициализацию
./init-letsencrypt.sh
```

Скрипт автоматически:
- ✅ Получит SSL сертификаты
- ✅ Настроит nginx
- ✅ Запустит все сервисы

### 4. Создание админа

```bash
docker compose -f docker-compose.prod.yml exec backend python manage.py createsuperuser
```

## ✅ Готово!

Ваш сайт доступен по адресу:
- 🌐 https://your-domain.com
- 🔧 https://your-domain.com/admin
- 📡 https://your-domain.com/api

## 📊 Полезные команды

```bash
# Просмотр логов
docker compose -f docker-compose.prod.yml logs -f

# Перезапуск сервисов
docker compose -f docker-compose.prod.yml restart

# Остановка
docker compose -f docker-compose.prod.yml down

# Обновление (после git pull)
docker compose -f docker-compose.prod.yml build
docker compose -f docker-compose.prod.yml up -d
```

## 📖 Подробная документация

См. [DEPLOYMENT.md](DEPLOYMENT.md) для полной инструкции.

## 🆘 Проблемы?

1. Проверьте DNS: `dig your-domain.com`
2. Проверьте порты: `sudo netstat -tulpn | grep :80`
3. Проверьте логи: `docker compose -f docker-compose.prod.yml logs`

---

**Важно:** Убедитесь, что DNS записи указывают на ваш сервер до запуска скрипта!

