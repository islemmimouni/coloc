"""Crée UNE FOIS le bucket S3 qui stocke l'état Terraform (il n'est jamais détruit).
Usage : python scripts/bootstrap_state.py NOM-UNIQUE-DU-BUCKET eu-west-3"""
import sys
import boto3

bucket, region = sys.argv[1], sys.argv[2]
s3 = boto3.client("s3", region_name=region)
extra = {} if region == "us-east-1" else {"CreateBucketConfiguration": {"LocationConstraint": region}}
s3.create_bucket(Bucket=bucket, **extra)
s3.put_bucket_versioning(Bucket=bucket, VersioningConfiguration={"Status": "Enabled"})
s3.put_bucket_encryption(Bucket=bucket, ServerSideEncryptionConfiguration={
    "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]})
s3.put_public_access_block(Bucket=bucket, PublicAccessBlockConfiguration={
    k: True for k in ("BlockPublicAcls", "IgnorePublicAcls", "BlockPublicPolicy", "RestrictPublicBuckets")})
print("Bucket d'état prêt :", bucket)
