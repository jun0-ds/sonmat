# sonmat v0.11 → v0.13 — 스펙을 어떻게 다룰 것인가

> 2026-04-26. v0.11.0 / v0.12.0 / v0.13.0 릴리스 노트이자, 그 이틀이 도달한 결론.

요약부터: sonmat에 **스펙을 1급 시민으로 다루는 의례**가 박혔다. v0.11.0은 사고 측면 — 암묵 가정(Conceptzia)을 표면화하고, 매뉴얼 밖 행위(spec-gap)를 즉시 기록하고, 자기 격언까지 의심하라는 규칙. v0.12.0은 작성 측면 — 스펙 조항마다 강제력(MUST/SHOULD/MAY)을 명시하고, 거절된 대안을 같이 적고, 폐기 시 sunset 의례를 거치라는 hint 6개. v0.13.0은 통합 측면 — 사용자 프로젝트에 `docs/specs/` 구조를 권고하는 template, scribe가 spec-gap 발생 시 후속 spec을 자동 제안하는 ritual, worker가 published spec을 읽고 alert하는 Stage 1 awareness.

여기까지 이틀. 이 글은 그 발걸음과, 그 안에서 두 번 멈췄던 자리.

---

## 왜 스펙이었나

이번 사이클은 한 질문에서 시작했다.

> "스펙은 자동적으로 실행이 되는가? 단순 투두리스트가 아니고 수정이 가능한 개발정의문서에 가까운 형태로 sonmat이 유도하고 있는가?"

답은 두 번 다 NO였다.

Claude Code 내장 todo는 한 세션에서 잘 작동하지만 휘발성이고, 우선순위·의존·개정 history가 없다. 사용자 프로젝트의 진짜 spec — 도메인 모델, API contract, 화면 책임, 통합 흐름 — 을 sonmat이 권위로 인식해 자동 추적·검증·alert하는 메커니즘은 0이었다. v0.10.1까지의 sonmat은 "사고 discipline + 가드 + 기록"이지 spec discipline은 아니었다.

이 빈 공간을 메우는 작업이 v0.11~v0.13.

---

## v0.11.0 — 사고 측면: 암묵 가정·spec-gap·자기 격언

`discipline/core.md`에 세 줄을 박았다.

**Before Acting #4 — Surface unstated assumptions (Conceptzia audit)**: 행동 전 "이 프로젝트에서 spec처럼 작동하는데 적혀있지 않은 것이 무엇인가" 묻기. *Conceptzia*는 1973년 Yom Kippur 전쟁 직전 이스라엘 정보부가 운용하던 가정 — "이집트는 공군 장거리 타격력 확보 전엔 공격 안 한다" — 인데, 어디에도 normative spec으로 박혀있지 않았으면서 모든 정보 평가의 필터로 작동했다. Bar-Joseph (*The Watchman Fell Asleep*, 2005)이 추적한 그 실패는 sonmat의 모든 worker에게 그대로 적용된다. spec에 적혀있지 않은 가정이 spec처럼 작동하면, 그 가정이 틀릴 때 검증할 채널이 없다.

**After Acting #4 — Spec-gap AAR**: 행동이 spec/discipline 밖이었으면 즉시 scribe Novel Trap의 새 flavor `spec_gap`으로 dispatch. 이건 1940년 5월 Eben-Emael 요새 점령에서 가져왔다. Feldwebel Helmut Wenzel이 책에 없던 세 가지 결정으로 작전을 살린 후, *Gefechtsbericht* (전투 보고)가 *Merkblatt 151/4 Der Fallschirmjäger*의 다음 판본으로 역류했다. 임기응변이 doctrine 갱신으로 흘러가는 그 짧은 고리. **검증 실패가 아니라 "spec이 못 잡은 케이스"** 도 메모리 입력이라는 것 — Novel Trap에 dual flavor (`verification_failure` + `spec_gap`)를 추가한 이유.

**Learn it — 자기 격언 비판**: 같은 항체가 어떤 맥락에서 두 번 실패하면, 항체 자체를 의심하라. 이건 RFC 9413 (2023, "Maintaining Robust Protocols")이 Postel의 robustness principle을 20년 deployment 후 normative하게 비판한 사건. 창시 격언도 정상적 수정 대상이다. sonmat 자체가 자기 규칙을 의심할 수 없으면 그 자체로 스펙 부패의 표준 패턴.

