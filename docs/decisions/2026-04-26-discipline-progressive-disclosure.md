# 2026-04-26 — Progressive disclosure rule in discipline

## Context

ADR `2026-04-25-icm-memory-mapping.md`가 도출한 흡수 후보 4건 중 네 번째 (마지막). ICM과 RinDig Content-Agent-Routing 둘 다 강조하는 핵심 원칙:

> "Agent reads down and stops as soon as it has what it needs."

이는 컨텍스트 비용 거버넌스의 기본 원칙. 현재 sonmat discipline에서 명시되지 않음. 결과:
- worker가 task에 필요 없는 깊이까지 file Read 진행
- subagent dispatch 시 컨텍스트 청구가 정당화 안 됨
- 탐색이 "혹시" 깊이로 흘러 비용 ↑

이미 sonmat discipline에 인접 원칙 있음:
- `discipline/core.md` While Exploring §1: "Name your hypotheses... Track which possibilities shrink as you go — if nothing is eliminated, the question may be wrong"
- `discipline/hints.md` Dev §1: "Reduce before you verify"

진보적 조기 종료(progressive disclosure)는 별개 원칙이지만 이들과 정합. 명시할 가치.

질문: discipline에 "조기 종료" 룰을 명시할 것인가, 어디에 박을 것인가.

## Decision

**`discipline/core.md` While Exploring 섹션에 한 항목 추가**한다. ICM·RinDig 외부 정합 자료 인용.

### 추가 항목 (3번째 항목으로)

```
### While Exploring
1. **Name your hypotheses**: ...
2. **Mark your position**: ...
3. **Stop as soon as enough**: Read top-down, stop when you have what the current task needs. The cheapest verification is the one you didn't have to do because the prior layer answered the question. (ICM "agent reads down and stops" principle.) If you find yourself reading "in case it's needed", flag the missing scope decision — that's a sign the task wasn't clearly bounded.
```

### 운영 함의

- subagent dispatch 시 "X 조사" 명세에 **종료 조건** 동반 의무 (예: "auth flow까지만, util 라이브러리 깊이 진입 금지")
- 다층 file Read 시 **현 layer가 답하면 다음 layer 진입 금지** — token budget(ADR `memory-token-budgets`) 정합
- `discipline/hints.md` Dev §1 "Reduce before you verify"와 호환 — 이건 결과물 영역, 새 항목은 탐색 영역

### 적용 범위

- 즉시 적용 (텍스트 추가, 동작 변경) — 다음 sonmat 릴리스 v0.11.1 이상에 포함

본 ADR은 결정 문서. 실제 텍스트 적용은 별도 commit (v0.11.1 patch release).

## Consequences

### 긍정적

- **컨텍스트 비용 ↓**: 매 task에서 불필요 깊이 진입 차단. token budget(ADR `memory-token-budgets`)과 결합 시 효과 ↑
- **subagent dispatch 명세 정합**: subagent dispatch에 종료 조건 포함하는 의례가 자연스러워짐 — 기존 Anthropic best practice("scope investigations narrowly")와 정합
- **외부 정합**: ICM "reads down and stops" + RinDig Content-Agent-Routing 모두 동일 원칙 → 외부 권위
- **기존 discipline 정합**: While Exploring §1·§2와 자연스럽게 결합 — 새 도메인 침범 아님

### 부정적·리스크

- **종료 판단 부담**: "enough"의 기준이 task마다 다름. 익숙한 도메인에선 자명, 낯선 도메인에선 종료 판단 자체가 verifying — 무한 회귀 위험
- **"in case" 본능 차단 비용**: worker의 자연스러운 "혹시" 탐색을 자르면 cross-cutting 발견 누락 가능. devil/inspect 같은 검증 skill로 보완 필요
- **신규 skill·feature 추가 시 진입장벽**: 새 skill의 "이게 어떤 layer에서 답하나" 결정이 새 의례 부담

### 트레이드오프 검증 시점

- 적용 후 첫 3개월 컨텍스트 사용 패턴 측정 (전후 비교)
- subagent dispatch 명세에 종료 조건 포함 비율 추적
- 차단된 "in case" 탐색이 실제 가치 있었던 경우 발생 시 재검토 (false negative 측정)

## 참조

- `2026-04-25-icm-memory-mapping.md` — 본 ADR의 상위 (마지막 흡수 ADR)
- `2026-04-26-memory-token-budgets.md`, `2026-04-26-l3-l4-strategic-distinction.md`, `2026-04-26-skill-md-template.md` — 자매 ADR
- `discipline/core.md` While Exploring (v0.11.0) — 적용 대상
- ICM (Van Clief & McDermott, arXiv 2603.16021) — "reads down and stops" 원칙
- RinDig Content-Agent-Routing — 같은 원칙의 routing layer 표현
- Anthropic Claude Code best practices — "scope investigations narrowly" + subagent 사용 권장
