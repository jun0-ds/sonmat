English: [README.en.md](README.en.md)

# sonmat (손맛)

> 엄마 손맛은 맛있는데 왜 내가 하면..?

> AI는 자신 있게 말한다. 그런데 틀렸다. 그리고 AI도 사용자도 눈치채지 못했다.

손맛(sonmat)은 AI와 사용자가 함께 **의심하고 바로잡는 습관**을 기르도록 돕는 Claude Code·Codex 플러그인이다.

## 무엇을 하는가

AI는 검증 없이 자신 있게 답을 내놓는다. 사용자는 그럴듯하게 들리니 받아들인다. 아무도 확인하지 않는 사이에 오류가 소리 없이 쌓인다.

sonmat은 이 순환을 끊는다.

- **AI 쪽에서는** 메인 세션과 모든 worker에 검증 규율을 건다. witness는 이 규율 대신 자기만의 독립 비교 규칙을 따른다. 규율의 세 동작은 Break it(어디서 무너지는지 찾는다), Cross it(다른 경로로 따로 확인한다), Ground it(짐작하지 말고 실행해 본다)이다.
- **사용자 쪽에서는** AI가 어떻게 추론했는지 투명하게 드러내, 그냥 믿는 대신 실제로 판단할 수 있게 한다.

핵심은 이것뿐이다. 나머지는 모두 구현이다.

## 여섯 축

sonmat의 검증은 여섯 축으로 나뉜다. 축마다 발동 조건이 따로 있어 필요한 것만 쓸 수 있다.

| 축 | 하는 일 | 언제 도는가 |
|---|---|---|
| guard | 민감한 파일이 섞였거나 테스트가 깨진 커밋을 막는다 | 메인 세션에서 자동으로 |
| inspect | 공유 코드·인증·인프라를 바꿀 때 영향 반경을 따져 본다 | 그런 변경 신호가 보일 때 |
| witness | 만든 결과를 사용자 원문 의도와 승인된 실행 기준선에 독립적으로 대조한다 | autoloop의 `[Judge]` 단계에서 커밋 전에, 그리고 세션을 끝낼 때 |
| punch | 빠진 것(누락)과 남은 것(잔재)을 찾아 완성도를 점검한다 | 넘기기 전, `/punch` |
| devil | 되돌리기 어려운 결정 앞에서 반론을 꺼낸다 | 큰 결정 전, `/devil` |
| scribe | 작업이 끝난 뒤 남길 만한 발견 사항을 기록한다 | 작업 뒤 백그라운드 |

이 밖에 자율 루프 `autoloop`과, 검색이 빗나갔을 때 표현을 바꿔 다시 찾는 `requery`가 있다. requery는 scribe가 남긴 기록을 읽는 쪽이다.

## 설치

### Claude Code

```bash
/plugin marketplace add jun0-ds/sonmat
/plugin install sonmat@sonmat
```

첫 세션에서 sonmat이 `~/.claude/CLAUDE.md`에 참조 블록을 알아서 심는다. 그다음에는 그냥 대화를 시작하면 된다.

### Codex

```bash
codex plugin marketplace add jun0-ds/sonmat
codex plugin add sonmat@sonmat
```

새 스레드를 열고 `/hooks`를 연다. SessionStart 훅을 신뢰하기 전에 내용을 검토한다. Codex는 신뢰를 훅의 해시에 묶어 두므로, 훅이 바뀌면 조용히 실행되지 않고 다시 검토를 기다린다.

이 훅은 `AGENTS.md`를 고치지 않고 세션 컨텍스트로 규율을 건다. 선택 사항인 네이티브 에이전트 설치기의 정확한 경로도 알려 준다. 그 스크립트를 검토한 뒤 훅이 출력한 명령을 실행하면 `sonmat_worker`, `sonmat_witness`, `sonmat_scribe`가 `~/.codex/agents/` 아래에 설치된다. 설치기는 여러 번 실행해도 결과가 같고, 로컬에서 고친 에이전트는 `--force`를 붙이지 않는 한 덮어쓰지 않는다.

