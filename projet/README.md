# ColocApp : infrastructure AWS avec Terraform

Structure : `/infra` (Terraform, modules, variables par environnement) · `/app` (code applicatif) · `/scripts` (exploitation, boto3) · `/docs` (architecture, décisions, journaux).

## 0. Outils à installer (une fois)
Git, [Terraform](https://developer.hashicorp.com/terraform/install) (version 1.10 ou plus), [AWS CLI](https://aws.amazon.com/cli/), Python 3 puis `pip install boto3`.

## 1. Charger les identifiants AWS (à refaire à chaque session si ils expirent)
Copiez les 3 valeurs de la console (accès, secret, token de session) dans `~/.aws/credentials` (Windows : `C:\Users\VOTRE-NOM\.aws\credentials`) :

    [default]
    aws_access_key_id = ...
    aws_secret_access_key = ...
    aws_session_token = ...

Définissez la région (PowerShell : `$env:AWS_DEFAULT_REGION="eu-west-3"`). **Ne commitez jamais ce fichier** (déjà exclu par `.gitignore`).

## 2. Vérifier le compte
    python scripts/verify_account.py
Notez le résultat dans `docs/compte-aws.md`.

## 3. Créer le bucket d'état (une seule fois pour tout le groupe)
    python scripts/bootstrap_state.py NOM-UNIQUE-DU-BUCKET eu-west-3
Copiez `infra/envs/dev.backend.hcl.example` vers `infra/envs/dev.backend.hcl` et mettez le même nom de bucket.

## 4. Configurer l'environnement
Éditez `infra/envs/dev.tfvars` (région, e-mails du budget, et `instance_profile_name` si votre compte interdit de créer des rôles).

## 5. Initialiser puis vérifier
    cd infra
    terraform init -backend-config=envs/dev.backend.hcl
    terraform validate
    terraform plan -var-file=envs/dev.tfvars
Lisez le plan : il liste ce qui va être créé. Rien n'est créé tant que vous ne lancez pas `apply`.

## 6. Construire
    terraform apply -var-file=envs/dev.tfvars
Test : `terraform output connexion_ssm` donne la commande pour ouvrir une session sur l'instance (profil d'instance requis), puis `curl localhost` doit afficher la page "instance applicative OK" : cela prouve aussi que l'accès sortant (NAT) fonctionne.

## 7. Détruire
    cd ..
    python scripts/destroy.py dev
Le script détruit, vérifie qu'il ne reste ni instance, ni NAT, ni IP élastique, et écrit dans `docs/journal-destructions.md`.

## Règles du groupe
- Une personne à la fois fait `apply` ou `destroy`. Toujours `plan` avant `apply`.
- Pas de secret dans Git. Une branche par modification, relue avant fusion.
- Le NAT Gateway coûte tant qu'il existe : détruisez en fin de séance.
