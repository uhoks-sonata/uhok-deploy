# Docker Compose 명령어 정리 (V4 - 분리된 파일 구조)

## 파일 구조
- `public/docker-compose.public.yml`: 웹 서비스 (nginx, frontend)
- `app/docker-compose.app.yml`: 앱 서비스 (backend, redis)
- `ml/docker-compose.ml.yml`: ML 서비스 (ml-inference)

## 기본 명령어 (순서대로)

### 1. 네트워크 생성 (최초 1회)
```bash
# uhok_net 외부 네트워크 생성
docker network create uhok_net

# 또는 Makefile 사용
make network-create
```

### 2. 웹 서비스 빌드 및 실행
```bash
# 웹 서비스 이미지 빌드
docker compose -f public/docker-compose.public.yml build

# 특정 서비스 이미지 빌드
docker compose -f public/docker-compose.public.yml build frontend

# 캐시 없이 강제 빌드
docker compose -f public/docker-compose.public.yml build --no-cache

# 빌드 후 즉시 시작
docker compose -f public/docker-compose.public.yml up --build

# 웹 서비스 시작 (백그라운드)
docker compose -f public/docker-compose.public.yml up -d

# 웹 서비스 시작 (포그라운드 - 로그 확인 가능)
docker compose -f public/docker-compose.public.yml up
```

### 3. 앱 서비스 빌드 및 실행
```bash
# 앱 서비스 이미지 빌드
docker compose -f app/docker-compose.app.yml build

# 특정 서비스 이미지 빌드
docker compose -f app/docker-compose.app.yml build backend

# 앱 서비스 시작 (백그라운드)
docker compose -f app/docker-compose.app.yml up -d

# Redis 포함 시작
docker compose -f app/docker-compose.app.yml --profile with-redis up -d
```

### 4. ML 서비스 빌드 및 실행
```bash
# ML 서비스 이미지 빌드
docker compose -f ml/docker-compose.ml.yml build

# ML 서비스 시작 (백그라운드)
docker compose -f ml/docker-compose.ml.yml up -d

# ML 서비스 시작 (포그라운드 - 로그 확인 가능)
docker compose -f ml/docker-compose.ml.yml up
```

### 5. 서비스 상태 확인
```bash
# 웹 서비스 상태 확인
docker compose -f public/docker-compose.public.yml ps

# 앱 서비스 상태 확인
docker compose -f app/docker-compose.app.yml ps

# ML 서비스 상태 확인
docker compose -f ml/docker-compose.ml.yml ps

# 모든 서비스 상태 확인
docker compose -f public/docker-compose.public.yml ps
docker compose -f app/docker-compose.app.yml ps
docker compose -f ml/docker-compose.ml.yml ps
```

### 6. 서비스 로그 확인
```bash
# 웹 서비스 로그 확인
docker compose -f public/docker-compose.public.yml logs

# 앱 서비스 로그 확인
docker compose -f app/docker-compose.app.yml logs

# ML 서비스 로그 확인
docker compose -f ml/docker-compose.ml.yml logs

# 특정 서비스 로그 확인
docker compose -f public/docker-compose.public.yml logs nginx
docker compose -f public/docker-compose.public.yml logs frontend
docker compose -f app/docker-compose.app.yml logs backend
docker compose -f app/docker-compose.app.yml logs redis
docker compose -f ml/docker-compose.ml.yml logs ml-inference

# 실시간 로그 확인
docker compose -f public/docker-compose.public.yml logs -f nginx
docker compose -f app/docker-compose.app.yml logs -f backend
docker compose -f ml/docker-compose.ml.yml logs -f ml-inference
```

