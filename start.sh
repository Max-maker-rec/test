#!/usr/bin/env bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ ! -f ".env" ]; then
    echo "Geen .env gevonden. Voer eerst setup.sh uit: bash setup.sh"
    exit 1
fi

source .venv/bin/activate

# ── Start ngrok op de achtergrond ─────────────────────────────────────────────
if command -v ngrok &>/dev/null; then
    echo -e "${YELLOW}ngrok starten...${NC}"
    ngrok http 8000 --log=stdout > /tmp/ngrok.log 2>&1 &
    NGROK_PID=$!

    # Wacht tot ngrok URL beschikbaar is
    for i in {1..10}; do
        NGROK_URL=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null \
            | python3 -c "import sys,json; t=json.load(sys.stdin)['tunnels']; print(next(x['public_url'] for x in t if x['proto']=='https'))" 2>/dev/null || true)
        if [ -n "$NGROK_URL" ]; then break; fi
        sleep 1
    done

    if [ -n "$NGROK_URL" ]; then
        echo -e "${GREEN}✓ Publieke URL: ${NGROK_URL}${NC}"
        echo -e ""
        echo -e "Stel dit in als webhook in je Meta dashboard:"
        echo -e "  ${YELLOW}${NGROK_URL}/webhook${NC}"
        echo -e ""
        VERIFY_TOKEN=$(grep WHATSAPP_VERIFY_TOKEN .env | cut -d= -f2)
        echo -e "Verify token: ${YELLOW}${VERIFY_TOKEN}${NC}"
        echo -e ""
    else
        echo -e "${YELLOW}⚠ ngrok URL niet beschikbaar. Controleer http://localhost:4040${NC}"
    fi

    # Ruim ngrok op bij afsluiten
    trap "kill $NGROK_PID 2>/dev/null; echo 'ngrok gestopt.'" EXIT
else
    echo -e "${YELLOW}⚠ ngrok niet gevonden — server draait alleen lokaal op poort 8000${NC}"
fi

# ── Start FastAPI server ───────────────────────────────────────────────────────
echo -e "${GREEN}Server starten op http://localhost:8000 ...${NC}"
echo -e "Stop met Ctrl+C\n"
python main.py
