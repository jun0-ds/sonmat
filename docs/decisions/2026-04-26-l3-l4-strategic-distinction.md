# 2026-04-26 — L3 reference vs L4 artifact strategic distinction

## Context

ADR `2026-04-25-icm-memory-mapping.md`가 도출한 흡수 후보 4건 중 두 번째. ICM 5층 모델의 핵심 원칙 하나는 **L3 reference와 L4 artifact의 strategic distinction**:

- **L3 reference** ("internalized as constraints"): stable 규약·디자인 시스템·voice 가이드. 항상 작동하는 제약. 매번 명시 참조 안 해도 행동에 흡수돼야
- **L4 artifact** ("processed as input"): run-specific 출력. 명시 입력으로 처리, 다음 stage가 사용

sonmat 현재 상태:
- `discipline/hints.md` = L3 (도메인 antibody, worker마다 inject)
- scribe artifact (`bridge-note.md`, `journal.md`) = L4 (run-specific 기록)
- 그러나 **sonmat 내부 처리 의례에서 두 종류를 동일하게 "참조"로 다룸**. 결과적으로:
  - L3 hints가 매번 명시 인용되지 않으면 적용 누락 (constraint로 작동 안 함)
  - L4 artifact가 자동 로드되어 다음 task의 가정으로 흘러듦 (input 의례 없이)

질문: sonmat에 L3·L4 처리 의례를 분리해 박을 것인가.

## Decision

**L3와 L4를 처리 의례 수준에서 분리**한다. 두 종류의 sonmat 자산 각각에 대해 다른 의례를 적용한다.

### L3 reference 처리 의례 — "constraint as background"

대상: `discipline/core.md`, `discipline/hints.md`, `~/.claude/sonmat/memory/trap_*.md`, `~/.claude/sonmat/memory/insight_*.md`, `~/.claude/CLAUDE.md`

의례:
1. **자동 inject** — worker dispatch 시 자동으로 프롬프트에 포함됨 (현재 sonmat 동작)
2. **명시 인용 불요** — worker가 행동 중 hint·trap 인용 안 해도 작동에 영향. 단 행동이 어떤 trap·hint와 충돌하면 surface 의무
3. **수정은 신중** — L3는 "stable 규약"이므로 자주 바뀌면 정체성 깨짐. budget(ADR `memory-token-budgets`) 강제 prune 의례와 결합
4. **inline 변경 금지** — task 중간에 worker가 "이 trap이 잘못됐다"고 판단해도 직접 고치지 않고 scribe novel trap dispatch로 우회

### L4 artifact 처리 의례 — "input on demand"

대상: scribe `bridge-note.md`, `journal.md`, `progress.md`, `notes/{hostname}.md`, `~/.claude/sonmat/control-tower/*.md`, project memory `projects/*/memory/`

의례:
1. **명시 Read 의무** — 자동 로드 안 됨. task 시작 시 또는 명시 트리거에 Read tool로 입력
2. **hypothesis로 다룸** — L4는 이전 작업의 표현이므로 "fact로 가정 금지". scribe SKILL.md `Bridge Note Consumption #5` (v0.11.0) 정합
3. **input → output 흐름** — 한 task의 L4 출력은 다음 task의 L4 입력. stage 간 명시 handoff
4. **만료·stale 표지** — timestamp 동반, 일정 기간 후 stale 경고 (ICM의 "run-specific" 본성 정합)

### 모호 영역 결정

- `discipline/core.md` 자체는 L3 (constraint)
- `discipline/hints.md`도 L3 (constraint)
- 그러나 **새 hint 추가가 발생하는 순간의 임시 작성물**은 L4 (artifact). 정식 hints.md에 들어가야 L3로 승격
- scribe `journal.md`는 L4. **journal에서 추출된 패턴이 trap_*.md로 승격되면 L3**

이 승격 경로(L4 → L3)가 sonmat 학습 메커니즘. scribe novel trap recording이 정확히 이 승격 의례 수행.

### 명시 표지 도입 (선택, 후속 결정)

각 파일에 frontmatter `tier: L3 | L4` 표지 도입 제안. 단 즉시 적용 안 함 — 별도 ADR로 도입 효과 측정 후 결정.

## Consequences

### 긍정적

- **L3 미작동 차단**: hints가 inject돼도 worker가 명시 인용 의무에 매여 있으면 burden, 그러나 명시 불요 + surface 의무로 정합 잡힘
- **L4 무자각 흡수 차단**: bridge-note가 hypothesis로 다뤄짐. Phase 2 통합 패턴 #15 (자기 비판) + scribe v0.11.0 변경 정합
- **승격 경로 가시화**: L4 → L3 이행 의례가 명문화돼 sonmat 학습이 우연이 아니라 의례화
- **ICM 외부 정합**: ICM 원칙 그대로 차용 → 권위 확보

### 부정적·리스크

- **표지 도입 비용**: frontmatter `tier` 표지 도입 시 기존 파일 일괄 수정 부담. 따라서 본 ADR은 **신규 파일에만 적용 권장, 기존 파일은 자연스러운 수정 시점에 추가**
- **승격 임계 모호**: L4 → L3 승격 trigger ("같은 패턴 N회 관측")가 명확하지 않음. 현재는 scribe novel trap의 "user 확인 필요"가 trigger로 작동하나 더 정량적 trigger 후속 결정 가치
- **L4 hypothesis 의례 비용**: bridge-note 매번 verify 강제하면 다음 세션 첫 응답 길어짐. v0.11.0 scribe 변경에 이미 반영됐으나 운용 부담 측정 필요

### 트레이드오프 검증 시점

- 신규 작성 L3·L4 파일에서 처리 의례 차이가 실제 작동하는지 6개월 후 평가
- L4 → L3 승격이 자연스럽게 일어나는지 scribe novel trap 통계 확인
- frontmatter `tier` 표지 도입 효과는 별도 ADR로 결정

## 참조

- `2026-04-25-icm-memory-mapping.md` — 본 ADR의 상위
- `2026-04-26-memory-token-budgets.md` — 자매 ADR (budget은 L3 prune 트리거)
- `skills/scribe/SKILL.md` (v0.11.0) — Bridge Note Consumption #5 hypothesis 처리 정합
- ICM (Van Clief & McDermott, arXiv 2603.16021) — strategic distinction 원본
- 후속: `2026-XX-XX-skill-md-template.md` (다음 ICM 흡수 ADR — SKILL.md도 L3·L4 분리 적용)
