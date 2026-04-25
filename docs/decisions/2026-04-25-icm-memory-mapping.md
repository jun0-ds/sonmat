# 2026-04-25 — ICM 5-layer 모델과 sonmat memory 계층의 정합·갭 분석

## Context

ADR `2026-04-25-l2-cognitive-architecture-positioning.md`에서 sonmat을 L2 인지 아키텍처(생각/행동/기억) 본체로 정식화. 그 직후 외부 정합 자료를 fetch한 결과, **Interpretable Context Methodology (ICM, Van Clief & McDermott, arXiv 2603.16021)** 의 5층 컨텍스트 모델이 sonmat의 기억(Memory) 축과 거의 동형임이 확인됨. ICM은 academia 인용 가능한 권위 + Anthropic Skills의 progressive disclosure 패턴과 호환되는 외부 표준.

**질문**: ICM 5층 모델을 sonmat에 어디까지 흡수할 것인가. 어디서 sonmat 현재 구조가 ICM과 동형이고, 어디서 갭이 있고, 어떤 갭을 메우는 게 가치 있는가.

이 ADR은 **분석·매핑** 문서이지 즉시 구조 변경 명령이 아니다. 갭을 메우는 실제 작업은 별도 후속 ADR로 진행한다 (sonmat 현 v0.10.1 작동 중 플러그인 보호).

### ICM 5층 (참조)

ICM은 컨텍스트를 5층으로 나누고 각 층에 token budget과 역할을 부여:

| ICM 층 | 역할 | 토큰 예산 | 상태 |
|--------|------|----------|------|
| **L0 Global Identity** | "Where am I?" workspace orientation | ~800 | 항상 로드 |
| **L1 Workspace Routing** | "Where do I go?" task routing | ~300 | 항상 로드 |
| **L2 Stage Contract** | "What do I do?" stage-specific instruction | 200-500 | stage 진입 시 로드 |
| **L3 Reference Material** | "What rules apply?" stable conventions | 500-2k | 명시 참조 시만 |
| **L4 Working Artifacts** | "What am I working with?" run-specific | 가변 | stage 출력으로 사용 |

핵심 원칙 (ICM 논문):
- "agent reads down and stops as soon as it has what it needs" — 하향식 조기 종료
- "L3 reference should be internalized as constraints; L4 artifacts processed as input" — strategic distinction
- Stage contract는 Inputs / Process / Outputs 3섹션 마크다운 템플릿

## Decision

ICM 5층 모델을 sonmat memory 축의 **참조 표준**으로 채택한다. 다음 매핑을 ADR로 박는다. 갭을 메우는 실제 구현은 후속 ADR로 단계 진행한다.

### 매핑표 (ADR 본체)

| ICM 층 | 역할 | sonmat 현 매핑 | 정합도 | 갭 |
|--------|------|---------------|--------|-----|
| **L0 Global Identity** | workspace orientation | `~/.claude/CLAUDE.md` (글로벌) + `discipline/core.md` (sonmat 본체) + `memory/core/` | 강 | 토큰 예산 명시 없음. 분량 통제 의례 부재 |
| **L1 Workspace Routing** | task routing | `memory/MEMORY.md` 인덱스 + 프로젝트별 `CLAUDE.md` | 강 | MEMORY.md 200줄 truncation 룰은 있으나 "300토큰" 같은 명시 budget 없음 |
| **L2 Stage Contract** | stage instruction | sonmat 각 skill의 `SKILL.md` | 중 | Inputs/Process/Outputs 정형 포맷 미강제. skill별로 자유롭게 작성됨 |
| **L3 Reference Material** | stable conventions | `discipline/hints.md` (도메인 antibody), `~/.claude/sonmat/memory/trap_*.md`, `insight_*.md` | 강 | "internalized as constraints" 명시 의례 없음 |
| **L4 Working Artifacts** | run-specific | `notes/{hostname}.md` (inbox), scribe `bridge-note.md` / `journal.md`, project memory | 강 | "stage 출력 → 다음 stage 입력" 같은 sequential pipeline 부재. sonmat은 비순차 |

### 정합도 평가

- **강 정합 4층** (L0, L1, L3, L4) — sonmat이 이미 ICM 형태와 거의 동형. 큰 재구조화 불필요
- **중 정합 1층** (L2 Stage Contract) — sonmat skill SKILL.md가 자유 포맷. ICM Inputs/Process/Outputs 강제하면 일관성 ↑이나 작동 중 플러그인 변경 부담

### 흡수 가치 vs 보류

#### 흡수 가치 있는 패턴 (후속 ADR 후보)

1. **토큰 예산 per layer 명시** — sonmat memory 각 계층에 "이 분량 넘으면 압축·승격·archive" 룰. 현재는 MEMORY.md 200줄만 명시. core/domain/archive 각각에 budget 있으면 prune 의례 강제 가능
2. **L3/L4 strategic distinction** — `hints.md` (constraint, 항상 적용)과 scribe artifact (input, 참조 시만)의 처리 의례 분리. 현재는 둘 다 "참조"로 흐릿
3. **Skill SKILL.md Inputs/Process/Outputs 템플릿** — 신규 skill만 적용, 기존 skill은 점진 (큰 재구조화 금지 원칙)
4. **하향식 조기 종료 룰** — "agent reads down and stops as soon as it has what it needs"를 discipline에 한 줄로 박음. 불필요한 깊이 진입 차단

