---
name: blueteam-incident-timeline-writing
description: Write an incident-response report from triage findings — chronological narrative, scope of compromise, containment/eradication/recovery actions taken, and lessons learned — for an incident commander, legal counsel, or leadership audience rather than a technical peer. Use when turning raw log-triage output into a deliverable that must hold up under scrutiny (including potential legal or regulatory review), not just explain what happened technically. Covers structure, evidentiary tone, and what to keep separate from a penetration-test report despite superficial similarity.
---

# Blue Team — Incident Timeline / IR Report Writing

## Purpose
Produce a report that an incident commander can make decisions from, and that survives being read later by legal counsel, a regulator, or a cyber-insurance adjuster — which means it must be precise about what's confirmed versus inferred, and complete about what was done and when.

## How this differs from a pentest report
A pentest report proves a risk to a client who authorized the engagement, for its own internal remediation planning. An IR report documents an event that already happened, to an audience that may include people with legal or regulatory obligations tied to it. That changes the tone requirements: hedge nothing you're not sure of, and don't round up severity or scope for impact — an incident report that overclaims scope (or underclaims it) creates real downstream liability, not just a slightly-off risk rating.

## Structure
1. **Header / metadata** — incident identifier, date/time of detection versus date/time of the underlying activity (these differ, and the gap matters), classification, and who authorized the response.
2. **Executive summary** — what happened, what was affected, current status (contained / eradicated / monitoring), in plain language a non-technical decision-maker can act on immediately.
3. **Timeline** — the chronological, source-attributed account from `blueteam-log-triage`, carried through to containment. Mark each entry confirmed or inferred; never blend the two without saying so.
4. **Scope of compromise** — exactly which systems, accounts, and data were confirmed affected, and — just as important — what was checked and confirmed **not** affected. An IR report that only lists what went wrong, without stating what was verified clean, invites reasonable doubt about whether the rest was actually checked.
5. **Containment, eradication, and recovery actions** — what was done, when, and by whom, in the order it happened. This section is itself evidence of due diligence; write it as a factual action log, not a summary.
6. **Root cause** — the initial access vector and why it worked, rated by confidence level like the rest of the timeline.
7. **Notification and disclosure considerations** — flag, without giving legal advice, that scope and data-type findings above may trigger breach-notification obligations, and that legal counsel should review the report before external notification decisions are made.
8. **Lessons learned / recommendations** — what changes (detections, hardening, process) would have caught this earlier or contained it faster, feeding back into `blueteam-detection-engineering` and hardening backlogs.
9. **Appendices** — full evidence log, tool output, and any indicators of compromise for internal detection use.

## Evidentiary tone discipline
- State confidence levels explicitly and consistently (confirmed / inferred / unable to determine) — the same discipline as the underlying triage timeline, carried through to the final document.
- Never speculate about attribution or motive beyond what the evidence directly supports.
- Log every action taken during response with a timestamp, even ones that turned out to be unnecessary — an incomplete action log is worse for credibility than one that shows a wrong turn that was corrected.

## Composes with
`blueteam-log-triage` (supplies the raw timeline this report is built from), `blueteam-detection-engineering` (lessons-learned findings become new detection rules), `pentest-report-anonymization`-style scrubbing if a sanitized version is ever needed for external sharing (only with legal sign-off, given the sensitivity of IR content).
