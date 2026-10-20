"""Détruit l'infrastructure d'un environnement, vérifie qu'il ne reste rien de coûteux, et journalise.
Usage : python scripts/destroy.py dev"""
import datetime
import getpass
import subprocess
import sys
from pathlib import Path

import boto3

ROOT = Path(__file__).resolve().parents[1]
JOURNAL = ROOT / "docs" / "journal-destructions.md"
PROJECT = "coloc"


def leftovers(region: str) -> list[str]:
    ec2 = boto3.client("ec2", region_name=region)
    tag = [{"Name": "tag:Project", "Values": [PROJECT]}]
    found = []
    states = [{"Name": "instance-state-name", "Values": ["pending", "running", "stopped"]}]
    for res in ec2.describe_instances(Filters=tag + states)["Reservations"]:
        found += [f"instance {i['InstanceId']}" for i in res["Instances"]]
    nats = ec2.describe_nat_gateways(Filter=tag + [{"Name": "state", "Values": ["pending", "available"]}])
    found += [f"nat-gateway {n['NatGatewayId']}" for n in nats["NatGateways"]]
    found += [f"elastic-ip {a['AllocationId']}" for a in ec2.describe_addresses(Filters=tag)["Addresses"]]
    return found


def main() -> int:
    env = sys.argv[1] if len(sys.argv) > 1 else ""
    if env not in ("dev", "prod"):
        print("Usage : python scripts/destroy.py dev|prod")
        return 2
    if input(f"Tapez '{env}' pour confirmer la destruction : ").strip() != env:
        print("Annulé.")
        return 1
    code = subprocess.run(["terraform", f"-chdir={ROOT / 'infra'}", "destroy", f"-var-file=envs/{env}.tfvars",
                           "-auto-approve"]).returncode
    region = boto3.session.Session().region_name or "eu-west-3"
    rest = leftovers(region)
    status = "OK" if code == 0 and not rest else "A VERIFIER"
    when = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M")
    line = f"| {when} UTC | {env} | {getpass.getuser()} | {status} | {', '.join(rest) or 'rien'} |\n"
    with JOURNAL.open("a", encoding="utf-8") as f:
        f.write(line)
    print(line.strip())
    return 0 if status == "OK" else 1


if __name__ == "__main__":
    sys.exit(main())
