#!/bin/bash

###############################################################################
# M3 Mobile SDK Documentation - Portable PDF Generator (Bash)
#
# This portable version can run on ANY Linux/macOS/WSL by specifying the
# source documentation directory as a parameter.
#
# Usage:
#   ./convert-all-sdk-docs-portable.sh
#   ./convert-all-sdk-docs-portable.sh /path/to/docs
#   ./convert-all-sdk-docs-portable.sh /path/to/docs --no-open
#
# Requirements:
#   - Node.js (v14+)
#   - npm install -g md-to-pdf
#   - Git (for version history, optional)
###############################################################################

# set -e  # Exit on error (disabled for better error handling)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Parse arguments
DOCS_PATH=""
SKIP_OPEN=false

for arg in "$@"; do
    case $arg in
        --no-open)
            SKIP_OPEN=true
            shift
            ;;
        *)
            if [ -z "$DOCS_PATH" ]; then
                DOCS_PATH="$arg"
            fi
            shift
            ;;
    esac
done

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/output/professional"
TEMP_DIR="$SCRIPT_DIR/output/temp"
CONFIG_FILE="$SCRIPT_DIR/.md-to-pdf.json"
PREPROCESS_SCRIPT="$SCRIPT_DIR/preprocess-markdown.js"

# Auto-detect docs directory if not provided
if [ -z "$DOCS_PATH" ]; then
    # Try common locations
    POSSIBLE_PATHS=(
        "/c/Users/M3/Android-Library-M3SDK/docs"
        "$SCRIPT_DIR/../Android-Library-M3SDK/docs"
        "$SCRIPT_DIR/docs"
        "$SCRIPT_DIR/sdk-docs"
        "$SCRIPT_DIR/../docs"
        "$HOME/Android-Library-M3SDK/docs"
        "$HOME/Projects/Android-Library-M3SDK/docs"
    )

    for path in "${POSSIBLE_PATHS[@]}"; do
        if [ -d "$path" ]; then
            DOCS_PATH="$path"
            break
        fi
    done

    # If still not found, ask user
    if [ -z "$DOCS_PATH" ]; then
        echo -e "${YELLOW}========================================${NC}"
        echo -e "${YELLOW}Documentation Directory Not Found${NC}"
        echo -e "${YELLOW}========================================${NC}"
        echo ""
        echo -e "${NC}Please specify the path to your SDK documentation directory.${NC}"
        echo -e "${NC}This should be the folder containing your markdown files.${NC}"
        echo ""
        echo -e "${GRAY}Example: /home/user/Android-Library-M3SDK/docs${NC}"
        echo ""
        read -p "Enter documentation directory path: " DOCS_PATH

        if [ ! -d "$DOCS_PATH" ]; then
            echo ""
            echo -e "${RED}Error: Directory not found: $DOCS_PATH${NC}"
            exit 1
        fi
    fi
fi

# Validate docs directory
if [ ! -d "$DOCS_PATH" ]; then
    echo -e "${RED}Error: Documentation directory not found: $DOCS_PATH${NC}"
    echo ""
    echo -e "${YELLOW}Usage: $0 /path/to/docs${NC}"
    exit 1
fi

# Convert to absolute path
DOCS_PATH="$(cd "$DOCS_PATH" && pwd)"

# Create output directories
mkdir -p "$OUTPUT_DIR"
mkdir -p "$TEMP_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}M3 Mobile SDK - Portable PDF Generator${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"
echo ""

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}[X] Node.js is not installed${NC}"
    echo -e "${YELLOW}    Download from: https://nodejs.org/${NC}"
    exit 1
fi
NODE_VERSION=$(node --version)
echo -e "${GREEN}[OK] Node.js is installed ($NODE_VERSION)${NC}"

# Check md-to-pdf
if ! command -v md-to-pdf &> /dev/null; then
    echo -e "${RED}[X] md-to-pdf is not installed${NC}"
    echo -e "${YELLOW}    Install it with: npm install -g md-to-pdf${NC}"
    exit 1
fi
echo -e "${GREEN}[OK] md-to-pdf is installed${NC}"

# Check Git (optional)
if command -v git &> /dev/null; then
    echo -e "${GREEN}[OK] Git is installed (version history enabled)${NC}"
else
    echo -e "${YELLOW}[!] Git not found (version history disabled)${NC}"
fi

# Check files
if [ ! -f "$PREPROCESS_SCRIPT" ]; then
    echo -e "${RED}[X] Preprocessor script not found: $PREPROCESS_SCRIPT${NC}"
    exit 1
fi
echo -e "${GREEN}[OK] Preprocessor script found${NC}"

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}[X] Config file not found: $CONFIG_FILE${NC}"
    exit 1
fi
echo -e "${GREEN}[OK] Config file found${NC}"

echo ""
echo -e "${BLUE}Configuration:${NC}"
echo -e "${CYAN}  Source docs: $DOCS_PATH${NC}"
echo -e "${CYAN}  Output dir:  $OUTPUT_DIR${NC}"
echo ""

# Find all English markdown files
echo -e "${BLUE}Searching for SDK documentation files...${NC}"

# Array to store file paths
declare -a MD_FILES

# Find all English markdown files
while IFS= read -r -d '' file; do
    # Skip README.md in root docs folder if needed
    # You can customize this filtering logic
    MD_FILES+=("$file")
done < <(find "$DOCS_PATH" -type f \( -name "*.md" \) -print0 2>/dev/null)

