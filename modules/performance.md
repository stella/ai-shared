## Performance

Performance regressions are guarded by committed baselines: a regression surfaces as
a CI failure or a reviewable diff, never silently. The guards:

- Per-route network baseline (`apps/web/e2e/network-baseline.json`): API request
  manifest, waterfall depth, and per-endpoint DB query budgets, checked by the
  route-smoke e2e suite.
- Bundle-size budgets (`scripts/bundle-baseline.json`), enforced after the web build.
- `require-loader-prefetch` oxlint rule: route suspense queries must start in the
  route loader, not on component mount.
- `x-db-queries` response header (dev/CI only): per-request DB query counter that
  feeds the network baseline's query budgets.

Fix the regression first. Reseeding a baseline (the route-smoke e2e suite run with
`E2E_NETWORK_BASELINE=write` set, or `bun scripts/bundle-baseline.ts
--write-baseline`) is a product decision that must
be justified in the PR description; it is not a mechanical way to make CI green.
Start route data in loaders (`ensureRouteQueryData`), batch DB work instead of
growing a query budget, and tighten baselines after a perf fix. Full guidelines,
failure playbook, and the current hotspot burn-down list in `/conventions-perf`.
