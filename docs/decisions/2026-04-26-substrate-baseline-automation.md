# 2026-04-26 — Substrate baseline measurement: manual first, automation deferred

## Context

ADR `2026-04-26-spec-auto-reference.md` (T2-B) 가 Stage 1 → Stage 2 진입 자격 판정용 5 메트릭을 정의:
- Spec section 분량 분포
- Modal 명시율
- Acceptance criteria 존재율
- Supersession chain 정합도
- Last update 분포 (staleness)

T2-B는 이 메트릭을 **누가 측정하는가** 결정 보류. 본 ADR이 그 결정.

옵션 3개:
1. **자동 측정** — sonmat hook이 `docs/specs/` 스캔, 메트릭 계산, 저장
2. **수동 self-report** — 사용자 또는 worker가 점검, 결과 기록
3. **반자동** — worker가 frontmatter만 파싱, 분량·존재율 통계는 자동, 정성 항목은 사용자 판단

사용자 v0.11.0~0.13.0 진화 맥락:
- "프롬프트 first, hooks는 인프라만" 원칙 (`memory/domain/sonmat_design_principles.md` §2)
- 작동 중 플러그인 보호 (ADR `l2-cognitive-architecture-positioning` 운영 원칙 4: 큰 재구조화 별도 ADR)
- hook 추가는 캐싱 깨짐 위험 (지웅 피드백 2026-04-01)

질문: 첫 진입 시 어느 옵션이 안전·실용적인가.

## Decision

**옵션 2 — 수동 self-report 채택**. 옵션 1·3은 보류, 6개월 운용 후 재검토.

### 첫 진입 메커니즘

Stage 1 활성 사용자가 baseline 측정 시:

1. 사용자(또는 worker가 사용자 위탁받아) `docs/specs/_index.md`의 모든 spec ID 순회
2. 각 spec 파일을 worker가 Read
3. 5 메트릭을 worker가 정성·정량 평가:
   - **Spec section 분량 분포** (자동 계산 가능 — 줄 수)
   - **Modal 명시율** (자동 계산 가능 — `MUST|SHOULD|MAY` 정규식)
   - **Acceptance criteria 존재율** (정성 — Part 3 채워졌는지)
   - **Supersession chain 정합도** (자동 계산 가능 — frontmatter `supersedes`/`superseded-by` 양방향 일관)
   - **Staleness** (자동 계산 가능 — `last-updated` vs 현재)
4. 결과를 `docs/specs/_baseline.md`에 사용자가 기록 (worker가 draft 작성, 사용자 confirm)
5. baseline 통과 시 `_index.md`에 `sonmat.spec_verification: enabled` 추가 (Stage 2 진입)

### `_baseline.md` 형식

```markdown
# Spec baseline (`docs/specs/_baseline.md`)

> Measurement window: {YYYY-MM-DD} ~ {YYYY-MM-DD}
> Stage 1 활성 30일 이상 또는 10 task 이상 운용 후 측정

## 메트릭

| 메트릭 | 임계 | 측정값 | 통과 |
|--------|------|--------|------|
| Spec 평균 분량 | 30-200 line/file | ... | ✓/✗ |
| Modal 명시율 | ≥ 50% | ... | ✓/✗ |
| Acceptance criteria 존재율 | ≥ 60% | ... | ✓/✗ |
| Supersession 정합도 | 양방향 일관성 100% | ... | ✓/✗ |
| Staleness | 1년 이상 미갱신 spec ≤ 20% | ... | ✓/✗ |

## Stage 1 운용 메트릭 (T2-B 본 ADR 정합)

| 항목 | 임계 | 측정값 | 통과 |
|------|------|--------|------|
| Spec inline reference 정확도 | > 70% | ... | ✓/✗ |
| Heeded ratio (alert dismiss vs heeded) | > 50% | ... | ✓/✗ |

## 결정

- [ ] Stage 2 진입 권고 (모든 임계 통과)
- [ ] Stage 1 유지 (1+ 임계 미달 — 어느 메트릭, 개선 계획)

## 메모
{사용자 정성 평가}
```

### 자동화 보류 사유

- **hook 추가는 큰 변경** — sonmat "프롬프트 first" 원칙 위반 후보. 충분 검증 없이 도입 시 캐싱·환각 위험 (지웅 피드백 정합)
- **첫 운용 후에야 임계값 정합 알 수 있음** — 50% / 60% / 70% 등 임계가 적합한지 실 데이터 없음. 자동화 먼저 박으면 잘못된 임계 화석화
- **반자동(옵션 3)은 한계 모호** — 어디까지 자동, 어디부터 수동 결정에 또 ADR 필요. 첫 진입엔 단순함 우선

### 자동화 trigger

다음 조건 모두 만족 시 자동화 옵션 재검토 ADR 작성:
- 수동 self-report로 6개월 이상 운용
- 3+ 사용자 프로젝트가 Stage 1 활성
- 임계값이 실 데이터로 정합화됨
- 사용자(준선생)가 자동화 ROI 명시 평가

## Consequences

### 긍정적

- **작동 중 플러그인 보호**: hook 추가 없어 v0.13.0 호환성 유지
- **임계값 실 데이터 기반 정합 가능**: 자동화 전에 수동 측정으로 임계 보정
- **사용자 자율**: 측정·평가가 사용자 의지에 종속 — substrate 부재 사용자에게 자동 측정 강제 안 함
- **단순한 첫 진입**: `_baseline.md` 한 파일 + frontmatter parsing만으로 충분

### 부정적·리스크

- **수동 부담**: spec N개일 때 N번 Read + 평가. 큰 spec 카탈로그 사용자 fatigue
- **메트릭 일관성 위험**: 사용자 정성 평가가 시점마다 다를 수 있음 — Acceptance criteria "존재율" 같은 주관적 항목
- **임계값 추정**: 50% / 60% / 70% 등 첫 임계가 자의적. 실 데이터로 갱신해야
- **자동화 지연 비용**: 6개월 수동 운용이 자동화보다 비용 클 수 있음 — 그러나 잘못된 자동화 비용 더 큼

### 트레이드오프 검증 시점

- 첫 사용자 baseline 측정 시 — 5 메트릭이 실제 측정 가능한지
- 6개월 운용 후 — 임계값 정합성 + 자동화 ROI 평가
- 다중 사용자 프로젝트 등장 시 — 메트릭 일관성 검증

## 후속 ADR 후보

- `2026-XX-XX-baseline-automation-hook.md` — 6개월 운용 후 자동화 도입 결정 (조건 만족 시)
- `2026-XX-XX-baseline-thresholds-v2.md` — 실 데이터 기반 임계값 정합화

## 참조

- `2026-04-26-spec-auto-reference.md` (T2-B) — 본 ADR의 직속 상위 (메트릭 5개 정의)
- `2026-04-26-project-spec-structure.md` (T2-A) — `docs/specs/` 권고
- `~/.claude/memory/domain/sonmat_design_principles.md` §2 — "프롬프트 first, hooks는 인프라만" 원칙
- `discipline/hints.md` v0.13.0 Spec consumption — Stage 1 운용 메트릭 (inline reference 정확도, heeded ratio)
