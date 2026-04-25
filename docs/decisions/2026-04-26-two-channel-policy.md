# 2026-04-26 — Two-channel policy: sonmat open-source ↔ OpenRabbit commercial

## Context

ADR `2026-04-25-l2-cognitive-architecture-positioning.md` 와 OpenRabbit 인계문(`~/.claude/memory/domain/openrabbit.md`)에서 sonmat과 OpenRabbit 사내 IP가 **같은 L2 인지 아키텍처 IP를 공유, 채널만 다름**으로 정식화. ADR `2026-04-25-hunsugun-positioning.md` D6에서 brand·라이선스 분리 명시했으나 정책은 미정.

두 채널:
- **sonmat 채널** (오픈소스): MIT(현 BSD-3) 라이선스, GitHub jun0-ds/sonmat marketplace, 개인 → 범용 → 오픈
- **OpenRabbit 채널** (상용): 폐쇄 / 고객별 라이선스, 사내 deploy, 도메인 특화

질문: 두 채널의 IP·brand·feature·기여 흐름을 어떻게 분리·공유하는가. 충돌 방지 정책.

## Decision

**L2 contract는 공유, L3·운영 노하우는 채널별 분기**. 다음 5 원칙을 박는다.

### P1. L2 본체는 sonmat 오픈소스에 우선 박힘

L2 인지 아키텍처(생각/행동/기억 세 축)의 contract·규약은 **sonmat 리포에 ADR로 박는 것이 정본**. OpenRabbit이 같은 L2를 사용하더라도 **사내 fork 안 함** — sonmat의 L2 ADR을 권위 자료로 참조.

### P2. L3 어댑터는 채널별 분기 가능

L3(SKILL.md 포맷 적용, 어댑터 변형 등)은 채널별로 다르게 표현 가능. 단:
- sonmat 채널 = 공개 표준 어댑터 (Anthropic Skills, ICM 등 외부 정합 가능한 것)
- OpenRabbit 채널 = 고객사 도메인 특화 어댑터 (폐쇄 가능)

L3 어댑터 변경이 L2 contract 변경 압력을 만들 시, **L2는 sonmat 채널에 먼저 박은 후 OpenRabbit이 차용** (P1 정합)

### P3. Brand 분리 명시

- **sonmat / 훈수꾼** = 오픈소스 채널 brand. 한국어 가명 + 영문 가명(kibitzer)
- **OpenRabbit 측 상용명** = 별도 결정 (현재 미정). sonmat / 훈수꾼 단어 사용 금지
- 영업 자료에서 OpenRabbit이 sonmat·훈수꾼 단어 직접 사용 안 함. 단, **외부 학술 자료 인용처럼 "L2 인지 아키텍처는 sonmat 오픈소스 프로젝트(github.com/jun0-ds/sonmat)에서 검증된 패턴 차용"** 형식의 출처 표기는 권장 (권위 확보)

### P4. Feature 흐름 정책

**오픈소스 → 상용 (회수)**: sonmat에서 검증된 패턴이 OpenRabbit L2 자산으로 일반화. 이 흐름은 별도 ADR `recovery-pipeline` 에서 절차 명시.

**상용 → 오픈소스 (기여 환류)**: OpenRabbit 사내 발견이 sonmat에 환류 가능. 단:
- 고객사 IP·secrets·도메인 특화 정보는 **익명화·일반화 의무**
- 환류는 정상 sonmat contribution 절차 (PR / issue / discussion) 통과
- 환류 결정은 OpenRabbit 사내 거버넌스로 판단

**병렬 발견**: 같은 패턴이 두 채널에서 동시 발견되면 **sonmat 우선 박음** (P1 정합). 이후 OpenRabbit이 차용.

### P5. 라이선스 분리 + 기여자 권리

- sonmat 채널 = BSD-3-Clause (현재). 기여자는 본인 contribution을 BSD-3로 라이선스
- OpenRabbit 채널 = 폐쇄 / 고객별. 기여자(사내 직원·계약자)는 OpenRabbit 측 IP 양도 또는 라이선스 계약
- **개인 기여자(준선생)가 양 채널 contributor**인 경우, contribution 시점에 어느 채널로 가는지 명시 (가장 흔한 케이스 — 본 ADR 작성 시점)

### 사용자 (준선생) 본인 contributor 정책 (잠정)

준선생 본인이 양 채널 모두에 기여하는 핵심 contributor. 충돌 방지:
- L2 contract → sonmat 우선
- 도메인 특화 발견 (의료 / 금융) → OpenRabbit 우선
- 모호 영역 → contribution 시 명시 결정. 결정 누락 시 sonmat 우선 (P1 default)

## Consequences

### 긍정적

- **L2 IP fork 차단**: P1로 OpenRabbit이 sonmat L2 fork하지 않음 → 두 채널이 같은 IP 공유 유지
- **Brand 분리로 시장 충돌 차단**: P3로 OpenRabbit 영업 시 sonmat 단어 충돌 없음
- **회수·환류 흐름 명시**: P4로 양방향 흐름 절차 명확 (단 회수 절차는 별도 ADR)
- **Brooks "ledger of refusal" 정신**: 어떤 contribution이 어느 채널로 가는지 명시 의례가 분기 결정 추적 가능

### 부정적·리스크

- **이중 contribution 부담**: 개인(준선생)이 양 채널 contributor면 매 contribution 시 채널 결정 부담
- **L3 어댑터 분기 정합 깨질 위험**: P2의 채널별 L3 분기가 L2 contract 변경 압력 만들면 P1 (sonmat 우선) 위반 위험. 의례적 검토 필요
- **법률 검토 미실행**: P5 라이선스 분리는 변호사 검토 안 함. 첫 OpenRabbit 고객사 계약 전에 법률 검토 필수
- **익명화 부담**: P4 상용 → 오픈소스 환류 시 익명화 작업 부담. 환류 비율 ↓ 가능
- **Brand 영문명 단일화 검토 필요**: "sonmat" / "훈수꾼" / "kibitzer" 셋이 OpenRabbit 영업 시 혼란 가능. 본 ADR은 이름 결정 보류 — 별도 brand ADR 후속 가치

### 트레이드오프 검증 시점

- 첫 OpenRabbit 고객사 계약 전 — P5 라이선스 분리 법률 검토
- 첫 sonmat → OpenRabbit 회수 시도 시 (ADR `recovery-pipeline` 작성 후) — P4 회수 절차 작동성
- 첫 OpenRabbit → sonmat 환류 시도 시 — P4 환류 절차 + 익명화 부담 측정
- 1년 후 두 채널 brand 인지도 측정 — P3 분리가 시장에서 유지되는지

## 참조

- `2026-04-25-l2-cognitive-architecture-positioning.md` — 본 ADR의 상위 (L2 IP 공유 원칙)
- `2026-04-25-hunsugun-positioning.md` D6 — brand 분리 잠정 결정
- `~/.claude/memory/domain/openrabbit.md` — OpenRabbit 사내 IP 회수 관점
- `~/Documents/001_OpenRabbit/docs/decisions/2026-04-25-agent-shell-folder-core.md` — OpenRabbit 두 겹 포지션
- 후속: `2026-XX-XX-recovery-pipeline.md` — sonmat → OpenRabbit 회수 절차 (ADR 6)
