.PHONY: help build up down logs restart clean migrate createsuperuser shell db-shell backup restore

help: ## Показать справку
	@echo "Доступные команды:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Собрать все Docker образы
	docker-compose build

up: ## Запустить все контейнеры
	docker-compose up -d
	@echo "✅ Приложение запущено!"
	@echo "Frontend: http://localhost"
	@echo "Backend: http://localhost/api/"
	@echo "Admin: http://localhost/admin/"

down: ## Остановить все контейнеры
	docker-compose down

logs: ## Показать логи всех сервисов
	docker-compose logs -f

logs-backend: ## Показать логи backend
	docker-compose logs -f backend

logs-frontend: ## Показать логи frontend
	docker-compose logs -f frontend

logs-db: ## Показать логи базы данных
	docker-compose logs -f db

restart: ## Перезапустить все контейнеры
	docker-compose restart

restart-backend: ## Перезапустить только backend
	docker-compose restart backend

clean: ## Удалить контейнеры и volumes (⚠️ БД будет удалена!)
	docker-compose down -v
	docker system prune -f

migrate: ## Применить миграции Django
	docker-compose exec backend python manage.py migrate

makemigrations: ## Создать миграции Django
	docker-compose exec backend python manage.py makemigrations

createsuperuser: ## Создать суперпользователя Django
	docker-compose exec backend python manage.py createsuperuser

shell: ## Открыть Django shell
	docker-compose exec backend python manage.py shell

bash: ## Открыть bash в backend контейнере
	docker-compose exec backend bash

db-shell: ## Открыть PostgreSQL shell
	docker-compose exec db psql -U wedding_user -d wedding_db

backup: ## Создать backup базы данных
	mkdir -p backups
	docker-compose exec db pg_dump -U wedding_user wedding_db > backups/backup-$$(date +%Y%m%d-%H%M%S).sql
	@echo "✅ Backup создан в backups/"

restore: ## Восстановить последний backup (использование: make restore FILE=backups/backup-XXXXX.sql)
	@if [ -z "$(FILE)" ]; then \
		echo "❌ Укажите файл: make restore FILE=backups/backup-XXXXX.sql"; \
		exit 1; \
	fi
	docker-compose exec -T db psql -U wedding_user wedding_db < $(FILE)
	@echo "✅ База данных восстановлена"

init: ## Инициализация проекта (первый запуск)
	@echo "🚀 Инициализация проекта..."
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "✅ Создан .env файл"; \
	fi
	docker-compose build
	docker-compose up -d
	@echo "⏳ Ожидание запуска базы данных..."
	sleep 5
	docker-compose exec backend python manage.py migrate
	@echo ""
	@echo "✅ Проект инициализирован!"
	@echo ""
	@echo "Теперь создайте суперпользователя:"
	@echo "  make createsuperuser"
	@echo ""
	@echo "Приложение доступно по адресам:"
	@echo "  Frontend: http://localhost"
	@echo "  Backend API: http://localhost/api/"
	@echo "  Admin: http://localhost/admin/"

status: ## Показать статус контейнеров
	docker-compose ps

rebuild: ## Пересобрать и перезапустить все контейнеры
	docker-compose down
	docker-compose build --no-cache
	docker-compose up -d

test: ## Запустить тесты
	docker-compose exec backend python manage.py test

collectstatic: ## Собрать статические файлы
	docker-compose exec backend python manage.py collectstatic --noinput

dev-backend: ## Запустить только БД, backend локально
	docker-compose up -d db
	@echo "БД запущена. Теперь запустите backend локально:"
	@echo "  cd backend"
	@echo "  source ../env/bin/activate"
	@echo "  export POSTGRES_HOST=localhost"
	@echo "  python manage.py runserver"

dev-frontend: ## Инструкция для запуска frontend локально
	@echo "Запустите frontend локально:"
	@echo "  cd frontend"
	@echo "  npm install"
	@echo "  npm run dev"