devil skill에도 손을 댔다. §2.5에 **project-relevance gate** — Stakes / Amendment cost / Next-action delta 세 질문으로 "이 반박이 지금 프로젝트에 본질적으로 중요한가" 필터. 아니면 `off-project`로 정직히 종료. 반박을 위한 반박이 가장 비싼 false work라는 인식.

scribe Bridge Note에 4 원리 — status-form / Traps mandatory / hypothesis 표시 / brevity. Toby Codex의 4계층 handoff 글에서 가져왔는데, 거기 나온 7섹션 강제는 받지 않았다. *A3 한 장 제약* 정신: 못 맞추는 건 본질이 아니다.

여기까지 v0.11.0. 사고 layer 강화.

---

## v0.12.0 — 작성 측면: 6개의 spec authoring hint

이때 한 번 멈췄다. 준선생이 물었다.

> "이번에 새로 업데이트 한 부분 개발 도메인에서 스펙 생성 및 관리도 포함이에요?"

정직한 답은 NO였다. v0.11.0은 사고 일반에 작동하지 spec 작성·관리에 직접 inject되는 건 아니었다. *모든 도메인이 받는다*는 의미에서 스펙 도메인도 자동 수혜이긴 했지만, "스펙 작성 자체의 도메인 특화 의례"는 빠져 있었다.

그래서 Phase 3로 넘어갔다. 건축은 IT의 origin이다 — Christopher Alexander의 *Pattern Language*가 GoF Design Patterns로 직접 차용된 것처럼. 그러나 건축 spec 방법론은 5세기 + 더 깊이 검증된 인프라가 있다. 5개 agent를 병렬로 띄워 1차/권위 자료 인용 기반으로 조사했다:

- 고대-중세 (Vitruvius / Yingzao Fashi 8-grade modular system / 중세 cathedral lodge tracing floor)
- 르네상스-모더니즘 (Alberti *lineamenta* vs *materia* / Palladio printed plates / Beaux-Arts esquisse / Bauhaus Vorkurs / Le Corbusier Five Points / CIAM Athens Charter / Pruitt-Igoe 실패)
- BIM·CSI MasterFormat (50 Divisions, Three-Part Format, IFC entity hierarchy, ISO 19650 LOIN, COBie handover)
- Lean Construction·IPD (Last Planner System 5 conversation, PPC, Pull Planning, IPD risk pool, Big Room, Target Value Design, Set-Based Design)
- 실무자 괴리 의례 (RFI, Submittal, Change Order, Punch list, As-built, Hidden Conditions, Constructability Review, Constructive Change Doctrine)

이 5개 case + cross-cutting 8 패턴에서 6 hint가 도출됐다. `discipline/hints.md` Dev 도메인에 신설한 "Spec authoring" sub-section:

1. **Modal calibration** — 각 조항 MUST/SHOULD/MAY 명시 + RFC 2119 §6 자기 한정 ("interop 또는 harm-prevention 외엔 method 강요 금지"). 모더니즘이 발견한 것: 어휘에 강제력 계층이 없으면 spec이 작동 안 한다.
2. **Intent vs mechanism** — Auftragstaktik의 *Was/Warum* (무엇을/왜) 만 명령서에 담고 *Wie* (어떻게)는 현장 재량. 포팅·재구현 시 알고리즘 재현이 아니라 contract 재현.
3. **Record rejected alternatives** — Brooks의 "ledger of refusal", Talmud의 *eilu v'eilu* (소수 의견 보존). 미래 재구현이 같은 실패 branch를 다시 발견하지 않게.
4. **Closure ceremony on retirement** — PEP 404 모델 ("Python 2.8 will never exist"). sunset date 명시 안 하면 좀비가 자원을 영원히 흡수한다.
5. **Amend via successor, not in-place edit** — RFC `Updates:` / `Obsoletes:` chain. 본문 수정은 결정 history를 파괴한다.
6. **Spec ambiguity → numbered question** — AIA G716 RFI 모델. 추측으로 진행하지 말고 번호 붙여 사용자에게 물어라. *Fishing RFI* 자기검열까지 — 답을 알면서 paper trail 만들려고 묻는 건 거절.

여기서 두 번째로 멈췄다. devil로 한 번 더 정제했다.

