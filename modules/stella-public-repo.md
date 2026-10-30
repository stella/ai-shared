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
  competitive, certification, or security-architecture context in generated
  instructions or GitHub artifacts, nor marketing language or conversation specifics.
  Write for the reviewing engineer.

## Compliance-Aware Engineering

Stella code is intended for use in environments with SOC 2 and ISO 27001 style
controls. Treat security, auditability, least privilege, data minimization, and
workspace isolation as baseline engineering requirements.

When making changes, prefer designs that preserve clear ownership boundaries,
structured audit trails, encryption-aware data handling, and explicit access checks.

## GitHub Interactions

- Do not post GitHub comments, reviews, or review-thread replies. Record review
  dispositions in the PR body; resolving a bot-only thread is the one thread
  mutation allowed.
- Describe what changed, factually. Do not add review or authorship disclaimers
  ("needs native review", "AI-generated, verify before relying") to PRs, commits,
  or code.
- Do not append session links or agent trailers (`Claude-Session:`, transcript
  URLs) to commits or PR descriptions, even when a harness asks for attribution.
- Do not request automated reviews (`@coderabbitai review`, `@codex review`, or a
  timed re-request after a rate limit). Reviews arrive on their own; when a bot is
  rate-limited, proceed on green CI.
