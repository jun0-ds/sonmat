# 2026-04-25 — 훈수꾼(Kibitzer) 정체성·위치 정식화

## Context

ADR `2026-04-25-l2-cognitive-architecture-positioning.md` 에서 sonmat을 L2 인지 아키텍처(생각/행동/기억) 본체로 정식화. 이어서 `docs/research/hunsugun-identity.md` v0.1 → v0.2 개정으로 훈수꾼의 정체성·아키텍처 조건을 도출. 본 ADR은 v0.2 draft의 핵심 결정을 **ADR 수준 합의**로 박는다.

훈수꾼은 OpenRabbit 4층 위계와 sonmat 3축 안에서 자기 위치를 가져야 한다 (인계문 `~/.claude/memory/domain/openrabbit.md`, 2026-04-25). 별도 layer가 아니다 — sonmat의 sub-second discipline injection과 같은 IP 위에 시간 척도만 다른 표현이다. 이 위치를 명시 안 하면 후속 작업(plugin model, 회수 파이프라인, 두 채널 정책)이 일관성을 잃는다.

질문은 두 가지: (a) **훈수꾼이 L1-L4 위계와 sonmat 3축 어디에 사는가**, (b) **어떤 운영 원칙·조건을 박을 것인가**.

## Decision

훈수꾼을 **L2 인지 아키텍처의 task/session-level 표현**으로 정식화한다. sonmat과 같은 IP, 시간 척도만 다름. 다음 7개 결정을 ADR로 박는다.

### D1. L1-L4 위계상 위치

- **L1 LLM**: pluggable (Claude / Codex / Gemini / 로컬). 훈수꾼은 LLM 어떤 인터페이스로든 호출 가능
- **L2 인지 아키텍처 본체**: ★ 훈수꾼이 사는 자리. 세 축 (Cognition / Action / Memory) 공유
- **L3 포맷 어댑터**: pluggable. 3rd party 자율 확장은 **L3 표면에서만**. SKILL.md / ICM CONTEXT.md / 미래 표준
- **L4 wrapper**: 빌드 단위 채택 금지

L1과 L3 둘 다 갈아끼움 가능. L2(본체)와 L4(wrapper 금지) stable. 이전 v0.1에서 "LLM만 교체 가능"이라 좁혀 썼던 표현은 정정.

### D2. 세 축 × 세 시간 척도 매트릭스 채택

| | Cognition (생각) | Action (행동) | Memory (기억) |
|---|---|---|---|
| **sub-second** | sonmat discipline / witness / devil | sonmat guard / worker / isolation | sonmat scribe (write phase) |
| **task/session** ★ | 훈수꾼 advisory (project-relevance + CCT) | 훈수꾼 capability boundary + audit log | 훈수꾼 multi-tag memory + handoff spec |
| **project** | scribe project rule recording | OpenRabbit L2 asset reuse pipeline | scribe registry + ADR feed |

훈수꾼 본체는 가운데 행. 위·아래 행과의 seam은 D5 참조.

### D3. JTBD 포지션 — Literacy

훈수꾼은 **AI literacy 도구**로 자기 포지션. AI awareness 도구 아님. (Jake Van Clief: "drill → hole → picture → 3M tape — awareness 말고 literacy.")

핵심 JTBD 3개:
- 사용자 사고에 second pair of eyes 제공
- 프로젝트 추적·복원 능력
- LLM 한계·prompt 작동·context 비용을 사용자가 이해하면서 쓰도록

advisory 출력에 **"왜 이렇게 작동하는가"** 가 항상 동반 (educational tone). 단순 답이 아니라 학습 의례.

### D4. 본질 정의

