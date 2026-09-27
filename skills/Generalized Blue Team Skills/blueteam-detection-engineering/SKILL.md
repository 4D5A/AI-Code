---
name: blueteam-detection-engineering
description: Turn a known TTP, CVE, or IOC into a testable detection rule (Sigma, KQL, or SPL) with a documented false-positive rate and a repeatable test plan. Use when a pentest finding, a threat report, or a new CVE needs a corresponding detection rather than just a patch — closing the loop from "this attack works" to "we would notice." Covers log-source selection, rule construction, benign-baseline tuning, and validation against both the real technique and common false-positive generators.
---

# Blue Team — Detection Engineering

Defensive goal: for every attack technique that matters to this environment, know whether it would actually be *noticed*, not just whether it is *patched*.

## The question this answers
Not "is this vulnerable" but **"if someone did this tomorrow, would an analyst see it — and would they see it fast enough to matter."** A detection with a 40% false-positive rate that gets tuned out within a week is worse than no detection, because it trains analysts to ignore the alert.

## Method
1. **Start from a concrete technique, not a category.** "Detect Kerberoasting" is too broad; "detect a service-ticket request for an account with an SPN and a weak/no AES support flag, at a rate above baseline for that account" is buildable. Pull the technique from a pentest finding, a CVE advisory, or a specific ATT&CK sub-technique — never build a rule against a vague label.
2. **Identify the log source that actually captures the behavior**, not the one that's merely available. Confirm the source is enabled and retained at the fidelity the rule needs (e.g., Windows Event ID 4769 with the right audit policy enabled; a proxy log with full URI, not just domain) before writing logic against it.
3. **Write the narrowest rule that still catches the technique**, then generalize deliberately. Start from the exact artifact the technique leaves (a specific event ID plus field values, a specific process-command-line pattern), rather than a broad keyword match.
4. **Establish a benign baseline before tuning.** Run the rule against at least a representative window of real production logs before it ever reaches an analyst's queue. A rule tuned only against a lab environment will misfire constantly against real, noisy production traffic (backup jobs, scheduled tasks, legitimate admin tooling that resembles the technique).
5. **Document the false-positive generators explicitly.** For each rule: what legitimate activity looks similar, and what field distinguishes it. This is what lets someone tune the rule six months from now without regressing it.
6. **Validate against the real technique**, not just the log line you expect it to produce — run the actual attack (in a lab, or reference `pentest-offensive-tooling` output) and confirm the rule fires, and confirm it fires on variations (a different tool implementing the same technique) rather than one specific command line.

## Output format
For each rule: the technique it detects (name and reference), the log source and minimum required audit/logging configuration, the rule logic in a portable format (Sigma preferred, translated to the target platform's query language), the known false-positive generators and their distinguishing field, and the validation evidence (a real or lab-generated true positive, plus a confirmed non-fire against the noted false-positive generators).

## Composes with
`pentest-fingerprinting-cve` and `pentest-offensive-tooling` (the offensive side identifies the technique to detect), `blueteam-log-triage` (the rule feeds the triage process once it's live), `blueteam-incident-timeline-writing` (a rule that fired is a timeline's first data point).
