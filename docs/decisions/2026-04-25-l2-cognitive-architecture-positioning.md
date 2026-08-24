# 2026-04-25 — sonmat을 L2 인지 아키텍처(생각/행동/기억) 본체로 정식화

## Context

OpenHuman AI 사업 인계문(2026-04-25, `~/.claude/memory/domain/openhuman.md`)에서 빌드 표준 4층 위계가 정리됨:

- **L1 LLM** — 의존하되 손대지 않음
- **L2 인지 아키텍처** = 생각·행동·기억 세 축, 벤더 무관, "거의 불변" → 사내 IP 본체
- **L3 포맷·런타임 어댑터** — SKILL.md, ICM/MWP, subagent .md → 갈아끼우는 어댑터
- **L4 오케스트레이션 wrapper** — LangGraph, AutoGen, OpenClaw 등 → **빌드 단위 채택 금지**

이 위계에서 **sonmat의 현재 위치**가 명시됨: "L2 인지 아키텍처의 개인용 R&D 프로토타입". 같은 OpenHuman 4층 위계 안에서 sonmat과 OpenHuman 사내 IP는 **같은 L2를 공유**, 채널만 다름:
- sonmat = 개인 세팅 → 범용 → 오픈소스 채널
- OpenHuman = 상용·사내 IP 채널

지금까지 sonmat은 "Claude Code 플러그인"으로 자기 정체를 잡아왔으나, 이는 L3 표면(어댑터)에 자기 정의를 종속시킨 것. 5년 후 SKILL.md 포맷이 다른 표준에 자리 내주면 sonmat이 같이 사라질 위험. 외부 정합 자료 검토(2026-04-25 fetch — ICM arXiv 2603.16021, RinDig Content-Agent-Routing) 결과 sonmat의 메모리/discipline 구조가 이미 L2 인지 아키텍처 형태와 동형임이 확인됨.

질문은 "sonmat의 자기 정의를 어느 층에 묶을 것인가".

## Decision

**sonmat을 L2 인지 아키텍처 본체로 정식화한다.** L3 포맷 어댑터에 종속되지 않는 벤더 무관 추상화를 강화한다.

### 세 축 명시

| L2 축 | 현재 sonmat 표현 |
|------|----------------|
| **Cognition (생각)** | discipline (Break/Cross/Ground + Pace/Weight/Learn), witness, devil |
| **Action (행동)** | guard, worker, isolation |
| **Memory (기억)** | scribe, journal, bridge-note, memory/{core,domain,archive} 계층 |

이 세 축이 sonmat의 자기 정의 본체. 각 축의 내부 구현은 L3 어댑터(SKILL.md, hooks, subagents)로 갈아끼움 가능.

### 운영 원칙 4개

1. **L3 어댑터 종속 금지**: 새 기능을 SKILL.md 포맷·Claude Code 훅·MCP에만 박지 않는다. 각 L2 축의 추상 contract를 마크다운 spec으로 먼저 적고, 그 위에 현재 표현(L3)을 만든다. 5년 후 다른 어댑터로 옮길 수 있어야 한다.
2. **L4 wrapper 채택 금지**: LangGraph, AutoGen, CrewAI 같은 오케스트레이션 wrapper를 sonmat 빌드 단위로 채택하지 않는다. 런타임 후보로만 본다.
3. **벤더 무관 abstraction 강화**: LLM은 L1로 분리. 한국어 modal 비대칭 같은 모델별 차이는 L2 contract에서 흡수. 모델 교체 시 sonmat 본체는 변하지 않아야 한다.
4. **회수 파이프라인 가능 상태 유지**: sonmat에서 검증된 패턴이 OpenHuman L2 사내 자산으로 일반화 가능하도록 추상화 강도를 높인다. 라이센싱·brand는 채널별로 분기되더라도 L2 IP는 공유.

### sonmat은 작동 중 플러그인이라는 사실 존중

이 결정은 **방향**이지 즉시 갈아엎는 명령이 아니다. 현재 작동하는 sonmat 플러그인은 그대로 운용한다. 신규 기능·개정은 위 4 원칙에 맞춰 진행하고, 기존 기능은 점진적 정합화. 큰 재구조화는 별도 ADR로.

## Consequences