CCT 적용해보면 모든 제안의 load-bearing 가정은 "건축의 dialogue infrastructure가 software에 transferable"이었다. counter-fit이 강하다 — 건축 ritual이 작동하는 이유가 도메인 고유 인센티브(물리적 비가역성, 50-100년 lifecycle, 강한 규제, 큰 자본 노출)에 종속됐을 가능성. 그게 sw에 결여되면 ritual import는 substrate 없는 cargo-cult가 된다 (Asiana 214 패턴).

그래서:
- v0.12.0 hints 6개는 진행하되 "사용자 본인 의지 substrate 위에서 작동" 표시
- 원래 core.md에 박을 뻔한 dialogue ritual은 hints.md로 이동 (RFI는 사용자-AI 상호작용 의례, core 부적합)
- Tier 2 (자동 참조, evolution loop)는 ADR로 분리, substrate baseline 측정 단계 추가

이게 devil project-relevance gate가 작동한 첫 케이스. "정말로 이 변경이 다음 행동을 바꾸나"가 핵심 질문이었다.

---

## v0.13.0 — 통합 측면: template + scribe amendment + Stage 1 awareness

여기까지 ADR 17건이 쌓였다. 사용자 한 마디:

> "작성 및 구현 진입까지 이어서 하죠"

v0.13.0이 그 진입.

**`templates/spec-template.md`** — CSI Three-Part Format을 그대로 빌렸다. Part 1 General (intent — what / why / scope / out-of-scope / stakeholders), Part 2 Behavior (각 조항 modal + acceptance criteria + known implementations), Part 3 Verification (test location / manual check / 알려진 failure modes). + Rejected alternatives, Amendment log, Closure ceremony 블록. frontmatter에 id / status / modal default / supersedes / superseded-by / references.

**`templates/spec-index-template.md`** — `docs/specs/_index.md` scaffold. ≤ 50 lines (sonmat token-budget convention). sonmat opt-in flag 두 개 — `spec_awareness` (Stage 1) / `spec_verification` (Stage 2).

**scribe SKILL.md 확장** — Novel Trap Recording §5 신설. 세 조건 (project가 `docs/specs/` 가짐 + `_index.md`에 `sonmat.spec_awareness: enabled` + 식별 가능한 기존 spec 매핑) 만족 시, scribe가 후속 spec을 자동 제안한다:

```
💡 Spec gap detected: {pattern}
   Maps to: {existing spec id or section}
   Catch-signal: {what spec clause would have caught this}

   Propose amendment via successor spec? [Yes / No log only / Edit first]
```

`Yes`면 후속 spec 파일 생성, 원본 spec frontmatter에 `superseded-by` 메타 추가. **closure ceremony 자동 트리거** — full supersession 시 sunset date + fork-prevention 강제. **LEARN journal entry 무조건** — Yes/No/Edit 모두 retrospective 자료.

