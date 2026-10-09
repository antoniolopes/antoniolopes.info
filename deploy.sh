#!/bin/bash

set -euo pipefail

# --------------------------------------------------
# Configuration
# --------------------------------------------------

CONFIG_FILE="$HOME/.config/homepage-deploy.conf"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ Configuration file not found: $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

# Always deploy relative to the script's location
LOCAL_DIR="$(cd "$(dirname "$0")" && pwd)"

# --------------------------------------------------
# Arguments
# --------------------------------------------------

DRY_RUN=false

case "${1:-}" in
    --dry-run)
        DRY_RUN=true
        ;;
    "")
        ;;
    *)
        echo "Usage: $0 [--dry-run]"
        exit 1
        ;;
esac

# --------------------------------------------------
# Deployment
# --------------------------------------------------

echo "======================================"
echo "🚀 Homepage Deployment"
echo "======================================"
echo "Host:   $FTP_HOST"
echo "Remote: $REMOTE_DIR"
echo "Local:  $LOCAL_DIR"
echo ""

MIRROR_OPTIONS=(
    --reverse
    --verbose
    --only-newer
    --parallel=4
    --exclude-glob=.git/
    --exclude-glob=.DS_Store
    --exclude-glob=.env
    --exclude-glob=node_modules/
    --exclude-glob=deploy.sh
)

if [[ "$DRY_RUN" == true ]]; then
    echo "🔍 DRY RUN: No files will be uploaded."
    MIRROR_OPTIONS+=(--dry-run)
else
    echo "📤 Uploading files..."
fi

# Convert options array to a command string
printf -v MIRROR_ARGS '%s ' "${MIRROR_OPTIONS[@]}"

lftp -u "$FTP_USER","$FTP_PASS" \
     -p "$FTP_PORT" \
     "ftp://$FTP_HOST" <<EOF

set ftp:ssl-force true
set ftp:ssl-protect-data true
set ssl:verify-certificate true
set net:max-retries 2

mirror $MIRROR_ARGS "$LOCAL_DIR" "$REMOTE_DIR"

bye
EOF

echo ""
echo "✅ Deployment completed!"