### 7. 서비스 재시작
```bash
# 웹 서비스 재시작
docker compose -f public/docker-compose.public.yml restart

# 앱 서비스 재시작
docker compose -f app/docker-compose.app.yml restart

# ML 서비스 재시작
docker compose -f ml/docker-compose.ml.yml restart

# 특정 서비스 재시작
docker compose -f public/docker-compose.public.yml restart nginx
docker compose -f app/docker-compose.app.yml restart backend
docker compose -f ml/docker-compose.ml.yml restart ml-inference

# 서비스 중지 후 다시 시작
docker compose -f app/docker-compose.app.yml stop backend
docker compose -f app/docker-compose.app.yml start backend
```

## 컨테이너 관리

### 8. 컨테이너 접속
```bash
# 웹 서비스 컨테이너 내부 접속
docker compose -f public/docker-compose.public.yml exec nginx sh
docker compose -f public/docker-compose.public.yml exec frontend sh

# 앱 서비스 컨테이너 내부 접속
docker compose -f app/docker-compose.app.yml exec backend bash
docker compose -f app/docker-compose.app.yml exec redis redis-cli

# ML 서비스 컨테이너 내부 접속
docker compose -f ml/docker-compose.ml.yml exec ml-inference bash

# 컨테이너 내부에서 명령어 실행
docker compose -f app/docker-compose.app.yml exec backend python -c "print('Hello')"
```

### 9. 컨테이너 정보 확인
```bash
# 웹 서비스 설정 확인
docker compose -f public/docker-compose.public.yml config

# 앱 서비스 설정 확인
docker compose -f app/docker-compose.app.yml config

# ML 서비스 설정 확인
docker compose -f ml/docker-compose.ml.yml config

# 특정 서비스 설정 확인
docker compose -f app/docker-compose.app.yml config backend
```

## 프로젝트별 명령어 (uhok 프로젝트)

### 10. 개발 환경 실행 (순서대로)
```bash
# 1단계: 네트워크 생성 (최초 1회)
docker network create uhok_net

# 2단계: 웹 서비스 시작 (nginx + frontend)
docker compose -f public/docker-compose.public.yml up -d

# 3단계: 앱 서비스 시작 (backend + redis)
docker compose -f app/docker-compose.app.yml --profile with-redis up -d

# 4단계: ML 서비스 시작 (ml-inference)
docker compose -f ml/docker-compose.ml.yml up -d

# 접속 URL: http://localhost:80 (또는 http://localhost)
# ML 서비스: http://localhost:8001
```

### 11. 개별 서비스 관리
```bash
# 웹 서비스 개별 관리
docker compose -f public/docker-compose.public.yml build frontend
docker compose -f public/docker-compose.public.yml up -d frontend

# nginx 시작 (이미지 빌드 불필요)
docker compose -f public/docker-compose.public.yml up -d nginx

# 앱 서비스 개별 관리
docker compose -f app/docker-compose.app.yml build backend
docker compose -f app/docker-compose.app.yml up -d backend

# redis 시작 (이미지 빌드 불필요)
docker compose -f app/docker-compose.app.yml up -d redis

# ML 서비스 관리
docker compose -f ml/docker-compose.ml.yml build
docker compose -f ml/docker-compose.ml.yml up -d
```

### 12. 로그 모니터링
```bash
# 웹 서비스 로그 확인
docker compose -f public/docker-compose.public.yml logs

# 앱 서비스 로그 확인
docker compose -f app/docker-compose.app.yml logs

# ML 서비스 로그 확인
docker compose -f ml/docker-compose.ml.yml logs

# 특정 서비스 로그 확인
docker compose -f public/docker-compose.public.yml logs nginx
docker compose -f public/docker-compose.public.yml logs frontend
docker compose -f app/docker-compose.app.yml logs backend
docker compose -f app/docker-compose.app.yml logs redis
docker compose -f ml/docker-compose.ml.yml logs ml-inference

# 실시간 로그 확인
docker compose -f public/docker-compose.public.yml logs -f nginx
docker compose -f app/docker-compose.app.yml logs -f backend
docker compose -f ml/docker-compose.ml.yml logs -f ml-inference

# 특정 시간 이후 로그
docker compose -f app/docker-compose.app.yml logs --since="2025-01-17T06:00:00" backend

# 마지막 N줄 로그
docker compose -f app/docker-compose.app.yml logs --tail=50 backend
```

