#!/usr/bin/env bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== WhatsApp Automation Setup ===${NC}\n"

# ── 1. Python check ────────────────────────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
    echo -e "${RED}Python3 niet gevonden. Installeer Python 3.10+ en probeer opnieuw.${NC}"
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(sys.version_info.minor)')
if [ "$PYTHON_VERSION" -lt 10 ]; then
    echo -e "${RED}Python 3.10 of hoger vereist (gevonden: 3.${PYTHON_VERSION}).${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Python3 gevonden${NC}"

# ── 2. Virtualenv ──────────────────────────────────────────────────────────────
if [ ! -d ".venv" ]; then
    echo "Virtualenv aanmaken..."
    python3 -m venv .venv
fi
source .venv/bin/activate
echo -e "${GREEN}✓ Virtualenv actief${NC}"

# ── 3. Dependencies ────────────────────────────────────────────────────────────
echo "Dependencies installeren..."
pip install -q --upgrade pip
pip install -q -r requirements.txt
echo -e "${GREEN}✓ Dependencies geïnstalleerd${NC}"

# ── 4. .env aanmaken ──────────────────────────────────────────────────────────
if [ ! -f ".env" ]; then
    echo -e "\n${YELLOW}Je hebt de volgende gegevens nodig uit je Meta dashboard:${NC}"
    echo -e "  → https://developers.facebook.com/apps/\n"

    read -rp "Voer je WHATSAPP_PHONE_NUMBER_ID in: " PHONE_ID
    read -rp "Voer je WHATSAPP_ACCESS_TOKEN in: " ACCESS_TOKEN
    read -rp "Kies een zelfverzonnen VERIFY_TOKEN (bijv. mijn-geheime-token): " VERIFY_TOKEN

    cat > .env <<EOF
WHATSAPP_PHONE_NUMBER_ID=${PHONE_ID}
WHATSAPP_ACCESS_TOKEN=${ACCESS_TOKEN}
WHATSAPP_VERIFY_TOKEN=${VERIFY_TOKEN}
HOST=0.0.0.0
PORT=8000
EOF
    echo -e "${GREEN}✓ .env aangemaakt${NC}"
else
    echo -e "${GREEN}✓ .env bestaat al — overgeslagen${NC}"
fi

# ── 5. ngrok installeren ───────────────────────────────────────────────────────
if ! command -v ngrok &>/dev/null; then
    echo -e "\nngrok installeren..."
    ARCH=$(uname -m)
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')

    if [ "$ARCH" = "x86_64" ]; then ARCH_SLUG="amd64"; elif [ "$ARCH" = "aarch64" ]; then ARCH_SLUG="arm64"; else ARCH_SLUG="amd64"; fi

    NGROK_URL="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-${OS}-${ARCH_SLUG}.tgz"
    curl -sSL "$NGROK_URL" | tar xz -C /usr/local/bin 2>/dev/null || {
        curl -sSL "$NGROK_URL" | tar xz -C "$HOME/.local/bin" 2>/dev/null || true
    }
fi

if command -v ngrok &>/dev/null; then
    echo -e "${GREEN}✓ ngrok beschikbaar${NC}"
else
    echo -e "${YELLOW}⚠ ngrok niet geïnstalleerd. Installeer handmatig via https://ngrok.com/download${NC}"
fi

echo -e "\n${GREEN}=== Setup voltooid! ===${NC}"
echo -e "Start de server:  ${YELLOW}./start.sh${NC}"
