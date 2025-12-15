# 포터블 PDF 변환 스크립트 가이드

## 📦 개요

이 포터블 버전은 **어떤 컴퓨터에서도** 실행 가능하도록 설계되었습니다.

- ✅ **Windows** - `convert-all-sdk-docs-portable.ps1`
- ✅ **Linux/macOS** - `convert-all-sdk-docs-portable.sh`

---

## 🎯 질문에 대한 답변

### 1. 다른 Windows 컴퓨터에서 실행 가능한가?

**✅ YES** - 포터블 버전(`convert-all-sdk-docs-portable.ps1`)을 사용하면 가능합니다!

**필요한 것:**
- Node.js (v14+)
- `npm install -g md-to-pdf`
- 이 프로젝트 폴더 전체 (MdToPdf)

**실행 방법:**
```powershell
# 문서 경로를 지정해서 실행
.\convert-all-sdk-docs-portable.ps1 -DocsPath "D:\MyProject\docs"

# 또는 경로 없이 실행 (자동으로 찾거나 물어봄)
.\convert-all-sdk-docs-portable.ps1
```

### 2. Linux 컴퓨터에서도 실행 가능한가?

**✅ YES** - 포터블 Bash 버전(`convert-all-sdk-docs-portable.sh`)을 사용하면 가능합니다!

**필요한 것:**
- Node.js (v14+)
- `npm install -g md-to-pdf`
- 이 프로젝트 폴더 전체 (MdToPdf)

**실행 방법:**
```bash
# 실행 권한 부여 (최초 1회)
chmod +x convert-all-sdk-docs-portable.sh

# 문서 경로를 지정해서 실행
./convert-all-sdk-docs-portable.sh /home/user/projects/docs

# 또는 경로 없이 실행 (자동으로 찾거나 물어봄)
./convert-all-sdk-docs-portable.sh
```

---

## 🚀 사용 방법

### Windows (PowerShell)

#### 기본 실행
```powershell
.\convert-all-sdk-docs-portable.ps1
```
→ 자동으로 문서 폴더를 찾거나, 못 찾으면 경로를 물어봅니다.

#### 경로 지정 실행
```powershell
.\convert-all-sdk-docs-portable.ps1 -DocsPath "C:\Projects\SDK\docs"
```

#### Explorer 열기 건너뛰기
```powershell
.\convert-all-sdk-docs-portable.ps1 -DocsPath "C:\Projects\SDK\docs" -SkipExplorer
```

### Linux / macOS

#### 기본 실행
```bash
./convert-all-sdk-docs-portable.sh
```

#### 경로 지정 실행
```bash
./convert-all-sdk-docs-portable.sh /home/user/projects/docs
```

#### 파일 탐색기 열기 건너뛰기
```bash
./convert-all-sdk-docs-portable.sh /home/user/projects/docs --no-open
```

---

## 📋 자동 경로 탐지

스크립트는 다음 위치를 자동으로 검색합니다:

### Windows
1. `C:\Users\M3\Android-Library-M3SDK\docs`
2. `..\Android-Library-M3SDK\docs`
3. `.\docs`
4. `.\sdk-docs`
5. `..\docs`

### Linux/macOS
1. `$SCRIPT_DIR/../Android-Library-M3SDK/docs`
2. `$SCRIPT_DIR/docs`
3. `$SCRIPT_DIR/sdk-docs`
4. `$HOME/Android-Library-M3SDK/docs`
5. `$HOME/Projects/Android-Library-M3SDK/docs`

찾지 못하면 사용자에게 직접 입력을 요청합니다.

---

## 📦 이식(배포) 방법

### 방법 1: 전체 폴더 복사

다른 컴퓨터로 이동할 때 **다음 파일들만** 복사하면 됩니다:

```
MdToPdf/
├── convert-all-sdk-docs-portable.ps1   # Windows용
├── convert-all-sdk-docs-portable.sh    # Linux/macOS용
├── preprocess-markdown.js              # 전처리 스크립트
├── .md-to-pdf.json                     # PDF 설정
├── sdk-professional.css                # 스타일시트
└── package.json                        # npm 설정
```

**불필요한 파일 (복사 안 해도 됨):**
- `output/` - 생성된 PDF (자동 생성됨)
- `node_modules/` - npm 패키지 (자동 설치됨)
- `*.pdf` - 테스트 파일
- `CHANGELOG.md`, `PROJECT-SUMMARY.md` 등

### 방법 2: ZIP 배포

```bash
# 필수 파일만 압축 (Windows)
Compress-Archive -Path `
  convert-all-sdk-docs-portable.ps1, `
  convert-all-sdk-docs-portable.sh, `
  preprocess-markdown.js, `
  .md-to-pdf.json, `
  sdk-professional.css, `
  package.json `
  -DestinationPath MdToPdf-Portable.zip

# 필수 파일만 압축 (Linux/macOS)
zip MdToPdf-Portable.zip \
  convert-all-sdk-docs-portable.ps1 \
  convert-all-sdk-docs-portable.sh \
  preprocess-markdown.js \
  .md-to-pdf.json \
  sdk-professional.css \
  package.json
```

---

## 🔧 새 컴퓨터에서 설정

### Windows

```powershell
# 1. Node.js 설치 (https://nodejs.org/)
# 다운로드 후 설치

# 2. md-to-pdf 설치
npm install -g md-to-pdf

# 3. npm 패키지 설치 (선택사항)
cd MdToPdf
npm install

