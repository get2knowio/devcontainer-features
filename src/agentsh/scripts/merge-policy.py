#!/usr/bin/env python3
"""Merge the non-overridable agentsh security floor with a selected user policy."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Any

try:
    import yaml
except ImportError:  # pragma: no cover - exercised only where local Python lacks PyYAML
    yaml = None


ALLOWED_TOP_LEVEL_KEYS = {
    "version",
    "name",
    "file_rules",
    "network_rules",
    "command_rules",
    "env_policy",
    "dns_redirects",
    "connect_redirects",
    "package_rules",
    "metadata",
    "settings",
    "sandbox",
    "approval",
    "audit",
    "logging",
    "unix_sockets",
}

LIST_SECTION_KEYS = {
    "file_rules",
    "network_rules",
    "command_rules",
    "dns_redirects",
    "connect_redirects",
    "package_rules",
}


def load_policy(path: Path) -> dict[str, Any]:
    if not path.exists():
        raise ValueError(f"policy file does not exist: {path}")

    try:
        text = path.read_text(encoding="utf-8")
        if yaml is not None:
            loaded = yaml.safe_load(text)
        else:
            loaded = json.loads(
                subprocess.check_output(
                    [
                        "ruby",
                        "-ryaml",
                        "-rjson",
                        "-e",
                        "print JSON.generate(YAML.safe_load(STDIN.read, aliases: true) || {})",
                    ],
                    input=text,
                    text=True,
                )
            )
    except (subprocess.CalledProcessError, json.JSONDecodeError) as exc:
        raise ValueError(f"invalid YAML in {path}: {exc}") from exc
    except Exception as exc:
        if yaml is None or exc.__class__.__module__.split(".")[0] != "yaml":
            raise
        raise ValueError(f"invalid YAML in {path}: {exc}") from exc

    if loaded is None:
        return {}
    if not isinstance(loaded, dict):
        raise ValueError(f"policy root must be a mapping: {path}")
    return loaded


def validate_policy(policy: dict[str, Any], path: Path) -> None:
    for key, value in policy.items():
        if key not in ALLOWED_TOP_LEVEL_KEYS:
            raise ValueError(f"unknown top-level policy key in {path}: {key}")
        if key in LIST_SECTION_KEYS:
            if not isinstance(value, list):
                raise ValueError(f"policy section must be a list in {path}: {key}")
            for index, item in enumerate(value):
                if not isinstance(item, dict):
                    raise ValueError(f"policy rule must be a mapping in {path}: {key}[{index}]")
                if not item:
                    raise ValueError(f"policy rule must not be empty in {path}: {key}[{index}]")
                if "name" in item and not isinstance(item["name"], str):
                    raise ValueError(f"policy rule name must be a string in {path}: {key}[{index}]")


def merge_policies(floor: dict[str, Any], user: dict[str, Any]) -> dict[str, Any]:
    merged = dict(user)

    for key, floor_value in floor.items():
        if isinstance(floor_value, list):
            user_value = user.get(key, [])
            if not isinstance(user_value, list):
                user_value = []
            merged[key] = [*floor_value, *user_value]
        elif key not in merged:
            merged[key] = floor_value

    return merged


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("floor_policy", type=Path)
    parser.add_argument("user_policy", type=Path)
    parser.add_argument("-o", "--output", type=Path)
    return parser.parse_args()


def dump_policy(policy: dict[str, Any]) -> str:
    if yaml is not None:
        return yaml.safe_dump(policy, sort_keys=False)

    return subprocess.check_output(
        ["ruby", "-rjson", "-ryaml", "-e", "puts JSON.parse(STDIN.read).to_yaml"],
        input=json.dumps(policy),
        text=True,
    )


def main() -> int:
    args = parse_args()

    try:
        floor = load_policy(args.floor_policy)
        user = load_policy(args.user_policy)
        validate_policy(floor, args.floor_policy)
        validate_policy(user, args.user_policy)
        merged = merge_policies(floor, user)
        rendered = dump_policy(merged)
        if args.output:
            args.output.write_text(rendered, encoding="utf-8")
        else:
            sys.stdout.write(rendered)
    except ValueError as exc:
        print(f"agentsh policy merge error: {exc}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