### 다시 설치하기

스킬이 보이지 않으면 터미널에서 다음 명령을 직접 실행한다.

```bash
# 재설치
claude plugin marketplace add jun0-ds/sonmat
claude plugin install sonmat@sonmat
```

그래도 해결되지 않으면 저장소를 직접 복제한 뒤 플러그인을 등록한다.

```bash
rm -rf ~/.claude/plugins/marketplaces/sonmat
git clone https://github.com/jun0-ds/sonmat.git ~/.claude/plugins/marketplaces/sonmat
claude plugin install sonmat@sonmat
```

자세한 진단 방법은 [문제 해결 안내](docs/troubleshooting.md)에 있다.

### 플랫폼별 참고

sonmat은 Windows와 Linux/macOS에서 모두 돈다. 훅 층(`run-hook.cmd`)은 두 셸이 함께 읽는 스크립트라서, cmd.exe는 배치 부분을, Unix 셸은 bash 부분을 실행한다.

**Windows (네이티브)**
- Claude Code가 cmd.exe로 `run-hook.cmd`를 부른다.
- 스크립트는 Git for Windows의 bash(`C:\Program Files\Git\bin\bash.exe`)나 PATH에 있는 다른 bash를 찾아 쓴다.
- Git for Windows가 깔려 있으면 따로 설정할 것이 없다.

> **Git Bash (MSYS2) 주의**: Git Bash에서 `/plugin install`처럼 슬래시로 시작하는 명령을 실행하면 MSYS2가 이를 `C:/Program Files/Git/plugin` 같은 경로로 바꿀 수 있다. `MSYS_NO_PATHCONV=1`로 경로 변환을 끄거나 WSL2를 쓴다.
>
> ```bash
> # Git Bash에서 경로 변환 비활성화
> export MSYS_NO_PATHCONV=1
> ```

**Windows (WSL2) — 권장**
- Claude Code가 WSL2 안에서 돌기 때문에 훅이 평범한 bash로 실행된다.
- 경로가 Linux 그대로(`~/.claude/...`) 유지되어 파일 시스템을 넘나드는 문제가 없다.
- Git Bash의 MSYS2 경로 변환 문제가 생기지 않는다.
- `settings.json`의 훅은 bash 스크립트를 직접 가리키게 한다.
  ```json
  {
    "type": "command",
    "command": "bash ~/.claude/plugins/marketplaces/sonmat/hooks/session-start"
  }
  ```

**Linux / macOS**
- 설치하면 바로 돈다. 따로 설정할 것이 없다.

### 다른 AI CLI

Claude Code와 Codex에는 네이티브 플러그인 어댑터가 있다. 규율과 스킬은 평범한 마크다운이라, 다른 AI CLI에서도 손으로 설정하면 쓸 수 있다.

CLI마다 전역 지침을 읽는 방식이 다르다. 프로젝트 규칙은 하네스가 지원하는 곳이면 어디서나 `AGENTS.md`에 둔다. Claude Code는 최소한의 `CLAUDE.md` 어댑터를 거쳐 이 파일을 읽는다.

| CLI | 전역 지침 파일 | 프로젝트 규칙 파일 | sonmat 파일을 둘 곳 |
|-----|-------------------------|-------------------|--------------------------|
| Claude Code | `CLAUDE.md` | `AGENTS.md` (`CLAUDE.md`가 불러옴) | 플러그인 설치 (위 참고) |
| Codex | `AGENTS.md` | `AGENTS.md` | 위의 네이티브 플러그인 설치 |
| Gemini CLI | `GEMINI.md` | 그 CLI의 프로젝트 지침 파일 | `~/.gemini/sonmat/` |
| 기타 | 그 CLI가 주 지침으로 읽는 파일 | 그 CLI의 프로젝트 지침 파일 | 그곳에 복사 |

