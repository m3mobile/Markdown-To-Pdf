# 기존 vs 포터블 버전 비교

## 📊 빠른 비교표

| 항목 | 기존 버전 | 포터블 버전 |
|------|----------|------------|
| **파일명 (Windows)** | `convert-all-sdk-docs.ps1` | `convert-all-sdk-docs-portable.ps1` |
| **파일명 (Linux)** | `convert-all-sdk-docs.sh` | `convert-all-sdk-docs-portable.sh` |
| **경로 설정** | ❌ 하드코딩 (`C:\Users\M3\...`) | ✅ 자동 탐지 + 매개변수 |
| **다른 PC 실행** | ❌ 불가능 | ✅ 가능 |
| **Linux/macOS** | ⚠️ Git Bash만 (제한적) | ✅ 완전 지원 |
| **대화형 입력** | ❌ 없음 | ✅ 경로 직접 입력 가능 |
| **필수 도구 확인** | ⚠️ md-to-pdf만 | ✅ Node.js, md-to-pdf, Git 모두 확인 |

---

## 🔍 상세 비교

### 1. 경로 처리

#### 기존 버전
```powershell
# 하드코딩됨 - 변경 불가
$DocsDir = "C:\Users\M3\Android-Library-M3SDK\docs"
```
→ 다른 컴퓨터에서는 이 경로가 없어서 실패

#### 포터블 버전
```powershell
# 자동 탐지 + 매개변수 + 대화형 입력
param([string]$DocsPath = "")

# 여러 위치 자동 검색
$possiblePaths = @(
    "C:\Users\M3\Android-Library-M3SDK\docs",
    "..\Android-Library-M3SDK\docs",
    ".\docs",
    ...
)

# 못 찾으면 사용자에게 물어봄
if (not found) {
    $DocsPath = Read-Host "Enter documentation directory path"
}
```
→ 어떤 컴퓨터에서도 작동

---

### 2. 사용 방법

#### 기존 버전
```powershell
# Windows (고정 경로만 사용)
.\convert-all-sdk-docs.ps1

# Linux (Git Bash만)
./convert-all-sdk-docs.sh
```

#### 포터블 버전
```powershell
# Windows - 자동 탐지
.\convert-all-sdk-docs-portable.ps1

# Windows - 경로 지정
.\convert-all-sdk-docs-portable.ps1 -DocsPath "D:\Projects\docs"

# Linux/macOS - 자동 탐지
./convert-all-sdk-docs-portable.sh

# Linux/macOS - 경로 지정
./convert-all-sdk-docs-portable.sh /home/user/docs

# CI/CD - Explorer 안 열기
./convert-all-sdk-docs-portable.sh /path/to/docs --no-open
```

---

### 3. 필수 도구 확인

#### 기존 버전
```powershell
# md-to-pdf만 확인
if (-not (Get-Command md-to-pdf)) {
    exit 1
}
```

#### 포터블 버전
```powershell
# 모든 도구 확인
✓ Node.js (v20.x.x)
✓ md-to-pdf
✓ Git (optional - for version history)
✓ Preprocessor script
✓ Config file
```

---

### 4. OS 지원

#### 기존 버전
```bash
# Linux - Git Bash for Windows 전용
explorer.exe "$(cygpath -w "$OUTPUT_DIR")"
```
→ 순수 Linux에서는 `cygpath` 명령어 없어서 실패

#### 포터블 버전
```bash
# OS 자동 감지
case "$(uname -s)" in
    Linux*)
        xdg-open "$OUTPUT_DIR" || nautilus "$OUTPUT_DIR" || dolphin "$OUTPUT_DIR"
        ;;
    Darwin*)
        open "$OUTPUT_DIR"  # macOS
        ;;
    MINGW*|MSYS*)
        explorer.exe "$(cygpath -w "$OUTPUT_DIR")"  # Windows
        ;;
esac
```
→ 모든 OS에서 작동

---

## 🎯 실제 사용 시나리오

### 시나리오 1: 팀원 컴퓨터 (Windows)

#### 기존 버전
```
❌ 실패 - 경로 C:\Users\M3\... 없음
```

#### 포터블 버전
```powershell
.\convert-all-sdk-docs-portable.ps1 -DocsPath "D:\TeamMember\SDK\docs"
✓ 성공
```

