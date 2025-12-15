# M3 SDK Documentation - Quick Start Guide

## ⚡ 5초 시작 가이드

```powershell
# MdToPdf 폴더에서 실행
.\convert-all-sdk-docs.ps1
```

끝! 모든 PDF가 `output/professional/` 폴더에 생성됩니다.

**새 기능 (v2.0):**
- 📑 자동 목차 (TOC) 포함
- 📜 Git 커밋 히스토리 자동 추가

---

## 📋 주요 명령어

### 1. 전체 문서 변환 (PowerShell - 권장)
```powershell
.\convert-all-sdk-docs.ps1
```

### 2. 전체 문서 변환 (Git Bash)
```bash
./convert-all-sdk-docs.sh
```

### 3. 자동 감시 모드 (파일 저장 시 자동 변환)
```powershell
.\watch-and-convert.ps1
```

### 4. 단일 파일 변환
```bash
md-to-pdf "path/to/document.md" --config-file .md-to-pdf.json --basedir .
```

---

## 📁 생성된 파일 확인

```powershell
# 출력 폴더 열기
explorer output\professional

# 또는
cd output\professional
ls -R
```

---

## 🎨 스타일 수정

### 색상 변경
`sdk-professional.css` 파일 열기 → 상단 `:root` 섹션 수정

```css
:root {
  --primary-color: #0066cc;  /* 원하는 색상으로 변경 */
}
```

### 간격 조정
```css
/* 헤더-코드블록 간격 */
h1, h2, h3 {
  margin-bottom: 2em;  /* 원하는 값으로 */
}
```

---

## 🔧 문제 해결

### PDF가 생성 안 돼요
```bash
# md-to-pdf 재설치
npm install -g md-to-pdf
```

### 스타일이 안 먹혀요
```bash
# 설정 파일 확인
cat .md-to-pdf.json

# CSS 파일 확인
ls -la sdk-professional.css
```

---

## 📊 결과

현재 시스템으로 생성된 PDF:
- ✅ 총 21개 문서
- ✅ 총 크기: 10.77 MB
- ✅ 평균 파일 크기: ~500 KB
- ✅ 변환 속도: ~3초/파일

---

## 💡 팁

### 빠른 미리보기
```powershell
# PDF 바로 열기
.\convert-all-sdk-docs.ps1
# 자동으로 폴더가 열림 → PDF 클릭
```

### 특정 카테고리만 변환
```bash
# keytool만
find /c/Users/M3/Android-Library-M3SDK/docs/keytool -name "*-english.md" -exec md-to-pdf {} --config-file .md-to-pdf.json --basedir . \;
```

### Git 연동
```bash
# 변환 후 자동 커밋 (선택사항)
.\convert-all-sdk-docs.ps1
git add output/professional/**/*.pdf
git commit -m "Update SDK documentation PDFs"
```

---

## 📞 도움말

자세한 내용은 `README.md` 참고

**문제 발생 시:**
1. `README.md` 의 FAQ 확인
2. 설정 파일 확인: `.md-to-pdf.json`
3. CSS 확인: `sdk-professional.css`

---

**제작:** M3 Mobile 문서화 팀
**최종 업데이트:** 2025-11-24
