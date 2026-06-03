# Contract: Policy Assets and Merge Behavior

## Security Floor

Path: `src/agentsh/policies/security-floor.yaml`

Installed path: `/usr/local/share/agentsh/security-floor.yaml`

Mode/ownership: root-owned, mode `0444`

Required rule:

```yaml
file_rules:
  - name: deny-agentsh-config-write
    paths:
      - "**/.devcontainer/**"
      - "**/.agentsh/**"
      - "/etc/agentsh/**"
      - "/run/agentsh/**"
      - "/usr/local/share/agentsh/**"
      - "/usr/local/bin/agentsh"
      - "/usr/local/bin/agentsh-shell-shim"
    operations: [write, create, delete]
    decision: deny
```

The floor is non-negotiable. No feature option or overlay field may disable it.

## Example Policy

Path: `src/agentsh/policies/example.yaml`

Installed path: `/etc/agentsh/policy.yaml`

Mode/ownership: root-owned, readable by users

The example policy must:

- Be valid for the pinned agentsh release.
- Work when merged with the security floor.
- Demonstrate file, network, command, and environment policy behavior.
- Exclude the `deny-agentsh-config-write` floor rule.
- Include an approval fallback for unknown network access.

## Overlay Policy

Default path: `.devcontainer/agentsh-policy.yaml`

Resolution: path is relative to workspace root.

Behavior:

- If absent, use `/etc/agentsh/policy.yaml` as the user policy.
- If present and valid, use overlay as the user policy.
- If present and invalid, fail container startup.

## Merge Rules

Input:

1. Security floor
2. Selected user policy

Output: `/run/agentsh/policy.yaml`

Rules:

- Start with the full selected user policy.
- For each top-level key in the floor whose value is a list, prepend the floor list to the
  corresponding user list.
- If the corresponding user value is missing or not a list, treat it as an empty list.
- Preserve scalar top-level keys from the user policy.
- Preserve ordering so floor rules are evaluated first.
- Fail on invalid YAML, unknown top-level keys, or malformed rule entries.

Note: agentsh `0.20.2` accepts `env_policy` rather than the planned `env_rules` top-level
section. Runtime policy assets use `env_policy` for compatibility with the pinned release.

## Runtime Policy State

| State | Meaning |
|-------|---------|
| `default` | No overlay found; default policy merged with floor |
| `overlay:<path>` | Overlay found and merged with floor |
| `invalid` | Floor or selected user policy invalid; startup fails |

## Approvals

Policy rules with `decision: approve` create pending approvals that agentsh serves
asynchronously over its REST API (`/api/v1/approvals`). A notifier sidecar resolves them; if
none is attached, the action fails secure (deny) after `approvalTimeoutSeconds`. There is no
outbound approval webhook, and the feature does not wrap or translate approval payloads.