if [ ${#MD_FILES[@]} -eq 0 ]; then
    echo -e "${RED}[X] No markdown files found in: $DOCS_PATH${NC}"
    echo ""
    echo -e "${YELLOW}Searched for:${NC}"
    echo -e "${GRAY}  - *-english.md${NC}"
    echo -e "${GRAY}  - *-en.md${NC}"
    echo -e "${GRAY}  - *_kr.md${NC}"
    echo -e "${GRAY}  - README*.md${NC}"
    exit 1
fi

echo -e "${GREEN}Found ${#MD_FILES[@]} documentation files${NC}"
echo ""

# Counter for successful conversions
SUCCESS_COUNT=0
FAIL_COUNT=0
declare -a FAILED_FILES

# Convert each file
for md_file in "${MD_FILES[@]}"; do
    # Get relative path from docs dir
    rel_path="${md_file#$DOCS_PATH/}"

    # Create category-based subdirectory
    category_dir="$(dirname "$rel_path")"
    if [ "$category_dir" = "." ]; then
        output_category_dir="$OUTPUT_DIR"
    else
        output_category_dir="$OUTPUT_DIR/$category_dir"
    fi
    mkdir -p "$output_category_dir"

    # Get filename without extension
    filename="$(basename "$md_file" .md)"

    echo -e "${YELLOW}Converting:${NC} $rel_path"

    # Preprocess markdown (add TOC and version history)
    temp_md="$TEMP_DIR/${filename}-processed.md"
    repo_path="$(dirname "$DOCS_PATH")"

    cd "$SCRIPT_DIR"

    # Step 1: Preprocess markdown
    echo -ne "  -> Preprocessing (TOC + Git history)..."
    if node "$PREPROCESS_SCRIPT" "$md_file" "$temp_md" "$repo_path" >/dev/null 2>&1; then
        echo -e " ${GREEN}[OK]${NC}"
    else
        echo -e " ${YELLOW}[!] (using original)${NC}"
        cp "$md_file" "$temp_md"
    fi

    # Step 2: Convert to PDF
    echo -ne "  -> Generating PDF..."
    if md-to-pdf "$temp_md" --config-file "$CONFIG_FILE" --basedir "$SCRIPT_DIR" 2>/dev/null; then
        # Check if PDF was generated
        pdf_file="${temp_md%.md}.pdf"

        if [ -f "$pdf_file" ]; then
            # Move to organized output directory
            mv "$pdf_file" "$output_category_dir/$filename.pdf"
            echo -e " ${GREEN}[OK]${NC}"

            if [ "$category_dir" = "." ]; then
                echo -e "  ${GREEN}[OK] Saved: $filename.pdf${NC}"
            else
                echo -e "  ${GREEN}[OK] Saved: $category_dir/$filename.pdf${NC}"
            fi
            ((SUCCESS_COUNT++))
        else
            echo -e " ${RED}[X]${NC}"
            echo -e "  ${RED}[X] PDF not found: $pdf_file${NC}"
            FAILED_FILES+=("$rel_path")
            ((FAIL_COUNT++))
        fi
    else
        echo -e " ${RED}[X]${NC}"
        echo -e "  ${RED}[X] Conversion failed${NC}"
        FAILED_FILES+=("$rel_path")
        ((FAIL_COUNT++))
    fi

    # Clean up temp markdown
    rm -f "$temp_md"

    echo ""
done

# Generate summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Conversion Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Successful:${NC} $SUCCESS_COUNT"
echo -e "${RED}Failed:${NC} $FAIL_COUNT"
echo ""

if [ $FAIL_COUNT -gt 0 ]; then
    echo -e "${RED}Failed files:${NC}"
    for failed in "${FAILED_FILES[@]}"; do
        echo "  - $failed"
    done
    echo ""
fi

# List all generated PDFs with sizes
echo -e "${BLUE}Generated PDFs:${NC}"
find "$OUTPUT_DIR" -name "*.pdf" -type f -exec ls -lh {} \; 2>/dev/null | awk '{
    # Extract size and path
    size = $5
    path = $0
    sub(/.*'"$(basename "$OUTPUT_DIR")"'\//, "", path)
    sub(/^[^ ]+ +[^ ]+ +[^ ]+ +[^ ]+ +[^ ]+ +[^ ]+ +[^ ]+ +[^ ]+ +/, "", path)
    printf "  %s  %s\n", size, path
}'
echo ""

# Calculate total size
total_size=$(du -sh "$OUTPUT_DIR" 2>/dev/null | awk '{print $1}')
echo -e "${GREEN}Total output size:${NC} $total_size"
echo -e "${GREEN}Output directory:${NC} $OUTPUT_DIR"
echo ""

# Clean up temp directory
rm -rf "$TEMP_DIR"

# Open output directory (OS-specific)
if [ "$SKIP_OPEN" = false ]; then
    echo -e "${BLUE}Opening output directory...${NC}"

    # Detect OS and open accordingly
    case "$(uname -s)" in
        Linux*)
            # Try common Linux file managers
            if command -v xdg-open &> /dev/null; then
                xdg-open "$OUTPUT_DIR" 2>/dev/null &
            elif command -v nautilus &> /dev/null; then
                nautilus "$OUTPUT_DIR" 2>/dev/null &
            elif command -v dolphin &> /dev/null; then
                dolphin "$OUTPUT_DIR" 2>/dev/null &
            fi
            ;;
        Darwin*)
            # macOS
            open "$OUTPUT_DIR" 2>/dev/null
            ;;
        CYGWIN*|MINGW*|MSYS*)
            # Git Bash on Windows
            if command -v explorer.exe &> /dev/null; then
                explorer.exe "$(cygpath -w "$OUTPUT_DIR" 2>/dev/null || echo "$OUTPUT_DIR")" 2>/dev/null &
            fi
            ;;
    esac
fi

echo -e "${GREEN}Done!${NC}"
