# UHOK 배포 환경 (Docker Compose)

UHOK 프로젝트의 전체 스택을 Docker Compose로 관리하는 배포 환경입니다. 
백엔드, 프론트엔드, 임베딩&벡터유사도계산 ML 서비스, Redis, Nginx를 포함한 마이크로서비스 아키텍처를 제공합니다.

## 📁 폴더 구조

```
uhok-deploy/
├── app/                            # 앱 서비스 (백엔드, 프론트엔드, Redis)
│   ├── .env
│   └── docker-compose.app.yml
├── ml/                             # 임베딩&벡터유사도계산 ML 서비스
│   ├── .env
│   └── docker-compose.ml.yml
└── public/                         # 공개 서비스 (Nginx, 전체 통합)
│   ├── .env
│   ├── docker-compose.public.yml
│   └── nginx.conf
├── Makefile
└── docker-compose-commands.md
```

### 주요 파일
- `public/docker-compose.public.yml` - 웹 서비스 (Nginx, 프론트엔드)
- `public/nginx.conf` - Nginx 리버스 프록시 설정
- `app/docker-compose.app.yml` - 앱 서비스 (백엔드, Redis)
- `ml/docker-compose.ml.yml` - ML 서비스
- `Makefile` - 자주 사용하는 Docker Compose 명령어 단축키
- `docker-compose-commands.md` - Docker Compose 명령어 상세 가이드

## 🏗️ 아키텍처

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │    │   ML Inference  │
│   (React.js)    │    │   (FastAPI)     │    │   (FastAPI)     │
│   Port: 80      │    │   Port: 9000    │    │   Port: 8001    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                      │                       │
         └──────────────────────┼───────────────────────┘
                                │
                       ┌─────────────────┐
                       │     Nginx       │
                       │  (Reverse Proxy)│
                       │   Port: 80      │
                       └─────────────────┘
                                │
                       ┌─────────────────┐
                       │     Redis       │
                       │   Port: 6379    │
                       └─────────────────┘
```

## 🚀 서비스 구성

### 공개 서비스 (public/)
- **nginx** (nginx:1.25-alpine) - 리버스 프록시 및 로드 밸런서
- **frontend** (uhok-frontend) - React 프론트엔드 애플리케이션

### 앱 서비스 (app/)
- **backend** (uhok-backend) - Python FastAPI 백엔드 서비스
- **redis** (redis:7-alpine) - 캐시 및 세션 저장소 (프로필: `with-redis`)

### ML 서비스 (ml/)
- **ml-inference** (uhok-ml-inference) - Python ML 서비스

## 🔧 빠른 시작

### 1. 네트워크 생성 (최초 1회)
```bash
# uhok_net 외부 네트워크 생성
docker network create uhok_net
```

### 2. 전체 서비스 실행
```bash
# uhok-deploy 루트에서 실행
make up-all

# 또는 개별 실행
make up          # 웹 서비스 (nginx + frontend)
make up-app      # 앱 서비스 (backend + redis)
make up-ml       # ML 서비스 (ml-inference)
```

### 3. 개별 서비스 실행
```bash
# 백엔드만 실행 (Redis 포함)
make up-backend

# ML 서비스만 실행
make up-ml

# 프론트엔드만 실행
make up-frontend

# Nginx만 실행
make up-nginx
```

## 🎯 주요 기능

### 백엔드 서비스 (uhok-backend)
- **사용자 관리**: JWT 기반 인증 시스템, 회원가입/로그인
- **홈쇼핑 서비스**: 상품 관리, 편성표 조회, 검색, 찜 기능, 라이브 스트리밍
- **콕 서비스**: 상품 관리, 할인 상품, 장바구니, 검색 기능
- **주문 관리**: 통합 주문 시스템, 결제 처리, 웹훅 방식 결제 확인
- **레시피 추천**: 재료 기반 레시피 추천, 하이브리드 추천, 벡터 유사도 검색
- **데이터베이스 연동**: MariaDB, PostgreSQL 지원
- **ML 서비스 연동**: 별도 ML 서비스와 통신

### 프론트엔드 서비스 (uhok-frontend)
- **반응형 웹 UI**: 모바일/데스크톱 지원
- **인증 시스템**: 자동 토큰 갱신, 401 에러 처리
- **레시피 검색**: 키워드 및 재료 기반 검색
- **쇼핑 기능**: 홈쇼핑, 콕 상품 통합 쇼핑
- **사용자 인터페이스**: 직관적인 사용자 경험

### ML 서비스 (uhok-ml-inference)
- **임베딩 생성**: SentenceTransformers 기반 레시피 임베딩
- **모델**: paraphrase-multilingual-MiniLM-L12-v2
- **성능 최적화**: CPU 전용, 컨테이너화된 배포

## 🔍 서비스 상세 정보

### Backend (uhok-backend)
- **포트**: 9000 (내부)
- **헬스체크**: `/api/health`
- **환경변수**: `../uhok-backend/.env` 파일 사용
- **의존성**: MariaDB, PostgreSQL (외부), Redis
- **이미지**: uhok-backend:latest

### Frontend (uhok-frontend)
- **포트**: 80 (내부)
- **빌드**: React 애플리케이션
- **정적 파일**: Nginx를 통해 서빙
- **이미지**: uhok-frontend:latest

### ML Inference (uhok-ml-inference)
- **포트**: 8001 (외부 노출)
- **헬스체크**: `/health`
- **환경변수**: `../uhok-ml-inference/.env` 파일 사용
- **역할**: 임베딩 모델 서비스
- **이미지**: uhok-ml-inference:latest
- **볼륨**: `ml_cache` (모델 캐시)

### Redis
- **포트**: 6379 (내부)
- **볼륨**: `redis_data` (데이터 영속성)
- **프로필**: `with-redis`
- **이미지**: redis:7-alpine

### Nginx
- **포트**: 80 (외부 노출)
- **역할**: 리버스 프록시, 로드 밸런서
- **설정**: `nginx.conf`
- **이미지**: nginx:1.25-alpine
