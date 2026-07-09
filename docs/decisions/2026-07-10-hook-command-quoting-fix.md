# 2026-07-10 — SessionStart 훅 명령 quoting 수정 (Unix `exit 127` 정정)

## Context

`hooks/hooks.json`의 SessionStart 훅 명령이 다음 형태였다:

```json
"command": "'${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd' session-start"
```

Unix/WSL/macOS에서 매 세션 시작마다 빨간 배너가 떴다:

```
SessionStart:startup hook error
Failed with non-blocking status code: /bin/sh: 1:
${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd: not found   (exit 127)
```

**근본 원인은 두 겹이다:**

1. **작은따옴표 → env var 미확장.** Claude Code는 플러그인 훅에 `CLAUDE_PLUGIN_ROOT`를 *환경변수*로 넘긴다 (텍스트 치환이 아니다 — 치환이었다면 에러에 리터럴 `${CLAUDE_PLUGIN_ROOT}`가 아니라 실경로가 찍혔을 것). 셸은 작은따옴표 안의 `${...}`를 확장하지 않으므로 `/bin/sh`가 리터럴 경로를 명령으로 받아 `not found`(127)로 죽는다. 확장 여부는 실증했다 — 작은따옴표는 리터럴, 큰따옴표는 확장.

2. **bare 실행 → +x 필요.** 인터프리터 프리픽스 없이 파일을 직접 실행하므로 `run-hook.cmd`에 실행권한(+x)이 있어야 한다. 그런데 install이 배포하는 파일은 mode 644라, 1이 고쳐져도 `Permission denied`로 이어진다. (dev repo 원본도 644 — +x는 애초에 없었다.)

즉 이 훅은 **폴리글롯이 도입된 v0.2.1 이래 Unix에서 한 번도 정상 동작한 적이 없다.** Windows에서만 (cmd.exe가 확장자로 `.cmd`를 처리) 돌았고, Unix 세션은 조용히 배너만 띄웠다. session-start 스크립트의 실제 일(버전 mismatch 알림·상태 마이그레이션·discipline 블록 심기)이 Unix 사용자에게 안 걸리고 있었다. CC 2.1.81~2.1.205 전 버전에서 재현 — 최신 CC 회귀가 아니다.

대조군: Anthropic 공식 플러그인(hookify·security-guidance·ralph-loop·explanatory-output-style)은 **전부** `bash "${CLAUDE_PLUGIN_ROOT}/hooks/x.sh"` — 인터프리터 프리픽스 + 큰따옴표 관례다. 폴리글롯 `.cmd`를 쓰는 곳은 없다 (공식은 posix-shell-everywhere를 전제).

## Decision

명령을 공식 관례와 동일한 **인터프리터 프리픽스 + 큰따옴표** 형태로 바꾼다:

```json
"command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" session-start"
```

- `bash`가 파일을 *읽어서* 실행하므로 **+x 불필요** (설치 권한에 의존하지 않음).
- 큰따옴표는 `${CLAUDE_PLUGIN_ROOT}` **확장을 허용**하면서 공백 경로도 보존.
- `run-hook.cmd` 폴리글롯은 **그대로 유지**한다. bash가 실행하면 `: << 'CMDBLOCK'` heredoc으로 Windows 배치 블록을 건너뛰고 Unix 블록(`exec bash "${SCRIPT_DIR}/session-start"`)이 돈다. Windows 배치 분기는 이제 사실상 dead code지만 무해하고, 파일을 남겨 두면 Windows에서 cmd.exe가 직접 `.cmd`를 호출하는 경로도 깨지 않는다 (minimal-change).

파일 변경은 `hooks/hooks.json` 한 줄뿐. run-hook.cmd·session-start 스크립트는 손대지 않았다.

## Consequences

- **Unix/WSL/macOS 세션 시작 배너 소멸**, session-start의 side-effect(알림·마이그레이션·plant)가 Unix에서도 실제로 동작. `/bin/sh -c '<command>'` 형태로 실증 — exit 0, valid `hookSpecificOutput` JSON.
- Windows: 영향 없음 (공식 플러그인이 같은 `bash "..."`를 크로스플랫폼으로 쓰는 것이 posix-shell 전제의 근거).
- 외부 사용자(공개 플러그인, issue #1 @eunbi0513-collab 등 Mac/Linux 사용자) 전원이 이 버그의 영향권이었다 — 이 릴리스로 해소.
- 전파: PATCH 릴리스 v0.15.1 → GitHub push → 각 머신 `update-plugins.sh`(SessionStart async)가 `claude plugin marketplace update` + `claude plugin update`로 다음 세션에 자동 반영. larchive-gpu-dev/prod(0.15.0, 버그 확인됨)도 이 경로로 정정.

## Alternatives considered

- **작은따옴표 → 큰따옴표만 바꾸고 bare 유지** (`"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd" session-start`): env는 확장되지만 +x 문제가 남는다 (install이 644로 벗김). 실행권한을 릴리스마다 보장해야 하는 취약성 → 기각.
- **`.cmd` 폴리글롯 제거하고 `session-start` 직접 호출** (`bash "${CLAUDE_PLUGIN_ROOT}/hooks/session-start" session-start`): 더 단순하지만 Windows에서 cmd.exe가 `.cmd`를 확장자로 직접 처리하는 분기를 잃는다. Windows 동작을 이 Unix 머신에서 검증 불가 → 회귀 위험을 피해 minimal-change(폴리글롯 유지) 선택.
