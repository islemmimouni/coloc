# ADR 0001 : solution d'accès sortant (§5.3)

**Statut** : proposé, à valider par le groupe.

**Contexte** : les instances sont dans des sous-réseaux privés (non joignables depuis Internet) mais doivent installer des paquets et appeler des services externes.

| Option | Avantages | Inconvénients | Coût |
|---|---|---|---|
| NAT Gateway (un seul) | Géré par AWS, simple, fiable | Coût horaire + par Go, point unique de panne (une zone) | à chiffrer avec le calculateur |
| NAT Gateway par zone | Haute disponibilité | Coût multiplié par le nombre de zones | |
| Instance NAT | Moins cher | À administrer soi-même, moins robuste | |
| Endpoints VPC uniquement | Aucun accès Internet, très sûr | Seulement les services AWS | |

**Décision proposée** : un NAT Gateway unique, plus un endpoint S3 (gratuit). Le coût est maîtrisé par la destruction hebdomadaire de l'environnement. **Justifiez ici** votre choix final avec vos chiffres.

**Conséquences** : en cas de panne de la zone du NAT, les sous-réseaux privés perdent l'accès sortant ; acceptable pour un environnement d'étude.
