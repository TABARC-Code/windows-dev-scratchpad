# TABARC Windows Utilities — Development Plan

Updated 19 October 2026. This tracks completed repository changes separately from Windows verification.

## Phase 0 — Correctness and safety

Source changes committed:
- Port Warden: PowerShell 5.1 parsing, process-ID variable collision, listener-only termination lookup, warning-only example.
- Smart Folder Sync: dry run, non-overlapping roots, optional quarantine mirror and empty-source guard.
- Environment Snapshot: default redaction of credential-like environment variables.
- Log Rotator: verification before clearing the original.
- Zombie Process Reaper and Event Log Diff: restore the missing executable tools.
- Auto Re-Login: explicit application target, foreground check and protected credential prompt.

Validation gate:
- PowerShell 5.1 and 7 parse checks on a Windows runner.
- Run fixture and edge-case tests: empty source, existing destination, nested roots, locked logs, executable errors.
- Review paths containing junctions, symlinks, long names and non-ASCII characters.
- No claim of tested Windows functionality until the runner or a real Windows machine confirms it.

## Phase 1 — Common entry point

Initial implementation: Tabarc-Windows-Toolkit.ps1 (list, status, snapshot, changes, emergency, eventlog and port).
- Keep tools separately installable, with readable paths and no forced new dependencies.
- Add per-command structured results, exit codes and clear missing-dependency messages.
- Share basic config, structured logging and notification conventions.
- Support a portable Windows folder without requiring administrator rights for read-only commands.
- Add portable mode and a small optional tray interface only after command behaviour is stable.

Acceptance: list shows real installed paths, missing tools are obvious, and read-only status never changes system state.

## Phase 2 — Change Detective

Initial implementation: Change-Detective.ps1 comparing environment snapshots for PATH, installed apps, services, tasks, tools and environment variables.
- Expand observed-change categories: startup entries, Windows updates, driver versions and network configuration.
- Optionally ingest Event Log Diff reports using evidence timestamps and record IDs.
- Add a timeline viewer and JSON/HTML exports with redaction.
- Label changes as observations; never imply causality from temporal proximity alone.
- Ensure that fields hidden in source snapshots are never reconstructed or leaked in exports.

Acceptance: fixture tests cover additions, removals, updates, ordering changes, missing values and redacted credentials. Evidence must be traceable to its source and time.

## Phase 3 — Reliability toolkit

- Wi-Fi recovery: initial layered gateway/upstream/DNS diagnostic and capped opt-in resets implemented (`windows-wifi-auto-recovery`); remaining: broader live-network tests and alert routing.
- UI automation: read-only display geometry and foreground-window DPI inspector implemented (`windows-ui-sanity-tools`); remaining: window-relative click targeting, action recorder, per-step checks and emergency stop.
- Rebuild assistant: initial local inventory, WinGet export and restoration checklist implemented (`scripts/09-Rebuild-Inventory.ps1`); future: selected application configuration inventories, verify imports and restore testing. No unattended import by default.
- Disk inspector: health indicators when provided by hardware, directory growth history and versioned quarantine for duplicates.
- Notifications: Windows events/logging first; opt-in Home Assistant routing with throttling.

Acceptance: each tool operates independently, has a dry-run path for mutation and a documented rollback or recovery strategy.

## Phase 4 — Optional integrations

- Printventory: print-job status and failure history with explicit adapters.
- Media Organiser: read-only inventory, resumable scans, provenance and deliberate write modes.
- Home Assistant: subscription-based system alerts with user-controlled data selection.
- Wargaming Lexicon and creative projects: prioritise their domain-specific roadmaps; don't make them dependencies of Windows maintenance tools.

Acceptance: each integration can be disabled without impairing standalone operation.

## Shared engineering rules

1. Use PowerShell 5.1-compatible syntax unless a project explicitly requires 7+.
2. Treat system modifications as privileged operations; default to read-only or reversible behaviour.
3. Store no plaintext passwords or secrets in logs, snapshots or committed configurations.
4. Use parameter validation, precise error codes, bounded retries and clear operator output.
5. Test both scripts and README examples against actual files.
6. Document limitations and verified tests accurately.
