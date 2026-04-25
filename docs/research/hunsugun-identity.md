# 훈수꾼 (Kibitzer) — 정체성·아키텍처 정의 v0.2

> 시작: 2026-04-24, **개정 2026-04-25 (OpenRabbit 4층 위계 + ICM 외부 정합 반영)**
> 상태: **DRAFT — 검토 단계**. 적용 안 됨.
> 컴패니언: [spec-induction-and-sisyphus-review.md](spec-induction-and-sisyphus-review.md), [glossary.md](glossary.md), [../decisions/2026-04-25-l2-cognitive-architecture-positioning.md](../decisions/2026-04-25-l2-cognitive-architecture-positioning.md)
>
> 표기 규칙: **[U]** 준선생 명시 / **[+]** 클로드 제안 / **[?]** 미해결

---

## 0. 한 줄 정의

훈수꾼은 **L2 인지 아키텍처(생각/행동/기억)의 task/session-level 표현**. sonmat과 같은 IP 위에서 시간 척도만 다르다. **벤더·포맷 무관** L2 본체 위에 LLM(L1)과 어댑터(L3)는 갈아끼울 수 있다.

```
                ┌─ Cognition (생각) ─┬─ Action (행동) ─┬─ Memory (기억) ─┐
sub-second 표현  │ sonmat            │ sonmat          │ sonmat           │
                │ discipline/witness│ guard/worker    │ scribe (write)   │
                │ /devil            │ /isolation      │                  │
                ├───────────────────┼─────────────────┼──────────────────┤
task/session    │ 훈수꾼 advisory    │ 훈수꾼          │ 훈수꾼           │
표현 (★ 본체)   │ (project-relevance│ capability      │ multi-tag memory │
                │ + CCT)            │ boundary + audit│ + handoff spec   │
                ├───────────────────┼─────────────────┼──────────────────┤
project 표현    │ scribe project   │ OpenRabbit L2   │ scribe registry  │
                │ rule recording    │ asset reuse     │ + ADR feed       │
                └───────────────────┴─────────────────┴──────────────────┘
```

각 cell이 sonmat·훈수꾼·OpenRabbit 자산화의 어느 부분과 매핑되는지 명시. **이게 통합 structure**.

---

## 1. 정체성

### 본질

