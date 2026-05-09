# CLAUDE.md – OpenClaw/NemoClaw Personal AI Infrastructure

## Hva dette repoet er

Personlig AI-infrastruktur bygget på NVIDIA NemoClaw + Anthropic OpenClaw (Claude Code).
Kjører på Ubuntu 24.04 med RTX 4090, 64 GB RAM, lokal Qwen3 + Claude API.

## Arkitektur

```
Microsoft Teams (kanal eller personlig chat)
    │  varsler: Incoming Webhook
    │  kommandoer: /bull /bear /analyse /inbox
    ▼
Teams Bot (Node.js, botbuilder SDK, port 3978)
    │
    ▼
OpenClaw (Claude Code / NemoClaw)
    │
    ├── BullAgent          – optimistisk case per aksje
    ├── BearAgent          – pessimistisk case per aksje
    ├── RiskRewardAgent    – sammenstiller bull/bear, posisjonsstørrelse
    ├── AlternativAgent    – sektoralternativer og valuering
    └── EmailTriageAgent   – triage av Gmail / Hotmail / M365
```

## Prioriteringer

1. **Aksjeportefølje** (~14 mill NOK, norske + internasjonale)
2. **E-post** (Gmail, Hotmail, Azure M365)
3. **Arbeidsautomatisering** (Move AS, SQL Server DBA, Slack, møtereferater)

## Infrastruktur

| Komponent | Detalj |
|-----------|--------|
| OS | Ubuntu 24.04 |
| GPU | RTX 4090 24 GB VRAM |
| RAM | 64 GB |
| Lokal modell nå | Qwen3 14B (bytter til 32B når ny disk er klar) |
| Cloud analyse | Claude API Sonnet |
| Nyhetsdata | Perplexity Pro API |
| UI | Microsoft Teams |
| NemoClaw | v0.1.0 @ `~/.nemoclaw` |

## Regler

- Ingen API-nøkler i Git – bruk `.env` og `.env.example`
- Alle scripts kjøres på Ubuntu, ikke Mac
- Agenter beskrives i `agents/*.md`
- Konfig legges i `config/`
- Oppsett-script i `scripts/setup.sh`

## Utvikling

```bash
cp .env.example .env
# Fyll inn API-nøkler i .env
bash scripts/setup.sh
```

## NemoClaw-status

NemoClaw er installert på denne maskinen:
- Binær: `~/.local/bin/nemoclaw`
- Kilde: `~/.nemoclaw/source/`
- Versjon: v0.1.0 (Alpha, april 2026+)
- Skills tilgjengelig: configure-inference, deploy-remote, get-started, manage-policy, monitor-sandbox, overview, reference, workspace

For å starte: `nemoclaw start` (krever OpenShell runtime)
