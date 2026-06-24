SHELL := /bin/bash
.ONESHELL:
COMPOSE ?= docker compose
CURL    ?= curl -s

# 서비스 정의
WEB_SERVICES = nginx frontend
APP_SERVICES = backend redis
ML_SERVICES  = ml-inference

.PHONY: up up-backend up-frontend up-nginx up-ml up-app up-all start stop down down-v restart-backend restart-frontend restart-nginx restart-redis restart-ml logs logs-app logs-ml logs-all health status status-web status-app status-ml nginx-reload prune-light prune-hard migrate shell-backend shell-ml shell-redis clean network-create help

up:
	$(COMPOSE) -f public/docker-compose.public.yml build frontend
	$(COMPOSE) -f public/docker-compose.public.yml up -d
	$(MAKE) health

up-backend:
	$(COMPOSE) -f app/docker-compose.app.yml up -d --build backend
	$(COMPOSE) -f app/docker-compose.app.yml ps
	-$(CURL) http://localhost/api/health || true

up-frontend:
	$(COMPOSE) -f public/docker-compose.public.yml up -d --build frontend
	$(COMPOSE) -f public/docker-compose.public.yml ps
	-$(CURL) -I http://localhost/ | head -n 1 || true

up-nginx:
	$(COMPOSE) -f public/docker-compose.public.yml up -d --build nginx
	$(COMPOSE) -f public/docker-compose.public.yml ps
	-$(CURL) -I http://localhost/ | head -n 1 || true
	-$(CURL) -I http://localhost/api/docs | head -n 1 || true

up-ml:
	$(COMPOSE) -f ml/docker-compose.ml.yml up -d --build
	$(COMPOSE) -f ml/docker-compose.ml.yml ps
	-$(CURL) http://localhost:8001/health || true

up-app:
	$(COMPOSE) -f app/docker-compose.app.yml up -d
	$(COMPOSE) -f app/docker-compose.app.yml ps

up-all:
	$(MAKE) up
	$(MAKE) up-app
	$(MAKE) up-ml

start:
	-$(COMPOSE) -f public/docker-compose.public.yml start || $(COMPOSE) -f public/docker-compose.public.yml up -d
	-$(COMPOSE) -f app/docker-compose.app.yml start || $(COMPOSE) -f app/docker-compose.app.yml up -d
	-$(COMPOSE) -f ml/docker-compose.ml.yml start || $(COMPOSE) -f ml/docker-compose.ml.yml up -d
	$(MAKE) health

stop:
	$(COMPOSE) -f public/docker-compose.public.yml stop
	$(COMPOSE) -f app/docker-compose.app.yml stop
	$(COMPOSE) -f ml/docker-compose.ml.yml stop
	$(MAKE) status

down:
	$(COMPOSE) -f public/docker-compose.public.yml down
	$(COMPOSE) -f app/docker-compose.app.yml down
	$(COMPOSE) -f ml/docker-compose.ml.yml down

down-v:
	$(COMPOSE) -f public/docker-compose.public.yml down -v
	$(COMPOSE) -f app/docker-compose.app.yml down -v
	$(COMPOSE) -f ml/docker-compose.ml.yml down -v

restart-backend:
	$(COMPOSE) -f app/docker-compose.app.yml up -d --build backend
	-$(CURL) http://localhost/api/health || true

restart-frontend:
	$(COMPOSE) -f public/docker-compose.public.yml up -d --build frontend
	-$(CURL) -I http://localhost/ | head -n 1 || true

restart-nginx:
	$(COMPOSE) -f public/docker-compose.public.yml up -d --build nginx
	-$(CURL) -I http://localhost/ | head -n 1 || true
	-$(CURL) -I http://localhost/api/docs | head -n 1 || true

restart-ml:
	$(COMPOSE) -f ml/docker-compose.ml.yml up -d --build
	-$(CURL) http://localhost:8001/health || true

restart-redis:
	$(COMPOSE) -f app/docker-compose.app.yml restart redis

logs:
	trap "exit 0" INT; \
	($(COMPOSE) -f public/docker-compose.public.yml logs -f --tail=200 nginx & \
	 $(COMPOSE) -f public/docker-compose.public.yml logs -f --tail=200 frontend & \
	 wait)

logs-app:
	trap "exit 0" INT; \
	($(COMPOSE) -f app/docker-compose.app.yml logs -f --tail=200 backend & \
	 $(COMPOSE) -f app/docker-compose.app.yml logs -f --tail=200 redis & \
	 wait)

logs-ml:
	$(COMPOSE) -f ml/docker-compose.ml.yml logs -f --tail=200

