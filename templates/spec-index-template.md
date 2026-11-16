# 명세 목록 (Spec catalog, `docs/specs/_index.md`)

> 프로젝트의 `docs/specs/_index.md`에 둔다. 50줄을 넘기지 않는다(인덱스 파일의 토큰 예산에 관한 sonmat 관례).
> 명세 하나에 한 행을 쓴다. 명세 내용을 여기에 옮겨 적지 않는다.

---

```yaml
sonmat:
  spec_awareness: disabled    # disabled | enabled (Stage 1 opt-in per ADR 2026-04-26-spec-auto-reference)
  spec_verification: disabled # disabled | enabled (Stage 2; requires Stage 1 baseline ≥ 30 days or 10 tasks)
```

---

## 현재 명세 (Active specs)

| ID | Title | Status | Modal | Last updated |
|----|-------|--------|-------|--------------|
| SPEC-20260426-example | Example spec | draft | should | 2026-04-26 |

## 대체·보관된 명세 (Superseded / archived)

| ID | Title | Superseded by | Sunset |
|----|-------|---------------|--------|
| | | | |

---

## 참고 (Notes)

- 새 명세: `spec-template.md`를 `docs/specs/SPEC-{YYYYMMDD}-{slug}.md`로 복사하고 위 표에 행을 더한다.
- 개정: `published` 상태인 명세의 본문은 고치지 않는다. `supersedes: SPEC-...` 메타데이터를 단 후속 명세를 만들고, 위 표에 그 행을 더한 뒤 이 명세 행의 `Status`를 `archived`로 바꾼다.
- `sonmat.spec_awareness: enabled`로 두면 Stage 1이 켜진다. sonmat은 작업을 시작할 때 이 인덱스를 읽고 관련 명세를 본문 안에서 알려 준다(알림만 하고 막지는 않는다). ADR `2026-04-26-spec-auto-reference.md`를 본다.
- Stage 2(witness·guard를 넓혀 실제로 검증하는 단계)는 기준선을 잰 뒤 따로 켜야 한다.
