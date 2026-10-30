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

Fix the regression first; a budget increase is a justified, reviewed decision,
never a mechanical way to make CI green. Start route data in loaders
(`ensureRouteQueryData`), batch DB work instead of growing a query budget, and
tighten budgets after a perf fix. How to justify an increase, the failure
playbook and the hotspot report live in `/conventions-perf`.
