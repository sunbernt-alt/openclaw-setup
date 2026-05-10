#!/usr/bin/env node
// Teams Bot – to-veis kommandoer via Microsoft Bot Framework
// Krever: Azure App Registration + Bot Channel Registration
// Start: node scripts/teams-bot.js

'use strict';

require('dotenv').config({ path: `${__dirname}/../.env` });

const { BotFrameworkAdapter, TurnContext } = require('botbuilder');
const http = require('http');

const PORT = parseInt(process.env.PORT || process.env.TEAMS_BOT_PORT || '3978', 10);

const adapter = new BotFrameworkAdapter({
    appId: process.env.TEAMS_BOT_APP_ID,
    appPassword: process.env.TEAMS_BOT_APP_PASSWORD,
});

adapter.onTurnError = async (context, error) => {
    console.error('[BotError]', error);
    await context.sendActivity('Noe gikk galt. Prøv igjen.');
};

// --- Kommandohåndtering ---

async function handleCommand(context, text) {
    const parts = text.trim().replace(/^\//, '').split(/\s+/);
    const cmd = parts[0].toLowerCase();
    const arg = parts[1]?.toUpperCase() || '';

    switch (cmd) {
        case 'bull':
            if (!arg) return context.sendActivity('Bruk: `/bull TICKER` – f.eks. `/bull EQNR`');
            return context.sendActivity(buildCard(`BullAgent: ${arg}`, bullPlaceholder(arg)));

        case 'bear':
            if (!arg) return context.sendActivity('Bruk: `/bear TICKER` – f.eks. `/bear EQNR`');
            return context.sendActivity(buildCard(`BearAgent: ${arg}`, bearPlaceholder(arg)));

        case 'analyse':
            if (!arg) return context.sendActivity('Bruk: `/analyse TICKER` – f.eks. `/analyse EQNR`');
            return context.sendActivity(buildCard(`Analyse: ${arg}`, analysePlaceholder(arg)));

        case 'inbox':
            return context.sendActivity(buildCard('E-post digest', inboxPlaceholder()));

        case 'hjelp':
        default:
            return context.sendActivity([
                '**OpenClaw – Tilgjengelige kommandoer:**',
                '`/bull TICKER`     – Optimistisk case',
                '`/bear TICKER`     – Pessimistisk case',
                '`/analyse TICKER`  – Bull + Bear + RiskReward',
                '`/inbox`           – E-post digest',
                '`/hjelp`           – Denne listen',
            ].join('\n'));
    }
}

// --- Adaptive Card-bygger ---

function buildCard(title, body) {
    return {
        type: 'message',
        attachments: [{
            contentType: 'application/vnd.microsoft.card.adaptive',
            content: {
                type: 'AdaptiveCard',
                version: '1.4',
                body: [
                    { type: 'TextBlock', text: title, weight: 'Bolder', size: 'Large' },
                    { type: 'TextBlock', text: body, wrap: true },
                ],
            },
        }],
    };
}

// --- Plassholdere (erstattes med ekte agent-kall) ---

function bullPlaceholder(ticker) {
    return `**${ticker} – Bulls-case**\n\n_BullAgent kjører analyse… (kobling til Claude API og Perplexity kommer her)_`;
}

function bearPlaceholder(ticker) {
    return `**${ticker} – Bears-case**\n\n_BearAgent kjører analyse… (kobling til Claude API og Perplexity kommer her)_`;
}

function analysePlaceholder(ticker) {
    return `**${ticker} – Full analyse**\n\n_Bull + Bear + RiskReward kjører… (kobling til Claude API og Perplexity kommer her)_`;
}

function inboxPlaceholder() {
    return '_EmailTriageAgent leser innboks… (kobling til M365 Graph API kommer her)_';
}

// --- HTTP-server ---

const server = http.createServer((req, res) => {
    if (req.method !== 'POST' || req.url !== '/api/messages') {
        res.writeHead(404);
        res.end();
        return;
    }

    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
        req.body = JSON.parse(body || '{}');
        adapter.processActivity(req, res, async (context) => {
            if (context.activity.type === 'message') {
                const text = TurnContext.removeRecipientMention(context.activity)?.trim() || '';
                await handleCommand(context, text);
            }
        });
    });
});

server.listen(PORT, () => {
    console.log(`Teams Bot lytter på port ${PORT}`);
    console.log('Endpoint: POST /api/messages');
    if (!process.env.TEAMS_BOT_APP_ID) {
        console.warn('ADVARSEL: TEAMS_BOT_APP_ID ikke satt – bot virker kun lokalt uten Azure');
    }
});