**설정 (네이티브 어댑터가 없는 CLI):**

AI와 처음 나누는 대화에 아래 내용을 그대로 붙여 넣는다. AI가 자기 환경에 sonmat을 직접 설정한다.

```
Install sonmat into your environment.

1. Clone https://github.com/jun0-ds/sonmat into your config directory
   as a single directory (Gemini: ~/.gemini/sonmat/).
   Keep it as one unit — sonmat is a unified verification system,
   not a collection of separate files.

2. Read sonmat/discipline/core.md and sonmat/discipline/hints.md,
   then embed their contents directly into your main instruction file
   (Gemini: GEMINI.md).
   Do NOT use file references like "see core.md" — paste the actual content,
   because references may be ignored.

3. List the sonmat/skills/ paths in your instruction file
   so you can use them when needed.
```

Claude Code와 Codex에서는 플러그인 어댑터가 규율을 불러온다. 다른 CLI에서는 위 지시를 받은 AI가 스스로 설정한다.

## 설계 철학

1. **자신 있을 때가 의심할 때다** — 모델이 확신할 때가 바로 반례를 찾아야 할 때다. 검증 없는 확신은 자세만 그럴듯한 환각일 뿐이다.

2. **전해지지 않는 규칙은 없는 규칙이다** — 메인 세션에만 있는 규율은 장식이다. sonmat은 worker를 위임하는 순간 규율을 함께 넣는다.

3. **자율은 방치가 아니다** — 자율 루프에도 안전장치가 필요하다. 에스컬레이션은 너무 이르지도 늦지도 않은 때에 걸린다.

4. **분야마다 함정이 다르다** — "테스트부터 써라"는 개발에서는 중요하지만 데이터 분석에서는 의미가 없다. "한 번에 하나만 바꿔라"는 ML에서는 꼭 필요하지만 문서 작업에서는 지나치다.

## 작동 방식

### 규율 불러오기

sonmat은 **프롬프트 우선** 구조다. 실행 중에 훅이 컨텍스트를 끼워 넣지 않는다.

```
CLAUDE.md (always loaded)
  └─ Thinking Discipline block — standing instruction: read core.md & apply every session
  └─ sonmat section (paths to discipline files)
       └─ core.md — verification rules (Break / Cross / Ground)
       └─ hints.md — domain-specific traps
```

첫 세션에서 훅은 `~/.claude/CLAUDE.md`에 두 가지를 심는다. 하나는 규율 파일의 경로를 적은 **참조 블록**이고, 다른 하나는 규율을 실제로 걸어 주는 상시 지시인 **Thinking Discipline 블록**(`core.md`와 `hints.md`를 읽고 모든 응답의 전제로 적용하라는 지시)이다. 이 블록이 없으면 새 사용자는 파일 위치만 받게 되어 규율이 약하게 걸린다. 사용자가 이미 자기 규율 절을 두고 있으면 이 실행 지시 블록은 심지 않으므로, 손으로 쓴 절과 겹치지 않는다. 그 뒤로 훅은 아무것도 출력하지 않는다. Claude는 평소처럼 CLAUDE.md를 불러오는 경로로 규율을 읽는다. additionalContext로 더해지는 부담은 0이다.

Codex도 같은 SessionStart 훅을 쓰지만 다른 분기를 탄다. `CLAUDE.md`나 `AGENTS.md`를 만들거나 고치지 않고, 규율 파일을 읽고 적용하라는 짧은 지시를 세션 컨텍스트로 넣는다. 네이티브 서브에이전트 정의는 `codex/agents/` 아래에 있고, 사용자가 설치기를 명시적으로 실행했을 때만 `~/.codex/agents/`로 복사된다.

### 루프와 에스컬레이션

`Plan → Execute → Evaluate → Judge → Repeat/Exit`로 돈다. 일이 꼬이면 단계를 올려 에스컬레이션한다(L0 스킬 → L1 일시 정지 → L2 worker 띄우기 → L3 worker 병렬).

