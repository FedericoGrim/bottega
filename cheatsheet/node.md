# Node.js

## npm

| Comando | Cosa fa |
| --- | --- |
| `node --version` | versione di Node |
| `npm init -y` | crea package.json |
| `npm install` | installa le dipendenze |
| `npm ci` | installa esattamente da package-lock.json |
| `npm install nome` | aggiunge un pacchetto |
| `npm install -D nome` | aggiunge un pacchetto di sviluppo |
| `npm uninstall nome` | rimuove un pacchetto |
| `npm run` | elenca gli script disponibili |
| `npm run dev` | avvia lo script dev |
| `npm test` | esegue i test |
| `npm outdated` | pacchetti da aggiornare |
| `npm audit` | cerca vulnerabilità nelle dipendenze |
| `npx nome` | esegue un pacchetto senza installarlo |

## Vite

| Comando | Cosa fa |
| --- | --- |
| `npm create vite@latest mia-app` | crea un progetto Vite |
| `npm run dev` | avvia il server di sviluppo |
| `npm run build` | compila in dist/ |
| `npm run preview` | prova la versione compilata |

## Next.js

| Comando | Cosa fa |
| --- | --- |
| `npx create-next-app@latest mia-app` | crea un progetto Next.js |
| `npm run dev` | avvia in sviluppo (localhost:3000) |
| `npm run build` | compila per la produzione |
| `npm run start` | avvia la versione compilata |
| `npm run lint` | controlla il codice |

## NestJS

| Comando | Cosa fa |
| --- | --- |
| `npm install -g @nestjs/cli` | installa la CLI di Nest |
| `nest new mio-progetto` | crea un progetto |
| `npm run start:dev` | avvia e riavvia a ogni modifica |
| `nest generate module utenti` | crea un modulo |
| `nest generate controller utenti` | crea un controller |
| `nest generate service utenti` | crea un service |
| `nest generate resource utenti` | crea modulo, controller, service e DTO insieme |
| `npm run test` | esegue i test unitari |
| `npm run test:e2e` | esegue i test end-to-end |

## pnpm

| Comando | Cosa fa |
| --- | --- |
| `pnpm install` | installa le dipendenze |
| `pnpm add nome` | aggiunge un pacchetto |
| `pnpm dlx nome` | come npx |
| `mise use -g pnpm` | installa pnpm per tutto il PC (Corepack non è incluso nelle versioni recenti di Node) |
| `pnpm add -D nome` | aggiunge un pacchetto di sviluppo |
| `pnpm remove nome` | rimuove un pacchetto |
| `pnpm run dev` | avvia lo script dev |
| `pnpm exec nome` | esegue un programma installato nel progetto |
| `pnpm install --frozen-lockfile` | come npm ci: installa esattamente da pnpm-lock.yaml |
| `pnpm update` | aggiorna le dipendenze |
