Tu travailles seul, sans jamais poser de question.

1. Lis OBJECTIF.md, SPEC_TECHNIQUE.md, CLAUDE.md, DECISIONS.md, TACHES.md et les 30 dernières lignes de JOURNAL.md.
2. Prends la première tâche marquée « - [ ] » dans TACHES.md.
3. Écris le code et les tests qui prouvent son critère « Terminé quand ».
4. Lance « make test ». Corrige jusqu'à ce que TOUS les tests passent. Ne supprime ni ne désactive aucun test.
5. Si un service externe n'a pas de clé : utilise l'implémentation « simulated », marque la tâche « - [~] »,
   ajoute une ligne dans BLOCAGES.md (« clé X manquante, mode simulé »), et termine la tâche quand même.
6. Si une décision n'est pas couverte par DECISIONS.md : choisis l'option la plus simple qui respecte OBJECTIF.md,
   ajoute-la à la fin de DECISIONS.md, et continue.
7. Ajoute 3 lignes à JOURNAL.md : ce que tu as fait, ce qui reste fragile, la prochaine étape.
8. Coche la tâche (« - [x] » ou « - [~] »), puis « git add -A » et « git commit -m "<numéro>: <résumé>" ».
9. Arrête-toi après UNE seule tâche.

Interdits : lire ou modifier .env, écrire une clé dans un fichier, appeler un service de paiement réel,
déployer en production, git push, supprimer l'historique.
