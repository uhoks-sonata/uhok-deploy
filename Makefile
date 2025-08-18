SHELL := /bin/bash
.ONESHELL:
COMPOSE ?= docker compose
CURL    ?= curl -s

.PHONY: up up-backend up-web start stop down down-v restart-backend restart-web logs health status nginx-reload prune-light prune-hard migrate

up:
	# """
	# 백엔드/웹/ML 추론 서비스 이미지를 병렬로 빌드하고, 모든 서비스를 기동한 뒤 기본 헬스를 점검합니다.
	# 비동기 처리: build를 &로 병렬 실행 후 wait.
	# """
	($(COMPOSE) build uhok-backend & $(COMPOSE) build uhok-web & $(COMPOSE) build uhok-ml-inference & wait)
	$(COMPOSE) up -d uhok-backend uhok-web uhok-ml-inference
	$(MAKE) health

up-backend:
	# """
	# 백엔드만 새로 빌드 후 기동합니다.
	# """
	$(COMPOSE) up -d --build uhok-backend
	$(COMPOSE) ps
	-$(CURL) http://localhost/api/healthz || true

up-web:
	# """
	# 웹(Nginx)만 새로 빌드 후 기동합니다.
	# """
	$(COMPOSE) up -d --build uhok-web
	$(COMPOSE) ps
	-$(CURL) -I http://localhost/ | head -n 1 || true
	-$(CURL) -I http://localhost/api/docs | head -n 1 || true

up-ml:
	# """
	# ML 추론 서비스만 새로 빌드 후 기동합니다.
	# """
	$(COMPOSE) up -d --build uhok-ml-inference
	$(COMPOSE) ps
	-$(CURL) http://localhost:8080/api/health || true

start:
	# """
	# 정지된 컨테이너를 다시 시작합니다. 없으면 up -d로 대체합니다.
	# """
	-$(COMPOSE) start || $(COMPOSE) up -d
	$(MAKE) health

stop:
	# """
	# 모든 서비스를 일시 중지합니다(이미지/볼륨 유지).
	# """
	$(COMPOSE) stop
	$(COMPOSE) ps

down:
	# """
	# 컨테이너와 네트워크를 제거하며 종료합니다(이미지/볼륨 보존).
	# """
	$(COMPOSE) down

down-v:
	# """
	# 컨테이너/네트워크/볼륨까지 제거합니다(데이터 삭제 주의).
	# """
	$(COMPOSE) down -v

restart-backend:
	# """
	# 백엔드만 재빌드/재기동 후 헬스 확인합니다.
	# """
	$(COMPOSE) up -d --build uhok-backend
	-$(CURL) http://localhost/api/healthz || true

restart-web:
	# """
	# 웹(Nginx)만 재빌드/재기동 후 루트/문서 응답을 확인합니다.
	# """
	$(COMPOSE) up -d --build uhok-web
	-$(CURL) -I http://n 1 || true
	-$(CURL) -I http://localhost/api/docs | head -n 1 || true

restart-ml:
	# """
	# ML 추론 서비스만 재빌드/재기동 후 헬스체크를 확인합니다.
	# """
	$(COMPOSE) up -d --build uhok-ml-inference
	-$(CURL) http://localhost:8080/api/health || true

logs:
	# """
	# 백엔드/웹/ML 추론 서비스 로그를 동시에 실시간 팔로우합니다. 종료: Ctrl+C
	# 비동기 처리: 세 로그를 &로 병렬 실행 후 wait.
	# """
	trap "exit 0" INT; \
	($(COMPOSE) logs -f --tail=200 uhok-backend & \
	 $(COMPOSE) logs -f --tail=200 uhok-web & \
	 $(COMPOSE) logs -f --tail=200 uhok-ml-inference & \
	 wait)

health:
	# """
	# 프록시 경유로 헬스/문서/루트 응답을 점검합니다.
	# """
	-$(CURL) http://localhost/api/healthz || true
	-$(CURL) -I http://localhost/api/docs | head -n 1 || true
	-$(CURL) -I http://localhost/ | head -n 1 || true

status:
	# """
	# 현재 Compose 서비스들의 상태를 표시합니다.
	# """
	$(COMPOSE) ps

nginx-reload:
	# """
	# nginx.conf 변경을 무중단 반영합니다. 실패 시 컨테이너 재시작으로 대체합니다.
	# """
	-$(COMPOSE) exec -T uhok-web nginx -s reload || $(COMPOSE) restart uhok-web

prune-light:
	# """
	# 사용하지 않는 이미지/네트워크/빌드 캐시를 정리합니다(데이터 보존).
	# """
	docker system prune -f

prune-hard:
	# """
	# 모든 미사용 이미지와 볼륨까지 강력 정리합니다(데이터 삭제 주의).
	# """
	docker system prune -a -f
	docker volume prune -f

migrate:
	# """
	# 백엔드 컨테이너에서 Alembic 마이그레이션을 실행합니다(ini 존재 시).
	# """
	$(COMPOSE) exec -T uhok-backend bash -lc 'set -e; \
	  if [ -f alembic_mariadb_auth.ini ]; then echo "▶ MariaDB AUTH"; alembic -c alembic_mariadb_auth.ini upgrade head; fi; \
	  if [ -f alembic_postgres_log.ini ]; then echo "▶ PostgreSQL LOG"; alembic -c alembic_postgres_log.ini upgrade head; fi'
