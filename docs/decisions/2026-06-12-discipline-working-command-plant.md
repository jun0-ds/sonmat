# 2026-06-12 — fresh 사용자에게 discipline 작동 명령 심기 (paths-only plant 정정)

## Context

session-start 훅은 첫 세션에 `~/.claude/CLAUDE.md`에 `## sonmat` 블록을 심는다. 그런데 이 블록은 *경로만* 담는다:

```
## sonmat
- Discipline: ~/.claude/plugins/marketplaces/sonmat/discipline/core.md
- Domain hints: ...
- Memory: ...
- Scribe logs (per project): ...
```

여기엔 **"core.md를 읽고 그 규율을 모든 응답의 전제로 적용하라"는 작동 명령이 없다.** 경로 불릿은 파일이 *어디 있는지*만 알려줄 뿐, *읽으라는 명령*이 아니다. README의 "Discipline loading" 절은 "Claude reads the discipline through the normal CLAUDE.md loading path"라고 적었지만, always-loaded 블록에 경로만 있고 imperative가 없으면 그 체인의 첫 고리가 비어 있다.

결과로 **fresh 사용자(플러그인만 설치, 자기 작동 명령이 없는 사람)에게 규율이 약하게 걸린다**: 스킬은 명시적으로 호출될 때 작동하고, worker는 autoloop가 dispatch할 때 규율을 받지만, 메인 세션엔 기본 doubt-and-verify 자세가 없다. 플러그인의 가치 명제("injects a verification discipline into every agent")가 fresh 사용자의 메인 세션에선 *읽으라는 지시 없는 경로 묶음*으로 줄어든다.

이 작동 명령은 지금까지 maintainer(jun0) 자신의 `~/.claude/CLAUDE.md` 맨 위 "Thinking Discipline" 절에만 손수 박혀 있었다. 그 절이 SoT였고, 플러그인은 그것을 의도적으로 담지 않았다 (v0.4.0 prompt-first 결정: 훅 additionalContext를 0으로, 규율은 CLAUDE.md → core.md 참조 체인으로). maintainer는 자기 절에 직접 "fresh sonmat 사용자는 이 절이 없으면 경로만 받아 규율이 약하게 걸린다 — 제품 갭, 별도 트랙"이라고 갭을 적어 두었다.

## Decision

**훅이 작동 명령을 담은 marker 블록을 *추가로* 심는다 — 단, 이미 작동 명령을 가진 사용자는 건너뛴다.**

기존 `## sonmat` 경로 블록은 그대로 둔다 (clobber 위험 0). 그 뒤에 별도의 idempotent marker 블록을 심는다:

```
<!-- sonmat:discipline:start -->
## Thinking Discipline (sonmat)

At the start of every session, Read ...core.md (and the matching domain hints.md) and
apply that discipline as the premise of every response: ...
<!-- sonmat:discipline:end -->
```

심기 가드는 두 조건의 AND-NOT이다:

1. `sonmat:discipline` marker가 아직 없고,
2. 사용자 CLAUDE.md에 이미 작동 명령이 없다 — 센티넬 = `core.md` 언급 **그리고** `전제`/`premise` 언급이 동시에 있으면 작동 명령이 있다고 본다.

세 경우가 깨끗이 갈린다:

- **fresh 설치**: 경로 블록(core.md 포함) 다음에 작동 명령 marker를 받는다. 센티넬은 `전제`/`premise`가 없어 미발동 → 심긴다. 규율이 비로소 걸린다.
- **경로-only 블록만 있는 기존 사용자**: `## sonmat`이 있어 경로 plant는 skip되지만, marker도 없고 `전제`/`premise`도 없어 → 작동 명령 marker가 심긴다 (업그레이드).
- **maintainer(jun0) 또는 손수 작동 명령을 둔 사용자**: 맨 위 절에 `core.md` + `전제`가 다 있어 센티넬 발동 → skip. 손수 절이 보존되고 중복이 없다.

**경로(install-resolved)만 쓴다** — maintainer 절대경로(`/home/jun0/...`)를 박지 않는다. portability 유지.

## Alternatives considered

- **훅 additionalContext로 매 세션 주입.** 채널이 이미 살아 있어(MSGS → additionalContext) 가장 작은 변경이지만, v0.4.0이 명시적으로 세운 prompt-first(additionalContext → 0) 원칙을 *뒤집는다*. 매 세션 주입은 always-loaded CLAUDE.md 콘텐츠보다 우선순위가 낮고 휘발적이다. 문서화된 핵심 원칙을 조용히 되돌리는 변경이라 기각.
- **`## sonmat` 경로 블록 자체를 marker-replace로 업그레이드.** 한 블록에 명령+경로를 합쳐 단순하지만, maintainer가 그 블록을 *손수 커스터마이즈*(개발 리포·버전 관리·sonmat-knowledge 포인터)해 둔 경우 marker-replace가 그 커스텀을 덮어쓴다. clobber 위험으로 기각 — 대신 별도 marker로 추가만 한다.
- **always-loaded 스킬/시스템 프롬프트로 명령 이전.** Claude Code 스킬은 always-loaded가 아니라 *호출형*이다 (현 6 스킬 전부 reactive). 플러그인엔 always-on 주입 surface가 SessionStart 훅의 additionalContext(= 위 1안) 또는 사용자 CLAUDE.md(= 본 결정)뿐. 세션 시작 always-on을 단독으로 못 줘서 기각.

## Consequences

- fresh 사용자의 메인 세션에 규율이 걸린다 — 플러그인의 가치 명제가 실현된다.
- prompt-first 유지: 명령이 always-loaded CLAUDE.md에 안착, 훅 런타임 주입 0.
- maintainer machine 무변경 — 손수 절 보존, 중복 0.
- plant-once 시맨틱(marker 존재로 가드). 명령 *문구*를 나중에 바꾸면 기존 사용자는 자동 갱신 안 됨 (경로 블록의 현 동작과 동일 한계). 갱신이 필요해지면 marker-replace로 격상 — 통증 후.
- MINOR (0.14.0 → 0.15.0): 새 capability(규율이 fresh 사용자에게 걸림), 훅의 CLAUDE.md 출력 계약 변경. breaking 아님.

## Status

Accepted (2026-06-12).
