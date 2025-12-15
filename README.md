# M3 Mobile SDK - Professional PDF Generator

**간단하고 자동화된 마크다운 → PDF 변환 도구**

안드로이드 코틀린/자바 SDK 문서를 개발자와 영업/마케팅 모두를 위한 전문적인 PDF로 자동 변환합니다.

## 🎯 주요 기능

### 📑 문서 구조
- ✅ **자동 목차 생성** - 마크다운 헤더에서 클릭 가능한 TOC 자동 생성
- ✅ **Git 버전 이력** - 문서의 커밋 히스토리 자동 추가 (Git 관리 파일만)
- ✅ **스마트 페이지 구성** - 제목 → TOC → 버전 이력 → 본문 순서로 배치

### 🎨 스타일 & 품질
- ✅ **완전 자동화** - 스크립트 하나로 모든 문서 변환
- ✅ **Java/Kotlin 구문 강조** - 완벽한 코드 하이라이팅
- ✅ **전문적인 스타일** - 개발자 + 비즈니스 친화적
- ✅ **간격 최적화** - 헤더/코드블록 간격 조정

### ⚙️ 편의 기능
- ✅ **자동 감시 모드** - 파일 저장 시 자동 PDF 생성
- ✅ **LaTeX 불필요** - 복잡한 설치 과정 없음

## 🎁 동료에게 공유하기 - 처음 설치 가이드

이 폴더를 받은 동료는 다음 3단계만 실행하면 바로 사용 가능합니다:

### 1단계: Node.js 설치 확인
```bash
node --version
# v14 이상이 설치되어 있어야 합니다
# 없다면 https://nodejs.org/ 에서 설치
```

### 2단계: 로컬 의존성 설치
```bash
# 이 프로젝트 폴더에서 실행
npm install
```
이 명령은 다음을 설치합니다:
- marked (마크다운 파싱)
- simple-git (Git 히스토리 추출)

### 3단계: md-to-pdf 전역 도구 설치
```bash
npm install -g md-to-pdf
```

### 4단계: 스크립트 실행
**PowerShell (Windows):**
```powershell
.\convert-all-sdk-docs-portable.ps1
```

**Bash (Linux/macOS/Git Bash):**
```bash
chmod +x convert-all-sdk-docs-portable.sh
./convert-all-sdk-docs-portable.sh
```

**결과**: `output/professional/` 폴더에 PDF 파일들이 생성됩니다!

### ⚠️ 필수 확인사항
- ✅ Node.js v14 이상 설치
- ✅ `npm install` 실행 완료
- ✅ `npm install -g md-to-pdf` 실행 완료
- ✅ Git 설치 (선택사항, 버전 히스토리 기능용)

### 💡 문제 해결
**"md-to-pdf를 찾을 수 없습니다" 오류:**
```bash
npm install -g md-to-pdf
```

**"marked 모듈을 찾을 수 없습니다" 오류:**
```bash
npm install
```

**"권한이 없습니다" 오류 (Linux/macOS):**
```bash
chmod +x convert-all-sdk-docs-portable.sh
```

## 🚀 빠른 시작

### 1. 필수 요구사항

```bash
# Node.js가 설치되어 있는지 확인
node --version  # v20 이상 권장

# md-to-pdf 전역 도구 설치
npm install -g md-to-pdf

# 프로젝트 의존성 설치 (처음 한 번만)
npm install
```

### 2. 모든 SDK 문서를 한 번에 변환

**PowerShell (권장):**
```powershell
.\convert-all-sdk-docs.ps1
```

**Git Bash / Linux:**
```bash
./convert-all-sdk-docs.sh
```

**결과:** `output/professional/` 폴더에 모든 PDF 생성

### 3. 단일 파일 변환

```bash
# 현재 디렉토리에서 실행 (.md-to-pdf.json 자동 사용)
md-to-pdf path/to/your-document.md --config-file .md-to-pdf.json --basedir .
```

### 4. 자동 감시 모드 (파일 저장 시 자동 변환)

**PowerShell:**
```powershell
.\watch-and-convert.ps1
```

**Git Bash:**
```bash
./watch-and-convert.sh
```

파일을 저장할 때마다 자동으로 PDF가 업데이트됩니다!

## 📁 프로젝트 구조

