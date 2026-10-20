# ADR 0002 : stratégie d'état Terraform

**Décision** : état distant dans un bucket S3 (versionné, chiffré, accès public bloqué), verrouillage natif S3 (`use_lockfile`), une clé par environnement (`dev/…`, `prod/…`).

**Pourquoi** : l'état local se perd et ne se partage pas ; il contient des informations sensibles. Le bucket est créé **une seule fois** par `scripts/bootstrap_state.py` et n'est **jamais** détruit par les cycles hebdomadaires.

**Risques** : bucket supprimé par erreur (le versionnement permet de restaurer) ; deux personnes qui font `apply` en même temps (le verrou l'empêche).
