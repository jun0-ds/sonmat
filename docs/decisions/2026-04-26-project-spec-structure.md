# 2026-04-26 — User project `docs/specs/` structure recommendation (T2-A)

## Context

ADR `2026-04-25-l2-cognitive-architecture-positioning.md` 운영 원칙 1 (L3 어댑터 종속 금지)과 Phase 3 architecture-methodology 연구 결과 (`docs/research/architecture-methodology-and-spec-discipline.md`)에서 도출된 Tier 2 첫 번째 항목.

준선생 핵심 질문 (이번 세션):
- **Q1**: 스펙은 자동적으로 실행이 되는가? (현재 NO)
- **Q2**: 단순 투두 ≠ 통합 정의문서로 유도하는가? (현재 NO)

현재 sonmat은 사용자 프로젝트의 spec 문서 자체를 다루는 의례 0. 글로벌 CLAUDE.md §7에 `docs/decisions/` (ADR) 권고만 있고, **spec 자체** 위치·형식은 미정.

Phase 3 연구의 직접 매핑 가능 모델:
- **A3 CSI MasterFormat Three-Part Format** — Part 1 General / Part 2 Products / Part 3 Execution (50 Divisions × 6-digit numbering)
- **A3 ISO 19650 Information Container** — discrete·named·versioned + lifecycle status (WIP / Shared / Published / Archived)
- **A3 ISO 12006-2** — categorical schema commons

devil 정제 결과 (counter strength: Moderate, verdict: Holds with disclaimer): 사용자 substrate 부재 시 빈 의례·cargo-cult 위험. **권고만, 강제 안 함** 명시 필수.

질문: sonmat이 사용자 프로젝트에 spec 문서 구조를 권고하는가, 어떤 형식인가, 강제력은 어디까지인가.

## Decision

**`docs/specs/` 디렉토리 구조 + 3-Part 템플릿을 권고로 도입**한다. 강제 0. 사용자 프로젝트가 substrate 갖춘 경우만 작동.

### 권고 구조

```
{project}/
├── docs/
│   ├── decisions/          # ADR (기존 §7)
│   ├── plans/              # 진행 계획 (기존 §7)
│   ├── archive/            # 졸업 (기존 §7)
│   ├── specs/              # ★ 신규 권고
│   │   ├── _index.md       # spec 카탈로그 (50줄 이내)
│   │   ├── {spec-id}.md    # 한 spec 단위 = 한 파일
│   │   └── archive/        # deprecated specs
│   └── *.md                # 가이드·리서치 (기존 §7)
```

### Spec 파일 템플릿 (CSI Three-Part 차용)

```markdown
---
id: SPEC-{YYYYMMDD}-{slug}
status: draft | shared | published | archived
modal: must | should | may          # 전체 spec의 강제력 tier
supersedes: SPEC-...                # 선행 spec (있으면)
superseded-by: SPEC-...             # 대체 spec (deprecated 시)
---

# {Spec Title}

## Part 1 — General (intent)
- **What**: 달성 상태 (외부 관찰 가능 동작)
- **Why**: 이 spec이 존재하는 이유
- **Scope**: 적용 범위 / 비적용 범위
- **References**: 관련 ADR·외부 표준 링크

## Part 2 — Behavior (contract)
- 각 조항 앞에 modal 명시 (MUST/SHOULD/MAY)
- 각 조항 자기 한정 (interop 또는 harm-prevention 외엔 method 강요 금지)
- Acceptance criteria (검증 가능 형태)

## Part 3 — Verification
- 어떻게 spec 충족 확인하나
- Test/check 위치 (코드 path or 외부 도구)
- 알려진 implementation 2개 이상이면 명시 (RFC 2026 정신)

## Rejected alternatives
- 무엇을 고려했고 왜 거절했나 (Brooks ledger of refusal)

## Amendment log
- 본문 직접 수정 안 함. 변경은 후속 spec으로 supersede
```

### 강제력 명시 — 권고만, 강제 0

본 ADR은 **권고**다. 강제 메커니즘은 의도적으로 도입하지 않는다:
- sonmat이 작업 시작 시 `docs/specs/` 존재 여부 자동 확인 안 함
- spec 부재가 작업 차단 사유 아님
- spec과 코드 충돌 자동 감지 안 함 (T2-B 영역, 별도 ADR)

