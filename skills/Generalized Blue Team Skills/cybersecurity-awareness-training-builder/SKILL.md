---
name: cybersecurity-awareness-training-builder
description: Build or refresh an annual (or per-client) cybersecurity awareness training deck — updating the current-threats section to reflect the past year, keeping structure and branding consistent across repeat clients, and producing a matching CPE/completion certificate. Use when delivering recurring security-awareness training rather than a one-off talk, especially where the same core curriculum gets refreshed and re-delivered to multiple clients over multiple years. Covers what to refresh versus what to keep stable, sourcing current threat trends responsibly, and generating a consistent completion artifact.
---

# Cybersecurity Awareness Training — Annual Builder

## Purpose
Recurring awareness training earns its value from being *current* without being rebuilt from scratch every time. This turns "update last year's deck" into a repeatable process instead of a from-memory redo, and keeps every client-specific copy consistent in structure even as content is refreshed.

## What stays stable versus what gets refreshed each cycle
**Stable** (change only if the audience or format genuinely changes):
- Core structure: what security awareness fundamentally is, why it matters to the audience, the baseline hygiene topics (passwords/MFA, phishing recognition, physical security, incident reporting process).
- Branding, template, and delivery format.
- The completion-certificate template and CPE-tracking mechanism.

**Refreshed every cycle:**
- **Current-threats section** — the specific attack trends, scam patterns, and incidents from the past 12 months relevant to the audience's industry. Source this from your own recent research and reputable current reporting rather than reusing prior-year examples verbatim; a training that cites a three-year-old breach as "recent" undercuts its own credibility.
- **Any regulatory or compliance references** that may have changed (a cited requirement or standard version can go stale silently).
- **Client-specific customization**, if the same core deck is delivered to multiple clients — company name, any client-specific policy references, and examples tailored to that client's industry (e.g., an example relevant to a legal or financial-services client will land differently than a generic one).

## Method
1. Start from the prior cycle's deck as the base, not a blank template — this is a refresh, not a rewrite.
2. Replace the current-threats section's examples and statistics with ones from the past 12 months; remove anything now dated enough to undercut credibility.
3. Check every external reference (regulatory citation, statistic source, named tool or platform) for staleness — a citation that was accurate two years ago can be wrong today even if no one manually changed it.
4. Re-apply any client-specific customization needed for this delivery.
5. Regenerate the completion certificate for this cycle/client with the correct date and CPE value, keeping the template consistent with prior cycles so a multi-year attendee's certificates look like a coherent series.

## Sourcing current threats responsibly
Prefer recent, reputable, named sources (vendor threat reports, CISA/industry advisories, recent reporting) over an unattributed "threats are rising" claim. State the actual trend, not a vague generality, and keep the audience's real exposure in view — a small business audience needs different emphasis than one made up of IT staff.

## Output
An updated training deck (with a clearly dated current-threats section), a client-specific variant if needed, and a generated completion/CPE certificate matching the delivery date and attendee.

## Composes with
`blueteam-email-security-posture` (phishing-awareness sections benefit from real, current findings rather than generic examples), `blueteam-log-triage`/`blueteam-incident-timeline-writing` (a recent real incident, appropriately anonymized, is far more effective training material than a hypothetical one).
