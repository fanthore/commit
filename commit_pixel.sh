#!/usr/bin/env bash
set -euo pipefail

# ---------------------------
# CONFIG
# ---------------------------
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
README_FILE="$REPO_DIR/README.md"
COMMIT_FILE="$REPO_DIR/pixel.txt"
BRANCH="main"

INTENSITY=5
DRY_RUN=false

# ---------------------------
# CLI FLAGS
# ---------------------------
for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=true
      ;;
    --intensity=*)
      INTENSITY="${arg#*=}"
      ;;
  esac
done

# ---------------------------
# DATE
# ---------------------------
TODAY=$(date +%F)
TODAY_EPOCH=$(date -d "$TODAY" +%s)
DOW=$(date +%u)

# ---------------------------
# READ MESSAGE
# ---------------------------
MESSAGE=$(grep '^message="' "$README_FILE" | cut -d'"' -f2 | tr '[:lower:]' '[:upper:]')

IFS=' ' read -r -a WORDS <<< "$MESSAGE"
WORD1="${WORDS[0]-}"
WORD2="${WORDS[1]-}"

# ---------------------------
# INITIALIZATION (STATE)
# ---------------------------
START_DATE=$(grep '^start_date="' "$README_FILE" | cut -d'"' -f2 || true)

if [[ -z "$START_DATE" ]]; then
  if [[ "$DRY_RUN" == false ]]; then
    START_DATE="$TODAY"
    echo "Initializing start_date=$START_DATE"

    echo "start_date=\"$START_DATE\"" >> "$README_FILE"

    cd "$REPO_DIR"
    git add "$README_FILE"
    git commit -m "Initialize pixel start date"
    git push origin "$BRANCH"
  else
    # dry-run → simulate start today
    START_DATE="$TODAY"
  fi
fi

START_EPOCH=$(date -d "$START_DATE" +%s)

# ---------------------------
# RELATIVE WEEK INDEX
# ---------------------------
SECONDS_DIFF=$(( TODAY_EPOCH - START_EPOCH ))
WEEK_INDEX=$(( SECONDS_DIFF / 604800 ))  # 7*24*60*60

# ---------------------------
# FONT (same as previous)
# ---------------------------
declare -A FONT

FONT[A]="111101111"; FONT[B]="110111110"; FONT[C]="111100111"
FONT[D]="110101110"; FONT[E]="111110111"; FONT[F]="111110100"
FONT[G]="111101111"; FONT[H]="101111101"; FONT[I]="111010111"
FONT[J]="011001110"; FONT[K]="101110101"; FONT[L]="100100111"
FONT[M]="111111101"; FONT[N]="111111111"; FONT[O]="111101111"
FONT[P]="111111100"; FONT[Q]="111101011"; FONT[R]="111111101"
FONT[S]="111110011"; FONT[T]="111010010"; FONT[U]="101101111"
FONT[V]="101101010"; FONT[W]="101111101"; FONT[X]="101010101"
FONT[Y]="101010010"; FONT[Z]="111011111"

FONT["."]="000000010"
FONT[","]="000000110"
FONT["!"]="010010010"
FONT["?"]="111001010"
FONT["\""]="101000000"
FONT["'"]="010000000"

BLANK="000000000"

# ---------------------------
# FUNCTIONS
# ---------------------------
get_pixel() {
  local char="$1"; local col="$2"; local row="$3"
  local pattern="${FONT[$char]:-$BLANK}"
  local index=$((row * 3 + col))
  echo "${pattern:$index:1}"
}

word_length() {
  echo $(( ${#1} * 4 ))
}

get_char_for_col() {
  local word="$1"; local col="$2"
  local char_index=$(( col / 4 ))
  local offset=$(( col % 4 ))
  [[ $offset -eq 3 ]] && return
  echo "${word:$char_index:1}"
}

# ---------------------------
# LAYOUT
# ---------------------------
LEN1=$(word_length "$WORD1")
LEN2=$(word_length "$WORD2")
MAX_LEN=$(( LEN1 > LEN2 ? LEN1 : LEN2 ))

COL=$(( WEEK_INDEX % MAX_LEN ))

if [[ "$DOW" -eq 1 ]]; then
  ROW_STATE="OFF"
else
  if [[ "$DOW" -le 4 ]]; then
    FONT_ROW=0
    ROW_STATE="TOP"
  else
    FONT_ROW=2
    ROW_STATE="BOTTOM"
  fi
fi

# ---------------------------
# PIXEL COMPUTE
# ---------------------------
PIXEL=0

if [[ "$ROW_STATE" != "OFF" ]]; then
  LETTER1=$(get_char_for_col "$WORD1" "$COL")
  LETTER2=$(get_char_for_col "$WORD2" "$COL")

  if [[ -n "${LETTER1:-}" && $COL -lt $LEN1 ]]; then
    PIXEL=$(get_pixel "$LETTER1" $((COL % 4)) "$FONT_ROW")
  fi

  if [[ -n "${LETTER2:-}" && $COL -lt $LEN2 ]]; then
    PIXEL2=$(get_pixel "$LETTER2" $((COL % 4)) "$FONT_ROW")
    [[ "$PIXEL2" -eq 1 ]] && PIXEL=1
  fi
fi

# ---------------------------
# DRY RUN
# ---------------------------
if [[ "$DRY_RUN" == true ]]; then
  echo "=== DRY RUN ==="
  echo "Start date    : $START_DATE"
  echo "Today         : $TODAY"
  echo "Week index    : $WEEK_INDEX"
  echo "Column        : $COL"
  echo "Row state     : $ROW_STATE"
  echo "Pixel         : $PIXEL"
  echo "Intensity     : $INTENSITY"

  [[ "$PIXEL" -eq 1 ]] && echo "Would commit $INTENSITY times"
  exit 0
fi

# ---------------------------
# COMMIT
# ---------------------------
if [[ "$PIXEL" -eq 1 ]]; then
  cd "$REPO_DIR"

  for ((i=1;i<=INTENSITY;i++)); do
    echo "$(date) [$i/$INTENSITY]" >> "$COMMIT_FILE"
  done

  git add "$COMMIT_FILE"

  if ! git diff --cached --quiet; then
    git commit -m "pixel week=$WEEK_INDEX intensity=$INTENSITY"
    git push origin "$BRANCH"
  fi
fi