### 13. 문제 해결
```bash
# 웹 서비스 상태 확인
docker compose -f public/docker-compose.public.yml ps

# 앱 서비스 상태 확인
docker compose -f app/docker-compose.app.yml ps

# ML 서비스 상태 확인
docker compose -f ml/docker-compose.ml.yml ps

# 컨테이너 리소스 사용량 확인
docker stats

# 특정 컨테이너 상세 정보
docker inspect uhok-backend
docker inspect uhok-frontend
docker inspect uhok-ml-inference

# 네트워크 확인
docker network ls
docker network inspect uhok_net
```

## 유용한 옵션들

### 14. 추가 옵션
```bash
# 웹 서비스 강제 재생성
docker compose -f public/docker-compose.public.yml up -d --force-recreate

# 앱 서비스 강제 재생성
docker compose -f app/docker-compose.app.yml up -d --force-recreate

# ML 서비스 강제 재생성
docker compose -f ml/docker-compose.ml.yml up -d --force-recreate

# 특정 서비스만 강제 재생성
docker compose -f app/docker-compose.app.yml up -d --force-recreate backend

# 볼륨과 함께 완전 정리
docker compose -f public/docker-compose.public.yml down -v --remove-orphans
docker compose -f app/docker-compose.app.yml down -v --remove-orphans
docker compose -f ml/docker-compose.ml.yml down -v --remove-orphans

# 사용하지 않는 이미지 정리
docker image prune

# 모든 사용하지 않는 리소스 정리
docker system prune
```

## 환경 변수 관리

### 15. 환경 설정
```bash
# 웹 서비스 환경 변수 파일 지정
docker compose -f public/docker-compose.public.yml --env-file .env up -d

# 앱 서비스 환경 변수 파일 지정
docker compose -f app/docker-compose.app.yml --env-file .env up -d

# ML 서비스 환경 변수 파일 지정
docker compose -f ml/docker-compose.ml.yml --env-file .env up -d

# 특정 환경 변수 오버라이드
docker compose -f app/docker-compose.app.yml up -d -e DEBUG=1
```

## 백업 및 복원

### 16. 데이터 백업
```bash
# Redis 볼륨 백업
docker run --rm -v uhok-deploy_redis_data:/data -v $(pwd):/backup alpine tar czf /backup/redis-backup.tar.gz -C /data .

# ML 캐시 볼륨 백업
docker run --rm -v uhok-deploy_ml_cache:/data -v $(pwd):/backup alpine tar czf /backup/ml-cache-backup.tar.gz -C /data .

# Redis 볼륨 복원
docker run --rm -v uhok-deploy_redis_data:/data -v $(pwd):/backup alpine tar xzf /backup/redis-backup.tar.gz -C /data

# ML 캐시 볼륨 복원
docker run --rm -v uhok-deploy_ml_cache:/data -v $(pwd):/backup alpine tar xzf /backup/ml-cache-backup.tar.gz -C /data
```

## 트러블슈팅

### 17. 일반적인 문제 해결
```bash
# 포트 충돌 확인
netstat -tulpn | grep :80
netstat -tulpn | grep :8001

# 웹 서비스 로그에서 에러 확인
docker compose -f public/docker-compose.public.yml logs | grep -i error

# 앱 서비스 로그에서 에러 확인
docker compose -f app/docker-compose.app.yml logs | grep -i error

# ML 서비스 로그에서 에러 확인
docker compose -f ml/docker-compose.ml.yml logs | grep -i error

# 컨테이너 리소스 사용량 확인
docker stats --no-stream

# 네트워크 연결 테스트
docker compose -f public/docker-compose.public.yml exec nginx ping backend
docker compose -f app/docker-compose.app.yml exec backend ping redis

# Redis 연결 테스트
docker compose -f app/docker-compose.app.yml exec redis redis-cli ping
```

