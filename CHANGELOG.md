# Changelog

All notable changes to the M3 SDK PDF Generator will be documented in this file.

## [2.0.0] - 2025-11-24

### Added
- **Automatic Table of Contents (TOC)** - Clickable TOC generated from markdown headers
- **Git Version History** - Document commit history displayed after TOC
- **Intelligent Version Tracking** - Automatically skips version history for non-Git files
- **Preprocessor Script** - `preprocess-markdown.js` for markdown enhancement
- **Enhanced Styling** - Special TOC and version history styles in CSS

### Changed
- Conversion scripts now use 2-step process (preprocess → convert)
- Increased PDF file sizes due to TOC and version history (average +100-200KB)
- Updated both PowerShell and Bash scripts with preprocessing step

### Technical Details
- New dependency: `marked` v11.1.1 for markdown parsing
- New dependency: `simple-git` v3.22.0 for Git operations
- TOC depth: H1-H4 headers
- Version history limit: 10 most recent commits
- Temp files automatically cleaned up after conversion

## [1.0.0] - 2025-11-24

### Initial Release
- Basic markdown to PDF conversion
- Professional styling with M3 Mobile branding
- Java/Kotlin syntax highlighting
- Automated batch conversion scripts
- Custom CSS styling (sdk-professional.css)
- Support for 21+ SDK documents