### 구조

```
sonmat/
├── skills/          # autoloop, guard, inspect, punch, devil, scribe, requery
├── discipline/      # core.md (verification) + hints.md (domain traps)
├── agents/          # Claude Code worker, witness, and scribe definitions
├── codex/agents/    # Codex-native custom-agent definitions
├── scripts/         # explicit Codex agent installer
└── hooks/           # harness-aware session start adapter
```

- `skills/`: 일곱 스킬(autoloop, guard, inspect, punch, devil, scribe, requery)
- `discipline/`: 검증 규칙 `core.md`와 분야별 함정 `hints.md`
- `agents/`: Claude Code용 worker, witness, scribe 정의
- `codex/agents/`: Codex 네이티브 에이전트 정의
- `scripts/`: Codex 에이전트를 명시적으로 설치하는 스크립트
- `hooks/`: 하네스를 구분해 동작하는 세션 시작 어댑터

## 다른 플러그인을 쓰다 왔다면

널리 쓰이는 Claude Code 플러그인에는 같은 빈틈이 있다. 규칙이 메인 세션에만 머물고, 서브에이전트는 빈 상태로 시작한다.

| 플러그인 | 메인 세션 규칙 | 규칙이 worker에 닿는가 |
|--------|-------------------|---------------------|
| [superpowers](https://github.com/obra/superpowers) | ✓ | ✗ ([#237](https://github.com/obra/superpowers/issues/237)) |
| [GSD](https://github.com/gsd-build/gsd-2) | ✓ | 불분명 |
| [karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) | ✓ | ✗ |
| ultrathink | ✓ | ✗ ([#25591](https://github.com/anthropics/claude-code/issues/25591)) |

관련 이슈: [claude-code#8395](https://github.com/anthropics/claude-code/issues/8395), [claude-code#22022](https://github.com/anthropics/claude-code/issues/22022)

| 예전 | sonmat에서 |
|--------|---------------|
| superpowers TDD/디버그/리뷰 | `discipline/core.md` + `hints.md` |
| superpowers 브레인스토밍 | `skills/autoloop/` 기획 질문 |
| GSD spec → plan → execute | `skills/autoloop/` 기획·실행 단계 |
| karpathy-skills 원칙 | `discipline/core.md` |

## 자주 묻는 질문

**Q: sonmat은 무엇인가?**
A: AI와 사람이 함께 일할 때 검증하는 습관을 심는 Claude Code·Codex 플러그인이다. guard, inspect, witness, punch, devil(반론), scribe 여섯 검사 축이 상황에 반응해 돌면서, AI 산출물의 오류가 쌓이기 전에 잡는다. 이름의 손맛은 솜씨 좋은 요리사만 내는 맛을 가리킨다. 그럭저럭 나온 결과와, 검증하고 근거를 댄 작업 사이의 차이를 뜻한다.

**Q: superpowers나 ultrathink 같은 다른 Claude Code 플러그인과 무엇이 다른가?**
A: 규율이 전해지느냐가 가장 큰 차이다. sonmat은 worker를 위임할 때 검증 규율을 함께 넣는다. witness는 따로 정한 비교 규칙을 받고, 실행한 에이전트의 추론은 받지 않는다.

**Q: Codex CLI나 Gemini CLI에서도 되는가?**
A: 된다. Codex에는 네이티브 플러그인 매니페스트, 하네스를 구분하는 SessionStart 분기, 선택 사항인 네이티브 커스텀 에이전트가 있다. Gemini CLI는 sonmat이 전용 어댑터를 내지 않으므로 지금도 한 번 손으로 설정해서 쓴다.

**Q: 작업이 느려지지 않는가?**
A: Claude Code는 프롬프트 우선 구조라서, 처음 한 번 `CLAUDE.md`를 준비한 뒤로는 훅이 규율 컨텍스트를 더하지 않는다. Codex는 규율 파일을 읽고 적용하라는 짧은 SessionStart 지시 하나를 더한다. 검증 스킬과 에이전트는 작업 흐름이 부를 때만 돈다.

**Q: 업데이트 알림은 어떻게 켜는가?**
A: 기본값은 꺼짐이다. 기기마다 필요하면 상태 디렉터리를 만들고 `on`이나 `off`를 적는다.

```bash
mkdir -p "${SONMAT_HOME:-$HOME/.sonmat}"
printf 'on\n' > "${SONMAT_HOME:-$HOME/.sonmat}/update-notify"
# To turn notifications off:
printf 'off\n' > "${SONMAT_HOME:-$HOME/.sonmat}/update-notify"
```

파일 내용이 정확히 `on`이면 SessionStart 훅이 평소처럼 세 시간 간격으로 새 버전을 확인하고, 알맞은 업데이트 명령을 알려 준다. 이 플래그는 알림만 정한다. 하네스의 자동 업데이트는 계속 그 CLI의 설정을 따른다.

**Q: 여섯 검증 축은 각각 무엇을 하는가?**
A: **guard**는 민감한 파일이 섞이거나 테스트가 깨진 나쁜 커밋을 막는다. **inspect**는 공유 코드·인증·인프라를 바꿀 때 영향 반경을 점검한다. **witness**는 만든 결과를 사용자 원문 의도와 승인된 실행 기준선에 독립적으로 대조한다. **punch**는 누락과 남은 잔재를 찾아 완성도를 점검한다. **devil**은 되돌리기 어려운 결정 전에 반론을 꺼낸다. **scribe**는 작업이 끝난 뒤 발견 사항을 기록한다.

**Q: requery는 무엇을 하는가?**
A: requery는 같은 루프에서 찾아 읽는 쪽을 맡는다. 인덱스·헤더·`grep`으로 처음 찾은 것이 빗나가면, 동의어·시점·추상 수준·관점을 바꿔 질문을 다시 쓰고 정형 기록에서 비정형 기록 순으로 다시 찾는다. 인덱스나 도구를 새로 더하지 않는다. requery가 읽는 기록은 scribe가 남긴다. 지난 결정이나 인계 내용을 찾지 못할 때 `/requery`를 부른다.

**Q: 스킬 일부만 써도 되는가?**
A: 된다. 축마다 발동 조건이 따로 있다. guard는 메인 세션에서 자동으로 돌고, 넘기기 전에는 `/punch`를, 큰 결정 전에는 `/devil`을, 검색이 빗나갔을 때는 `/requery`를 부르면 된다. 한꺼번에 다 쓸 필요는 없다.

## 문제 해결

설치가 실패하거나, Windows에서 경로가 엉뚱하게 바뀌거나, 스킬이 보이지 않으면 [문제 해결 안내](docs/troubleshooting.md)를 본다.

## 개발 검사

저장소 루트에서 Linux나 WSL로 실행한다.

```bash
bash tests/test-codex-support.sh
bash tests/test-update-notify.sh
```

지원 테스트는 `uv run --no-project python`으로 실제 훅 출력을 파싱해, 경로 문자열이 JSON 인코딩을 거쳐도 그대로 남는지 확인한다. 이 파서 의존성은 테스트에만 쓰고, 훅 자체는 Bash만 쓴다. 경로 시험 데이터에는 Windows 네이티브 파일 이름에 쓸 수 없는 제어 문자가 들어 있으므로, 이 검사가 Windows 네이티브 동작까지 보증하지는 않는다.

## 출처 표기

프로젝트에서 sonmat을 쓰거나 언급한다면 한 줄 남겨 주면 고맙겠다.

> Built with [sonmat](https://github.com/jun0-ds/sonmat) by jun0-ds

## 라이선스

BSD 3-Clause — `LICENSE`를 본다.
