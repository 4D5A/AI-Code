---
name: blueteam-log-triage
description: Triage and correlate logs across Windows Event Log, firewall, proxy, and mail-gateway sources during the first hours of an incident or a proactive hunt, to separate signal from noise and reconstruct a timeline. Use when there's a suspected compromise, an alert that needs context before escalation, or a proactive sweep for a known technique across available log sources. Covers what to pull first, how to correlate across sources with different clocks and identifiers, and honestly distinguishing confirmed activity from merely-consistent-with-it.
---

# Blue Team — Log Triage and Timeline Reconstruction

## Purpose
The first hour of triage decides whether an incident gets contained quickly or missed entirely. The goal is a defensible, time-ordered account of what happened — built from evidence, not assumption.

## What to pull first, and in what order
1. **The alert or artifact that started the investigation** — pin its exact timestamp, source, and the raw log line, not a summarized version. Every other step measures time relative to this anchor.
2. **The narrowest-scope, highest-fidelity source for that specific artifact** — if the trigger is a suspicious logon, pull the relevant Windows Security Event IDs (4624/4625/4768/4769 and similar) for that account and host before widening scope. Don't start with a broad log search across the whole environment; start at the point of the alert and expand outward only as evidence justifies it.
3. **Adjacent network evidence** — firewall/proxy logs for the same host and time window, to establish what the host talked to (or was talked to by) around the event.
4. **Mail-gateway logs**, if there's any possibility of an email-delivered initial access vector — even when the current alert looks unrelated to email, ruling this in or out early prevents re-scoping the whole investigation later.

## Correlation discipline
- **Normalize timestamps to one timezone before comparing anything.** Windows Event Log, firewall syslog, and mail-gateway logs frequently default to different zones (local vs. UTC) — a timeline built without reconciling this will have events in the wrong order, which is worse than no timeline at all because it looks confident and isn't.
- **Correlate on more than one identifier.** A single username or IP match across sources can be coincidental (shared NAT, a service account used by many processes); prefer combinations (user + host + time window, or process + parent process + host) before treating two log lines as the same event.
- **Distinguish "confirms" from "is consistent with."** A log line that merely doesn't contradict the working theory is not evidence for it. Say plainly when a piece of the timeline is inferred rather than directly evidenced, and note what additional log source (if retained) would confirm it.

## Timeline reconstruction
Build the timeline as a strict chronological table: timestamp (normalized), source, host/account, event, and confidence (confirmed / inferred). Mark the earliest confirmed indicator of compromise distinctly from the alert time — they are usually not the same moment, and the gap between them is itself an important finding (dwell time).

## Output
A chronological timeline table as above, a one-paragraph plain-language summary of what's confirmed versus still uncertain, and an explicit list of what additional log sources (if they exist and are retained) would close the remaining gaps.

## Composes with
`blueteam-detection-engineering` (a rule that fired is triage's starting artifact), `blueteam-incident-timeline-writing` (this skill builds the raw timeline; that one turns it into the IR deliverable), `blueteam-ad-hygiene-audit` (privileged-account findings often surface mid-triage and need the same current-vs-stale verification).