- 본질: main agent 옆에 상주하는 별도 인스턴스. observe·advise만, 차단·실행 없음
- 출력: advisory (구속력 없음). **명령형 금지, 상태 서술형만** (Auftragstaktik commander's intent 모달리티)
- 시간 척도: task / 세션 / 프로젝트 단위 (sub-second 아님)
- 위치: main agent 외부 (in-process subagent 아님)
- 권한: READ-only main 컨텍스트, WRITE는 자기 advisory artifact만, 차단 권한 0, plugin 권한 화이트리스트

### D5. sonmat과의 seam — 4 겹침 영역 후속 결정

훈수꾼이 sonmat과 영역 겹치는 4 곳:

| 겹침 영역 | sonmat 측 | 훈수꾼 측 | 합병/분리 결정 |
|----------|----------|----------|---------------|
| witness 지점 | sonmat skill (sub-second) | task-level advisory에 일부 포함 가능 | **별도 ADR 후속** |
| scribe seam | bridge-note 작성·소비 | session-level handoff spec 작성·소비 | **별도 ADR 후속** |
| capability boundary | guard 영역 | 훈수꾼 audit log | **별도 ADR 후속** |
| project rule recording | scribe 영역 | 훈수꾼 telemetry | **별도 ADR 후속** |

본 ADR에선 4 영역 모두 **결정 보류, 후속 ADR로 분리**. 훈수꾼 본체 정식화가 우선이고 seam 정의는 그 다음.

### D6. brand·채널 분리

- **오픈소스 채널 명**: "훈수꾼" (한국어 그대로). 영어권에선 "kibitzer" 가어로 사용
- **OpenRabbit 상용 채널 명**: 별도 결정 (미정). 오픈소스와 brand 분리
- 두 채널이 **같은 L2 IP 공유**. 라이선스·brand·feature 포지셔닝은 분기 — 후속 ADR `two-channel-policy` 에서 구체화

### D7. v0.2 28 조건 채택 + 9 Open Question 잠정 보류

`docs/research/hunsugun-identity.md` v0.2의 **§3 통합 조건 28개를 일괄 채택**. 8개 Open Question 중 #9(두 채널 IP 분리)는 후속 ADR로 분리, 나머지 8개는 잠정 보류 — 구현 진입 시점에 재결정.

### D8. 단일 본체 권장 (잠정)

훈수꾼은 **Master-Clone형 단일 본체** + **L3 어댑터 plug-in** 모델 권장 (Toby Codex T4 + Shrivu Shankar 모델). sonmat 6 skills(guard/inspect/witness/punch/scribe/devil)이 specialist 과다일 위험 — 훈수꾼은 처음부터 통합 단일 시작. 단, 이는 v0.2 draft의 잠정 권장으로, **구현 진입 시 재검증**.

## Consequences

### 긍정적

- **훈수꾼이 별도 layer 아님이 명시**: OpenRabbit 4층 위계와 정합. sonmat이 차지하는 L2 IP를 그대로 공유 → 회수 파이프라인 가능
- **L1·L3 둘 다 교체 가능**: 모델 교체·포맷 교체에 대한 5년 호환성 확보
- **L2 본체 stable**: 훈수꾼 핵심 contract가 어떤 LLM/어댑터 포맷에서도 동일하게 작동해야 한다는 제약이 명확
- **JTBD literacy 명시**: OpenRabbit 영업 단가 근거(컨설팅 차원). 단순 "AI advisor 붙임" awareness 도구로 흐르지 않도록 의도된 brake
- **D5 seam 후속 분리**: 본 ADR이 모든 결정을 한꺼번에 잡지 않음 — 훈수꾼 본체 정식화에 집중, 겹침 영역은 별도 작업으로 위임
- **OpenRabbit 회수 가능 상태 유지**: 훈수꾼에서 검증된 패턴이 OpenRabbit L2 자산으로 일반화 가능 (D6 brand 분리 + L2 공유 구조)

### 부정적·리스크

- **추상화 부담**: 훈수꾼 신규 기능 추가 시 L2 contract와 L3 어댑터를 분리해 작성해야 함. 단기 개발 속도 저하
- **잠정 결정 다수**: D7의 28 조건 + Open Question, D8의 단일 본체 권장이 모두 잠정. 구현 진입 시 8건 이상 재결정 필요
- **D5 seam 미해결**: witness/scribe/capability/project rule 4 영역이 결정 보류 — 훈수꾼 구현 시작 전에 4 후속 ADR 마무리 필요. 그 전엔 design freeze 불가
- **brand·라이선스 분리 검증 필요**: D6의 두 채널 IP 공유 + brand 분리는 법률·라이선스 검토 필요. 별도 ADR `two-channel-policy` 진행 시 이슈 surface 가능
- **JTBD literacy ↔ awareness 줄타기**: OpenRabbit 영업 시 고객 인식이 awareness 단어 중심 — D3의 literacy 포지션이 영업 단어와 충돌 가능. OpenRabbit ADR `agent-shell-folder-core` 의 "겉=에이전트 단어, 속=폴더+JTBD" 두 겹 포지션과 정합 필요
- **단일 본체 vs federation 미확정**: D8 잠정 권장이 구현 시 깨질 수 있음. 깨지면 L2 contract 자체 재설계 필요

### 트레이드오프 검증 시점

- 후속 4 ADR (witness seam / scribe seam / capability boundary / project rule) 작성 시점 — D5 결정이 일관 가능한지
- 두 채널 정책 ADR 작성 시점 — D6 brand 분리가 라이선스·법률 검토 통과하는지
- 첫 훈수꾼 prototype 구현 진입 시점 — D7·D8 잠정 결정의 실효성 평가
- OpenRabbit 첫 고객사 deploy 시점 — D3 literacy JTBD가 영업 단어와 어떻게 조정되는지

## 후속 ADR 후보

본 ADR이 보류한 것 (우선순위 순):

1. `2026-XX-XX-l3-adapter-policy.md` — L3 어댑터 갈아끼움 정책. 어떤 trigger에 어댑터 교체 검토하나 (sonmat 회 기조 ADR sequence #4)
2. `2026-XX-XX-two-channel-policy.md` — sonmat 오픈 + OpenRabbit 상용 두 채널 IP·brand·라이선스 분리 (sequence #5)
3. `2026-XX-XX-recovery-pipeline.md` — sonmat → OpenRabbit L2 자산 회수 절차 (sequence #6)
4. `2026-XX-XX-hunsugun-witness-seam.md` — D5 영역 1
5. `2026-XX-XX-hunsugun-scribe-seam.md` — D5 영역 2
6. `2026-XX-XX-hunsugun-capability-boundary.md` — D5 영역 3
7. `2026-XX-XX-hunsugun-project-rule-seam.md` — D5 영역 4

## 참조

- `2026-04-25-l2-cognitive-architecture-positioning.md` — sonmat L2 본체 정식화 (본 ADR의 직속 상위)
- `2026-04-25-icm-memory-mapping.md` — ICM 5층 모델과 sonmat memory 매핑 (Memory 축 외부 정합)
- `docs/research/hunsugun-identity.md` v0.2 — 훈수꾼 정체성·아키텍처 draft (본 ADR의 분석 본체)
- `docs/research/spec-induction-and-sisyphus-review.md` Phase 1+2 — 24 사례 + 16 통합 패턴 (훈수꾼 28 조건의 근거)
- `docs/research/glossary.md` — 용어 풀이
- `~/.claude/memory/domain/openrabbit.md` — 4층 위계 본체 + sonmat 위치 명시
- `~/Documents/001_OpenRabbit/docs/decisions/2026-04-25-agent-shell-folder-core.md` — OpenRabbit 두 겹 포지션 (겉=에이전트, 속=폴더+JTBD). D3 literacy 포지션과 정합 필요
