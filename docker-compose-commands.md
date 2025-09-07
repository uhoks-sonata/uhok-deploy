# Docker Compose 명령어 정리 (V2)

## 기본 명령어 (순서대로)

### 1. 이미지 빌드 (가장 먼저!)
```bash
# 모든 서비스 이미지 빌드
docker compose build

# 특정 서비스 이미지 빌드
docker compose build backend

# 캐시 없이 강제 빌드
docker compose build --no-cache

# 빌드 후 즉시 시작
docker compose up --build
```

### 2. 서비스 시작 및 중지
```bash
# 모든 서비스 시작 (백그라운드)
docker compose up -d

# 모든 서비스 시작 (포그라운드 - 로그 확인 가능)
docker compose up

# 특정 서비스만 시작
docker compose up -d backend

# 모든 서비스 중지
docker compose down

# 모든 서비스 중지 (볼륨도 함께 삭제)
docker compose down -v
```

### 3. 서비스 상태 확인
```bash
# 실행 중인 서비스 목록
docker compose ps

# 서비스 로그 확인
docker compose logs

# 특정 서비스 로그 확인
docker compose logs backend

# 실시간 로그 확인
docker compose logs -f backend
```

### 4. 서비스 재시작
```bash
# 모든 서비스 재시작
docker compose restart

# 특정 서비스 재시작
docker compose restart backend

# 서비스 중지 후 다시 시작
docker compose stop backend
docker compose start backend
```

## 컨테이너 관리

### 5. 컨테이너 접속
```bash
# 컨테이너 내부 접속
docker compose exec backend bash

# 컨테이너 내부에서 명령어 실행
docker compose exec backend python manage.py migrate
```

### 6. 컨테이너 정보 확인
```bash
# 컨테이너 상세 정보
docker compose config

# 특정 서비스 설정 확인
docker compose config backend
```

## 프로젝트별 명령어 (uhok 프로젝트)

### 7. 개발 환경 실행 (순서대로)
```bash
# 1단계: 이미지 빌드
docker compose build

# 2단계: 전체 스택 시작 (백엔드 + 프론트엔드 + nginx)
docker compose up -d

# 접속 URL: http://localhost:80 (또는 http://localhost)
```

### 8. 개별 서비스 관리
```bash
# 특정 서비스 빌드 후 시작
docker compose build backend
docker compose up -d backend

# 프론트엔드 빌드 후 시작
docker compose build frontend
docker compose up -d frontend

# nginx 시작 (이미지 빌드 불필요)
docker compose up -d nginx

# redis 시작 (이미지 빌드 불필요)
docker compose up -d redis

# ml-inference 빌드 후 시작 (커스텀 이미지 빌드 필요)
docker compose build ml-inference
docker compose --profile with-ml up -d ml-inference
```

### 9. 로그 모니터링
```bash
# 백엔드 로그 확인
docker compose logs -f backend

# 프론트엔드 로그 확인
docker compose logs -f frontend

# nginx 로그 확인
docker compose logs -f nginx

# redis 로그 확인
docker compose logs -f redis

# ml-inference 로그 확인
docker compose logs -f ml-inference

# 모든 서비스 로그 확인
docker compose logs -f
```

### 10. 문제 해결
```bash
# 컨테이너 상태 확인
docker compose ps

# 컨테이너 리소스 사용량 확인
docker stats

# 특정 컨테이너 상세 정보
docker inspect uhok-backend

# 네트워크 확인
docker network ls
docker network inspect uhok-deploy_app_net
```

## 유용한 옵션들

### 11. 추가 옵션
```bash
# 강제로 컨테이너 재생성
docker compose up -d --force-recreate

# 특정 서비스만 강제 재생성
docker compose up -d --force-recreate backend

# 볼륨과 함께 완전 정리
docker compose down -v --remove-orphans

# 사용하지 않는 이미지 정리
docker image prune

# 모든 사용하지 않는 리소스 정리
docker system prune
```

## 환경 변수 관리

### 12. 환경 설정
```bash
# 환경 변수 파일 지정
docker compose --env-file .env up -d

# 특정 환경 변수 오버라이드
docker compose up -d -e DEBUG=1
```

## 백업 및 복원

### 13. 데이터 백업
```bash
# 볼륨 백업
docker run --rm -v uhok-deploy_data:/data -v $(pwd):/backup alpine tar czf /backup/backup.tar.gz -C /data .

# 볼륨 복원
docker run --rm -v uhok-deploy_data:/data -v $(pwd):/backup alpine tar xzf /backup/backup.tar.gz -C /data
```

## 트러블슈팅

### 14. 일반적인 문제 해결
```bash
# 포트 충돌 확인
netstat -tulpn | grep :80

# 컨테이너 로그에서 에러 확인
docker compose logs | grep -i error

# 컨테이너 리소스 사용량 확인
docker stats --no-stream

# 네트워크 연결 테스트
docker compose exec nginx ping backend

# Redis 연결 테스트
docker compose exec redis redis-cli ping

# ML Inference 서비스 연결 테스트
docker compose exec ml-inference curl -f http://localhost:8001/health
```