---

### 시나리오 2: Ubuntu 서버 (CI/CD)

#### 기존 버전
```
❌ 실패 - cygpath 명령어 없음
❌ 실패 - explorer.exe 없음
```

#### 포터블 버전
```bash
./convert-all-sdk-docs-portable.sh /var/lib/jenkins/docs --no-open
✓ 성공
```

---

### 시나리오 3: macOS 개발자

#### 기존 버전
```
❌ 실패 - Windows 경로 형식
```

#### 포터블 버전
```bash
./convert-all-sdk-docs-portable.sh ~/Projects/SDK/docs
✓ 성공 (자동으로 Finder 열림)
```

---

## 📦 배포 시나리오

### 시나리오: 고객사에 전달

#### 기존 버전
```
1. 스크립트 전달
2. 고객사: 스크립트 실행
   → ❌ 실패 (경로 하드코딩됨)
3. 개발자: 스크립트 수정 필요
4. 고객사: 다시 실행
   → ✓ 성공
```

#### 포터블 버전
```
1. 스크립트 전달
2. 고객사: 스크립트 실행
   → 경로 입력 요청: /their/docs
   → ✓ 즉시 성공
```

---

## 🔧 기술적 차이

### 경로 처리

#### 기존
```powershell
$DocsDir = "C:\Users\M3\Android-Library-M3SDK\docs"  # 고정
```

#### 포터블
```powershell
# 1. 매개변수로 받기
param([string]$DocsPath = "")

# 2. 여러 위치 자동 검색
foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $DocsPath = $path
        break
    }
}

# 3. 못 찾으면 사용자 입력
if (not found) {
    $DocsPath = Read-Host "Enter path"
}

# 4. 절대 경로로 변환
$DocsPath = Resolve-Path $DocsPath
```

---

### 파일 탐색기 열기

#### 기존 (Windows만)
```powershell
Start-Process explorer.exe $OutputDir
```

#### 포터블 (모든 OS)
```powershell
# Windows
Start-Process explorer.exe $OutputDir

# Linux
xdg-open || nautilus || dolphin

# macOS
open

# CI/CD
--no-open 옵션으로 건너뛰기
```

---

## 💡 언제 어떤 버전을 사용할까?

### 기존 버전 사용 (추천하지 않음)
- ⚠️ 개발 컴퓨터 (C:\Users\M3\...)에서만 사용
- ⚠️ 경로가 항상 동일한 환경

### 포터블 버전 사용 (권장)
- ✅ **팀원들과 공유**
- ✅ **고객사 전달**
- ✅ **CI/CD 파이프라인**
- ✅ **Linux/macOS 환경**
- ✅ **다양한 프로젝트**

---

## 📋 마이그레이션 가이드

### 기존 버전에서 포터블 버전으로 전환

```bash
# 1. 기존 명령어
.\convert-all-sdk-docs.ps1

# 2. 포터블 명령어 (동일한 결과)
.\convert-all-sdk-docs-portable.ps1 -DocsPath "C:\Users\M3\Android-Library-M3SDK\docs"

# 3. 또는 자동 탐지 (경로가 자동으로 찾아짐)
.\convert-all-sdk-docs-portable.ps1
```

**변경 사항 없음 - 동일한 PDF 생성!**

---

## 🎉 결론

### 포터블 버전의 장점

1. ✅ **이식성** - 어떤 컴퓨터에서도 작동
2. ✅ **유연성** - 경로 자동 탐지 + 수동 지정
3. ✅ **호환성** - Windows, Linux, macOS 모두 지원
4. ✅ **안전성** - 필수 도구 사전 확인
5. ✅ **사용성** - 대화형 입력 지원

### 기존 버전의 한계

1. ❌ **고정 경로** - 개발 PC만 작동
2. ❌ **이식 불가** - 다른 컴퓨터에서 수정 필요
3. ❌ **제한적 OS** - Git Bash만 지원

---

## 📝 최종 권장사항

**포터블 버전을 사용하세요!**

```powershell
# Windows
.\convert-all-sdk-docs-portable.ps1

# Linux/macOS
./convert-all-sdk-docs-portable.sh
```

**기존 버전은 deprecated (사용 중단 권장)**