LPS 5 conversation의 should/can/will/did/**learn** 마지막 단계가 sonmat에 박힌 자리.

**hints.md Spec consumption sub-section** — Stage 1 active 사용자 한정 5 의례:
- 자동 read `_index.md` (작업 시작 시, 본문 아니고 index만 — RinDig "agent reads down and stops" 정합)
- inline reference (silent assumption 금지, 사용자에게 어느 spec 적용되는지 명시)
- alerts only, blocking 안 함 (Stage 2 권한)
- draft 비구속 (status: shared / published 만 권위)
- 본문 검증 (index는 hypothesis, 인용 전 본문 read)

Stage 0 default는 v0.12.0 동작 그대로. opt-in 안 하면 sonmat은 사용자 프로젝트 spec에 손대지 않는다.

마지막에 Stage 2 ADR 3건 — substrate baseline 측정 의례 (수동 self-report 첫 채택, hook 자동 측정은 6개월 보류), witness 확장 (published spec contract ↔ artifact 비교, isolation 4 원칙으로 보호), guard 확장 (contract violation BLOCK candidate, mechanism mismatch ALERT only, 비가역 capability + spec 충돌은 무조건 BLOCK).

Stage 2는 사용자가 baseline 통과 후 명시 opt-in 한 경우만. **sonmat이 강제 안 한다, 사용자 의지가 substrate**.

---

## 두 번의 멈춤이 만든 것

이번 사이클이 통째로 "ritual을 import해도 환경이 다르면 cargo-cult"라는 인식 하나에 묶여 있다.

첫 번째 멈춤(v0.11→v0.12 사이의 "스펙 생성·관리 포함됐나" 질문)은 *적용 범위* 자기 점검이었다. 건축 인프라는 풍부하지만 sw에 직접 옮길 때 어떤 부분만 옮길 것인가. 답: hints 6개 + 사용자 의지 substrate 의존.

두 번째 멈춤(v0.12→v0.13 사이의 devil 정제)은 *반박을 위한 반박* 자기 점검이었다. 건축이 5세기간 발달시켰다고 sw에 5세기치 ritual을 import하면 안 된다. PPC sw 등가 metric은 velocity로 이미 시도·실패한 길. 그래서 v0.13.0에 PPC는 빠졌다 — AAR 흐름만 우선, 측정은 6개월 운용 후.

devil이 설계 진행 자체를 정직하게 줄인 사건. 이 작동은 v0.11.0 §2.5 project-relevance gate가 자기 자신에 적용된 결과이기도 하다. 자기를 자기 도구로 점검하는 ritual.

---

## 한계 — 정직한 부분

- **Stage 1 active 사용자 0**. v0.13.0 시점 첫 사용자(나 자신)가 도입을 안 했다. template, ritual, hints가 작동하는지는 파일럿 후에야 안다.
- **substrate baseline 임계값 임의**. Modal 명시율 50% / acceptance criteria 60% / inline reference 정확도 70% — 첫 추정이고 실 데이터로 보정해야 한다.
- **건축 ritual의 인센티브 substrate가 sw에 없다**. IPD risk pool, 법적 책임, 비가역성, 자본 노출 임계 — sonmat 1인 사용 맥락엔 사용자 의지 substrate만 있다. 이게 충분한지는 아직 모른다.
- **자기 격언 비판이 자기 적용 어렵다**. v0.11.0이 자기 항체를 의심하라고 하지만, sonmat 자체가 같은 의심을 받는지는 외부 평가 필요.
- **PPC 등가 metric 부재**. 의도적으로 보류했으나 6개월 후 retrospective에서 정량 도구 필요 surface 시 다시 결정. 그 시점에 또 한 번 멈춰야 한다.

---

## 다음

T2 ADR 3건 + Stage 2 ADR 3건 작성 완료. 구현 진입은 사용자 첫 파일럿 결과 본 뒤. CLAUDE.md §7 글로벌 업데이트 (`docs/specs/` 권고 추가)는 별도 검토.

> **2026-04-27 update**: §7 글로벌 업데이트 적용 완료. `~/.claude/CLAUDE.md` §7 트리에 `docs/specs/` 줄 추가(decisions/ 다음), 리스트에 opt-in 권고·CSI Three-Part·강제 0·템플릿 경로 명시, `*.md` 줄에서 "스펙" 제거, 검토 순서 4번에 `_index.md`의 `sonmat.spec_awareness` 플래그 확인 추가. claude-config commit `1f21b9e`. 첫 사용자 프로젝트 파일럿(Stage 1 활성화)은 각 프로젝트 진입 시점에 검증으로 결정.

진짜 검증은 첫 사용자 프로젝트가 `docs/specs/_index.md`에 `sonmat.spec_awareness: enabled`를 박을 때 시작된다. 그때 Stage 1이 어떻게 작동하는지가 이 모든 결정의 진짜 데이터.

---

## 참고 — 사용한 것들

- ADR 시리즈 (`docs/decisions/`): L2 cognitive architecture positioning, ICM memory mapping, 훈수꾼 positioning, ICM 흡수 4건, governance 3건, D5 seam 4건, Tier 2 spec 3건, Stage 2 ADR 3건
- 연구 문서 (`docs/research/`): spec-induction-and-sisyphus-review (Phase 1+2, 24 case + 16 cross-cutting pattern), architecture-methodology-and-spec-discipline (Phase 3, 5 case + 8 pattern)
- 외부 정합: Vitruvius *De Arch.*, Christopher Alexander *Pattern Language* + *Nature of Order*, ICM (Van Clief & McDermott, arXiv 2603.16021), CSI MasterFormat 2020, ISO 19650, AIA Contract Documents (A201, G701, G704, G712, G714, G716), Lean Construction Institute (Ballard 2000 PhD), AIA IPD Guide 2007, RFC 2119 / 8174 / 9413, PEP 404, Yom Kippur Agranat Commission, Eben-Emael (Mrazek 1970)

용어 풀이는 `docs/research/glossary.md`에.
