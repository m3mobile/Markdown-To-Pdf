# M3 SDK 문서 - 버전 관리 가이드

**개발팀 내부 문서**

> ⚠️ **주의:** 이 문서는 내부용이며 고객사에서는 읽을 필요가 없습니다.

**최종 업데이트:** 2025-11-24
**버전:** 1.0
**담당자:** M3 Mobile 문서화 팀

---

## 📋 목차

- [개요](#개요)
- [문서 구조](#문서-구조)
- [Git 커밋 컨벤션](#git-커밋-컨벤션)
- [버저닝 전략](#버저닝-전략)
- [릴리스 프로세스](#릴리스-프로세스)
- [자동화 워크플로우](#자동화-워크플로우)
- [팀 협업](#팀-협업)
- [베스트 프랙티스](#베스트-프랙티스)
- [문제 해결](#문제-해결)
- [도구 및 명령어](#도구-및-명령어)

---

## 개요

### 목적

이 가이드는 Git, 자동 PDF 생성, 버전 추적을 사용하여 여러 SDK 문서 파일을 효율적으로 관리하기 위한 표준을 수립합니다.

### 핵심 원칙

1. **단일 진실 공급원 (Single Source of Truth)**: Git 저장소의 마크다운 파일
2. **자동 버전 추적**: Git 커밋 히스토리 → PDF 버전 히스토리
3. **일관된 컨벤션**: 표준화된 커밋 메시지 및 버저닝
4. **자동 생성**: PDF 생성을 위한 CI/CD 파이프라인
5. **쉬운 협업**: 명확한 리뷰 및 승인 프로세스

### 현재 시스템 아키텍처

```
Android-Library-M3SDK/
├── docs/
│   ├── startup/           # Startup 설정 SDK
│   ├── keytool/           # 키 리매핑 SDK
│   └── scanemul/          # 스캐너 에뮬레이션 SDK (향후)
└── .github/workflows/     # CI/CD 자동화

MdToPdf/
├── preprocess-markdown.js # TOC 및 Git 히스토리 생성기
├── convert-all-sdk-docs.* # 일괄 변환 스크립트
└── output/professional/   # 생성된 PDF
```

---

## 문서 구조

### 권장 폴더 구조

```
docs/
├── startup/
│   ├── wifi/
│   │   ├── wifi-stability-sdk-en.md
│   │   └── wifi-stability-sdk-ko.md
│   ├── app/
│   │   ├── apk-install-sdk-en.md
│   │   └── apk-install-sdk-ko.md
│   └── README.md
├── keytool/
│   ├── sl-series-key-setting-sdk-english.md
│   ├── sl-series-key-setting-sdk-korean.md
│   └── README.md
└── scanemul/
    ├── barcode-emulation-sdk-en.md
    └── README.md
```

### 파일 명명 규칙

**패턴:** `[기능명]-sdk-[언어].md`

**예시:**
```
✅ wifi-stability-sdk-en.md
✅ apk-install-sdk-ko.md
✅ sl-series-key-setting-sdk-english.md

❌ wifi_stability.md
❌ APKInstall-SDK.md
❌ keySettingDoc-EN.md
```

**언어 코드:**
- `en` 또는 `english` - 영어
- `ko` 또는 `korean` - 한국어

### 문서 구조 템플릿

```markdown
# [SDK 이름]

> **Note:**
> 시스템 요구사항, 버전 호환성, 지원 디바이스

## 개요

이 SDK가 무엇을 하는지에 대한 간략한 설명.

## 빠른 시작

### 기본 사용법
[가장 간단한 예시 코드]

## API 레퍼런스

### 메서드/브로드캐스트/인텐트
[상세 스펙]

## 완전한 예시

### Java 구현
[전체 작동 예시]

### Kotlin 구현
[전체 작동 예시]

## 테스트

### ADB 명령어
[커맨드라인 테스트 예시]

## 에러 처리

[일반적인 오류 및 해결책]

## FAQ

[자주 묻는 질문]
```

---

## Git 커밋 컨벤션

### 커밋 메시지 형식

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### 타입 (Types)

| 타입 | 설명 | 예시 |
|------|-------------|---------|
| `docs` | 문서 변경 | `docs(startup): Add WiFi configuration guide` |
| `feat` | 새로운 문서/섹션 | `feat(keytool): Add WD10 device support` |
| `fix` | 오타, 오류 수정 | `fix(scanemul): Correct API parameter type` |
| `refactor` | 내용 변경 없이 재구성 | `refactor(all): Reorganize folder structure` |
| `style` | 포맷, 마크다운 수정 | `style(keytool): Fix code block indentation` |
| `release` | 버전 릴리스 | `release: v2.1.0 - Major documentation update` |

### 스코프 (Scope) 예시

- `startup` - Startup 설정 SDK
- `keytool` - 키 리매핑 SDK
- `scanemul` - 스캐너 에뮬레이션 SDK
- `all` - 여러 카테고리에 영향

### 실제 예시

```bash
# 기능 추가
git commit -m "docs(startup): Add WiFi channel configuration examples"

# 버그 수정
git commit -m "fix(keytool): Correct key mapping table for SL20P"

# 여러 파일
git commit -m "docs: Update all SDK versions to 2.1.0

- startup: Add new WiFi stability options
- keytool: Update wake-up control API
- scanemul: Add barcode format support list"

# 릴리스
git commit -m "release: v2.1.0

Major updates:
- Enhanced WiFi configuration options
- New key mapping features for WD10
- Improved error handling examples"
```

### 하지 말아야 할 커밋

```bash
❌ git commit -m "update"
❌ git commit -m "fixed stuff"
❌ git commit -m "Changes to docs"
❌ git commit -m "WIP"
```

---

## 버저닝 전략

### Semantic Versioning (시맨틱 버저닝)

문서 릴리스에 **Semantic Versioning 2.0.0**을 사용합니다.

**형식:** `MAJOR.MINOR.PATCH`

```
v2.1.3
│ │ │
│ │ └─ PATCH: 버그 수정, 오타, 명확화
│ └─── MINOR: 새로운 섹션, 예시, 호환 가능한 추가
└───── MAJOR: 재구성, 호환성 깨짐, 대규모 재작성
```

### 예시

| 버전 | 변경사항 | 이유 |
|---------|--------|--------|
| `v1.0.0` | 최초 릴리스 | 첫 버전 |
| `v1.1.0` | 새로운 API 메서드 추가 | 새 내용 (MINOR) |
| `v1.1.1` | 예시 오타 수정 | 버그 수정 (PATCH) |
| `v2.0.0` | 완전 재작성 | 호환성 깨짐 (MAJOR) |

### 버전을 올려야 하는 경우

**MAJOR (1.x.x → 2.0.0):**
- 완전한 문서 재구성
- 이전 버전과 API 호환성 없음
- 주요 기능/섹션 제거

**MINOR (1.1.x → 1.2.0):**
- 새로운 SDK 기능 문서화
- 새로운 예시나 섹션 추가
- 향상된 설명

**PATCH (1.1.1 → 1.1.2):**
- 오타 수정
- 코드 예시 수정
- 기존 내용 명확화
- 링크 업데이트

### Git에서 버전 태그

```bash
# 주석 태그 생성
git tag -a v2.1.0 -m "Release 2.1.0: Enhanced WiFi configuration"

# 원격에 태그 푸시
git push origin v2.1.0

# 모든 태그 목록
git tag -l

# 태그 삭제 (실수한 경우)
git tag -d v2.1.0
git push origin :refs/tags/v2.1.0
```

---

## 릴리스 프로세스

### 릴리스 전 체크리스트

```markdown
## 릴리스 체크리스트

### 문서 리뷰
- [ ] 모든 마크다운 파일이 올바르게 포맷되어 있음
- [ ] 코드 예시가 테스트되고 작동함
- [ ] 링크가 유효함 (깨진 링크 없음)
- [ ] 목차가 내용과 일치함
- [ ] 스크린샷/이미지가 최신임
- [ ] 언어 일관성 (영어/한국어)

### 기술적 검증
- [ ] 모든 Git 커밋이 컨벤션을 따름
- [ ] CHANGELOG.md가 업데이트됨
- [ ] 버전 번호가 올바르게 올라감
- [ ] 로컬에서 PDF 생성 테스트
- [ ] 병합 충돌 없음

### 내용 품질
- [ ] 기술적 정확성 검증됨
- [ ] 예시에 에러 처리 포함
- [ ] API 스펙이 실제 구현과 일치
- [ ] 플레이스홀더 텍스트 없음 (TODO, TBD 등)

### 최종 단계
- [ ] 릴리스 태그 생성
- [ ] CI/CD를 통한 PDF 생성
- [ ] 릴리스 자산에 PDF 업로드
- [ ] 내부 위키/confluence 업데이트
- [ ] 관련 팀에 알림
```

### 단계별 릴리스 프로세스

#### 1. 릴리스 브랜치 준비

```bash
# main 브랜치에 있는지 확인
git checkout main
git pull origin main

# 릴리스 브랜치 생성
git checkout -b release/v2.1.0

# 필요시 최종 변경
git commit -m "release: Prepare v2.1.0"
```

#### 2. CHANGELOG 업데이트

`docs/CHANGELOG.md` 생성/업데이트:

```markdown
# Changelog

## [2.1.0] - 2025-11-24

### Added (추가됨)
- **Startup SDK**: WiFi 채널 설정 옵션
- **Keytool SDK**: WD10 디바이스 지원
- **All SDKs**: 향상된 에러 처리 예시

### Changed (변경됨)
- 더 나은 에러 처리가 포함된 코드 예시 개선
- API 파라미터 설명 업데이트

### Fixed (수정됨)
- 키 매핑 테이블 오타 수정 (keytool)
- WiFi 안정성 API 반환 값 수정

### Deprecated (폐기 예정)
- 구 WiFi 설정 방법 (새 v2 API 사용)

## [2.0.0] - 2025-11-10
...
```

#### 3. 릴리스 태그 생성

```bash
# 주석 태그 생성
git tag -a v2.1.0 -m "Release v2.1.0

Major updates:
- Enhanced WiFi configuration
- WD10 device support
- Improved examples"

# 태그 푸시
git push origin v2.1.0
```

#### 4. Main에 병합

```bash
# 릴리스 브랜치 병합
git checkout main
git merge release/v2.1.0

# main에 푸시
git push origin main

# 릴리스 브랜치 삭제 (선택사항)
git branch -d release/v2.1.0
```

#### 5. PDF 생성

**자동 (GitHub Actions 사용):**
- 태그 푸시 시 PDF가 자동 생성됨
- GitHub Actions 상태 확인
- Release 자산에서 다운로드

**수동 (필요시):**
```bash
cd MdToPdf
.\convert-all-sdk-docs.ps1  # Windows PowerShell
# 또는
bash convert-all-sdk-docs.sh  # Git Bash
```

#### 6. 릴리스 발행

GitHub에서:
1. Releases → Draft a new release로 이동
2. 태그 선택: `v2.1.0`
3. 릴리스 제목: `M3 SDK Documentation v2.1.0`
4. 설명: CHANGELOG에서 복사
5. PDF 첨부 (자동 첨부되지 않은 경우)
6. 릴리스 발행

---

## 자동화 워크플로우

### GitHub Actions 설정

`.github/workflows/generate-docs.yml` 생성:

```yaml
name: Generate SDK Documentation PDFs

on:
  push:
    branches: [main, master]
    paths:
      - 'docs/**/*.md'
  release:
    types: [published]
  workflow_dispatch:  # Manual trigger

jobs:
  generate-pdfs:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Full history for Git logs

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'

      - name: Install md-to-pdf
        run: npm install -g md-to-pdf

      - name: Install dependencies
        run: |
          cd MdToPdf
          npm install

      - name: Generate PDFs
        run: |
          cd MdToPdf
          bash convert-all-sdk-docs.sh

      - name: Upload PDFs as artifacts
        uses: actions/upload-artifact@v3
        with:
          name: sdk-documentation-${{ github.sha }}
          path: MdToPdf/output/professional/**/*.pdf
          retention-days: 90

      - name: Attach to Release
        if: github.event_name == 'release'
        uses: softprops/action-gh-release@v1
        with:
          files: MdToPdf/output/professional/**/*.pdf
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### 트리거 조건

| 이벤트 | 발생 시점 | 사용 사례 |
|-------|------|----------|
| `push` (docs/) | 마크다운 변경 시 | 지속적 생성 |
| `release` | 태그 발행 시 | 공식 릴리스 |
| `workflow_dispatch` | 수동 | 주문형 생성 |

### 생성된 PDF 보기

**GitHub Actions에서:**
1. Actions 탭으로 이동
2. 워크플로우 실행 선택
3. 아티팩트 다운로드

**Releases에서:**
1. Releases 탭으로 이동
2. 버전 선택
3. 자산에서 PDF 다운로드

---

## 팀 협업

### 문서 리뷰 프로세스

```
1. 작성자가 브랜치 생성
   └─> feature/add-wifi-examples

2. 작성자가 변경사항 커밋
   └─> docs(startup): Add WiFi configuration examples

3. Pull Request 생성
   ├─> 제목: docs(startup): Add WiFi configuration examples
   ├─> 설명: 상세 설명
   └─> 리뷰어: @tech-lead @doc-maintainer

4. 리뷰어가 확인
   ├─> 기술적 정확성
   ├─> 코드 예시 작동 여부
   ├─> 작성 품질
   └─> 포맷 일관성

5. 피드백 반영
   └─> 변경, 업데이트 푸시

6. 승인 및 병합
   └─> main으로 스쿼시 병합

7. PDF 자동 생성
   └─> GitHub Actions 실행
```

### Pull Request 템플릿

`.github/pull_request_template.md` 생성:

```markdown
## 설명
[변경사항에 대한 간략한 설명]

## 변경 유형
- [ ] 새로운 문서
- [ ] 기존 문서 업데이트
- [ ] 오류/오타 수정
- [ ] 재구성/리팩토링

## 영향받는 SDK
- [ ] Startup SDK
- [ ] Keytool SDK
- [ ] Scanemul SDK

## 체크리스트
- [ ] 코드 예시가 테스트됨
- [ ] 마크다운 포맷이 올바름
- [ ] 깨진 링크 없음
- [ ] 언어가 일관됨
- [ ] CHANGELOG 업데이트됨 (필요시)
- [ ] 스크린샷 업데이트됨 (해당시)

## 테스트
[이 변경사항을 검증하는 방법]

## 관련 이슈
Closes #[이슈 번호]
```

### 코드 리뷰 가이드라인

**확인할 사항:**

✅ **기술적 정확성**
- API 시그니처가 구현과 일치
- 파라미터 타입이 정확
- 반환 값이 정확
- 에러 코드가 유효

✅ **코드 품질**
- 예시가 오류 없이 컴파일됨
- 베스트 프랙티스 준수
- 에러 처리 포함
- 주석이 도움이 됨

✅ **문서 품질**
- 명확하고 간결한 작성
- 올바른 마크다운 포맷
- 일관된 용어
- 적절한 상세도

✅ **완전성**
- 필요한 모든 섹션 존재
- 엣지 케이스 다룸
- 일반적인 오류 해결
- 예시가 포괄적

❌ **집중하지 말아야 할 것**
- 사소한 문법 문제 (나중에 수정 가능)
- 개인 스타일 선호도
- 사소한 것에 대한 과도한 논쟁

---

## 베스트 프랙티스

### 좋은 문서 작성하기

#### 해야 할 것 ✅

```markdown
## 올바른 예시

### WiFi 안정성 모드 활성화

이 기능은 디바이스 슬립 중 WiFi 연결 끊김을 방지합니다.

**요구사항:**
- Android 8.0+
- M3 Startup SDK v1.2.0+

**예시:**

​```java
Intent intent = new Intent("com.m3.startup.ACTION_WIFI_STABILITY");
intent.putExtra("enabled", true);
context.sendBroadcast(intent);
​```

**예상 결과:**
슬립 모드 중에도 WiFi가 연결 상태를 유지합니다.

**문제 해결:**
WiFi가 여전히 끊긴다면, 디바이스 전원 설정을 확인하세요.
```

#### 하지 말아야 할 것 ❌

```markdown
## 잘못된 예시

### WiFi

WiFi 안정성을 사용할 수 있습니다.

​```java
// 코드
​```
```

### 대용량 문서 처리 (200+ 페이지)

**문제:** 200페이지 PDF는 생성 시간이 더 오래 걸립니다.

**해결책:**

1. **여러 문서로 분할**
   ```
   이전: startup-sdk.md (200 페이지)

   이후:
   - startup-wifi-sdk.md (50 페이지)
   - startup-app-sdk.md (50 페이지)
   - startup-ntp-sdk.md (30 페이지)
   - startup-usb-sdk.md (40 페이지)
   ```

2. **TOC 깊이 제한**
   ```javascript
   // preprocess-markdown.js
   const match = line.match(/^(#{1,3})\s+(.+)$/); // H1-H3만
   ```

3. **이미지 최적화**
   - 압축된 PNG 사용
   - 최대 너비: 1200px
   - 사진은 JPEG 사용

4. **타임아웃 증가**
   ```json
   // .md-to-pdf.json
   "launch_options": {
     "timeout": 120000  // 대용량 문서용 2분
   }
   ```

### 성능 최적화

**현재 성능:**
- 50 페이지: ~5초
- 100 페이지: ~10초
- 200 페이지: ~20-30초

**팁:**
1. 여러 문서의 경우 PDF를 병렬로 생성
2. 변경되지 않은 문서에 로컬 캐싱 사용
3. 강력한 CI 러너에서 생성 실행

### 다중 SDK 버전 관리

**시나리오:** SDK v1.x와 v2.x 문서를 동시에 유지해야 하는 경우.

**옵션 A: 별도 브랜치**
```bash
# v1.x 유지보수 브랜치
git checkout -b docs/v1-maintenance

# v2.x는 main에
git checkout main
```

**옵션 B: 버전 폴더**
```
docs/
├── v1/
│   └── startup-sdk.md
└── v2/
    └── startup-sdk.md
```

**권장사항:** 메이저 버전은 브랜치 사용, 마이너 버전은 폴더 사용.

---

## 문제 해결

### 일반적인 문제

#### 문제: PDF 생성 실패

**증상:**
```
[X] Conversion failed
```

**해결책:**
1. 마크다운 문법 확인
   ```bash
   # 마크다운 린터 사용
   npx markdownlint docs/**/*.md
   ```

2. Git 저장소 확인
   ```bash
   git status
   ```

3. node_modules 확인
   ```bash
   cd MdToPdf
   npm install
   ```

#### 문제: PDF에 Git 히스토리가 표시되지 않음

**증상:** "Document Version History" 섹션이 없음.

**해결책:**
1. 파일이 Git으로 추적되는지 확인
   ```bash
   git log --follow path/to/file.md
   ```

2. Git 저장소가 존재하는지 확인
   ```bash
   git status  # "not a git repository"라고 나오면 안 됨
   ```

3. 전처리 스크립트 확인
   ```bash
   node preprocess-markdown.js input.md output.md /path/to/repo
   ```

#### 문제: TOC 링크가 작동하지 않음

**증상:** TOC 링크 클릭 시 섹션으로 이동하지 않음.

**해결책:**
1. 헤더에 특수문자가 없는지 확인
   ```markdown
   ✅ ## API Reference
   ❌ ## API Reference (v2.0)  # 괄호는 문제를 일으킴
   ```

2. PDF 재생성
   ```bash
   rm output.pdf
   md-to-pdf input.md
   ```

#### 문제: PowerShell 스크립트가 인코딩 에러로 실패

**증상:**
```
문자열에 " 종결자가 없습니다
```

**해결책:** 이미 수정됨 - 스크립트에서 이모지가 ASCII로 대체됨.

---

## 도구 및 명령어

### 필수 도구

| 도구 | 목적 | 설치 |
|------|---------|---------|
| **Git** | 버전 관리 | [git-scm.com](https://git-scm.com) |
| **Node.js** | 스크립트 실행 환경 | [nodejs.org](https://nodejs.org) |
| **md-to-pdf** | PDF 생성 | `npm install -g md-to-pdf` |
| **VS Code** | 마크다운 에디터 | [code.visualstudio.com](https://code.visualstudio.com) |
| **markdownlint** | 린터 | `npm install -g markdownlint-cli` |

### 유용한 명령어

#### 빠른 PDF 생성

```bash
# 단일 파일
cd MdToPdf
node preprocess-markdown.js ../Android-Library-M3SDK/docs/keytool/sl-series-key-setting-sdk-english.md temp.md ../Android-Library-M3SDK
md-to-pdf temp.md --config-file .md-to-pdf.json --basedir .

# 모든 파일
.\convert-all-sdk-docs.ps1  # PowerShell
bash convert-all-sdk-docs.sh  # Bash
```

#### Git 명령어

```bash
# 파일 히스토리 보기
git log --follow --oneline docs/keytool/sl-series-key-setting-sdk-english.md

# 마지막 커밋의 변경사항 보기
git show HEAD:docs/keytool/sl-series-key-setting-sdk-english.md

# 이전 버전과 비교
git diff HEAD~1 docs/keytool/sl-series-key-setting-sdk-english.md

# 누가 라인을 변경했는지 찾기
git blame docs/keytool/sl-series-key-setting-sdk-english.md

# 모든 태그 목록
git tag -l

# 로컬 및 원격 태그 삭제
git tag -d v2.1.0
git push origin :refs/tags/v2.1.0
```

#### 마크다운 린팅

```bash
# 모든 마크다운 파일 린트
npx markdownlint docs/**/*.md

# 자동 수정 린트
npx markdownlint --fix docs/**/*.md

# 커스텀 규칙
npx markdownlint --config .markdownlint.json docs/**/*.md
```

### VS Code 확장

**권장:**
- `yzhang.markdown-all-in-one` - 마크다운 단축키
- `DavidAnson.vscode-markdownlint` - 린팅
- `bierner.markdown-preview-github-styles` - 프리뷰
- `eamodio.gitlens` - 고급 Git 기능

### 빠른 참조 카드

```bash
# 일일 워크플로우
git pull origin main              # 로컬 업데이트
git checkout -b docs/new-feature  # 브랜치 생성
# ... 변경 작업 ...
git add docs/
git commit -m "docs(scope): message"
git push origin docs/new-feature
# GitHub에서 PR 생성

# 릴리스 워크플로우
git checkout main
git pull origin main
git checkout -b release/v2.1.0
# ... CHANGELOG 업데이트 ...
git commit -m "release: Prepare v2.1.0"
git tag -a v2.1.0 -m "Release v2.1.0"
git push origin v2.1.0
git checkout main
git merge release/v2.1.0
git push origin main

# PDF 생성
cd MdToPdf
.\convert-all-sdk-docs.ps1

# 긴급 수정
git revert HEAD               # 마지막 커밋 되돌리기
git push origin main
```

---

## 부록

### 마크다운 치트시트

```markdown
# H1
## H2
### H3

**굵게** *기울임* `코드`

[링크 텍스트](url)

- 글머리 기호 목록
1. 번호 매기기 목록

​```java
// 코드 블록
​```

> 인용구

| 표 | 헤더 |
|-------|--------|
| 셀  | 셀   |
```

### Semantic Versioning 참조

- **MAJOR**: 호환성 깨지는 변경
- **MINOR**: 새로운 기능 (하위 호환)
- **PATCH**: 버그 수정 (하위 호환)

예시:
- 1.0.0 → 1.0.1 (patch)
- 1.0.1 → 1.1.0 (minor)
- 1.1.0 → 2.0.0 (major)

### 연락처 및 지원

**질문이 있으신가요?** 문서팀에 연락하세요:
- 리드: [name@company.com]
- 관리자: [name@company.com]

**버그를 발견하셨나요?** 이슈를 생성하세요:
- GitHub: [repository URL]
- 내부 위키: [wiki URL]

---

**문서 버전:** 1.0
**최종 업데이트:** 2025-11-24
**라이선스:** 내부 사용 전용
