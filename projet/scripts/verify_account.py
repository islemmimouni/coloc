"""Vérification du compte : à lancer à chaque nouvelle session, puis noter le résultat dans docs/compte-aws.md."""
import datetime
import boto3

me = boto3.client("sts").get_caller_identity()
print("Compte  :", me["Account"])
print("Identité:", me["Arn"])
print("Région  :", boto3.session.Session().region_name or "NON DEFINIE (export AWS_DEFAULT_REGION=...)")
print("Date    :", datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M UTC"))
