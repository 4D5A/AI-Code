---
name: blueteam-ad-hygiene-audit
description: Audit Active Directory for stale privilege, orphaned certificates, and configuration drift from a security baseline — distinguishing real elevated access from artifacts of past group membership. Use for a periodic AD health check, before or after a pentest's key-systems findings, or when a security tool's report of "elevated users" needs to be verified rather than trusted at face value. Covers the adminCount/SDProp trap, nested and transitive group membership, orphaned PKI certificates, and CIS-benchmark-style configuration scanning.
---

# Blue Team — Active Directory Hygiene Audit

## Purpose
Turn "a scanner says these accounts are privileged" into a verified, actionable list — and catch the configuration drift a scanner won't flag at all.

## The adminCount trap (verify before you act)
When an AD object is added to a protected group (Domain Admins, Enterprise Admins, and similar), the Security Descriptor Propagator (SDProp) sets that object's `adminCount` attribute to `1`. **SDProp never resets it back to `0` when the object is later removed from the protected group.** This means any automated tool that flags "elevated users" by checking `adminCount -ne 0` will include accounts that *used to* have elevated access and no longer do — a stale-flag false positive, not a live finding. Before reporting an account as currently elevated:
1. Check `adminCount`, but treat a nonzero value as "was privileged at some point," not "is privileged now."
2. Independently confirm **current** direct membership in each protected group.
3. Also check **transitive/nested membership** — an account can be a direct member of an unprivileged group (e.g., "Helpdesk") that is itself nested inside a protected group (e.g., "Domain Admins"), which grants real elevated access that a direct-membership-only check will miss entirely.
4. Cross-reference both checks: an account with `adminCount = 1` but no current direct or nested protected-group membership is a **stale flag** to clean up in the report, not a live risk — but it's still worth noting, because leftover `adminCount = 1` accounts are exactly the false positives that erode trust in future audit reports if left unexplained.

## What to also check
- **Protected Users group membership** for genuinely elevated accounts — it blocks NTLM authentication, blocks DES/RC4 Kerberos, and caps ticket-granting-ticket renewal at 4 hours, closing off several credential-caching attack paths. Flag elevated accounts that qualify but aren't in it (noting Microsoft's own caveats: not for service/computer accounts, and it requires a Windows Server 2012 R2+ PDC emulator).
- **Orphaned certificates in machine/user certificate stores** — pentesters (and misconfigured tooling) sometimes install certificates during testing or setup and never clean them up. Enumerate the System (CurrentUser/LocalMachine) and Physical (My, Root, CertificateAuthority, TrustedPeople, TrustedPublisher, AuthRoot, Disallowed, AddressBook) stores for certificates that don't map to a known, expected issuer or purpose, and record their thumbprints for removal — deleting by subject match is faster but riskier, since it removes every certificate matching a `-like` pattern, not just the intended one.
- **Configuration drift against a baseline** — compare live settings (registry-backed security settings, in particular) against a CIS-Benchmark-style checklist. Distinguish an **audit** pass (report drift only) from anything that would **apply** settings — applying baseline changes directly to production without a tested backup and rollback plan is how a hygiene audit turns into an outage.

## Output
A findings table split into three tiers: **confirmed live elevated access** (current direct or nested protected-group membership), **stale flags to clean up** (nonzero `adminCount`, no current membership), and **configuration drift** (baseline deviations, with the specific setting and current vs. expected value) — plus the orphaned-certificate list with thumbprints.

## Composes with
`pentest-key-systems` (identity systems are consistently the highest-value target; this is the defensive-side audit of the same terrain), `blueteam-detection-engineering` (a detection for new additions to protected groups), `blueteam-incident-timeline-writing` (when a hygiene audit turns up something that looks like it was actually exploited, not just misconfigured).