```
MdToPdf/
├── package.json                 # npm 패키지 설정
├── node_modules/                # npm 의존성 (marked, simple-git)
├── preprocess-markdown.js       # TOC & Git 이력 전처리 스크립트
├── .md-to-pdf.json              # PDF 변환 설정
├── sdk-professional.css         # 전문적인 스타일시트 (TOC/버전이력 포함)
├── convert-all-sdk-docs.ps1     # 전체 변환 (PowerShell)
├── convert-all-sdk-docs.sh      # 전체 변환 (Bash)
├── watch-and-convert.ps1        # 자동 감시 (PowerShell)
├── watch-and-convert.sh         # 자동 감시 (Bash)
├── output/
│   ├── temp/                    # 임시 전처리 파일 (자동 삭제)
│   └── professional/            # 생성된 PDF 파일
│       ├── keytool/
│       ├── startup/
│       └── ...
├── README.md                    # 상세 설명서
├── QUICK-START.md               # 빠른 시작 가이드
└── CHANGELOG.md                 # 변경 이력
```

## 🎨 스타일 커스터마이징

### 색상 변경

`sdk-professional.css` 파일 상단의 변수를 수정:

```css
:root {
  --primary-color: #0066cc;      /* M3 Blue */
  --secondary-color: #0052a3;    /* Dark Blue */
  --accent-color: #00aaff;       /* Light Blue */
  /* ... */
}
```

### 간격 조정

```css
/* 헤더와 코드블록 사이 간격 */
h1, h2, h3 {
  margin-bottom: 1.5em;  /* 원하는 값으로 변경 */
}

pre {
  margin-top: 20pt;      /* 위 간격 */
  margin-bottom: 24pt;   /* 아래 간격 */
}
```

### 코드 블록 폰트 크기

```css
pre code {
  font-size: 9pt;  /* 8pt ~ 11pt 권장 */
}
```

### 페이지 여백

`.md-to-pdf.json` 파일에서:

```json
{
  "pdf_options": {
    "margin": {
      "top": "25mm",
      "right": "20mm",
      "bottom": "25mm",
      "left": "20mm"
    }
  }
}
```

## 📊 생성 결과

### PDF 구조

각 PDF는 다음 순서로 구성됩니다:

1. **제목 페이지** - 문서 타이틀 (H1 헤더)
2. **📑 목차 (Table of Contents)** - 자동 생성된 클릭 가능한 목차
   - H2-H4 헤더로부터 추출
   - 계층적 들여쓰기
   - 클릭 시 해당 섹션으로 이동
3. **📜 문서 버전 이력** - Git 커밋 히스토리 (Git 관리 파일만)
   - 버전 번호 (v3.0, v2.0, v1.0...)
   - 커밋 해시, 날짜, 작성자, 변경 내용
   - 최근 10개 커밋 표시
4. **본문 내용** - 원본 마크다운 컨텐츠

### 스타일 특징

- **타이포그래피**: Segoe UI / 맑은 고딕 (한글 지원)
- **코드 폰트**: Consolas / Monaco
- **구문 강조**: GitHub 스타일 (Java, Kotlin 최적화)
- **표**: 그라디언트 헤더, 번갈아가는 행 색상
- **목차**: 파란색 링크, 계층적 들여쓰기
- **버전 이력**: 노란색 배경, 모노스페이스 버전 번호
- **페이지**: A4, 헤더/푸터 포함, 페이지 번호
- **노트/경고**: 색상으로 구분된 박스

### 파일 크기

- 평균 PDF 크기: ~500-1100 KB (TOC + 버전 이력 포함)
- 전체 문서 세트: ~14 MB (20개 파일)
- TOC/버전 이력으로 인한 추가 크기: 약 100-200 KB/파일

## 🔧 고급 사용법

### 특정 카테고리만 변환

```bash
# keytool 문서만 변환
find /c/Users/M3/Android-Library-M3SDK/docs/keytool -name "*-english.md" | while read file; do
  md-to-pdf "$file" --config-file .md-to-pdf.json --basedir .
done
```

### Word 파일(.docx)도 필요한 경우

```bash
# Pandoc 사용 (설치 필요)
pandoc input.md -o output.docx

# 또는 온라인 도구
# https://markdowntoword.net
```

### CI/CD 통합 (GitHub Actions)

`.github/workflows/generate-pdfs.yml`:

```yaml
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
          ./convert-all-sdk-docs.sh

      - name: Upload PDFs
        uses: actions/upload-artifact@v3
        with:
          name: sdk-documentation
          path: MdToPdf/output/professional/**/*.pdf
```

## ❓ FAQ

### Q: PDF 생성 시간이 얼마나 걸리나요?
**A:** 파일당 2-5초, 전체 문서는 1-2분 정도 소요됩니다.

### Q: 한글이 깨지나요?
**A:** 아니요. 맑은 고딕 폰트를 사용하여 완벽하게 지원합니다.

### Q: Java/Kotlin 구문 강조가 제대로 되나요?
**A:** 네! highlight.js의 GitHub 스타일을 사용하여 완벽하게 지원합니다.

