# 2026-04-26 — L3 adapter swap policy

## Context

ADR `2026-04-25-l2-cognitive-architecture-positioning.md`에서 L3 포맷·런타임 어댑터(SKILL.md, ICM/MWP, subagent .md, custom GPT 등)는 **"갈아끼우는 어댑터로만 사용"**, 5년 후 다른 표준이 자리 잡으면 어댑터만 교체, L2 보존 원칙 박음. ADR `2026-04-25-hunsugun-positioning.md` D1에서도 동일 원칙 재확인.

그러나 **언제·어떻게 어댑터를 교체하는가** 의 절차는 미정. 결과:
- 새 어댑터(예: 미래 SKILL.md 후속 표준) 등장 시 채택 결정 임의적
- 기존 어댑터 deprecation 의례 부재
- L2 contract가 어댑터 변경을 견디는지 검증 절차 부재

질문: L3 어댑터 갈아끼움 정책을 명문화한다.

## Decision

**L3 어댑터 채택·deprecation 4단 의례**를 도입.

### 4단 의례

1. **Discovery** — 새 L3 후보 표준 등장 시 90일 관찰 기간. 채택 안 함, 단지 등장 사실 + 적용 사례 기록 (research note)
2. **Mapping** — 기존 L2 contract와 후보 표준 매핑 작성. ADR 형식. ICM 매핑 ADR(`2026-04-25-icm-memory-mapping.md`)이 모범 케이스
3. **Pilot** — 기존 어댑터와 병행하여 신규 어댑터로 1~2개 skill·feature 시범 적용. 기존 어댑터 deprecation 안 함
4. **Adoption or Reject** — Pilot 결과로 (a) 정식 채택 (b) 거절 (c) 보류. 정식 채택 시 deprecation timeline 별도 ADR

### 채택 trigger 조건 (외부 표준 채택 검토 시점)

- 후보 표준이 **3개 이상 독립 구현체**를 가짐 (RFC 2026 정신 — interoperability 증거)
- **2년 이상 활발 유지** (signal of stability)
- sonmat L2 contract 7할 이상 깨끗하게 매핑됨
- 외부 학술 또는 권위 기관 인용 가능 (ICM처럼 arXiv 등)

위 4 조건 중 3 이상 만족 시 Mapping ADR 작성 자격. 미만이면 Discovery 단계 유지.

### Deprecation 의례

기존 어댑터 deprecation 시:
- **2-release warning** (RFC 8174 / Python PEP 387 모델) — 두 번의 minor 릴리스에서 deprecation 경고
- **Closure ceremony** — PEP 404 모델. 명시적 sunset 일자 + fork 저지 선언
- **Migration ADR** — 어떤 contract가 어떻게 새 어댑터로 옮겨지는지 명시

### 거절 의례

후보가 채택 거절되면:
- **거절 사유 ADR 명시** — 왜 거절했는지 (Brooks "ledger of refusal" 정신)
- **재평가 trigger** — 어떤 변화가 생기면 재평가할 것인지 명시 (예: "구현체 5개 도달 시")

### L4 wrapper는 별도 — 채택 금지 절대 룰

L4 (LangGraph, AutoGen, OpenClaw 등 orchestration wrapper)는 본 ADR 적용 대상 아님. L4는 채택 금지 절대 룰 (`l2-cognitive-architecture-positioning` ADR D2). 어떤 trigger 만족해도 L4 채택 안 함. L4는 "런타임 후보로만" 본다.

## Consequences

### 긍정적

- **임의 채택 차단**: 4단 의례로 유행 따라 어댑터 채택하는 zero-base 위험 차단
- **5년 호환성 보장**: discovery 90일 + pilot 단계가 buffer 역할 — 단명 표준에 묶이지 않음
- **외부 정합 권위**: 채택 trigger 4조건이 "3 독립 구현체", "2년 유지" 등 검증 가능 기준 → 영업 자료에서 sonmat 채택 어댑터의 신뢰성 근거
- **Brooks ledger of refusal 정합**: 거절 ADR 명시 의례가 미래 재평가 자료
- **L4 절대 금지 재확인**: 본 ADR 자체가 L4 금지 원칙 재 강조

### 부정적·리스크

- **느린 채택**: 90일 discovery + pilot으로 신규 표준 채택까지 6개월 이상 소요. 빠른 시장 변화에서 sonmat이 뒤처질 위험
- **의례 부담**: ADR 4건 (mapping / pilot / adoption / migration) 작성 부담. 1인 개발 sonmat에서 무거움
- **Trigger 임의성**: "3 독립 구현체", "2년" 등 수치는 추정. 첫 적용 후 갱신 필요
- **Pilot 기간 어댑터 병행 비용**: 두 어댑터 동시 유지는 기술 부채

### 트레이드오프 검증 시점

- 첫 L3 어댑터 후보 (현재 ICM 외 다음 등장 시) 채택 여부 결정 시
- L4 wrapper 채택 압력 (LangChain·AutoGen 등이 사실상 표준 되는 경우) 발생 시 본 ADR의 L4 절대 금지 재확인
- 5년 후 SKILL.md 포맷이 다른 표준에 자리 내주는 시점에 본 ADR 의례가 실제 작동했는지 평가

## 참조

- `2026-04-25-l2-cognitive-architecture-positioning.md` — 본 ADR의 상위 (L2 stable, L3 갈아끼움 원칙)
- `2026-04-25-icm-memory-mapping.md` — Mapping 단계의 모범 케이스 (ICM 흡수)
- `2026-04-25-hunsugun-positioning.md` D1 — 훈수꾼도 동일 원칙 적용
- RFC 8174, RFC 2026, Python PEP 387, PEP 404 — Deprecation·closure 의례 모델
- 후속: `2026-XX-XX-two-channel-policy.md` — 두 채널 IP 정책 (ADR 5)
