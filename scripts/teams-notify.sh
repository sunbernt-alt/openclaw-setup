#!/usr/bin/env bash
# teams-notify.sh – Send en melding til Teams via Incoming Webhook
# Bruk: bash scripts/teams-notify.sh "Din melding her"
#       bash scripts/teams-notify.sh "Tittel" "Detaljer her"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env"

[[ -f "$ENV_FILE" ]] && source "$ENV_FILE"

if [[ -z "${TEAMS_WEBHOOK_URL:-}" ]]; then
    echo "Feil: TEAMS_WEBHOOK_URL mangler i .env" >&2
    exit 1
fi

TITLE="${1:-OpenClaw}"
BODY="${2:-}"

# Hvis bare ett argument: bruk det som body, tittel blir "OpenClaw"
if [[ $# -eq 1 ]]; then
    TITLE="OpenClaw"
    BODY="$1"
fi

# Bygg MessageCard JSON (støttet av alle Teams-versjoner)
PAYLOAD=$(python3 -c "
import json, sys
payload = {
    '@type': 'MessageCard',
    '@context': 'https://schema.org/extensions',
    'themeColor': '0076D7',
    'summary': sys.argv[1],
    'sections': [{
        'activityTitle': sys.argv[1],
        'activityText': sys.argv[2]
    }]
}
print(json.dumps(payload))
" "$TITLE" "$BODY")

HTTP_STATUS=$(curl -sf -o /dev/null -w "%{http_code}" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD" \
    "$TEAMS_WEBHOOK_URL")

if [[ "$HTTP_STATUS" == "200" ]]; then
    echo "Sendt til Teams: $TITLE"
else
    echo "Feil ved sending til Teams (HTTP $HTTP_STATUS)" >&2
    exit 1
fi
