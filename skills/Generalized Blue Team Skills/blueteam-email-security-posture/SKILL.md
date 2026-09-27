---
name: blueteam-email-security-posture
description: Audit a domain's email-authentication posture — SPF, DKIM, and DMARC — from public DNS, identify missing or misconfigured records, and produce a prioritized remediation table. Use when assessing why spoofed or phishing email is getting through, onboarding a new domain, or performing a periodic email-security check. Covers common misconfigurations (duplicate SPF records, missing DMARC, undiscoverable DKIM selectors), how to tell providers apart from MX records, and honest handling of what can and can't be determined from DNS alone.
---

# Blue Team — Email Security Posture Audit

## Purpose
Most spoofed and phishing mail that gets through isn't a filter failure — it's a missing or broken authentication record the domain owner never verified. This turns "why did we get spoofed" into a systematic DNS-based check with a fix list.

## What to check, and why each one breaks independently
1. **SPF** — query TXT records for `v=spf1`. Two failure modes matter equally: **zero records** (nothing to check against, spam filters vary in how they treat this) and **more than one record** (the resolver returns them in an undefined order, so the same domain passes SPF for some recipients and fails for others — this is what makes spoofing reports look intermittent and confusing to the person reporting them). Count the records; don't just check existence.
2. **DMARC** — query `_dmarc.<domain>` for `v=DMARC1`. Same duplicate-record risk as SPF. Note the policy mode (`p=none` / `quarantine` / `reject`) — a domain with a DMARC record in `p=none` is not actually protected, it's only reporting; this is the single most common "we have DMARC" false confidence.
3. **DKIM** — the hard one. There is no reliable way to enumerate all DKIM selectors for a domain from DNS alone, because the selector name is chosen by whoever configured it and isn't recorded anywhere public. Query the well-known selectors first (`selector1`/`selector2` for Microsoft 365, `s1`/`s2` for SendGrid/PowerDMARC/other common ESPs) and treat a miss on all well-known selectors as **"may be missing," not "confirmed missing."** State this caveat explicitly in output — overclaiming a DKIM gap you can't actually confirm undermines the rest of the report.
4. **Identify the mail/filter provider from the MX record** (e.g., `mail.protection.outlook.com` → Exchange Online, `pphosted.com` → Proofpoint, `mimecast.com` → Mimecast) so remediation instructions point at the actual admin console the domain owner will use, not generic advice.

## Method
1. Resolve MX, and all TXT records, for the domain via a public or internal resolver.
2. Filter TXT records for SPF (`spf1`) and DMARC (`_dmarc` name, `DMARC1` value) patterns; count each — zero or multiple is a finding either way.
3. Check the DKIM well-known selectors matched to the identified provider (Microsoft 365 → `selector1`/`selector2`; generic ESPs → `s1`/`s2`); report presence, and flag absence as unconfirmed rather than definitive.
4. Cross-reference the DMARC policy mode against the SPF/DKIM findings — a `p=reject` policy sitting on top of a broken or absent SPF/DKIM is itself a finding (legitimate mail may be silently dropped).
5. Produce a per-domain table: record type, status (present / absent / duplicate / unconfirmed), current value if present, and the specific fix.

## Common misconfigurations to call out by name
- Two SPF records left over from a provider migration (the old one never removed).
- DMARC present but `p=none` with no one reviewing the aggregate reports it generates.
- DKIM configured for one sending path (e.g., the primary mail platform) but not for a secondary one (marketing or transactional mail sent from a different service under the same domain).

## Output
A findings table per domain (record, status, current value, fix) plus a plain-language summary: what an attacker spoofing this domain could currently get away with, and what closes each gap.

## Composes with
`blueteam-log-triage` (mail-gateway logs corroborate what DNS suggests), `blueteam-detection-engineering` (a rule for inbound mail that fails SPF/DKIM/DMARC from this domain's own name), `pentest-report-writing` style output conventions for the findings table.
