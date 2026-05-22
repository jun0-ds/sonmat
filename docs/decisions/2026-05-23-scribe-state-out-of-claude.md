# 2026-05-23 — scribe·메모리 상태를 `.claude/` 밖으로 (계층형 `~/.sonmat` 홈 + 통합은 opt-in)

## Context

sonmat은 두 곳에 영속 상태를 쓴다:
- 프로젝트 scribe 로그 — `{project}/.claude/sonmat/{bridge-note,journal,journal-archive,progress}.md` + 프로젝트 lesson
- 범용 lesson — `~/.claude/sonmat/memory/{trap,insight,punch}_*.md`

**문제 — 모든 `.claude/` 디렉토리가 Claude Code의 edit-confirmation 프롬프트를 띄운다.** 실측으로 확인했다: 프로젝트 레벨 `{project}/.claude/sonmat/`에 파일을 쓰면 `~/.claude/`와 똑같이 프롬프트가 뜬다 (공식 문서는 "user config home `~/.claude/`만"이라 기술하지만, 실제 동작은 *경로 무관 모든 `.claude` 디렉토리*. protected 목록에서 `.claude`가 `.git`·`.vscode`·`.idea`·`.husky`와 한 묶음인 것과 정합 — repository-state 보호 결). 이 보호는 `bypassPermissions` 외 모든 모드에서 작동하고 `permissions.allow`로도 못 끈다 (하드코딩된 deny-우선 circuit breaker).

결과: **모든 sonmat 사용자가 모든 프로젝트에서 scribe가 쓸 때마다 프롬프트를 받는다.** scribe는 background 영속 계층이라 이 마찰이 핵심 가치(세션을 잇는 자동 기록)를 갉아먹는다. 경로는 SKILL.md 지시문 + session-start 훅(`mkdir -p .claude/sonmat`)에 하드코딩, override 손잡이 없음.

추가 제약: sonmat은 더 큰 munteok 생태계의 **한 컴포넌트**다 (sonmat·bobusang·deodeumi + munteok 프레임워크). 사용자는 *sonmat만* 설치할 수도, *full munteok*를 쓸 수도 있다. 저장 위치 결정은 두 경우를 다 서빙해야 하며, standalone 사용자에게 munteok substrate(hearth/identity·madang·4-zone·한국어 브랜딩)를 강요해선 안 된다.

## Decision

**`.claude/`에 의존하지 않는 계층형 sonmat state 홈을 도입한다.**

### 1. 기본 홈 = `~/.sonmat/` (`.claude` 밖)

- `~/.sonmat/projects/{slug}/` — 프로젝트별 scribe (`bridge-note`·`journal`·`journal-archive`·`progress`·lesson). `{slug}`는 cwd에서 도출 (CC의 `~/.claude/projects/{slug}/` 방식 미러).
- `~/.sonmat/memory/` — 범용 lesson (`trap_*`·`insight_*`·`punch_*`).
- `~/.sonmat/`는 `~/.claude/` 밑이 아니고 protected 목록(`.git`/`.vscode`/`.idea`/`.husky`/`.claude`)에도 없다 → **프롬프트 없음**, harness-neutral (own-harness 이행에도 정합).

### 2. 경로 해소 = env > 기본 (fragile 자동감지 없음)

- `SONMAT_PROJECTS_BASE` / `SONMAT_MEMORY_DIR` env가 있으면 그걸 쓰고, 없으면 `~/.sonmat/...` 기본.
- **통합은 opt-in**: munteok 프레임워크가 (bobusang setup / 자기 훅으로) 그 env를 set해 sonmat 상태를 자기 안채로 redirect한다 — scribe → `desk/sonmat/{slug}`, memory → `bedrock/sonmat-memory`. munteok의 zone 분리(scribe=desk·fast / memory=bedrock·slow)를 보존.
- **standalone sonmat 사용자**는 `~/.sonmat/`만 얻는다 — substrate 강요 0. (계층형: 두 경우를 한 메커니즘으로, 단 강요 없이.)

### 3. 마이그레이션 + 하위호환