**유일한 sonmat 측 작용**: `discipline/hints.md` v0.12.0 추가된 Spec authoring 6 항목이 worker에 inject되어, **spec을 작성·갱신하는 task**일 때 형식·modal·closure·RFI 의례를 적용.

→ 사용자가 `docs/specs/` 디렉토리를 만들고 사용 시작하면 sonmat이 정합 의례로 보조. 만들지 않으면 sonmat 동작 0 변화. **opt-in 모델**.

### 권고 진입 trigger

sonmat이 `docs/specs/` 디렉토리 존재 감지 시 (작업 중 우연히 path 만나면):
- **silent**: 자동 alert 안 함. 분량·품질 평가 안 함
- **사용자 명시 요청 시**: spec 검토·갱신·신규 작성 의례 적용

### `MEMORY.md` / `_index.md` 분리

- `memory/MEMORY.md` (sonmat 글로벌) — 메모리 인덱스, 변경 없음
- `docs/specs/_index.md` (사용자 프로젝트) — spec 카탈로그. 50줄 이내 (ADR `memory-token-budgets` 정합 — `MEMORY.md` 200줄 ceiling 참조 모델)

### substrate 없음 인정 의례

본 ADR은 다음을 명시 인정:
- 사용자 프로젝트가 1인 프로젝트면 spec 의례 ROI 낮음 — 권고 적용 강제 안 함
- 팀 프로젝트라도 인센티브·문화 substrate 없으면 cargo-cult 위험
- IPD 같은 risk pool 없는 한 spec 의례는 부분 효과만 — Phase 3 A4·A5 결과의 정직한 인정

이 인정이 본 ADR의 "권고만, 강제 0" 원칙 근거.

## Consequences

### 긍정적

- **Q2 부분 답**: spec 문서 구조 + 템플릿 권고 도입 → 사용자가 원할 때 통합 정의문서로 유도 가능
- **CSI/ISO 19650 외부 정합**: Three-Part Format · lifecycle status · supersession metadata 직접 차용. 학술·산업 권위 확보
- **opt-in 보존**: 강제 0이라 작동 중 sonmat 호환성 깨지지 않음. 사용자 substrate 있는 프로젝트만 효과
- **v0.12.0 hints.md와 정합**: 새 6 spec authoring hints가 사용자 spec 작성 시 자연스럽게 작동
- **closure ceremony 명문화**: deprecated spec 처리 의례 (`status: archived` + supersession metadata)가 zombie 차단

### 부정적·리스크

- **권고만이라 적용률 낮을 가능성**: 강제 메커니즘 없으면 사용자가 만들지 않을 가능성 높음. ROI 낮음
- **substrate 가정 명시 부담**: "1인 프로젝트엔 ROI 낮음" 등 자기 한정이 사용자에게 어떻게 전달될지 미정
- **Spec 분량 ceiling 미정**: `docs/specs/{spec-id}.md` 한 파일 분량 제한 본 ADR엔 없음. T2-B 시점에 결정
- **다른 도메인 (frontend/backend 통합) 매핑 부재**: 본 ADR은 일반 spec 형식 권고만. 프론트/백 통합 정의 같은 도메인 특화 매핑은 별도

### 트레이드오프 검증 시점

- 첫 사용자 프로젝트가 `docs/specs/` 도입 시 — 템플릿이 실제 작동하는지
- 1년 후 권고 적용률 측정 — 강제 없는 권고의 실효성
- T2-B (spec 자동 참조) 진입 시점에 본 ADR substrate 인정이 baseline 측정 입력으로 작용하는지

## 참조

- `2026-04-25-l2-cognitive-architecture-positioning.md` — 본 ADR의 상위 (L2 본체 정식화)
- `2026-04-26-memory-token-budgets.md` — `_index.md` 50줄 ceiling 모델
- `2026-04-26-skill-md-template.md` — Inputs/Process/Outputs 템플릿 자매 (skill용 vs spec용)
- `~/.claude/CLAUDE.md` §7 — 프로젝트 docs 구조 (decisions/plans/archive 기존 + specs/ 신규)
- `docs/research/architecture-methodology-and-spec-discipline.md` — A3 CSI/BIM + A5 practitioner gap, 본 ADR의 연구 근거
- `discipline/hints.md` v0.12.0 Spec authoring 6 항목 — 본 ADR 도입 시 worker에 inject되는 의례
- 후속: `2026-04-26-spec-auto-reference.md` (T2-B), `2026-04-26-spec-evolution-loop.md` (T2-C)
