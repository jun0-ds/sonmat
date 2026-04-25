# 2026-04-26 — sonmat → OpenRabbit L2 asset recovery pipeline

## Context

ADR `2026-04-25-l2-cognitive-architecture-positioning.md` 운영 원칙 4 ("회수 파이프라인 가능 상태 유지") + ADR `2026-04-26-two-channel-policy.md` P4 (오픈소스 → 상용 회수 흐름)에서 sonmat에서 검증된 패턴을 OpenRabbit L2 자산으로 일반화하는 회수 흐름을 명시. 단 절차 미정.

OpenRabbit 인계문(`~/.claude/memory/domain/openrabbit.md`):
> "sonmat에서 검증된 패턴을 OpenRabbit 사내 IP로 일반화하는 **파이프라인이 자산화의 본질**"

질문: 회수 절차를 어떻게 박을 것인가. 무엇이 회수 단위, 어떤 trigger에 회수, 어떤 검증, 어떻게 사내 IP화.

## Decision

**5단계 회수 파이프라인** 도입.

### 5단계

#### S1. Detect (sonmat 측)

sonmat 운용 중 **반복 검증된 패턴** 식별. 검증 신호:
- ADR로 박힌 결정 (sonmat docs/decisions/)
- 2개 이상 도메인에서 작동 확인 (cross-domain 일반성)
- 6개월 이상 안정 사용
- scribe novel trap이 같은 영역에서 N회 dispatch (반복성 신호)

위 4 신호 중 2 이상 만족 시 **회수 후보로 등록**. 회수 후보 목록은 OpenRabbit 사내 backlog에 보관 (sonmat 리포 아님 — P3 brand 분리 정합).

#### S2. Abstract

회수 후보를 **sonmat 어휘에서 일반 L2 어휘로 추상화**:
- sonmat skill 이름 → OpenRabbit 사내 명명
- sonmat 디렉토리 구조 → OpenRabbit 빌드 표준
- 한국어 격식 → 영어 또는 다국어 (고객사 권장 언어)

추상화 결과는 **OpenRabbit `docs/decisions/`에 추상 ADR**로. 원 sonmat ADR을 출처 명시.

#### S3. Contextualize (도메인 적용)

추상 자산을 **첫 OpenRabbit 고객사 도메인** (의료/금융 등)에 적용. 고객사 특화 어댑터 작성. 이는 L3 어댑터 layer (P2 정합 — 채널별 L3 분기 가능).

#### S4. Validate

고객사 deploy 또는 사내 시뮬레이션으로 검증. 다음 측정:
- 추상 자산이 실제 작동하는가
- sonmat에서 작동했던 효과가 도메인 적용 후에도 유지되는가
- 추상화 과정에서 손실된 것이 무엇인가

검증 실패 시 S2 (추상화) 또는 S1 (검출) 단계 재고. 회수 거절 시 거절 ADR 명시 (P3 정합).

#### S5. Recover (정식 자산화)

검증 통과 시:
- OpenRabbit 사내 라이브러리에 정식 등록
- OpenRabbit ADR로 lifecycle 관리 (deprecation·갱신 책임 OpenRabbit 측)
- sonmat 측 ADR에 **회수 완료 표지** 추가 (links to OpenRabbit ADR — 단 OpenRabbit 사내 ADR 직접 링크 안 하고 "회수됨, 사내 자산화 완료" 정도만)

### Trigger 명시 (회수 시작 시점)

회수 파이프라인은 **OpenRabbit 측에서 시작**. sonmat은 detect만 하고 자동 진입 안 함:
- OpenRabbit이 새 고객사 받을 때 도메인에 맞는 L2 자산 후보 검토
- OpenRabbit 사내 quarterly review에서 회수 후보 목록 평가

sonmat 자체 운용에서는 회수 압력 없음 — sonmat은 오픈소스 prototype 정체성 유지 (ADR `l2-cognitive-architecture-positioning` 정합).

### 회수 단위

- **L2 contract 단위** — discipline 룰, 매 단위 의례 등. ADR로 박힐 수 있는 것
- **L3 어댑터 단위 회수 안 함** — L3는 채널별 분기 가능 (P2). OpenRabbit이 L3는 자체 작성

### 회수 거절 사유

다음은 회수 안 함:
- sonmat 개인 사용자 특화 패턴 (예: 한국어 modal 비대칭은 도메인 일반화 가치 ↑이지만, "준선생 hostname 기기별 동기화 패턴"은 회수 부적합)
- sonmat 정체성에 묶인 패턴 (skill 명 자체, brand 어휘)
- 보안·privacy 민감 패턴 (P5 라이선스 정합)

## Consequences

### 긍정적

- **자산화 절차 명시**: "L2 IP 공유"가 추상 원칙에 머물지 않고 5단계 절차로 환원 → 실행 가능
- **sonmat 정체성 보호**: sonmat은 detect만, 회수 시작은 OpenRabbit 측. sonmat이 상용 압력에 끌려가지 않음
- **거절 ADR 의례**: Brooks "ledger of refusal" 정신 — 회수되지 않은 것의 사유도 자료
- **L3 분기 보존**: 회수 단위가 L2 contract만으로 제한 → L3 채널 분기 (P2) 정합

### 부정적·리스크

- **OpenRabbit 측 quarterly review 부담**: 사내 거버넌스 의례 도입. 1인 OpenRabbit 운영자(준선생)에게 무거움
- **추상화 손실 위험**: S2에서 sonmat의 도메인 특수성이 추상화로 깎임 → 추상 자산이 일반화돼도 sonmat 원본만큼 작동 안 할 수 있음
- **회수 ADR 양 채널 동기화 부담**: sonmat ADR과 OpenRabbit ADR이 같은 자산 다루면 동기화 의례 필요. 본 ADR이 명시 안 함 — 후속 결정 가치
- **검증 실패 시 fallback 부재**: S4 실패 시 어떻게 fallback? 본 ADR은 "S2 또는 S1 재고"로만 — 실제 fallback 절차 부재

### 트레이드오프 검증 시점

- 첫 회수 시도 시 (OpenRabbit 첫 고객사 deploy 단계) — 5단계 작동성
- 추상화 손실 측정 — sonmat 원본 vs 추상 자산 효과 비교
- 회수 비율 측정 — 6개월간 회수 후보 vs 실제 회수 건수

## 참조

- `2026-04-25-l2-cognitive-architecture-positioning.md` 운영 원칙 4 — 회수 파이프라인 가능 상태 유지
- `2026-04-26-two-channel-policy.md` P4 — 오픈소스 → 상용 회수 흐름 원칙
- `~/.claude/memory/domain/openrabbit.md` — 사내 IP 자산화 관점 + 사내 라이브러리 자산화 정책 (제품개발 §3)
- `~/Documents/001_OpenRabbit/docs/decisions/2026-04-25-agent-shell-folder-core.md` — OpenRabbit 두 겹 포지션
- 본 ADR이 명시한 회수 후보 backlog 위치 — OpenRabbit 사내 (별도 결정)
