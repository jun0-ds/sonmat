---
id: SPEC-{YYYYMMDD}-{slug}
status: draft        # draft | shared | published | archived
modal: should        # must | should | may  (요구 수준을 따로 적지 않은 조항에 쓰는 기본값)
created: {YYYY-MM-DD}
last-updated: {YYYY-MM-DD}
supersedes:          # SPEC-... (선택. 이 명세가 앞 명세를 대신할 때)
superseded-by:       # SPEC-... (이 명세가 다른 명세로 대체될 때 채운다. 이 자리에서 직접 고치지 않고, 후속 명세가 이 역참조를 더한다)
references:
  # - {ADR id}
  # - {external standard}
---

# {명세 제목}

> 자리표시자를 채운다. 해당하지 않는 절은 지워도 되지만 옮기지는 않는다. 절의 순서도 계약의 일부다.

## 1부 — 개요: 의도 (Part 1 — General (intent))

- **무엇(What)**: {달성할 상태와 외부에서 확인할 수 있는 동작. 한 줄로.}
- **왜(Why)**: {이 명세가 있는 이유. 이 명세가 사라지면 무엇이 무너지는가.}
- **범위(Scope)**: {적용 범위 — 어떤 코드/모듈/도메인에 적용되는가}
- **범위 밖(Out of scope)**: {적용하지 않을 것을 명시. "이건 다른 명세가 다룬다" 또는 "의도적으로 비워 둔 곳"}
- **이해관계자(Stakeholders)**: {이 명세에 기대는 사람·시스템}

## 2부 — 동작: 계약 (Part 2 — Behavior (contract))

> 조항마다 요구 수준(MUST / SHOULD / MAY)을 명시하는 것이 좋다(SHOULD).
> MUST는 상호운용이나 피해 예방에 꼭 필요한 요구에만 쓴다(RFC 2119 §6의 자기 제한). 상호운용에 필요하지 않은 곳에서 방법을 강제하지 않는다.

- {조항 1 — MUST | SHOULD | MAY}
- {조항 2 — MUST | SHOULD | MAY}
- ...

### 수용 기준 (Acceptance criteria)

> 참·거짓을 가릴 수 있는 조건으로 쓴다. 기준마다 코드, 테스트, 관찰 가운데 하나로 확인할 수 있어야 한다.

- [ ] {기준 1 — 확인 방법}
- [ ] {기준 2 — 확인 방법}

### 알려진 구현 (Known implementations)

> RFC 2026의 정신을 따라, 서로 독립적이면서 함께 동작하는 구현이 둘 이상 있으면 성숙했다는 신호로 본다. 하나뿐이어도 적는다.

- {구현 1 — 코드 경로나 외부 시스템}
- {구현 2 — 있으면}

## 3부 — 검증 (Part 3 — Verification)

- **테스트 위치**: {경로나 외부 테스트 묶음}
- **손으로 하는 확인 (있으면)**: {검토자가 따라 할 단계}
- **이미 관찰한 실패 양상**: {알려진 함정. journal이나 함정 메모리가 있으면 링크한다.}

## 기각한 대안 (Rejected alternatives)

> Brooks가 말한 거절의 장부, 탈무드가 소수 의견을 남겨 두는 방식이다. 이 절이 없으면 나중에 다시 구현하는 사람이 이미 실패한 갈래를 또 찾아내게 된다.

- **{대안 1}** — 검토했다. {이유} 때문에 기각했다.
- **{대안 2}** — 검토했다. {이유} 때문에 기각했다.

## 개정 기록 (Amendment log)

> `status: published`가 된 뒤의 변경은 이 명세의 본문을 고쳐서 반영하지 **않는다**.
> 개정은 이 명세를 `supersedes:`로 가리키는 후속 명세로 낸다(RFC의 `Updates:` / `Obsoletes:` 방식).
> 이 기록에는 누가 언제 왜 개정을 제안했는지만 남기고, 개정 내용 자체는 남기지 않는다.

| Date | Proposer | Type | Outcome |
|------|----------|------|---------|
| {YYYY-MM-DD} | {누가} | propose successor / clarify only / withdraw | {SPEC-... | n/a} |

## 종료 (Closure, status: archived일 때만)

> 이 명세를 은퇴시킬 때 채운다. `status: archived`이면 반드시 채운다.

- **종료일**: {YYYY-MM-DD}
- **후속 명세**: {SPEC-... 또는 "후속 없음 — 기능 제거"}
- **갈래 방지**: {갈라져 나와 아직 살아 있는 판이 없다는 명시적 선언. PEP 404 방식.}
- **종료 이유**: {한 문단}
