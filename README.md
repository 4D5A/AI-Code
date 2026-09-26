# AI-Code

AI-assisted security tooling and reusable agent skills for authorized penetration testing and defensive security work.

This repository collects two kinds of artifact:

1. **Generalized Pentest Skills** — a set of methodology "skills" (portable, environment-agnostic playbooks) that guide an AI coding agent through a penetration test end to end, from recon to reporting.
2. **Scripts** — standalone AI-enhanced utilities that automate individual security tasks, such as DNS posture analysis.

Everything here is built to be reused across engagements and environments, with no client-specific data, secrets, or offensive code baked in.

---

## ⚠️ Authorized use only

The material in this repository is intended for **authorized penetration testing, defensive security, security research, and education**. Only assess systems you own or have **explicit written permission** to test, within a defined scope and rules of engagement. You are responsible for complying with all applicable laws and agreements. The authors provide this material with no warranty and accept no liability for misuse (see [LICENSE](LICENSE)).

---

## Repository structure

```
AI-Code/
├── scripts/
│   └── enumeration/
│       └── ai_enhanced_dns_analysis.ps1
├── skills/
│   └── Generalized Pentest Skills/
│       ├── pentest-enumeration/
│       ├── pentest-fingerprinting-cve/
│       ├── pentest-key-systems/
│       ├── pentest-offensive-tooling/
│       ├── pentest-report-writing/
│       ├── pentest-report-anonymization/
│       ├── pentest-system-hardening/
│       └── pentest-diagramming/
└── LICENSE
```

---

## Generalized Pentest Skills

Each skill is a self-contained `SKILL.md` with YAML frontmatter (`name` + `description`) and a body of methodology written as prose — no commands, no client data, no offensive code. They are designed to be dropped into an agent's skills directory (for example, `~/.claude/skills/`) so the agent can load the right playbook automatically when a task matches its description. They also stand alone as human-readable checklists.

The eight skills compose into a full engagement workflow:

| Skill | What it covers |
|---|---|
| **pentest-enumeration** | Low-noise host/subdomain/VLAN/port/service discovery. Reverse-DNS and internal-resolver-first techniques; avoiding disruption of shared third-party infrastructure. |
| **pentest-fingerprinting-cve** | Turning a host/port inventory into a precise software-and-version inventory, then mapping to CVEs and rating by *real* exploitability — separating confirmed CVEs from patch-currency risk. |
| **pentest-key-systems** | Identifying crown-jewel systems by access and privilege value (hypervisors, identity, secret stores, CI/source control, proxies, backups, management planes) and weighting them by reachability. |
| **pentest-offensive-tooling** | Safe, staged proof-of-concept methodology for authorized targets — smallest primitive first, stop-at-boundary discipline, secret masking, honest reporting of what was blocked. |
| **pentest-report-writing** | Structuring a client-ready report (executive summary, kill-chain narrative, severity-rated findings, prioritized actions) and exporting portably to HTML, PDF, and DOCX. |
| **pentest-report-anonymization** | Producing an external-safe copy — consistent placeholder mapping, scrubbing the machine-readable layer, avoiding re-identification, and deciding audience before content. |
| **pentest-system-hardening** | Converting findings into specific, ordered, verifiable remediation — patch-and-rotate, killing risky defaults, proxy and segmentation hardening, container hardening, DNS split-horizon. |
| **pentest-diagramming** | Designing accurate topology and attack-path diagrams; data-driven diagrams with one dataset and several views; keeping annotations separable for public builds. |

### Using the skills with an AI agent

1. Copy the individual skill folders (or the whole `Generalized Pentest Skills` directory) into your agent's skills location.
2. The agent selects a skill by matching the task to each skill's `description`.
3. Skills reference one another under their **Composes with** sections, mirroring the natural order of an engagement.

---

## Scripts

### `scripts/enumeration/ai_enhanced_dns_analysis.ps1`

A PowerShell utility that inspects a domain's DNS configuration and produces an AI-generated security assessment as a styled HTML report.

**What it does**
- Queries the target domain for email-security-relevant records (MX, SPF, DMARC, DKIM, and other TXT records) using the built-in Windows DNS resolver.
- Sends the collected records to an AI model with a cybersecurity-focused prompt to generate tailored recommendations (e.g., email authentication gaps).
- Compiles the records and recommendations into a local HTML report named `<Domain>-DnsReport.html`.

**Requirements**
- Windows PowerShell with `Resolve-DnsName` available.
- Network connectivity to your AI provider's API endpoint.
- A valid API key for the AI provider, supplied via the script's configuration. **Do not commit your API key** — keep it in an environment variable or a local, git-ignored config.

**Usage**

```powershell
.\ai_enhanced_dns_analysis.ps1 -Domain example.com
```

The report is written to the current directory. Review the AI-generated recommendations critically — treat them as a starting point for analysis, not authoritative conclusions.

---

## Requirements at a glance

- **Skills:** any agent that supports `SKILL.md`-style skills (or use them as human checklists).
- **Scripts:** Windows PowerShell and an AI provider API key.

---

## Contributing

Issues and pull requests are welcome. When contributing, keep the same discipline the skills themselves prescribe: no client-specific data, no secrets, no live offensive code — generalized methodology and reusable tooling only.

---

## License

Released under the [MIT License](LICENSE). © 2025 4D5A.
