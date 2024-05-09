import json
import logging
import os
import sys

import boto3

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)


def get_env_var(name, optional=False):
    """
    Function to get an environment variable
    and return its value.
    """
    try:
        value = os.environ[name]
        if value == "":
            raise KeyError
    except KeyError:
        if optional:
            return ""
        logger.error("Failed to get required environment variable " + name)
        sys.exit(1)

    return value


# flake8: noqa: E501
def get_valid_json_from_env(name, optional=True):
    """
    Function to get json content from environment variable,
    validate them and return in marshal format.
    """
    payload = get_env_var(name=name, optional=optional)
    if payload:
        try:
            if json.loads(payload):
                return payload
        except (KeyError, ValueError) as err:
            logger.error("Failed to parse %s: %s", name, err)
            if not optional:
                sys.exit(1)
    return None


def repo_tags():
    tags_env = get_valid_json_from_env(name="REPO_TAGS", optional=True)
    if tags_env:
        return [{"Key": k, "Value": v} for (k, v) in json.loads(tags_env).items()]
    return []


def is_managed_repo(repo):
    managed_prefixes = get_env_var("MANAGED_REPO_PREFIXES").split(",")
    for prefix in managed_prefixes:
        if repo.startswith(prefix.strip()):
            return True
    return False


def run(event, context):
    account_id = event["account"]
    repository = event["detail"]["requestParameters"]["repositoryName"]

    if not is_managed_repo(repository):
        logger.warning(
            "repository name %s doesn't match any of the MANAGED_REPO_PREFIXES",
            repository,
        )
        return

    client = boto3.client("ecr")

    try:
        repositories = client.describe_repositories(
            registryId=account_id, repositoryNames=[repository]
        )["repositories"]
    except:  # noqa: E722
        logger.info("failed to lookup repository %s, probably missing", repository)
        repositories = []

    # don't do anything if repository exists
    if not repositories:
        scan_on_push = (
            get_env_var(name="REPO_SCAN_ON_PUSH", optional=True).lower() == "true"
        )
        mutability = get_env_var(name="IMAGE_TAG_MUTABILITY")
        tags = repo_tags()
        try:
            client.create_repository(
                registryId=account_id,
                repositoryName=repository,
                imageTagMutability=mutability,
                imageScanningConfiguration={"scanOnPush": scan_on_push},
                encryptionConfiguration={"encryptionType": "AES256"},
                tags=tags,
            )
            logger.info("created %s repository", repository)
        except Exception as e:  # noqa: E722
            logger.error("failed to create repository %s: %s", repository, e)
            sys.exit(1)

        try:
            lifecycle_policy = get_valid_json_from_env("REPO_LIFECYCLE_POLICY")
            if lifecycle_policy:
                client.put_lifecycle_policy(
                    registryId=account_id,
                    repositoryName=repository,
                    lifecyclePolicyText=lifecycle_policy,
                )
                logger.info("created lifecycle_policy on %s", repository)
        except:  # noqa: E722
            logger.error("failed to create lifecycle_policy on %s", repository)

        try:
            repository_policy = get_valid_json_from_env("REPO_POLICY")
            if repository_policy:
                client.set_repository_policy(
                    registryId=account_id,
                    repositoryName=repository,
                    policyText=repository_policy,
                    force=False,
                )
                logger.info("created repository_policy on %s", repository)
        except:  # noqa: E722
            logger.error("failed to create repository_policy on %s", repository)

    logger.info("lambda %s completed", context.function_name)
