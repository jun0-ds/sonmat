# 2026-05-23 — 업데이트 전파 수정: 깨진 자동 pull → 동작하는 version-mismatch 알림

## Context

sonmat은 마켓플레이스 배포 플러그인이다. 변경(특히 데이터 경로 이전 같은 마이그레이션)이 사용자에게 닿으려면 업데이트 전파가 동작해야 한다. 실측 결과 session-start 훅의 자작 자동 업데이트는 **이중으로 깨져 있었다**:

1. **CC는 cache 복사본을 실행한다.** 설치된 플러그인은 `~/.claude/plugins/cache/{mp}/{plugin}/{version}/`에 *복사*되고(installed_plugins.json의 installPath), `hooks.json`의 `${CLAUDE_PLUGIN_ROOT}`가 이 cache를 가리킨다. cache엔 `.git`이 없다. 훅의 `git -C "$PLUGIN_ROOT" pull origin main`은 그 cache(non-repo)를 향하므로 **항상 실패**한다.
2. **알림이 한 번도 출력된 적 없다.** 훅은 `UPDATE_MSG`를 계산했지만 출력 `CONTEXT`는 `MSGS[@]`만 조립했다 — `UPDATE_MSG`는 `additionalContext`에 append되지 않아 Claude에게 **전혀 전달되지 않는 dead code**였다.

실제 전파는 **CC 네이티브의 version-범프 기반 re-cache**로만 일어난다 (cache `lastUpdated`가 0.13.3 릴리스일과 일치 = CC가 버전 범프 감지 시 re-cache). 단 third-party 마켓플레이스는 **auto-update 기본 OFF** → 끈 사용자는 수동 `/plugin update`가 필요하고, 그걸 알려주는 **"업데이트 있음" 알림이 사실상 없었다**. (외부 사용자가 v0.13.1 hook-breakage를 sonmat 알림이 아니라 *빨간 에러 배너*로 알게 된 정황과 정합.)

## Decision

훅의 자동 업데이트 블록을 **동작하는 version-mismatch 알림**으로 교체한다.

- 3시간 주기로 cache 버전(`$PLUGIN_ROOT/.claude-plugin/plugin.json`) vs 원격 main 버전(GitHub raw)을 비교.
- 다르면 **`MSGS`에 추가** → 기존 `CONTEXT` 조립 경로를 타고 `additionalContext`로 **실제 전달**. Claude가 세션 시작 시 사용자에게 안내: "sonmat X→Y 업데이트가 있어요 — `/plugin update sonmat@sonmat` 후 `/reload-plugins`로 적용하세요."
- **in-place `git pull` 제거** — cache 모델에서 불가능. 적용은 CC가 소유(`/plugin update`가 re-cache).
- 보안 검토 옵션 유지: marketplace 클론(`~/.claude/plugins/marketplaces/sonmat`, main 추적 git repo)에서 commit/diff를 보여주고 검토. (자동 pull한 코드가 아니라, 적용 *전* 검토 경로.)

역할 분담: **sonmat = 알림** (auto-update OFF 사용자에게 빠진 nudge 제공), **CC = 적용** (version 범프 → re-cache).

## Consequences

- 알림이 실제로 닿는다 (적용 전까지 3시간마다 reminder, 적용 후 자동 소멸 — 버전 일치).
- **bootstrap caveat**: 이 fix는 *fix가 실린 버전(0.13.4)부터* 효과. 기존 0.13.3 사용자는 옛 dead 훅이 돌아 0.13.4 출시를 알림받지 못한다 → **1회 수동 nudge 필요** (알려진 사용자에게 한 번 "update 해달라"). 이후 모든 업데이트는 자동 알림.
- 권장 후속(별도): README에 "sonmat 마켓플레이스 auto-update 켜기" 안내 추가 — 알림 없이도 CC가 자동 적용하게.
- 버전: **0.13.4 (PATCH)** — 깨진 동작 수정.
- 이 fix는 후속 [scribe·메모리 상태를 `.claude` 밖으로](2026-05-23-scribe-state-out-of-claude.md) 변경의 **rollout 선결 과제**다 — 알림이 닿아야 그 마이그레이션이 사용자에게 적용된다.
