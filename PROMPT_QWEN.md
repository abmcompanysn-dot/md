# Consigne pour Qwen — construire la base du projet

Copie tout le texte ci-dessous dans Qwen (Qwen Code ou autre outil capable d'écrire des fichiers et de lancer
des commandes dans le dépôt). Le dépôt doit déjà contenir tous les fichiers du kit.

---

Tu es l'ingénieur principal d'un nouveau projet. Tu construis la BASE du dépôt, que Claude Code
continuera ensuite automatiquement. Tu travailles seul, sans poser de question.

## À lire d'abord, dans cet ordre

1. `OBJECTIF.md` — le but de la version 1.
2. `SPEC_TECHNIQUE.md` — la spécification précise de la base (arborescence, versions, schéma SQL, API, événements, Kubernetes).
3. `CLAUDE.md` — les règles de code (elles s'appliquent aussi à toi).
4. `DECISIONS.md` — les décisions déjà prises. Si tu dois décider autre chose, choisis le plus simple et ajoute une ligne à la fin.
5. `TACHES.md` — la liste des tâches.

## Ton périmètre

Réalise uniquement les tâches **P0.1 à P0.12** de `TACHES.md`, dans l'ordre :
structure du monorepo, Makefile, docker-compose, squelette Go api + worker, migration et RLS,
authentification complète, module événements (outbox + relais + consommateur idempotent),
design system `packages/ui`, tableau de bord Next.js (inscription, connexion, mot de passe, page vide),
`contracts/openapi.yaml`, Dockerfiles, manifestes Kubernetes base + overlays.

Ne fais pas P0.13 et suivantes ni les sprints : Claude Code les fera sur le VPS.

## Règles strictes

- Respecte exactement l'arborescence, les noms de fichiers, les noms de tables et de routes de `SPEC_TECHNIQUE.md` :
  Claude Code s'appuiera dessus.
- Chaque tâche n'est terminée que si son critère « Terminé quand » est prouvé par un test qui passe avec `make test`.
- Aucun test supprimé, désactivé ou vidé pour passer.
- Aucune clé, aucun mot de passe réel dans le dépôt. Uniquement `env.example` avec des valeurs vides ou de développement.
- Ne lis pas et ne crée pas de fichier `.env`.
- Montants en entiers XOF, identifiants UUID v7, textes d'interface dans `messages/fr.json` et `messages/en.json`.
- Code Go formaté (`gofmt`), TypeScript strict, pas de `any` sans commentaire.
- Ne modifie pas `boucle.sh`, `prompts/boucle.md`, `.claude/settings.json`, `OBJECTIF.md`.

## Après chaque tâche

1. `make test` et `make lint` verts.
2. Coche la tâche dans `TACHES.md` : `- [x]`, ou `- [~]` si une partie dépend d'un service externe absent.
3. Ajoute 3 lignes dans `JOURNAL.md` : ce que tu as fait, ce qui reste fragile, la prochaine étape.
4. Commit git : `P0.x: résumé court`.

## À la fin (passation à Claude Code)

1. Vérifie la définition de « terminé » de la section 12 de `SPEC_TECHNIQUE.md`.
2. Écris dans `JOURNAL.md` une section « Passation » : ce qui est fait, les écarts par rapport à la spécification
   et pourquoi, les commandes pour lancer et tester, les points fragiles.
3. Liste dans `BLOCAGES.md` tout ce qui manque (clés, services externes).
4. Dernier commit : `P0: base prête pour Claude Code`.

Commence maintenant par P0.1.