#### 보류 (sonmat 현 레벨에 무리)

- **Numbered stages 폴더 (`01_research/`, `02_script/`)** — sonmat은 sequential pipeline 아님 (skills은 trigger-reactive). ICM의 stage 번호 매김은 ICM의 "ordered pipeline" 전제에 묶임. sonmat에 강제 시 정체성 혼란
- **`_config/`, `shared/` 디렉토리 분리** — sonmat은 `discipline/`, `skills/`, `agents/`, `hooks/` 분리 이미 충분. 추가 디렉토리는 redundant

### 결론적 매핑 (ADR 합의)

sonmat은 ICM 5층 모델과 **L0, L1, L3, L4 강 정합**, **L2 중 정합**. ICM의 핵심 기여(progressive disclosure, token budget, strategic distinction)는 sonmat에 흡수 가치 있으나, ICM의 sequential pipeline 전제(numbered stages)는 sonmat 정체성과 맞지 않음.

흡수 작업은 4건의 후속 ADR로 분리:

- `2026-XX-XX-memory-token-budgets.md` — core/domain/archive 분량 ceiling 명시
- `2026-XX-XX-l3-l4-strategic-distinction.md` — `hints.md` constraint vs scribe artifact 처리 의례 분리
- `2026-XX-XX-skill-md-template.md` — 신규 skill용 Inputs/Process/Outputs 템플릿 도입
- `2026-XX-XX-discipline-progressive-disclosure.md` — 하향식 조기 종료 룰 discipline 추가

## Consequences

### 긍정적

- **외부 학술 권위 확보**: ICM(arXiv 2603.16021) 인용 가능. OpenRabbit 영업 자료에서 sonmat L2 contract의 외부 정합 근거로 활용
- **5년 호환성**: SKILL.md 포맷 → ICM·MWP·다음 표준으로 이행 시 sonmat memory contract는 보존. ADR `2026-04-25-l2-cognitive-architecture-positioning.md`의 "L3 어댑터 갈아끼움" 원칙과 정합
- **Anthropic Skills progressive disclosure와 호환**: ICM과 Anthropic Skills 둘 다 같은 패턴(L2 stage contract, lazy load) 사용 → sonmat이 두 표면 모두에 자연 적응
- **갭 정밀화**: 막연히 "sonmat memory 개선"이 아니라 "L2 Stage Contract 정형 부재"처럼 구체 갭으로 환원. 후속 ADR이 명확

### 부정적·리스크

- **기존 SKILL.md 비균질**: 신규 skill에 Inputs/Process/Outputs 템플릿 적용 시 기존과 형태 차이. 점진 정렬 부담
- **Token budget 강제 시 학습 곡선**: 사용자(준선생)가 메모리 작성 시 "이 분량 넘었음 — 압축" 의례에 적응 필요
- **ICM 자체가 신생 표준 (2026)**: 5년 후 다른 표준에 대체될 가능성 있음. sonmat이 ICM 어휘에 종속되지 않도록 매핑은 **참조**로 유지 — sonmat 본체는 자기 어휘를 보존
- **MWP 학술본 부재**: ICM 리포(RinDig)는 "MWP 학술본 참조"라 했으나 fetch 결과 MWP 자체 spec 부재. ICM이 사실상 MWP 통합본. 별도 표준 아님 — 인계문에서 "MWP는 ICM 확장 학술본"으로 명시한 것이 정확

### 트레이드오프 검증 시점

- 4건 후속 ADR 중 첫 번째 적용 후 sonmat 운용 안정성 평가
- ICM이 5년 후 다른 표준에 자리 내주는 시점에 본 ADR의 매핑이 어떻게 이행되는지 측정
- OpenRabbit 첫 고객사 deploy 시 ICM 권위 인용이 영업 단가에 미치는 영향 평가

## 참조

- `2026-04-25-l2-cognitive-architecture-positioning.md` — 본 ADR의 상위 결정 (L2 본체 정식화)
- ICM (Van Clief & McDermott, arXiv 2603.16021) — 5-layer 컨텍스트 모델 본체
- `RinDig/Interpreted-Context-Methdology` — ICM 오픈소스 리포 (MIT)
- `RinDig/Content-Agent-Routing-Promptbase` — 컨텍스트 윈도우 단위 라우팅
- Anthropic Agent Skills — `~/.claude/skills/<name>/SKILL.md` Progressive Disclosure
- `~/.claude/CLAUDE.md` §5 — sonmat 현재 메모리 계층 (core/domain/archive)
- `~/.claude/memory/MEMORY.md` — 현재 인덱스 (200줄 truncation 룰)
- `docs/research/spec-induction-and-sisyphus-review.md` Phase 2 — Memory 축 외부 정합
- `docs/research/hunsugun-identity.md` v0.2 §2.4 — ICM 5층 정합 매핑 (훈수꾼 측면)