### 15. 자주 발생하는 오류와 해결방법

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
```

#### 포트 충돌
```bash
# 오류: port is already allocated
# 해결: 사용 중인 포트 확인 및 변경
netstat -tulpn | grep :80
# docker-compose.yml에서 포트 번호 변경
```

#### 권한 오류
```bash
# 오류: permission denied
# 해결: Docker 데몬 실행 상태 확인
docker version
# Windows: Docker Desktop 실행 확인
```

---

## 빠른 참조 (순서대로)

| 명령어 | 설명 |
|--------|------|
| `docker compose build` | 이미지 빌드 (가장 먼저!) |
| `docker compose up -d` | 백그라운드에서 모든 서비스 시작 |
| `docker compose ps` | 실행 중인 서비스 상태 확인 |
| `docker compose logs -f` | 실시간 로그 확인 |
| `docker compose restart` | 모든 서비스 재시작 |
| `docker compose down` | 모든 서비스 중지 |
| `docker compose exec <service> bash` | 컨테이너 내부 접속 |

## 프로젝트 구조
- **backend**: Python 백엔드 서비스 (포트 9000)
- **frontend**: 프론트엔드 서비스 (포트 80)
- **nginx**: Nginx 리버스 프록시 (포트 80)
- **redis**: Redis 서비스 (포트 6379)
- **ml-inference**: ML 추론 서비스 (포트 8001, with-ml 프로필)
- **app_net**: 서비스 간 통신을 위한 브리지 네트워크

## Redis 및 Nginx 전용 명령어

### 16. Redis 관리
```bash
# Redis 서비스 시작
docker compose up -d redis

# Redis 서비스 중지
docker compose stop redis

# Redis 서비스 재시작
docker compose restart redis

# Redis CLI 접속
docker compose exec redis redis-cli

# Redis 상태 확인
docker compose exec redis redis-cli ping

# Redis 데이터 확인
docker compose exec redis redis-cli keys "*"

# Redis 메모리 사용량 확인
docker compose exec redis redis-cli info memory
```

### 17. Nginx 관리
```bash
# Nginx 서비스 시작
docker compose up -d nginx

# Nginx 서비스 중지
docker compose stop nginx

# Nginx 서비스 재시작
docker compose restart nginx

# Nginx 설정 테스트
docker compose exec nginx nginx -t

# Nginx 설정 리로드
docker compose exec nginx nginx -s reload

# Nginx 상태 확인
docker compose exec nginx nginx -s status

# Nginx 접근 로그 확인
docker compose logs -f nginx
```

### 18. Redis와 Nginx 함께 관리
```bash
# Redis와 Nginx 동시 시작
docker compose up -d redis nginx

# Redis와 Nginx 동시 중지
docker compose stop redis nginx

# Redis와 Nginx 동시 재시작
docker compose restart redis nginx

# Redis와 Nginx 상태 확인
docker compose ps redis nginx
```

### 19. ML Inference 관리
```bash
# ML Inference 서비스 시작 (with-ml 프로필 필요)
docker compose --profile with-ml up -d ml-inference

# ML Inference 서비스 중지
docker compose stop ml-inference

# ML Inference 서비스 재시작
docker compose restart ml-inference

# ML Inference 빌드 후 시작
docker compose build ml-inference
docker compose --profile with-ml up -d ml-inference

# ML Inference 상태 확인
docker compose exec ml-inference curl -f http://localhost:8001/health

# ML Inference 로그 확인
docker compose logs -f ml-inference

# ML Inference 컨테이너 접속
docker compose exec ml-inference bash

# ML 모델 캐시 볼륨 확인
docker volume ls | grep ml_cache

# ML 모델 캐시 볼륨 삭제 (주의: 모델 재다운로드 필요)
docker volume rm uhok-deploy_ml_cache
```

### 20. 프로필 기반 실행
```bash
# 기본 서비스만 시작 (backend, frontend, nginx)
docker compose up -d

# Redis 포함하여 시작
docker compose --profile with-redis up -d

# ML Inference 포함하여 시작
docker compose --profile with-ml up -d

# Redis와 ML Inference 모두 포함하여 시작
docker compose --profile with-redis --profile with-ml up -d

# 모든 서비스 시작 (모든 프로필 포함)
docker compose --profile with-redis --profile with-ml up -d
```

### 21. ML Inference와 다른 서비스 함께 관리
```bash
# ML Inference와 Redis 동시 시작
docker compose --profile with-ml --profile with-redis up -d ml-inference redis

# ML Inference와 Nginx 동시 시작
docker compose --profile with-ml up -d ml-inference nginx

# ML Inference, Redis, Nginx 동시 시작
docker compose --profile with-ml --profile with-redis up -d ml-inference redis nginx

# ML Inference 상태 확인
docker compose ps ml-inference
```