- **L2 인지 아키텍처의 task/session-level 표현**. 별도 layer 아님. 같은 세 축의 다른 시간 척도
- 비유: 스포츠 코치 / Talmud 주석층 / Auftragstaktik 직속 참모 / IETF Last Call reviewer
- 출력: advisory (구속력 없음). 명령형 금지, 상태 서술형만 (Auftragstaktik commander's intent 모달리티)
- 위치: main agent 외부 (in-process subagent 아님)

### 훈수꾼이 아닌 것

- **명령자 아님** — main 결정 뒤집을 권한 없음
- **검열관 아님** — 차단 권한 없음 (그건 guard 영역)
- **실행자 아님** — 코드/파일 직접 수정 안 함
- **단순 reviewer 아님** — 사후 평가 외에 사전 advisory + 진행 중 alert 포함

### JTBD 포지션 [+]

OpenRabbit framework가 강조: "AI awareness 말고 **AI literacy**" (Jake Van Clief). 훈수꾼의 진짜 job:

| 후보 | 분류 | 채택 |
|------|------|------|
| "AI advisor 붙어있다" | awareness | ✗ 표면적·단가 약함 |
| 내 사고에 second pair of eyes | literacy | ✓ |
| 프로젝트 추적·복원 능력 | literacy | ✓ |
| LLM 한계·prompt 작동·context 비용 이해하면서 쓰기 | literacy | ✓ (educational tone 의례) |

→ 훈수꾼은 **literacy 도구**. advisory 출력에 "왜 이렇게 작동하는가"가 항상 동반.

---

## 2. 핵심 아키텍처 원칙

### 2.1 통합 단일 architecture [U]

훈수꾼 자체는 단일 일관 architecture. 기능별 기둥이 따로 흩어지면 안 됨. **Master-Clone형 단일 본체** + **L3 어댑터 plug-in** (Toby Codex T4 + Shrivu Shankar 모델).

sonmat 6 skills(guard/inspect/witness/punch/scribe/devil)가 specialist 과다일 위험 — 훈수꾼은 처음부터 통합 단일.

### 2.2 두 abstraction layer 모두 갈아끼움 [U + 정정]

- **L1 (LLM)**: pluggable. Claude / Codex / Gemini / 로컬 LLM 모두 같은 인터페이스
- **L3 (포맷 어댑터)**: pluggable. SKILL.md / ICM/MWP / subagent .md / 미래 표준
- **L2 (본체) + L4 (orchestration wrapper)**: stable·금지

(이전 v0.1에서 "LLM만 교체 가능"이라 좁혀 썼던 것 정정. L1·L3 둘 다 교체 가능해야 진짜 벤더 무관.)

### 2.3 3rd party 자율 확장 = L3 plugin model [U + 정정]

3rd party 확장은 **L3 어댑터 layer에서만**. L2 본체(인지 아키텍처 세 축)에는 손 못 댐.

- Plugin manifest로 capability 선언
- 샌드박스, 권한 화이트리스트
- 선언적 lifecycle hook (session-start, on-decision, on-commit 등)
- L3 표면 갈아끼움 — SKILL.md, ICM CONTEXT.md, 미래 포맷 모두 어댑터로

### 2.4 ICM 5층 모델과의 정합 [+]

ICM(Van Clief & McDermott, arXiv 2603.16021)이 정의한 5층 컨텍스트 모델은 sonmat·훈수꾼 **Memory 축**과 직접 정합. 차용 가능:

| ICM 층 | 역할 | sonmat 현재 매핑 | 훈수꾼 매핑 |
|--------|------|-----------------|------------|
| L0 Global Identity (~800 토큰) | "Where am I?" workspace orientation | `~/.claude/CLAUDE.md` + `discipline/core.md` | 훈수꾼 본체 manifest |
| L1 Workspace Routing (~300 토큰) | "Where do I go?" task routing | `memory/MEMORY.md` 인덱스 | session-level routing |
| L2 Stage Contract (200-500 토큰) | "What do I do?" stage-specific | sonmat skill SKILL.md | task-level advisory contract |
| L3 Reference (500-2k 토큰) | "What rules apply?" stable conventions | `discipline/hints.md`, domain knowledge | 영구 advisory templates |
| L4 Working Artifacts (variable) | "What am I working with?" run-specific | `notes/{hostname}.md`, scribe journal/bridge-note | session artifacts + telemetry |

차용 가치 큰 패턴:
- **Inputs/Process/Outputs CONTEXT.md 템플릿** — 각 task의 advisory가 어떤 입력 읽고, 무엇을 하고, 어떤 출력 내는지 명시
- **Token budget per layer** — 컨텍스트 비용 거버넌스(§3.4)와 직결
- **L3 reference vs L4 artifact 구분** — "internalized as constraints" vs "processed as input"

---

## 3. 통합 조건 28개 (v0.1 20개 + v0.2 8개 추가)

### v0.1 [+] 조건 (1.1~1.20)

#### 권한·검증

- **3.1 권한 경계** — READ-only main 컨텍스트 / WRITE는 advisory artifact만 / 차단 권한 0 / plugin 권한 화이트리스트
- **3.2 hypothesis 명시** — 모든 advisory에 confidence marker (★ tentative / ★★ 부분 / ★★★ invariant) + "코드와 대조 필요" 자기 주석
- **3.3 project-essentiality** — devil §2.5 게이트(Stakes/Amendment cost/Next-action delta) 동일 적용. off-project advisory는 침묵
- **3.7 실패 모드** — graceful degradation, silent vs visible fail 정책, 자기 환각 self-check

#### 운영

- **3.4 비용 거버넌스** — 세션당 LLM 호출 budget, trigger condition 명시(모든 turn 아님), cheap heuristic 1차 + expensive LLM 2차
- **3.5 privacy·다중 프로젝트 격리** — multi-tag memory + scope 명시 의무 + cross-project 차단
- **3.6 plugin 충돌 해소** — ranking 규칙, mediation, last-known-good rollback
- **3.8 버전·호환성** — SemVer for kibitzer interface, deprecation policy(2-release warning), closure ceremony(PEP 404)

#### 사용자·상호작용

- **3.9 사용자 override** — snooze/mute/redirect, 빈도 학습, explicit opt-in
- **3.10 self-reference 안전성** — 재귀 깊이 제한, self-advisory 별도 채널
- **3.11 append-only 이력** — advisory 영구 기록(dismiss해도), 무시된 advisory 추적 = 학습 데이터

#### 출력·감지

- **3.12 calibrated 출력 어휘** — IPCC 10진법 (very likely/likely/about as likely as not/...) + RFC 2119 (must/should/may) 두 어휘 카테고리별 매핑
- **3.13 한국어/영어 modal 비대칭** — 이중 부정·중첩 부정 탐지, 확인-거부 사이클 무시 감지

#### 시스템 통합·메모리

- **3.14 sonmat과의 seam** — sub-second는 sonmat 잔류, task/session은 훈수꾼, 게이트는 guard. 겹침 영역(witness/scribe) 단일화 결정 필요
- **3.15 메모리 모델** — GenericAgent 5-layer + tag dimension 직교 (project/domain/sensitivity/stakes/decay/source)
- **3.16 onboarding 의례** — §7 docs 구조 점검, Conceptzia 발굴, 사용자 패턴 학습 기간
- **3.17 telemetry feedback** — advisory별 outcome tracking, retrospective, ASRS 비처벌 reporting

#### 조정·시간

- **3.18 deterministic vs stochastic** — stable 기본, "다양성 강제"(Sakana SSOT) 옵션은 alternatives axis만
- **3.19 stake-matched depth** — 작은 task에 깊은 advisory 금지, 큰 task에 얕은 advisory 금지
- **3.20 archaeology / 시간 부패** — timestamp + context hash, expiry 명시, stale 경고

### v0.2 신규 [+] 조건 (3.21~3.28) — OpenRabbit framework 반영

- **3.21 인지 아키텍처 세 축 강제** — 훈수꾼은 sonmat 세 축(Cognition/Action/Memory)을 모두 가짐. 일부 축만이면 "advisor 흉내" 수준에 머묾
- **3.22 L3 어댑터 plug-in only** — 본체 L2는 immutable. 3rd party 확장은 SKILL.md / ICM·MWP / 미래 포맷 표면에서만
- **3.23 JTBD literacy 우선** — awareness 도구 아니라 literacy 도구로 자기 포지션. 출력에 "왜 이렇게 작동하는가" 항상 동반. educational tone
- **3.24 sonmat → OpenRabbit 회수 경로** — 훈수꾼에서 검증된 패턴을 추상화 N단계로 OpenRabbit L2 자산화. 회수 단위·기준·간격 명시. 두 채널이 같은 L2 IP 공유
- **3.25 외부 정합 자료 매핑 의무** — 새 plugin·기능 추가 시 ICM·MWP·RinDig·Anthropic Skills 등 외부 자료와의 매핑 명시 (영업·문서화 권위 + 5년 호환성 검증 도구)
- **3.26 두 채널 충돌 방지** — sonmat 오픈 + OpenRabbit 상용 동선. brand·라이센싱·feature 포지셔닝 충돌 방지 정책 (후속 ADR로 구체화)
- **3.27 폴더+마크다운 우선** — Jake Van Clief 핵심 — "폴더 = 메소드, 영어 = 지시문, 에이전트 = 런타임". 훈수꾼 자체도 폴더+마크다운 구조 우선, 코드 최소화. ICM Inputs/Process/Outputs 템플릿 차용
- **3.28 ICM 5층 흡수** — Memory 축 구현은 ICM 5층 모델 형식으로 정합화. token budget per layer + L3/L4 strategic distinction 차용

---

## 4. Open Questions [?]

1. **단일 본체 vs federation** — Master-Clone(단일) vs Lead-Specialist(복수). v0.2는 단일 권장이나 미확정
2. **로컬 vs 클라우드 vs 하이브리드** — privacy 함의
3. **persistence backing** — file / SQLite / vector DB?
4. **plugin 언어·형식** — Python · TypeScript · pure markdown? sonmat은 markdown, ICM도 markdown, GenericAgent는 Python
5. **main agent와의 통신 채널** — IPC / file / MCP / 별도 protocol?
6. **무료 vs 과금** — 사용자 비용 모델
7. **공개 vs 사적** — sonmat marketplace 모델 vs 사적 배포
8. **identity persona** — 일관 어조 유지 여부
9. **두 채널 IP 분리 정책** — sonmat 오픈 vs OpenRabbit 상용에서 어느 부분 공유, 어느 부분 분기 — **별도 ADR 필요**

---

## 5. sonmat과의 명확한 분기 + seam

| 시간 척도 | sonmat 영역 | 훈수꾼 영역 | 겹침 (단일화 필요) |
|----------|------------|------------|------------------|
| sub-second 사고 교정 | discipline injection (Break/Cross/Ground) | — | — |
| 미시 행위 게이트 | guard, witness, devil, punch | — | — |
| 사고 상태 기록 | scribe write phase | — | — |
| task-level advisory | — | 훈수꾼 main | witness 일부 |
| session-level handoff | scribe bridge-note | 훈수꾼 spec | scribe seam 단일화 |
| project-level pattern | scribe project rule | OpenRabbit 회수 + 훈수꾼 telemetry | 회수 파이프라인 명세화 |
| capability boundary | guard | 훈수꾼 audit log | 분리 또는 합병 결정 |

**겹침 영역 4개**(witness, scribe, capability, project rule)는 단일화 결정 후속 ADR 후보.

---

## 6. 다음 결정 (검토 요청)

1. **§0 시간 척도 매트릭스** + **§2 두 abstraction layer 정정** + **§4 ICM 정합** 통합 채택? (v0.1 → v0.2 본체)
2. **v0.2 신규 [+] 조건 8개** 일괄 채택?
3. **Open Question 9** (두 채널 IP 분리 정책) — ADR 작성할지, 잠정 보류할지
4. **단일 본체 vs federation** Open Question 1 — 결정 필요. 미결이면 design freeze 못 함
5. **brand "훈수꾼" 확정** (오픈소스 채널) + **OpenRabbit 측 상용명 별도** — OK [확정됨]

---

## 메모

- 본 문서는 sonmat docs/decisions/2026-04-25-l2-cognitive-architecture-positioning.md ADR을 따라 재구조화
- 이전 버전 v0.1 (2026-04-24)은 "별도 layer" 프레임이 OpenRabbit 위계와 정렬 안 됐음. v0.2에서 정정
- 작성 원칙: **분석·기획만, 구현 보류**. 이 문서는 즉시 실행되지 않음
