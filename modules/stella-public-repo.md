## Stella Context

Stella is an open-source legal workspace.

## Ideal Customer Profile (ICP)

**Current focus: mid-size law firms, 5-50 lawyers.**
Pragmatic, cost-conscious, not overly technical.

**Scale target: Magic Circle firms (2,000-5,000+ lawyers).**
The architecture must not block scaling to this level. See the Scalability section
below for decision guidelines.

International audience: do not assume English language or English typography
conventions are universal. Highlight competing standards (date formats, quotation
marks, citation styles, legal terminology) when relevant.

## Regulated Industry

Stella handles privileged legal data. All code must meet **SOC 2 Type II** and
**ISO 27001** standards: least privilege, audit trails, encryption, workspace
isolation, ethical walls. Full checklist in `/conventions-security`.

## GitHub Interactions

- When commenting on GitHub (PRs, issues), include "CC on behalf of @username" where
  username is the GitHub handle of the person who requested the comment.
- This repository (including PRs, commits, comments) is public. Never include
  marketing language, internal business context, pricing, competitive analysis, user
  identities, conversation specifics, or security architecture beyond what the diff
  shows. Write for the reviewing engineer.