### 긍정적

- **5년 호환성**: L3 포맷이 갈아엎혀도 L2 contract가 살아남음. SKILL.md → 다음 표준 이행 비용 ↓
- **벤더 무관성**: Claude Code 외 에이전트 환경(Codex, Gemini, 로컬 LLM)으로 이전 가능 — 기존 `sonmat_portability_exploration.md`의 동선과 정합
- **OpenHuman 회수 가능**: sonmat에서 검증된 패턴이 OpenHuman L2 사내 IP로 일반화 가능. 두 채널이 같은 IP 공유
- **외부 정합 권위 확보**: ICM(arXiv 2603.16021), MWP, Anthropic Skills의 progressive disclosure 등 외부 자료를 sonmat L2 contract의 **참조**로 인용 가능 — 영업·문서화 권위
- **훈수꾼 위치 명확**: 별도 layer가 아니라 **L2 인지 아키텍처의 task/session-level 표현**으로 위치. sonmat의 sub-second discipline injection과 동일 IP 다른 시간 척도

### 부정적·리스크

- **추상화 부담 증가**: 새 기능 추가 시 "L2 contract 먼저, L3 어댑터 나중" 두 단계 작업. 단기 개발 속도 저하
- **표면 변경 비용 임시 증가**: 기존 sonmat skill들이 L2 contract로 분리되지 않은 상태이므로, 신규 기능과 기존 기능 간 추상화 강도 차이 발생. 점진적 정렬 필요
- **L4 wrapper 유혹**: 빠른 데모·POC 압력에서 LangGraph 같은 wrapper를 끌어들이고 싶은 유혹. 빌드 단위 채택 금지 원칙 위반 시 5년 호환성 깨짐 — ADR로 명시 거절 의례 필요
- **두 채널 IP 충돌 가능성**: sonmat 오픈소스 + OpenHuman 상용이 같은 L2 공유. brand·라이센싱·기능 포지셔닝 충돌 방지 정책은 후속 ADR로

### 트레이드오프 검증 시점

- 다음 sonmat 버전(현재 v0.9.x → v1.0) 릴리스 시 본 결정의 정합성 재검토
- OpenHuman 첫 L2 자산 회수 시도 시 본 결정의 추상화 강도가 충분했는지 평가
- 5년 후 SKILL.md 포맷이 다른 표준에 자리 내주는 시점에 본 결정의 5년 호환성 효과 측정

## 후속 ADR 후보

- `2026-04-25-icm-memory-mapping.md` — sonmat memory 계층과 ICM 5층 모델의 정합·갭 분석, 어느 ICM 패턴을 sonmat L2 memory 축에 흡수할지
- `2026-XX-XX-hunsugun-positioning.md` — 훈수꾼이 sonmat L2 인지 아키텍처의 task/session-level 표현임을 정식화
- `2026-XX-XX-l3-adapter-policy.md` — L3 어댑터 갈아끼움 정책. 어떤 trigger에 어댑터 교체를 검토하는가
- `2026-XX-XX-recovery-pipeline.md` — sonmat → OpenHuman L2 자산 회수 절차

## 참조

- `~/.claude/memory/domain/openhuman.md` — 4층 위계 본체 + sonmat 위치 명시
- `~/Documents/001_OpenHuman/docs/decisions/2026-04-25-agent-shell-folder-core.md` — OpenHuman 첫 ADR (보강 절에서 4층 위계 명시)
- `~/.claude/memory/domain/sonmat_design_principles.md` — sonmat 릴리스별 설계 결정
- `~/.claude/memory/domain/sonmat_portability_exploration.md` — vendor-agnostic 이전 전략 (이 ADR과 같은 동선)
- `docs/research/spec-induction-and-sisyphus-review.md` — Phase 2 통합 패턴, sonmat 설계 feed
- `docs/research/hunsugun-identity.md` — 훈수꾼 정체성 draft (본 ADR 따라 재구조화 예정)
- ICM (Van Clief & McDermott, arXiv 2603.16021) — 5-layer context model, 외부 정합 자료
- RinDig/Content-Agent-Routing-Promptbase — 컨텍스트 윈도우 단위 라우팅
- Anthropic Agent Skills — L3 어댑터 후보 1
