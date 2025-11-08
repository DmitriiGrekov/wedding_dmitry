#!/bin/bash

# Скрипт для управления развертыванием
# Использование: ./manage-deploy.sh [команда] [режим]

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция вывода с цветом
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Определяем режим (HTTPS или HTTP)
MODE=""
if [ -f "docker-compose.prod.yml" ] && [ "$(docker compose -f docker-compose.prod.yml ps -q 2>/dev/null | wc -l)" -gt 0 ]; then
    MODE="https"
    COMPOSE_FILE="docker-compose.prod.yml"
elif [ -f "docker-compose.http-only.yml" ] && [ "$(docker compose -f docker-compose.http-only.yml ps -q 2>/dev/null | wc -l)" -gt 0 ]; then
    MODE="http"
    COMPOSE_FILE="docker-compose.http-only.yml"
else
    # Проверяем последний запущенный
    if [ -f "docker-compose.http-only.yml" ]; then
        MODE="http"
        COMPOSE_FILE="docker-compose.http-only.yml"
    else
        MODE="https"
        COMPOSE_FILE="docker-compose.prod.yml"
    fi
fi

# Переопределяем режим, если передан аргумент
if [ "$2" == "https" ] || [ "$2" == "ssl" ]; then
    MODE="https"
    COMPOSE_FILE="docker-compose.prod.yml"
elif [ "$2" == "http" ] || [ "$2" == "no-ssl" ]; then
    MODE="http"
    COMPOSE_FILE="docker-compose.http-only.yml"
fi

# Функция показа помощи
show_help() {
    echo "Управление развертыванием Wedding App"
    echo "======================================"
    echo ""
    echo "Использование: ./manage-deploy.sh [команда] [режим]"
    echo ""
    echo "Команды:"
    echo "  status        - Показать статус сервисов"
    echo "  start         - Запустить приложение"
    echo "  stop          - Остановить приложение"
    echo "  restart       - Перезапустить приложение"
    echo "  logs          - Показать логи (Ctrl+C для выхода)"
    echo "  logs [service]- Показать логи конкретного сервиса"
    echo "  rebuild       - Пересобрать и перезапустить"
    echo "  clean         - Остановить и удалить все (без volumes)"
    echo "  clean-all     - Остановить и удалить все (включая volumes)"
    echo "  shell         - Открыть shell в backend контейнере"
    echo "  createsuperuser - Создать суперпользователя Django"
    echo "  migrate       - Применить миграции базы данных"
    echo "  collectstatic - Собрать статические файлы"
    echo "  stats         - Показать использование ресурсов"
    echo "  help          - Показать эту помощь"
    echo ""
    echo "Режимы:"
    echo "  https, ssl    - Использовать HTTPS режим (с SSL)"
    echo "  http, no-ssl  - Использовать HTTP режим (без SSL)"
    echo "  (по умолчанию определяется автоматически)"
    echo ""
    echo "Примеры:"
    echo "  ./manage-deploy.sh status           # Статус текущего режима"
    echo "  ./manage-deploy.sh restart https    # Перезапуск HTTPS версии"
    echo "  ./manage-deploy.sh logs backend     # Логи backend сервиса"
    echo "  ./manage-deploy.sh rebuild          # Пересборка"
    echo ""
}

# Функция проверки существования compose файла
check_compose_file() {
    if [ ! -f "$COMPOSE_FILE" ]; then
        print_error "Файл $COMPOSE_FILE не найден!"
        print_info "Запустите сначала:"
        if [ "$MODE" == "https" ]; then
            print_info "  ./init-letsencrypt.sh"
        else
            print_info "  ./init-http-only.sh"
        fi
        exit 1
    fi
}

# Основная логика
case "$1" in
    status)
        print_info "Режим: $MODE (файл: $COMPOSE_FILE)"
        check_compose_file
        docker compose -f $COMPOSE_FILE ps
        ;;
    
    start)
        print_info "Запуск приложения в режиме: $MODE"
        check_compose_file
        docker compose -f $COMPOSE_FILE up -d
        print_success "Приложение запущено"
        docker compose -f $COMPOSE_FILE ps
        ;;
    
    stop)
        print_info "Остановка приложения в режиме: $MODE"
        check_compose_file
        docker compose -f $COMPOSE_FILE down
        print_success "Приложение остановлено"
        ;;
    
    restart)
        print_info "Перезапуск приложения в режиме: $MODE"
        check_compose_file
        docker compose -f $COMPOSE_FILE restart
        print_success "Приложение перезапущено"
        docker compose -f $COMPOSE_FILE ps
        ;;
    
    logs)
        print_info "Логи приложения в режиме: $MODE"
        check_compose_file
        if [ -z "$2" ] || [ "$2" == "http" ] || [ "$2" == "https" ] || [ "$2" == "ssl" ] || [ "$2" == "no-ssl" ]; then
            docker compose -f $COMPOSE_FILE logs -f
        else
            docker compose -f $COMPOSE_FILE logs -f $2
        fi
        ;;
    
    rebuild)
        print_info "Пересборка и перезапуск в режиме: $MODE"
        check_compose_file
        docker compose -f $COMPOSE_FILE up -d --build
        print_success "Приложение пересобрано и перезапущено"
        docker compose -f $COMPOSE_FILE ps
        ;;
    
    clean)
        print_warning "Остановка и удаление контейнеров (volumes сохранятся)"
        check_compose_file
        docker compose -f $COMPOSE_FILE down
        print_success "Очистка завершена"
        ;;
    
    clean-all)
        print_warning "Остановка и удаление контейнеров и volumes"
        print_error "ВНИМАНИЕ: Это удалит все данные базы данных!"
        read -p "Продолжить? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            check_compose_file
            docker compose -f $COMPOSE_FILE down -v
            print_success "Полная очистка завершена"
        else
            print_info "Отменено"
        fi
        ;;
    
    shell)
        print_info "Открытие shell в backend контейнере"
        check_compose_file
        if [ "$MODE" == "https" ]; then
            docker compose -f $COMPOSE_FILE exec backend /bin/sh
        else
            docker compose -f $COMPOSE_FILE exec backend /bin/sh
        fi
        ;;
    
    createsuperuser)
        print_info "Создание суперпользователя Django"
        check_compose_file
        docker compose -f $COMPOSE_FILE exec backend python manage.py createsuperuser
        ;;
    
    migrate)
        print_info "Применение миграций базы данных"
        check_compose_file
        docker compose -f $COMPOSE_FILE exec backend python manage.py migrate
        print_success "Миграции применены"
        ;;
    
    collectstatic)
        print_info "Сборка статических файлов"
        check_compose_file
        docker compose -f $COMPOSE_FILE exec backend python manage.py collectstatic --noinput
        print_success "Статические файлы собраны"
        ;;
    
    stats)
        print_info "Использование ресурсов"
        docker stats --no-stream
        ;;
    
    help|--help|-h|"")
        show_help
        ;;
    
    *)
        print_error "Неизвестная команда: $1"
        echo ""
        show_help
        exit 1
        ;;
esac

