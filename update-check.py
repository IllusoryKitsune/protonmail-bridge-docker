#!/usr/bin/env python3
"""Check upstream Proton Mail Bridge for a new release.

Writes the latest tag into VERSION and the amd64 .deb URL into deb/PACKAGE,
then commits and (optionally) pushes. Designed to run from a GitHub Actions
cron, but safe to run locally.
"""

import argparse
import os
import subprocess
import sys

import requests


GITHUB_API = "https://api.github.com/repos/protonmail/proton-bridge/releases/latest"


def git(*args: str) -> int:
    """Run git with the given arguments; return the exit code."""
    return subprocess.call(["git", *args])


def fetch_latest_release() -> dict:
    headers = {
        "Accept": "application/vnd.github+json",
        "User-Agent": "illusorykitsune-protonmail-bridge-docker-update-check",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    token = os.environ.get("GITHUB_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    resp = requests.get(GITHUB_API, headers=headers, timeout=30)
    resp.raise_for_status()
    return resp.json()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "is_pull_request",
        nargs="?",
        default="false",
        help="'true' on pull-request events; skips the push step.",
    )
    args = parser.parse_args()
    is_pull_request = args.is_pull_request.lower() == "true"

    release = fetch_latest_release()
    version = release["tag_name"]
    deb_assets = [a for a in release["assets"] if a["name"].endswith(".deb")]
    if not deb_assets:
        print("No .deb asset found in the latest release.", file=sys.stderr)
        return 1
    deb = deb_assets[0]["browser_download_url"]

    print(f"Latest release is: {version}")

    with open("VERSION", "w") as f:
        f.write(version)

    with open("deb/PACKAGE", "w") as f:
        f.write(deb)

    git("config", "--local", "user.name", "GitHub Actions")
    git("config", "--local", "user.email", "actions@github.com")
    git("add", "-A")

    # `git diff --cached --quiet` exits 0 when there are no staged changes.
    if git("diff", "--cached", "--quiet") == 0:
        print("Version didn't change")
        return 0

    if git("commit", "-m", f"Bump version to {version}") != 0:
        print("Git commit failed!", file=sys.stderr)
        return 1

    if is_pull_request:
        print("This is a pull request, skipping push step.")
        return 0

    if git("push") != 0:
        print("Git push failed!", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
