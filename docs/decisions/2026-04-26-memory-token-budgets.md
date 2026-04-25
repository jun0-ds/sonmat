# 2026-04-26 — Memory layer token budgets

## Context

ADR `2026-04-25-icm-memory-mapping.md`가 도출한 흡수 후보 4건 중 첫 번째. ICM 5층 모델의 핵심 기여 하나는 **각 층에 명시 토큰 예산** 부여 (~800 / ~300 / 200-500 / 500-2k / variable). sonmat 메모리 계층(`core` / `domain` / `archive` + `MEMORY.md` 인덱스)은 현재 **`MEMORY.md` 200줄 truncation 외에 budget 없음**. 그 결과:

- `core/`가 무제한 누적 가능 → 매 세션 로드되는 텍스트 분량 통제 불가
- `domain/` 항목이 압축·승격·archive 의례 없이 쌓임
- `MEMORY.md`는 200줄 인덱스만 강제, 그 인덱스가 가리키는 파일 분량 통제 부재

질문: sonmat memory 각 계층에 token budget을 박아 "이 분량 넘으면 압축/승격/archive 의무" 룰을 도입할 것인가.

## Decision

**계층별 budget을 도입**한다. 단, ICM의 정확한 토큰 수치를 직접 차용하지 않고 sonmat 운용 맥락(매 세션 자동 로드 vs on-demand vs 비활성)에 맞춰 환산한다.

### Budget 표

| 계층 | 자동 로드 여부 | budget (가이드) | 초과 시 의례 |
|------|--------------|---------------|------------|
| `~/.claude/CLAUDE.md` (글로벌) | ✓ 매 세션 | ≤ 250 line | 압축 또는 import (`@path` 활용) 분리 |
| `discipline/core.md` | ✓ worker마다 inject | ≤ 100 line | 항목 통합·중복 제거. 새 항목 추가 시 기존 항목 검토 의무 |
| `discipline/hints.md` | ✓ worker마다 inject | ≤ 150 line | 도메인별 분할 제안. 도메인 추가 시 기존 도메인 dedupe |
| `memory/core/` 각 파일 | ✓ 세션 시작 시 전부 로드 | ≤ 80 line/파일, ≤ 6 파일 | 6 파일 초과 시 sub-discipline 통합 또는 `domain/` 강등 검토 |
| `memory/MEMORY.md` 인덱스 | ✓ 매 세션 | ≤ 200 line (기존) | 200 초과 시 핵심만 남기고 archive 인덱스로 분리 |
| `memory/domain/` 각 파일 | on-demand Read | ≤ 200 line/파일 | 200 초과 시 (a) 분할 (b) `archive/` 이동 (c) 핵심만 압축 |
| `memory/archive/` | 미로드 (탐색 시만) | 무제한 | budget 없음. 단 `archive/` 인덱스가 있으면 그 인덱스는 ≤ 100 line |
| `notes/{hostname}.md` (inbox) | on-demand | ≤ 100 line | 100 초과 시 정식 메모리로 승격 또는 폐기 |
| `notes/shared.md` | on-demand | ≤ 100 line | 동일 |

### 운영 원칙 4개

1. **Budget은 ceiling이 아니라 prune trigger** — 초과는 "압축할 시점"의 신호. 즉시 자르지 말 것
2. **자동 로드 계층은 엄격, on-demand는 느슨** — 매 세션 로드되는 것은 컨텍스트 비용 직접 발생
3. **새 항목 추가 시 기존 항목 검토 의무** — 추가는 곧 prune 검토 트리거 (ICM-2 후속 ADR `l3-l4-strategic-distinction`의 "internalized as constraint" 원칙과 정합)
4. **Budget 위반은 차단 아니라 flag** — 글로벌 CLAUDE.md가 기존부터 250줄 넘었는지 등 자동 감지 hook 후보 (단 hook은 별도 결정)

### 작동 중 플러그인 보호

본 ADR은 **신규 작성·수정에만 적용**. 기존 파일 일괄 prune 강제 안 함. 각 파일은 다음 자연스러운 수정 시점에 budget 점검.

## Consequences

### 긍정적

- **컨텍스트 비용 가시화**: 매 세션 로드되는 분량의 ceiling이 명시되어 "왜 컨텍스트가 빠르게 차는가" 진단 가능
- **prune 의례 강제**: budget 위반이 신호 역할 → 누적된 stale 메모리 정리 트리거. Phase 2 통합 패턴 #4 ("제약이 곧 스펙") 정합
- **ICM 정합 권위**: 외부 학술 자료(ICM)가 동일 패턴 권장 → 영업 자료 인용 가능
- **`core` 비대화 차단**: 6 파일 / 80 line 제약이 sonmat의 "core는 onboarding 압축본"이라는 정체성 보호

### 부정적·리스크

- **수치 임의성**: sonmat 운용 맥락 환산이라 했지만 첫 budget은 추측. 실제 운용에서 너무 빡빡하거나 너무 느슨할 수 있음 → 첫 6개월 실측 후 v2 budget으로 갱신
- **자동 로드 계층 prune 비용**: `discipline/core.md`가 100 line 넘으면 의례적 dedupe 작업 부담. sonmat 기능 추가 속도 저하 가능
- **자동 감지 hook 의존**: 운영 원칙 4가 hook 없이는 사람 의지에만 의존 → 별도 hook ADR 후속 가치 있음

### 트레이드오프 검증 시점

- 첫 6개월 실측 후 budget 수치 v2 갱신
- `discipline/core.md`가 100 line 도달 시 prune 의례가 실제 작동하는지 평가
- ICM-3 후속 ADR (`skill-md-template`)이 신규 SKILL.md 분량 budget도 다루는지 확인

## 참조

- `2026-04-25-icm-memory-mapping.md` — 본 ADR의 상위 (ICM 5층 흡수 후보 4건 중 1건)
- `2026-04-25-l2-cognitive-architecture-positioning.md` — L2 본체로서 sonmat memory 계층 정체성
- `~/.claude/CLAUDE.md` §5 — 현재 메모리 계층 설명
- ICM (Van Clief & McDermott, arXiv 2603.16021) — 5-layer token budget 원본
- 후속: `2026-XX-XX-l3-l4-strategic-distinction.md` (다음 ICM 흡수 ADR)
