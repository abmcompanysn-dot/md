#!/usr/bin/env bash
# =====================================================================
# Boucle autonome : relance Claude Code tâche après tâche jusqu'à la fin
# de TACHES.md. Pour arrêter : créer un fichier vide nommé STOP.
# =====================================================================
set -uo pipefail

MAX_PASSAGES=${MAX_PASSAGES:-80}     # limite de sécurité (consommation du forfait)
MAX_REPARATIONS=3                    # essais de réparation si les tests échouent
BRANCHE=${BRANCHE:-boucle}           # branche poussée vers GitHub (déploie sur le serveur de test)

mkdir -p logs
touch JOURNAL.md BLOCAGES.md

# Les clés de test sont chargées dans l'environnement : le code et les tests
# les utilisent, mais Claude n'a pas le droit de lire le fichier .env.
if [ -f .env ]; then set -a; . ./.env; set +a; fi

git checkout -B "$BRANCHE" >/dev/null 2>&1 || true

for i in $(seq 1 "$MAX_PASSAGES"); do
  if ! grep -q '^- \[ \]' TACHES.md; then
    echo "$(date '+%F %T') Toutes les tâches sont terminées." | tee -a logs/boucle.log
    exit 0
  fi
  if [ -f STOP ]; then
    echo "$(date '+%F %T') Arrêt demandé (fichier STOP)." | tee -a logs/boucle.log
    exit 0
  fi

  TACHE=$(grep -m1 '^- \[ \]' TACHES.md | cut -c7-60)
  AVANT=$(git rev-parse HEAD 2>/dev/null || echo "aucun")
  echo "$(date '+%F %T') Passage $i : $TACHE" | tee -a logs/boucle.log

  claude -p "$(cat prompts/boucle.md)" >> logs/claude.log 2>&1

  ok=0
  for r in $(seq 0 "$MAX_REPARATIONS"); do
    if make test > logs/tests.log 2>&1; then ok=1; break; fi
    [ "$r" -eq "$MAX_REPARATIONS" ] && break
    echo "$(date '+%F %T')   tests en échec, réparation $((r+1))" | tee -a logs/boucle.log
    claude -p "Les tests échouent. Lis logs/tests.log, corrige le code sans supprimer ni désactiver de test, relance make test jusqu'à ce que tout passe, puis fais un commit. Ne pose aucune question." >> logs/claude.log 2>&1
  done

  if [ "$ok" -eq 1 ]; then
    if [ "$(git rev-parse HEAD)" != "$AVANT" ]; then
      # Sauvegarde du code sur GitHub
      git push -q origin "$BRANCHE" >> logs/boucle.log 2>&1 \
        && echo "$(date '+%F %T')   OK, poussé sur $BRANCHE" | tee -a logs/boucle.log
      # Déploiement sur le serveur de test (namespace staging du k3s)
      if make deploy-staging >> logs/deploy.log 2>&1 && make smoke-staging >> logs/deploy.log 2>&1; then
        echo "$(date '+%F %T')   déployé sur staging" | tee -a logs/boucle.log
      elif grep -q '^deploy-staging:' Makefile 2>/dev/null; then
        echo "$(date '+%F %T')   déploiement en échec, retour à la version précédente" | tee -a logs/boucle.log
        for d in $(kubectl -n staging get deploy -o name 2>/dev/null); do
          kubectl -n staging rollout undo "$d" >> logs/deploy.log 2>&1 || true
        done
        echo "- $(date '+%F') Déploiement staging en échec après « $TACHE » (voir logs/deploy.log)." >> BLOCAGES.md
        git add BLOCAGES.md && git commit -qm "boucle: déploiement staging en échec"
      fi
    fi
  else
    # Tests toujours rouges : on revient au dernier état sain et on note le problème.
    echo "$(date '+%F %T')   échec après $MAX_REPARATIONS réparations, retour à l'état précédent" | tee -a logs/boucle.log
    git reset -q --hard "$AVANT"
    git clean -fdq -e .env -e logs
    # La tâche est marquée [!] pour que la boucle passe à la suivante sans s'arrêter.
    sed -i '0,/^- \[ \]/s//- [!]/' TACHES.md
    echo "- $(date '+%F') Tâche « $TACHE » : tests toujours en échec après $MAX_REPARATIONS réparations (voir logs/tests.log)." >> BLOCAGES.md
    git add TACHES.md BLOCAGES.md && git commit -qm "boucle: tâche mise de côté ($TACHE)"
  fi
done

echo "$(date '+%F %T') Limite de $MAX_PASSAGES passages atteinte." | tee -a logs/boucle.log