### 18. 자주 발생하는 오류와 해결방법

#### 이미지 참조 오류
```bash
# 오류: unable to get image 'nginx:1.25-alpine:0.1.0': invalid reference format
# 해결: docker-compose.yml에서 이미지 태그 형식 확인
# 올바른 형식: nginx:1.25-alpine
# 잘못된 형식: nginx:1.25-alpine:0.1.0
```

#### 빌드 컨텍스트 오류
```bash
# 오류: build path does not exist
# 해결: 상대 경로 확인 및 디렉토리 존재 여부 확인
ls -la ../uhok-backend
ls -la ../uhok-frontend
ls -la ../uhok-ml-inference
```

#### 포트 충돌
```bash
# 오류: port is already allocated
# 해결: 사용 중인 포트 확인 및 변경
netstat -tulpn | grep :80
netstat -tulpn | grep :8001
# docker-compose.yml에서 포트 번호 변경
```

#### 권한 오류
```bash
# 오류: permission denied
# 해결: Docker 데몬 실행 상태 확인
docker version
# Windows: Docker Desktop 실행 확인
```

#### 네트워크 오류
```bash
# 오류: network uhok_net not found
# 해결: 네트워크 생성
docker network create uhok_net
```

---

## 빠른 참조 (순서대로)

| 명령어 | 설명 |
|--------|------|
| `docker network create uhok_net` | 네트워크 생성 (최초 1회) |
| `docker compose -f public/docker-compose.public.yml build` | 웹 서비스 이미지 빌드 |
| `docker compose -f app/docker-compose.app.yml build` | 앱 서비스 이미지 빌드 |
| `docker compose -f ml/docker-compose.ml.yml build` | ML 서비스 이미지 빌드 |
| `docker compose -f public/docker-compose.public.yml up -d` | 웹 서비스 시작 |
| `docker compose -f app/docker-compose.app.yml up -d` | 앱 서비스 시작 |
| `docker compose -f ml/docker-compose.ml.yml up -d` | ML 서비스 시작 |
| `docker compose -f public/docker-compose.public.yml ps` | 웹 서비스 상태 확인 |
| `docker compose -f app/docker-compose.app.yml ps` | 앱 서비스 상태 확인 |
| `docker compose -f ml/docker-compose.ml.yml ps` | ML 서비스 상태 확인 |
| `docker compose -f public/docker-compose.public.yml logs -f` | 웹 서비스 실시간 로그 |
| `docker compose -f app/docker-compose.app.yml logs -f` | 앱 서비스 실시간 로그 |
| `docker compose -f ml/docker-compose.ml.yml logs -f` | ML 서비스 실시간 로그 |
| `docker compose -f public/docker-compose.public.yml restart` | 웹 서비스 재시작 |
| `docker compose -f app/docker-compose.app.yml restart` | 앱 서비스 재시작 |
| `docker compose -f ml/docker-compose.ml.yml restart` | ML 서비스 재시작 |
| `docker compose -f public/docker-compose.public.yml down` | 웹 서비스 중지 |
| `docker compose -f app/docker-compose.app.yml down` | 앱 서비스 중지 |
| `docker compose -f ml/docker-compose.ml.yml down` | ML 서비스 중지 |
| `docker compose -f app/docker-compose.app.yml exec backend bash` | 백엔드 컨테이너 접속 |
| `docker compose -f ml/docker-compose.ml.yml exec ml-inference bash` | ML 서비스 컨테이너 접속 |

## 프로젝트 구조
- **nginx**: Nginx 리버스 프록시 (포트 80) - 웹 서비스
- **frontend**: React 프론트엔드 서비스 (포트 80) - 웹 서비스
- **backend**: Python 백엔드 서비스 (포트 9000) - 앱 서비스
- **redis**: Redis 서비스 (포트 6379) - 앱 서비스
- **ml-inference**: ML 추론 서비스 (포트 8001) - ML 서비스
- **uhok_net**: 서비스 간 통신을 위한 외부 브리지 네트워크

