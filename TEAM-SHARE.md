# M3 SDK PDF 변환 시스템 - 팀 공유 문서

## 📌 프로젝트 개요

**목적:** M3 SDK 마크다운 문서를 전문적인 PDF로 자동 변환
**대상:** 개발자 + 영업/마케팅 팀
**상태:** ✅ 운영 준비 완료 (2025-11-27)

---

## ✨ 주요 기능

### 1. 자동화된 문서 처리
- **자동 목차 생성** - H1~H4 헤더에서 클릭 가능한 TOC 생성
- **Git 버전 히스토리** - main/master 브랜치의 커밋 이력 자동 추출
- **배치 변환** - 스크립트 하나로 모든 문서 일괄 변환

### 2. 전문적인 스타일링
- Java/Kotlin 구문 강조
- 코드 블록 자동 줄바꿈 (PDF 잘림 방지)
- M3 Mobile 브랜드 컬러
- 개발자 + 비즈니스 친화적 디자인

---

## 🚀 사용 방법

### 🎯 포터블 버전 (권장 - 어떤 컴퓨터에서도 실행 가능!)

#### Windows
```powershell
# 자동 경로 탐지
.\convert-all-sdk-docs-portable.ps1

# 또는 경로 직접 지정
.\convert-all-sdk-docs-portable.ps1 -DocsPath "D:\MyProject\docs"
```

#### Linux/macOS
```bash
# 실행 권한 부여 (최초 1회)
chmod +x convert-all-sdk-docs-portable.sh

# 자동 경로 탐지
./convert-all-sdk-docs-portable.sh

# 또는 경로 직접 지정
./convert-all-sdk-docs-portable.sh /home/user/docs
```

### 기존 버전 (현재 컴퓨터 전용)
```powershell
cd C:\Users\M3\MdToPdf
.\convert-all-sdk-docs.ps1
```

### 변환 결과
- **입력:** `C:\Users\M3\Android-Library-M3SDK\docs\` (또는 지정한 경로)
- **출력:** `C:\Users\M3\MdToPdf\output\professional\`
- **변환 시간:** 전체 21개 문서 약 2분
- **성공률:** 100% (21/21)

---

## 📊 현재 상태 (2025-11-27)

### ✅ 완료된 작업

1. **표의 빈 행 문제 해결**
   - CSS 최적화로 완전 해결
   - 테스트 문서로 검증 완료

2. **전체 배치 변환 성공**
   - 21개 문서 모두 변환 완료
   - 총 출력 크기: 13.17MB
   - 실패: 0건

3. **성능 검증 완료**
   - 최대 문서(32KB) 변환 시간: 34.5초
   - 성능 이슈 없음

4. **Git 버전 관리 개선**
   - main/master 브랜치 커밋만 표시
   - Feature 브랜치 커밋 제외

---

## 📁 프로젝트 구조

```
C:\Users\M3\MdToPdf\
├── convert-all-sdk-docs.ps1      # 전체 변환 스크립트 (이거 실행!)
├── preprocess-markdown.js        # TOC/버전히스토리 자동 생성
├── sdk-professional.css          # PDF 스타일 정의
├── .md-to-pdf.json               # 변환 설정
└── output/professional/          # 생성된 PDF 파일
```

---

## 📄 생성되는 PDF 구조

각 PDF는 다음 순서로 자동 구성됩니다:

1. **문서 제목** (H1 헤더)
2. **목차 (TOC)** - 클릭 가능, 같은 페이지에 표시
3. **버전 히스토리** - Git 커밋 이력 (별도 페이지)
4. **본문 내용**

---

## 🔍 알아야 할 사항

### Git 워크플로우
- **Feature 브랜치**에서 문서 작업
- **main/master로 머지** 시에만 버전 히스토리 반영
- PDF 생성 시 main/master 브랜치 커밋만 표시

### 커밋 메시지 규칙 (권장)
```bash
docs: WiFi 설정 API 문서 추가
feat: 새로운 키 매핑 기능 추가
fix: 타이포 수정
```

### 시스템 요구사항
- Node.js (v14+)
- Git
- PowerShell 또는 Bash
- `md-to-pdf` (이미 설치됨)

---

## 💡 빠른 테스트

### 단일 파일 변환 테스트
```bash
cd C:\Users\M3\MdToPdf
node preprocess-markdown.js "test-output.md" "temp.md" "."
md-to-pdf temp.md --config-file .md-to-pdf.json --basedir "C:\Users\M3\MdToPdf"
```

### 실시간 자동 변환 (개발 중)
```powershell
.\watch-and-convert.ps1
```
파일 저장 시 자동으로 PDF 생성됨!

---

## 📚 참고 문서

- `PORTABLE-GUIDE.md` - **포터블 버전 완전 가이드 (필독!)**
- `PORTABLE-COMPARISON.md` - 기존 vs 포터블 버전 비교
- `PROJECT-SUMMARY.md` - 상세 기술 문서 및 이슈 해결 내역
- `README.md` - 전체 사용 설명서
- `INTERNAL-DOC-VERSION-MANAGEMENT.md` - 버전 관리 가이드

---

## 🎯 다음 단계

### 필요한 작업
1. ✅ 생성된 PDF 시각적 검증 (권장)
2. ⏭️ 실제 고객사 전달 준비
3. ⏭️ CI/CD 파이프라인 통합 (선택)

### 주의사항
- Git 추적되지 않는 파일은 버전 히스토리 생성 안 됨
- PowerShell 인코딩 이슈로 이모지 대신 ASCII 문자 사용 ([OK], [X], [!])

---

## 📞 문제 발생 시

1. **PDF가 안 생성되면**
   ```bash
   npm install -g md-to-pdf  # 재설치
   ```

2. **스타일이 안 먹히면**
   - `.md-to-pdf.json`에서 CSS 경로 확인
   - `sdk-professional.css` 파일 존재 확인

3. **버전 히스토리가 비어있으면**
   - 파일이 Git으로 추적되는지 확인
   - main/master 브랜치에 커밋이 있는지 확인

---

## 🔑 핵심 요약

**현재 시스템은 완전히 작동하며 운영 준비가 완료되었습니다.**

- ✅ 21개 문서 변환 성공 (100%)
- ✅ 모든 주요 이슈 해결
- ✅ 자동화 완료
- ✅ 성능 검증 완료

**지금 바로 사용 가능합니다:**

```powershell
# 포터블 버전 (권장 - 어디서나 실행!)
.\convert-all-sdk-docs-portable.ps1

# 기존 버전 (현재 컴퓨터만)
.\convert-all-sdk-docs.ps1
```

---

## 🌍 이식성 (Portability)

### ✅ 다른 컴퓨터에서도 실행 가능!

**포터블 버전을 사용하면:**
- ✅ **다른 Windows PC** - 경로만 지정하면 즉시 실행
- ✅ **Linux 서버** - CI/CD 파이프라인에 바로 통합
- ✅ **macOS** - 개발자 맥북에서도 실행
- ✅ **고객사 전달** - 수정 없이 바로 사용 가능

**상세 가이드:** `PORTABLE-GUIDE.md` 참조

---

**문의사항:** 프로젝트 담당자에게 연락
**최종 업데이트:** 2025-12-05
**버전:** 2.0 (Portable + Production Ready)
