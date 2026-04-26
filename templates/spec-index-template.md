# Spec catalog (`docs/specs/_index.md`)

> Place this at `docs/specs/_index.md` in your project. Keep ≤ 50 lines (sonmat token-budget convention for index files).
> One spec = one row. Do not embed spec content here.

---

```yaml
sonmat:
  spec_awareness: disabled    # disabled | enabled (Stage 1 opt-in per ADR 2026-04-26-spec-auto-reference)
  spec_verification: disabled # disabled | enabled (Stage 2; requires Stage 1 baseline ≥ 30 days or 10 tasks)
```

---

## Active specs

| ID | Title | Status | Modal | Last updated |
|----|-------|--------|-------|--------------|
| SPEC-20260426-example | Example spec | draft | should | 2026-04-26 |

## Superseded / archived

| ID | Title | Superseded by | Sunset |
|----|-------|---------------|--------|
| | | | |

---

## Notes

- New spec: copy `spec-template.md` to `docs/specs/SPEC-{YYYYMMDD}-{slug}.md`. Add row above.
- Amendment: do not edit a `published` spec body. Create successor with `supersedes: SPEC-...` metadata. Add row above and mark this row's `Status` to `archived`.
- `sonmat.spec_awareness: enabled` activates Stage 1 — sonmat reads this index at task start and inline-references relevant specs (alert only, no blocking). See ADR `2026-04-26-spec-auto-reference.md`.
- Stage 2 (active verification — witness/guard extension) requires opt-in after baseline measurement.