logs-all:
	trap "exit 0" INT; \
	($(COMPOSE) -f public/docker-compose.public.yml logs -f --tail=200 nginx & \
	 $(COMPOSE) -f public/docker-compose.public.yml logs -f --tail=200 frontend & \
	 $(COMPOSE) -f app/docker-compose.app.yml logs -f --tail=200 backend & \
	 $(COMPOSE) -f app/docker-compose.app.yml logs -f --tail=200 redis & \
	 $(COMPOSE) -f ml/docker-compose.ml.yml logs -f --tail=200 & \
	 wait)

health:
	-$(CURL) http://localhost/api/health || true
	-$(CURL) -I http://localhost/api/docs | head -n 1 || true
	-$(CURL) -I http://localhost/ | head -n 1 || true
	-$(CURL) http://localhost:8001/health || true

status:
	$(COMPOSE) -f public/docker-compose.public.yml ps
	$(COMPOSE) -f app/docker-compose.app.yml ps
	$(COMPOSE) -f ml/docker-compose.ml.yml ps

status-web:
	$(COMPOSE) -f public/docker-compose.public.yml ps

status-app:
	$(COMPOSE) -f app/docker-compose.app.yml ps

status-ml:
	$(COMPOSE) -f ml/docker-compose.ml.yml ps

nginx-reload:
	-$(COMPOSE) -f public/docker-compose.public.yml exec -T nginx nginx -s reload || $(COMPOSE) -f public/docker-compose.public.yml restart nginx

prune-light:
	docker system prune -f

prune-hard:
	docker system prune -a -f
	docker volume prune -f

migrate:
	$(COMPOSE) -f app/docker-compose.app.yml exec -T backend bash -lc 'set -e; \
	  if [ -f alembic_mariadb_auth.ini ]; then echo "▶ MariaDB AUTH"; alembic -c alembic_mariadb_auth.ini upgrade head; fi; \
	  if [ -f alembic_postgres_log.ini ]; then echo "▶ PostgreSQL LOG"; alembic -c alembic_postgres_log.ini upgrade head; fi'

shell-backend:
	$(COMPOSE) -f app/docker-compose.app.yml exec backend bash

shell-ml:
	$(COMPOSE) -f ml/docker-compose.ml.yml exec ml-inference bash

shell-redis:
	$(COMPOSE) -f app/docker-compose.app.yml exec redis redis-cli

clean:
	$(MAKE) down-v
	docker system prune -a -f
	docker volume prune -f

network-create:
	docker network create uhok_net || true

help:
	@echo "=== UHOK 프로젝트 Makefile 도움말 ==="
	@echo ""
	@echo "기본 명령어:"
	@echo "  make up          - 웹 서비스 시작 (nginx + frontend)"
	@echo "  make up-app      - 앱 서비스 시작 (backend + redis)"
	@echo "  make up-ml       - ML 추론 서비스 시작"
	@echo "  make up-all      - 모든 서비스 시작"
	@echo "  make start       - 정지된 서비스 재시작"
	@echo "  make stop        - 모든 서비스 일시 중지"
	@echo "  make down        - 컨테이너와 네트워크 제거"
	@echo "  make down-v      - 컨테이너/네트워크/볼륨 제거"
	@echo ""
	@echo "개별 서비스 관리:"
	@echo "  make up-backend    - 백엔드만 시작"
	@echo "  make up-frontend   - 프론트엔드만 시작"
	@echo "  make up-nginx      - nginx만 시작"
	@echo "  make restart-*     - 각 서비스 재시작"
	@echo "  make restart-ml    - ML 추론 서비스 재시작"
	@echo ""
	@echo "로그 및 상태:"
	@echo "  make logs          - 웹 서비스 로그 보기 (nginx + frontend)"
	@echo "  make logs-app      - 앱 서비스 로그 보기 (backend + redis)"
	@echo "  make logs-ml       - ML 추론 서비스 로그 보기"
	@echo "  make logs-all      - 모든 서비스 로그 보기"
	@echo "  make health        - 서비스 헬스 체크"
	@echo "  make status        - 모든 서비스 상태 확인"
	@echo "  make status-web    - 웹 서비스 상태 확인"
	@echo "  make status-app    - 앱 서비스 상태 확인"
	@echo "  make status-ml     - ML 추론 서비스 상태 확인"
	@echo ""
	@echo "유틸리티:"
	@echo "  make migrate       - 데이터베이스 마이그레이션"
	@echo "  make nginx-reload  - nginx 설정 재로드"
	@echo "  make shell-backend - 백엔드 컨테이너 접속"
	@echo "  make shell-ml      - ML 추론 서비스 컨테이너 접속"
	@echo "  make shell-redis   - Redis 컨테이너 접속"
	@echo "  make clean         - 모든 리소스 정리"
	@echo "  make prune-light   - 가벼운 정리"
	@echo "  make prune-hard    - 강력한 정리"
	@echo "  make network-create - uhok_net 네트워크 생성"
