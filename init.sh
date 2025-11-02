#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🎉 Инициализация Wedding Guest Management System${NC}"
echo ""

# Проверка наличия Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker не установлен${NC}"
    echo "Установите Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Проверка наличия Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose не установлен${NC}"
    echo "Установите Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}✅ Docker и Docker Compose установлены${NC}"
echo ""

# Создание .env файла
if [ ! -f .env ]; then
    echo -e "${YELLOW}📝 Создание .env файла...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✅ .env файл создан${NC}"
else
    echo -e "${GREEN}✅ .env файл уже существует${NC}"
fi
echo ""

# Сборка образов
echo -e "${YELLOW}🔨 Сборка Docker образов...${NC}"
docker-compose build
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Образы собраны${NC}"
else
    echo -e "${RED}❌ Ошибка при сборке образов${NC}"
    exit 1
fi
echo ""

# Запуск контейнеров
echo -e "${YELLOW}🚀 Запуск контейнеров...${NC}"
docker-compose up -d
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Контейнеры запущены${NC}"
else
    echo -e "${RED}❌ Ошибка при запуске контейнеров${NC}"
    exit 1
fi
echo ""

# Ожидание запуска базы данных
echo -e "${YELLOW}⏳ Ожидание запуска PostgreSQL...${NC}"
sleep 10

# Проверка здоровья БД
MAX_ATTEMPTS=30
ATTEMPT=0
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if docker-compose exec -T db pg_isready -U wedding_user &> /dev/null; then
        echo -e "${GREEN}✅ PostgreSQL готов к работе${NC}"
        break
    fi
    ATTEMPT=$((ATTEMPT+1))
    echo -n "."
    sleep 1
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo -e "${RED}❌ PostgreSQL не запустился за отведенное время${NC}"
    echo "Проверьте логи: docker-compose logs db"
    exit 1
fi
echo ""

# Применение миграций
echo -e "${YELLOW}🔄 Применение миграций Django...${NC}"
docker-compose exec -T backend python manage.py migrate
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Миграции применены${NC}"
else
    echo -e "${RED}❌ Ошибка при применении миграций${NC}"
    exit 1
fi
echo ""

# Сбор статических файлов
echo -e "${YELLOW}📦 Сбор статических файлов...${NC}"
docker-compose exec -T backend python manage.py collectstatic --noinput
echo -e "${GREEN}✅ Статические файлы собраны${NC}"
echo ""

# Создание суперпользователя (опционально)
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Проект успешно инициализирован!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}📍 Приложение доступно по следующим адресам:${NC}"
echo ""
echo -e "  ${GREEN}Frontend:${NC}     http://localhost"
echo -e "  ${GREEN}Backend API:${NC}  http://localhost/api/guests/"
echo -e "  ${GREEN}Admin Panel:${NC} http://localhost/admin/"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}⚠️  Не забудьте создать суперпользователя для доступа к админке:${NC}"
echo -e "  ${GREEN}docker-compose exec backend python manage.py createsuperuser${NC}"
echo ""
echo -e "или используйте команду:"
echo -e "  ${GREEN}make createsuperuser${NC}"
echo ""
echo -e "${YELLOW}📚 Полезные команды:${NC}"
echo -e "  ${GREEN}make help${NC}              - Показать все доступные команды"
echo -e "  ${GREEN}make logs${NC}              - Показать логи всех сервисов"
echo -e "  ${GREEN}make down${NC}              - Остановить контейнеры"
echo -e "  ${GREEN}make restart${NC}           - Перезапустить контейнеры"
echo -e "  ${GREEN}docker-compose ps${NC}      - Статус контейнеров"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎊 Готово! Приятной работы!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