- session-start 훅: 새 위치가 비어있고 옛 위치가 있으면 **1회 이주** — `{project}/.claude/sonmat/` → 새 projects 경로, `~/.claude/sonmat/memory/` → `~/.sonmat/memory/`. idempotent.
- skill 지시문: 새 위치 우선, 없으면 **옛 위치 fallback-read** (방어). → fallback이 있으므로 기존 사용자 데이터 유실 0 = breaking 아님.

### 4. planted 블록 갱신

- 신규 설치 시 훅이 심는 `## sonmat` 블록의 memory 경로를 `~/.sonmat/memory/`로 (현재 `~/.claude/sonmat/memory/`).

## Consequences

### 변경 표면

- `skills/scribe/SKILL.md` (88·97·123·190·297-299), `skills/autoloop/SKILL.md` (22), `skills/punch/SKILL.md` (93, memory 경로), `agents/sonmat-scribe.md` (28·58·70), `hooks/session-start` (디렉토리 생성 + 이주 + planted 블록).
- 기존 ADR들의 `.claude/sonmat` 참조는 historical record이므로 rewrite하지 않음 (본 ADR이 supersede).
- 버전: **MINOR (0.14.0)** — 신경로 + 이주 + fallback이라 기존 셋업 비파괴. (MAJOR 논쟁 여지: "setup 위치 변경"이지만 fallback으로 사용자 액션 불요 → MINOR로 판단.)

### munteok instance 측 (별도, claude-config·munteok-anchae)

- `SONMAT_PROJECTS_BASE`·`SONMAT_MEMORY_DIR` env set (anchae로 redirect).
- 기존 symlink hack 은퇴 가능: `~/.claude/sonmat/memory` → bedrock, `~/control-tower/.claude/sonmat` → desk/sonmat (env가 대체).
- 글로벌 `~/.claude/CLAUDE.md` §sonmat 표·§7의 `.claude/sonmat` 참조 갱신.

### Rollout 전제 — 업데이트 전파 (검증된 발견, 2026-05-23)

이 변경이 사용자에게 닿으려면 업데이트 전파가 동작해야 하는데, **현재 sonmat의 자작 자동 업데이트는 CC의 현행 plugin 모델에서 깨져 있다** (실측 확인):

- CC가 실행하는 것은 **cache 복사본** (`cache/{mp}/{plugin}/{version}/`, `hooks.json`의 `${CLAUDE_PLUGIN_ROOT}`가 가리킴). cache엔 `.git`이 없다.
- session-start 훅의 `git -C "$PLUGIN_ROOT" pull origin main`은 그 cache(non-repo)를 향하므로 **실패** → 버전 범프 시 훅은 *silent "auto-pull failed"* 가지로 빠져 사용자에게 알리지도 않는다.
- 실제 전파는 **CC 네이티브의 version-범프 기반 re-cache**로만 일어난다 (cache `lastUpdated`가 0.13.3 릴리스일과 일치). 단 third-party 마켓플레이스는 **auto-update가 기본 OFF** → 끈 사용자는 수동 `/plugin update` 필요.

→ **선결 과제**: 깨진 git-pull 블록을 *동작하는 version-mismatch 알림*으로 교체 — cache 버전 vs 원격 main 버전을 비교해 다르면 "sonmat X→Y 가능, `/plugin update sonmat@sonmat` 후 `/reload-plugins`" 안내. (auto-pull은 cache 모델에서 불가하나 *알림*은 가능.) 이 fix 없이는 본 경로 변경·마이그레이션이 auto-update OFF 사용자에게 닿지 않고, 마이그레이션 훅도 그들에겐 실행되지 않는다.

- **bootstrap caveat**: 알림 fix는 *그 fix가 실린 버전부터* 효과를 낸다 (옛 버전의 깨진 훅이 마지막으로 한 번 더 도는 동안은 무통보). 기존 사용자에게는 1회 수동 nudge가 필요할 수 있다.
- 이 propagation fix는 본 경로 변경과 독립적으로 *모든* 향후 sonmat 변경에 영향을 주므로, **별도 ADR/선행 작업으로 다루는 것을 권장**한다.