## Redis 및 Nginx 전용 명령어

### 19. Redis 관리
```bash
# Redis 서비스 시작
docker compose -f app/docker-compose.app.yml up -d redis

# Redis 서비스 중지
docker compose -f app/docker-compose.app.yml stop redis

# Redis 서비스 재시작
docker compose -f app/docker-compose.app.yml restart redis

# Redis CLI 접속
docker compose -f app/docker-compose.app.yml exec redis redis-cli

# Redis 상태 확인
docker compose -f app/docker-compose.app.yml exec redis redis-cli ping

# Redis 데이터 확인
docker compose -f app/docker-compose.app.yml exec redis redis-cli keys "*"

# Redis 메모리 사용량 확인
docker compose -f app/docker-compose.app.yml exec redis redis-cli info memory
```

### 20. Nginx 관리
```bash
# Nginx 서비스 시작
docker compose -f public/docker-compose.public.yml up -d nginx

# Nginx 서비스 중지
docker compose -f public/docker-compose.public.yml stop nginx

# Nginx 서비스 재시작
docker compose -f public/docker-compose.public.yml restart nginx

# Nginx 설정 테스트
docker compose -f public/docker-compose.public.yml exec nginx nginx -t

# Nginx 설정 리로드
docker compose -f public/docker-compose.public.yml exec nginx nginx -s reload

# Nginx 상태 확인
docker compose -f public/docker-compose.public.yml exec nginx nginx -s status

# Nginx 접근 로그 확인
docker compose -f public/docker-compose.public.yml logs -f nginx
```

### 21. Redis와 Nginx 함께 관리
```bash
# Redis와 Nginx 동시 시작
docker compose -f app/docker-compose.app.yml up -d redis
docker compose -f public/docker-compose.public.yml up -d nginx

# Redis와 Nginx 동시 중지
docker compose -f app/docker-compose.app.yml stop redis
docker compose -f public/docker-compose.public.yml stop nginx

# Redis와 Nginx 동시 재시작
docker compose -f app/docker-compose.app.yml restart redis
docker compose -f public/docker-compose.public.yml restart nginx

# Redis와 Nginx 상태 확인
docker compose -f app/docker-compose.app.yml ps redis
docker compose -f public/docker-compose.public.yml ps nginx
```

### 22. 전체 서비스 실행 옵션
```bash
# 웹 서비스 시작 (nginx + frontend)
docker compose -f public/docker-compose.public.yml up -d

# 앱 서비스 시작 (backend + redis)
docker compose -f app/docker-compose.app.yml --profile with-redis up -d

# ML 서비스 시작 (ml-inference)
docker compose -f ml/docker-compose.ml.yml up -d

# 모든 서비스 빌드 및 시작
docker compose -f public/docker-compose.public.yml up -d --build
docker compose -f app/docker-compose.app.yml up -d --build
docker compose -f ml/docker-compose.ml.yml up -d --build
```

## Makefile 사용 (권장)

### 23. Makefile 명령어
```bash
# 네트워크 생성
make network-create

# 모든 서비스 시작
make up-all

# 개별 서비스 시작
make up          # 웹 서비스 (nginx + frontend)
make up-app      # 앱 서비스 (backend + redis)
make up-ml       # ML 서비스

# 로그 확인
make logs        # 웹 서비스 로그
make logs-app    # 앱 서비스 로그
make logs-ml     # ML 서비스 로그
make logs-all    # 모든 서비스 로그

# 상태 확인
make status      # 모든 서비스 상태
make health      # 헬스체크

# 서비스 중지
make stop        # 모든 서비스 중지
make down        # 컨테이너 제거
make down-v      # 볼륨까지 제거

# 정리
make clean       # 모든 리소스 정리
make prune-light # 가벼운 정리
make prune-hard  # 강력한 정리
```
