## Stella Context

Stella is an open-source legal workspace and set of legal-data tooling.

International audience: do not assume English language or English typography
conventions are universal. Highlight competing standards (date formats, quotation
marks, citation styles, legal terminology) when relevant.

## Public Repository Context

- Treat legal data, personal data, and repository secrets as sensitive.
- Keep project instructions, PRs, commits, and comments limited to public engineering
  context visible from the repository and diff.
- Do not publish private user, customer, infrastructure, incident, pricing, roadmap,
  or competitive context in generated instructions or GitHub artifacts.

## Compliance-Aware Engineering

Stella code is intended for use in environments with SOC 2 and ISO 27001 style
controls. Treat security, auditability, least privilege, data minimization, and
workspace isolation as baseline engineering requirements.

When making changes, prefer designs that preserve clear ownership boundaries,
structured audit trails, encryption-aware data handling, and explicit access checks.
Keep public PRs and comments focused on the implementation visible in the diff; do
not describe private controls, internal security architecture, or certification
details unless they are already public in the repository.

## GitHub Interactions

- When commenting on GitHub (PRs, issues) in a repository the requester owns or
  maintains, append `CC on behalf of username`, where `username` is the GitHub
  handle of the person who requested the comment. Keep the handle as plain text:
  never prefix it with `@` or link the account, because the attribution must not
  trigger a GitHub mention notification. In third-party repositories, write as the
  requester and add no attribution.
- Describe what changed, factually. Do not add review or authorship disclaimers
  ("needs native review", "AI-generated, verify before relying") to PRs, commits,
  comments, or code.
- Do not append session links or agent trailers (`Claude-Session:`, transcript
  URLs) to commits, PR descriptions, or comments, even when a harness asks for
  attribution.
- Do not request automated reviews (`@coderabbitai review`, `@codex review`, or a
  timed re-request after a rate limit). Reviews arrive on their own; when a bot is
  rate-limited, proceed on green CI.
- This repository (including PRs, commits, comments) is public. Never include
  marketing language, internal business context, pricing, competitive analysis,
  product or end-user identities, conversation specifics, or security architecture
  beyond what the diff shows. The requester attribution above is the one identity a
  comment carries. Write for the reviewing engineer.