# 4. 실행!
.\convert-all-sdk-docs-portable.ps1
```

### Linux/macOS

```bash
# 1. Node.js 설치
# Ubuntu/Debian
sudo apt update
sudo apt install nodejs npm

# macOS (Homebrew)
brew install node

# 2. md-to-pdf 설치
sudo npm install -g md-to-pdf

# 3. npm 패키지 설치 (선택사항)
cd MdToPdf
npm install

# 4. 실행 권한 부여
chmod +x convert-all-sdk-docs-portable.sh

# 5. 실행!
./convert-all-sdk-docs-portable.sh
```

---

## ✨ 주요 개선 사항

### 기존 스크립트와 비교

| 기능 | 기존 버전 | 포터블 버전 |
|------|----------|------------|
| **경로 하드코딩** | ❌ `C:\Users\M3\...` 고정 | ✅ 자동 탐지 + 매개변수 |
| **타 컴퓨터 실행** | ❌ 불가능 | ✅ 가능 |
| **Linux 지원** | ⚠️ Git Bash만 | ✅ 모든 Linux/macOS |
| **경로 자동 탐색** | ❌ 없음 | ✅ 여러 위치 자동 검색 |
| **대화형 입력** | ❌ 없음 | ✅ 경로 직접 입력 가능 |
| **필수 도구 확인** | ⚠️ 일부만 | ✅ Node.js, md-to-pdf, Git 모두 확인 |
| **파일 탐색기 열기** | Windows만 | ✅ Windows, Linux, macOS 모두 지원 |

---

## 🧪 테스트 시나리오

### 시나리오 1: 완전히 다른 Windows PC

```powershell
# 팀원 PC (D:\Projects\SDK\docs)
.\convert-all-sdk-docs-portable.ps1 -DocsPath "D:\Projects\SDK\docs"
```

### 시나리오 2: Linux 서버 (CI/CD)

```bash
# Ubuntu 서버
./convert-all-sdk-docs-portable.sh /var/lib/jenkins/workspace/sdk/docs --no-open
```

### 시나리오 3: macOS 개발자

```bash
# macOS
./convert-all-sdk-docs-portable.sh ~/Projects/Android-SDK/docs
```

### 시나리오 4: 경로를 모를 때

```powershell
# Windows - 대화형 모드
.\convert-all-sdk-docs-portable.ps1

# 스크립트가 물어봄:
# "Enter documentation directory path: "
# 입력: C:\MyDocs
```

---

## 🔍 문제 해결

### "md-to-pdf is not installed"

```bash
npm install -g md-to-pdf
```

### "Node.js is not installed"

- **Windows**: https://nodejs.org/ 에서 설치
- **Ubuntu**: `sudo apt install nodejs npm`
- **macOS**: `brew install node`

### "Documentation directory not found"

절대 경로로 다시 시도:
```powershell
# Windows
.\convert-all-sdk-docs-portable.ps1 -DocsPath "C:\Full\Path\To\Docs"

# Linux
./convert-all-sdk-docs-portable.sh /full/path/to/docs
```

### Linux에서 "Permission denied"

```bash
chmod +x convert-all-sdk-docs-portable.sh
```

### 파일 탐색기가 안 열림

옵션을 추가해서 건너뛰기:
```powershell
# Windows
.\convert-all-sdk-docs-portable.ps1 -SkipExplorer

# Linux
./convert-all-sdk-docs-portable.sh --no-open
```

---

## 📝 예제: 실제 사용 시나리오

### 예제 1: 고객사 전달

```bash
# 1. 필수 파일만 압축
zip -r SDK-PDF-Generator.zip \
  convert-all-sdk-docs-portable.* \
  preprocess-markdown.js \
  .md-to-pdf.json \
  sdk-professional.css \
  package.json \
  PORTABLE-GUIDE.md

# 2. 고객사에 전달
# - SDK-PDF-Generator.zip
# - PORTABLE-GUIDE.md (사용 설명서)

# 3. 고객사에서 실행
unzip SDK-PDF-Generator.zip
./convert-all-sdk-docs-portable.sh /path/to/their/docs
```

### 예제 2: CI/CD 파이프라인

```yaml
# .github/workflows/generate-pdf.yml
name: Generate SDK PDFs

on:
  push:
    paths:
      - 'docs/**/*.md'

jobs:
  convert:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'

      - name: Install md-to-pdf
        run: npm install -g md-to-pdf

      - name: Convert to PDF
        run: |
          cd MdToPdf
          chmod +x convert-all-sdk-docs-portable.sh
          ./convert-all-sdk-docs-portable.sh ../docs --no-open

      - name: Upload PDFs
        uses: actions/upload-artifact@v3
        with:
          name: sdk-documentation
          path: MdToPdf/output/professional/**/*.pdf
```

---

## 🎓 요약

### ✅ 답변

1. **다른 Windows 환경에서 실행 가능?**
   - YES - `convert-all-sdk-docs-portable.ps1` 사용

2. **Linux에서도 실행 가능?**
   - YES - `convert-all-sdk-docs-portable.sh` 사용

3. **같은 결과 생성?**
   - YES - 두 스크립트 모두 동일한 PDF 생성

### 📦 배포 체크리스트

- [ ] Node.js 설치됨
- [ ] `npm install -g md-to-pdf` 실행됨
- [ ] 필수 파일 6개 복사됨
- [ ] Linux에서는 `chmod +x` 실행됨
- [ ] 문서 경로 확인됨
- [ ] 스크립트 실행 성공

---

**이제 어떤 컴퓨터에서도 실행 가능합니다!** 🎉