### Q: 이전 Pandoc 시스템과 비교하면?
**A:**
- ✅ 설치 훨씬 간단 (LaTeX 불필요)
- ✅ 변환 속도 더 빠름
- ✅ 자동화 쉬움
- ✅ 스타일 커스터마이징 직관적 (CSS)

### Q: 표(Table)가 길면 어떻게 되나요?
**A:** 자동으로 페이지가 나뉘어집니다. `page-break-inside: avoid`로 행이 분리되지 않습니다.

### Q: 목차(TOC)를 추가하려면?
**A:** 마크다운 파일 상단에 추가:

```markdown
# Table of Contents

- [Overview](#overview)
- [API Reference](#api-reference)
- [Examples](#examples)
```

## 🆚 비교: 이전 vs 현재

| 항목 | Pandoc + LaTeX | md-to-pdf |
|------|----------------|-----------|
| 설치 복잡도 | ⭐⭐⭐⭐⭐ (매우 복잡) | ⭐ (매우 간단) |
| 변환 속도 | 느림 (10-20초/파일) | 빠름 (2-5초/파일) |
| 스타일 수정 | 어려움 (LaTeX) | 쉬움 (CSS) |
| 자동화 | 복잡 | 매우 쉬움 |
| 구문 강조 | 보통 | 우수 |
| 간격 조정 | 복잡 | 쉬움 |

## 📝 사용 예시

### 예시 1: 개발 중 실시간 미리보기

```bash
# 터미널 1: 파일 감시
./watch-and-convert.sh

# VS Code에서 문서 편집 → 저장
# → 자동으로 PDF 생성
# → PDF 뷰어가 자동 새로고침
```

### 예시 2: 릴리스 전 전체 문서 생성

```powershell
# 모든 문서 변환
.\convert-all-sdk-docs.ps1

# output/professional 폴더 → ZIP
Compress-Archive -Path .\output\professional\* -DestinationPath SDK-Documentation.zip

# 고객사에 전달
```

### 예시 3: 특정 문서만 빠르게 변환

```bash
# 한 파일만
md-to-pdf docs/keytool/sl-series-key-setting-sdk-english.md --config-file .md-to-pdf.json --basedir .

# 생성된 PDF를 바로 열기
start docs/keytool/sl-series-key-setting-sdk-english.pdf
```

## 🎓 팁 & 베스트 프랙티스

### 1. 마크다운 작성 팁

```markdown
<!-- 코드블록에 언어 명시 (구문 강조에 중요!) -->
```java
Intent intent = new Intent();
```

<!-- 표는 간단하게 -->
| Parameter | Type | Description |
|-----------|------|-------------|
| key | String | The key name |

<!-- 노트/경고는 blockquote -->
> **Note:**
> This feature requires API level 28+
```

### 2. 성능 최적화

- 이미지는 적절한 크기로 (800px 이하 권장)
- 한 문서에 50개 이상의 코드블록은 피하기
- 표는 20개 컬럼 이하로

### 3. 버전 관리

```bash
# Git에 포함할 것
git add .md-to-pdf.json sdk-professional.css convert-all-sdk-docs.*

# Git에서 제외할 것 (.gitignore)
output/
node_modules/
*.pdf
```

## 📞 문제 해결

### PDF가 생성되지 않아요

```bash
# 1. md-to-pdf 재설치
npm uninstall -g md-to-pdf
npm install -g md-to-pdf

# 2. 권한 확인
ls -la .md-to-pdf.json sdk-professional.css

# 3. 경로 확인
pwd  # MdToPdf 디렉토리에 있는지 확인
```

### 스타일이 적용되지 않아요

```bash
# CSS 파일 경로 확인
ls -la sdk-professional.css

# 설정 파일 확인
cat .md-to-pdf.json | grep stylesheet
```

### 구문 강조가 안 돼요

마크다운에서 언어를 명시했는지 확인:

```markdown
<!-- ❌ 잘못됨 -->
```
code here
```

<!-- ✅ 올바름 -->
```java
code here
```
```

## 🔗 참고 자료

- [md-to-pdf GitHub](https://github.com/simonhaenisch/md-to-pdf)
- [Markdown Guide](https://www.markdownguide.org/)
- [Highlight.js](https://highlightjs.org/)
- [CSS for Print](https://www.smashingmagazine.com/2015/01/designing-for-print-with-css/)

---

**최종 업데이트**: 2025-11-24
**버전**: 1.0.0
**제작**: M3 Mobile 문서화 팀

**✨ 간단하게 시작하세요:**
```powershell
.\convert-all-sdk-docs.ps1
```
