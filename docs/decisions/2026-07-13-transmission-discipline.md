# 2026-07-13 — 전달 규율(transmission)을 discipline에 편입

## Context

류선생이 김이박의 한국어 산출물이 잘 안 읽힌다고 지적했다 (협업자료가 특히). 샘플로 per-project 메모리 문서 하나(`agentic_skills_matt_pocock_aihero.md`)를 골라 문장 단위로 검토하니, 실패가 두 종으로 갈렸다.

- **은유가 진술을 대체함**: `자세`(stance), `직교로 보면 얕음`(orthogonal), `~에 거주`(reside). 지우면 주장 자체가 사라진다 — 은유가 진술 *자리에* 서 있었다.
- **미결정 전가**: `흡수 결정 X`. 누가·무엇을·왜 아직 안 정했는지가 전부 증발하고, 독자가 결정을 재구성해야 행동할 수 있다.

반대로 **무죄**인 압축도 많았다. `문턱`·`sonmat`·`ADR-0001` 같은 공유 라벨은 수신자(류선생·미래의 나)가 앵커를 이미 쥐고 있어 투명하다. `sonmat = OS·런타임 / Matt = 도메인 라이브러리`처럼 **정확한 진술 위에 얹힌 유추**는 이해를 강화한다. 즉 판정은 어휘가 아니라 **수신자**가 가른다 — 같은 문장이 사석 메모에선 무죄, 인계 문서에선 유죄다.

두 개의 비대칭이 결정적이었다.

1. **discipline 문서 자체는 이 규율을 이미 잘 지킨다.** `core.md`는 전부 `**라벨**: 정의 + 구체 앵커`(Yom Kippur *Conceptzia*, RFC 9413) 형식이라 라벨만 던지는 게 구조적으로 막힌다. 은유(antibody, outrunning your headlights)도 전부 진술 위에 얹혀 있다. **고칠 게 없다.**
2. **그런데 같은 저자의 한국어 산출물은 실패한다.** 차이는 언어다. `stance`·`orthogonal`·`reside`는 영어에선 닳아서 죽은 은유라 독자가 곧장 주장에 도달하지만, 음차되면 한국어에선 *살아 있는 형상*으로 도착한다. 실패가 **수입(import) 특이적**이라, 영어로 쓴 절반에선 보이지 않는다.

그리고 이 규율은 새 원리가 아니다. `core.md`에 이미 씨앗이 있다 — *See as a stranger*("The maker is blind to what the reader trips on"), *Unwritten state is invisible*, *Surface unstated assumptions*. 전달 규율 = **See as a stranger를 언어와 문서에 적용한 특수 사례**.

## Decision

**한 곳에 몰아넣지 않고, 파일 계약에 따라 셋으로 나눠 심는다.**

1. **`discipline/core.md` → After Acting → *See as a stranger*** — 원리만 한 문장 벼린다: 이 규칙이 *쓰는 것*에도 걸린다는 것, 그리고 **수신자 상대성**(어떤 앵커를 그 독자가 쥐고 있냐가 판정을 가른다 → 문장을 판정하기 전에 수신자를 지명하라). 구체 검사는 hints로 포인터.
2. **`discipline/hints.md` → Document → `### Transmission`** — 검사 3종. ① 수신자 지명(판정의 전제) ② **지우기 테스트**(은유를 지웠을 때 주장이 남으면 무죄=설계된 유추, 무너지면 유죄=진술 대체) ③ **미결정 전가 금지**(누가·무엇을·왜 셋을 다 쓰거나, 아예 빼거나). hints.md의 선언된 계약이 "기본값으로 놓치는 non-obvious trap"이므로 검사류의 제집이다.
3. **`discipline/hints.md` → Korean 절 → `### Writing Korean output`** — 기전 2종. ① 음차된 죽은 은유의 부활 ② 전보체 한국어는 조사·서술어를 떨구며 *누가·무엇을·왜*까지 같이 떨군다(영어 약어체는 동사와 논항을 남기는 편). 절 제목도 `Korean ↔ English mixed prompts` → `Korean ↔ English (mixed prompts in, Korean prose out)`로 고치고 읽기/쓰기 두 방향으로 나눴다 — 기존 절은 **입력 읽기 쪽만** 덮고 산출 쪽엔 눈이 없었다.

## Alternatives considered

- **전부 core.md에.** 매 세션·매 워커에 걸려 가장 강하지만, core.md는 의도적으로 짧고(55줄) 원리만 담는다. 검사 3종은 trap 형태라 hints의 계약이다. core.md 비대는 progressive-disclosure 결정(2026-04-26)의 역행이라 기각.
- **hints.md에 최상위 `## Transmission` 도메인 신설.** 전달은 Dev·AI/ML과 나란한 *도메인*이 아니라 기존 규칙(See as a stranger)의 *적용*이다. 문서 산출이 곧 그 무대이므로 `## Document` 하위가 정확한 자리. 최상위로 올리면 원리와의 계보가 끊긴다.
- **discipline 무변경, sonmat-memory에 antibody로만 박제.** 메모리는 *사례*를 기록하고 discipline은 *규칙*을 세운다. 이건 일회성 트랩이 아니라 모든 산출 턴에 걸리는 상시 규칙이라, 메모리에만 두면 다음에 같은 실수를 하고 나서야 걸린다. 기각(단, 개별 실패 사례는 여전히 scribe 몫).

## Consequences

- 김이박의 한국어 어조 명령(글로벌 CLAUDE.md §0 + `voice.md`)이 이제 **스타일 선호가 아니라 규율에 근거**한다. voice.md는 어조(해요체)를, discipline은 전달(앵커·은유·미결정)을 맡는 분업.
- `hints.md`는 모든 워커에 주입된다 — Korean 하위절은 한국어로 쓰는 사용자에게만 값을 낸다. hints의 자기필터 계약("The worker applies what's relevant")에 기대는 비용. 영어 전용 fork에겐 죽은 무게 ~6줄.
- MINOR (0.15.0 → 0.16.0): 새 domain hints + core.md 규칙 벼림. breaking 아님.
- ⚠ **한계 — 규칙을 세웠지 습관을 고친 건 아니다.** 이 실패는 규칙이 없어서가 아니라 *한국어를 쓸 때 자기 문장을 안 봐서* 났다(영어 discipline은 같은 저자가 잘 썼다). 규칙은 읽혀야 발동한다. 실사용 관찰이 carry — 산출물에서 은유 대체·미결정 전가가 계속 나오면, 다음 후보는 게이트(`guard` 확장)이지 문구 보강이 아니다.
- 미착수: **fresh 사용자 축의 CLAUDE.md 압축**(`SoT`·`lag`·`작동 명령` 등, 글로벌 CLAUDE.md에 "제품 갭, 별도 트랙"으로 이미 자인됨)은 이번 범위 밖. 이제 그 갭을 *부를 이름*은 생겼다 — 이중 수신자 문서.

## Status

Accepted (2026-07-13).
