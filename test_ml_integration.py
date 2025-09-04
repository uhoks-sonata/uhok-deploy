#!/usr/bin/env python3
"""
ML 서비스와 백엔드 통합 테스트 스크립트
"""

import asyncio
import httpx
import json
import time
from typing import Dict, Any

# 테스트 설정
ML_SERVICE_URL = "http://localhost:8001"
BACKEND_URL = "http://localhost:5000"

async def test_ml_service_direct():
    """ML 서비스 직접 테스트"""
    print("🔍 ML 서비스 직접 테스트...")
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            # 헬스체크
            health_response = await client.get(f"{ML_SERVICE_URL}/health")
            health_response.raise_for_status()
            health_data = health_response.json()
            print(f"✅ ML 서비스 헬스체크: {health_data}")
            
            # 임베딩 생성
            embed_response = await client.post(
                f"{ML_SERVICE_URL}/api/v1/embed",
                json={"text": "갈비탕", "normalize": True}
            )
            embed_response.raise_for_status()
            embed_data = embed_response.json()
            print(f"✅ 임베딩 생성: 차원={embed_data['dim']}, 벡터 길이={len(embed_data['embedding'])}")
            
            return True
    except Exception as e:
        print(f"❌ ML 서비스 테스트 실패: {e}")
        return False

async def test_backend_ml_integration():
    """백엔드 ML 서비스 통합 테스트"""
    print("\n🔍 백엔드 ML 서비스 통합 테스트...")
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            # 백엔드 헬스체크
            health_response = await client.get(f"{BACKEND_URL}/api/health")
            health_response.raise_for_status()
            print(f"✅ 백엔드 헬스체크 성공")
            
            # 레시피 검색 (ML 서비스 사용)
            search_response = await client.get(
                f"{BACKEND_URL}/api/recipes/search",
                params={
                    "recipe": "갈비탕",
                    "method": "recipe",
                    "page": 1,
                    "size": 3
                },
                headers={"Authorization": "Bearer test_token"}
            )
            
            if search_response.status_code == 200:
                search_data = search_response.json()
                print(f"✅ 레시피 검색 성공: 결과 수={len(search_data.get('recipes', []))}")
                return True
            else:
                print(f"⚠️ 레시피 검색 응답: {search_response.status_code}")
                return False
                
    except Exception as e:
        print(f"❌ 백엔드 통합 테스트 실패: {e}")
        return False

async def test_ml_service_logs():
    """ML 서비스 로그 확인"""
    print("\n🔍 ML 서비스 로그 확인...")
    try:
        import subprocess
        result = subprocess.run(
            ["docker-compose", "logs", "ml-inference", "--tail=10"],
            capture_output=True,
            text=True,
            cwd="."
        )
        
        if result.returncode == 0:
            logs = result.stdout
            if "embed" in logs.lower() or "request" in logs.lower():
                print("✅ ML 서비스 요청 로그 발견")
                return True
            else:
                print("⚠️ ML 서비스 요청 로그 없음")
                return False
        else:
            print(f"❌ 로그 확인 실패: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"❌ 로그 확인 실패: {e}")
        return False

async def main():
    """메인 테스트 함수"""
    print("🚀 ML 서비스 통합 테스트 시작")
    print("=" * 50)
    
    # 1. ML 서비스 직접 테스트
    ml_ok = await test_ml_service_direct()
    
    # 2. 백엔드 통합 테스트
    backend_ok = await test_backend_ml_integration()
    
    # 3. 로그 확인
    logs_ok = await test_ml_service_logs()
    
    # 결과 요약
    print("\n📊 테스트 결과 요약")
    print("=" * 50)
    print(f"ML 서비스 직접 테스트: {'✅ 성공' if ml_ok else '❌ 실패'}")
    print(f"백엔드 통합 테스트: {'✅ 성공' if backend_ok else '❌ 실패'}")
    print(f"ML 서비스 로그 확인: {'✅ 성공' if logs_ok else '❌ 실패'}")
    
    if ml_ok and backend_ok:
        print("\n🎉 ML 서비스가 백엔드에서 정상적으로 사용되고 있습니다!")
    else:
        print("\n⚠️ 일부 테스트가 실패했습니다. 로그를 확인해주세요.")

if __name__ == "__main__":
    asyncio.run(main())
