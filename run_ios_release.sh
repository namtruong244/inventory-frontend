#!/bin/bash
# ==============================================================================
# Script: run_ios_release.sh
# Purpose: Build and run Flutter app in RELEASE mode on physical iPhone
#          with configurable backend server URL via --dart-define=API_BASE_URL
#
# Usage:
#   ./run_ios_release.sh                        # Auto-detects Mac LAN IP and iPhone
#   ./run_ios_release.sh <API_URL>              # Custom Backend URL
#   ./run_ios_release.sh <API_URL> <DEVICE_ID>  # Custom Backend URL & Device ID
#
# Examples:
#   ./run_ios_release.sh
#   ./run_ios_release.sh http://192.168.1.157:8080
#   ./run_ios_release.sh https://4ounu3zxuaqhhhv47rhuduoxny0xdqti.lambda-url.ap-southeast-1.on.aws/
# ==============================================================================

set -e

# Terminal colors
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}====================================================${NC}"
echo -e "${BOLD}${BLUE}   🚀 Flutter iOS Release Runner for Physical iPhone ${NC}"
echo -e "${BOLD}${BLUE}====================================================${NC}"

# Navigate to project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 1. Detect or assign Backend Server URL
CUSTOM_URL="$1"
if [ -n "$CUSTOM_URL" ] && [ "$CUSTOM_URL" != "--help" ]; then
    API_URL="$CUSTOM_URL"
else
    # Auto-detect LAN IP of Mac (Wi-Fi en0 or en1)
    MAC_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "")
    if [ -n "$MAC_IP" ]; then
        API_URL="http://${MAC_IP}:8080"
    else
        API_URL="http://localhost:8080"
    fi
fi

# Remove trailing slash if present
API_URL="${API_URL%/}"

# 2. Detect connected physical iOS Device
CUSTOM_DEVICE="$2"
if [ -n "$CUSTOM_DEVICE" ]; then
    DEVICE_ID="$CUSTOM_DEVICE"
else
    echo -e "${YELLOW}🔍 Detecting connected physical iPhone...${NC}"
    DEVICE_ID=$(flutter devices --machine 2>/dev/null | python3 -c "import sys, json
try:
    devs = json.load(sys.stdin)
    ios_devs = [d['id'] for d in devs if d.get('targetPlatform') == 'ios' and not d.get('emulator', False)]
    print(ios_devs[0] if ios_devs else '')
except Exception:
    print('')" 2>/dev/null || echo "")

    # Fallback to known physical device ID if auto-detection was empty
    if [ -z "$DEVICE_ID" ]; then
        DEVICE_ID="00008101-00011480019A001E"
    fi
fi

# 3. Display Configuration
echo -e "${GREEN}📱 Target Device :${NC} ${BOLD}$DEVICE_ID${NC}"
echo -e "${GREEN}🌐 Backend API   :${NC} ${BOLD}$API_URL${NC}"
echo -e "${GREEN}⚙️  Build Mode    :${NC} ${BOLD}RELEASE${NC}"
echo -e "${BLUE}----------------------------------------------------${NC}"

# Quick health check warning for local backend
if [[ "$API_URL" == *"192.168."* ]] || [[ "$API_URL" == *"localhost"* ]] || [[ "$API_URL" == *"127.0.0.1"* ]]; then
    # Test if port 8080 on localhost responds
    if ! nc -z -G 1 127.0.0.1 8080 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Notice: Port 8080 on your Mac seems inactive.${NC}"
        echo -e "${YELLOW}   Please ensure your Backend server is running so the iPhone can connect.${NC}"
        echo -e "${BLUE}----------------------------------------------------${NC}"
    else
        echo -e "${GREEN}✅ Local backend server is running on port 8080.${NC}"
        echo -e "${BLUE}----------------------------------------------------${NC}"
    fi
fi

echo -e "${BOLD}Starting release run...${NC}"
echo -e "Executing: ${BLUE}flutter run --release -d \"$DEVICE_ID\" --dart-define=API_BASE_URL=\"$API_URL\"${NC}\n"

exec flutter run --release -d "$DEVICE_ID" --dart-define=API_BASE_URL="$API_URL"
