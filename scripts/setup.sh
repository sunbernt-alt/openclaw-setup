#!/usr/bin/env bash
# setup.sh – Sett opp OpenClaw/NemoClaw personlig AI-infrastruktur
# Plattform: Ubuntu 22.04+
# Kjør: bash scripts/setup.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# --- 1. Sjekk .env ---
info "Sjekker .env..."
if [[ ! -f "$REPO_ROOT/.env" ]]; then
    warn ".env ikke funnet – kopierer .env.example"
    cp "$REPO_ROOT/.env.example" "$REPO_ROOT/.env"
    error "Fyll inn verdiene i $REPO_ROOT/.env og kjør scriptet på nytt"
fi
# shellcheck disable=SC1091
source "$REPO_ROOT/.env"

# --- 2. Sjekk påkrevde verktøy ---
info "Sjekker verktøy..."
REQUIRED_TOOLS="node npm docker nemoclaw"
for tool in $REQUIRED_TOOLS; do
    if ! command -v "$tool" &>/dev/null; then
        error "$tool er ikke installert. Se README.md."
    fi
    version=$("$tool" --version 2>/dev/null | head -1)
    info "  $tool: $version"
done

# --- 3. Sjekk Node.js versjon ---
NODE_MAJOR=$(node --version | sed 's/v\([0-9]*\).*/\1/')
if (( NODE_MAJOR < 22 )); then
    error "Node.js 22+ kreves. Nåværende: $(node --version)"
fi

# --- 4. Sjekk API-nøkler ---
info "Sjekker API-nøkler..."
[[ -z "${ANTHROPIC_API_KEY:-}" ]]   && error "ANTHROPIC_API_KEY mangler i .env"
[[ -z "${PERPLEXITY_API_KEY:-}" ]]  && error "PERPLEXITY_API_KEY mangler i .env"
[[ -z "${TELEGRAM_BOT_TOKEN:-}" ]]  && error "TELEGRAM_BOT_TOKEN mangler i .env"
[[ -z "${TELEGRAM_CHAT_ID:-}" ]]    && error "TELEGRAM_CHAT_ID mangler i .env"
info "  API-nøkler OK"

# --- 5. Test Claude API ---
info "Tester Claude API..."
CLAUDE_RESPONSE=$(curl -sf https://api.anthropic.com/v1/models \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    | python3 -c "import sys,json; d=json.load(sys.stdin); print('OK, modeller:', len(d.get('data',[])))" 2>/dev/null) \
    || error "Claude API-test feilet. Sjekk ANTHROPIC_API_KEY."
info "  Claude API: $CLAUDE_RESPONSE"

# --- 6. Test Telegram Bot ---
info "Tester Telegram Bot..."
TG_RESPONSE=$(curl -sf "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe" \
    | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['result']['username'])" 2>/dev/null) \
    || error "Telegram Bot-test feilet. Sjekk TELEGRAM_BOT_TOKEN."
info "  Telegram Bot: @$TG_RESPONSE"

# --- 7. Test lokal LLM ---
info "Tester lokal LLM (${LOCAL_LLM_MODEL:-qwen3:14b})..."
if curl -sf "${LOCAL_LLM_BASE_URL:-http://localhost:11434}/api/tags" &>/dev/null; then
    info "  Ollama tilgjengelig"
else
    warn "  Ollama ikke tilgjengelig på ${LOCAL_LLM_BASE_URL:-http://localhost:11434} – kun cloud-modus"
fi

# --- 8. NemoClaw status ---
info "Sjekker NemoClaw..."
NEMOCLAW_VERSION=$(nemoclaw --version 2>/dev/null | head -1 || echo "ukjent")
info "  NemoClaw: $NEMOCLAW_VERSION"

# --- 9. Sett opp cron-jobber for EmailTriageAgent ---
info "Setter opp email-triage cron-jobber..."
CRON_ENTRY_MORNING="0 7 * * 1-5 cd $REPO_ROOT && bash scripts/email-triage.sh morning >> /tmp/email-triage.log 2>&1"
CRON_ENTRY_AFTERNOON="0 14 * * 1-5 cd $REPO_ROOT && bash scripts/email-triage.sh afternoon >> /tmp/email-triage.log 2>&1"

if ! crontab -l 2>/dev/null | grep -q "email-triage.sh morning"; then
    (crontab -l 2>/dev/null; echo "$CRON_ENTRY_MORNING") | crontab -
    info "  Cron: email-triage kl. 07:00 (man-fre) lagt til"
else
    info "  Cron: email-triage morgen allerede konfigurert"
fi

if ! crontab -l 2>/dev/null | grep -q "email-triage.sh afternoon"; then
    (crontab -l 2>/dev/null; echo "$CRON_ENTRY_AFTERNOON") | crontab -
    info "  Cron: email-triage kl. 14:00 (man-fre) lagt til"
else
    info "  Cron: email-triage ettermiddag allerede konfigurert"
fi

# --- 10. Send test-melding til Telegram ---
info "Sender test-melding til Telegram..."
curl -sf "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d "chat_id=${TELEGRAM_CHAT_ID}" \
    -d "text=✅ OpenClaw/NemoClaw oppsett fullført på $(hostname). Klar til bruk\!" \
    &>/dev/null && info "  Test-melding sendt" || warn "  Klarte ikke sende test-melding"

echo ""
info "=== Oppsett fullført ==="
info "Neste steg:"
info "  1. Les agents/*.md for å forstå agentene"
info "  2. Kjør: nemoclaw start  (starter OpenShell sandbox)"
info "  3. I Telegram: /bull EQNR  (for første aksjeanalyse)"
