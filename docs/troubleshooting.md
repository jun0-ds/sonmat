# Troubleshooting

sonmat 설치/실행 중 발생하는 문제와 해결법.

## Codex 훅이 `Review 1`로 남을 때

Codex는 플러그인의 비관리 훅을 처음부터 실행하지 않는다. 새 세션에서 `/hooks`를 열고 sonmat의 SessionStart 정의와 실제 명령을 검토한 뒤 신뢰해야 한다. 훅 파일이 바뀌면 해시도 바뀌므로 다시 검토하는 것이 정상이다.

신뢰하기 전에도 스킬은 설치될 수 있지만 SessionStart가 맡는 discipline 연결과 네이티브 에이전트 설치 안내는 나오지 않는다.

## Codex에서 `sonmat_witness`가 보이지 않을 때

Codex 플러그인은 스킬과 훅을 발견하지만 플러그인 안의 Claude Code용 `agents/*.md`를 `~/.codex/agents/`로 복사하지 않는다. 새 세션에서 sonmat 훅이 출력한 설치 명령을 검토한 뒤 실행한다.

개발 체크아웃에서는 다음처럼 직접 실행할 수 있다.

```bash
bash scripts/install-codex-agents.sh
```

기존 TOML이 패키지 원본과 다르면 설치기는 쓰기 전에 멈춘다. 차이를 검토한 뒤 패키지 버전으로 교체할 의도가 분명할 때만 `--force`를 붙인다. 설치 뒤에는 새 세션을 시작해야 에이전트 구성이 로드된다.

## Codex가 `CLAUDE.md`를 만들거나 고칠 때

v0.17.0부터 Codex 분기는 `PLUGIN_DATA`로 하네스를 구분하며 Claude 파일을 건드리지 않는다. 이런 변경이 보이면 먼저 설치 버전을 확인한다.

```bash
codex plugin list
```

v0.16.1 이하면 마켓플레이스를 갱신하고 플러그인을 다시 설치한다. v0.17.0 이상인데도 재현되면 `/hooks`에 표시된 source path와 hook definition을 함께 확인한다.

## Skills이 안 보일 때

**증상**: `/sonmat:autoloop` 등 스킬이 자동완성에 나타나지 않거나 실행 시 "unknown skill" 에러.

**진단**:

```bash
claude plugin list
```

sonmat이 목록에 없으면 플러그인 등록이 깨진 상태.

**해결**:

1. 먼저 기존 설치 제거 시도:
   ```bash
   claude plugin uninstall sonmat
   ```

2. 재설치 (터미널에서 직접 실행):
   ```bash
   claude plugin marketplace add jun0-ds/sonmat
   claude plugin install sonmat@sonmat
   ```

3. 위 방법이 안 되면 수동 클론 후 등록:
   ```bash
   rm -rf ~/.claude/plugins/marketplaces/sonmat
   git clone https://github.com/jun0-ds/sonmat.git ~/.claude/plugins/marketplaces/sonmat
   claude plugin install sonmat@sonmat
   ```

4. 재설치 후 **새 세션을 시작**해야 스킬이 로드된다.

**확인**: `claude plugin list`에서 sonmat 확인 + 새 세션에서 `/sonmat:` 입력 시 자동완성 표시.

> **참고**: `/plugin install` 같은 슬래시 명령은 Claude Code 대화 내 입력용이다.
> 터미널에서는 `claude plugin install` 형태로 실행한다.

## Windows Git Bash MSYS2 경로 변환 문제

**증상**: Git Bash에서 `/plugin install` 같은 슬래시 명령이 `C:/Program Files/Git/plugin` 등 Windows 경로로 변환되어 실패.

**원인**: MSYS2(Git for Windows 기반)가 `/`로 시작하는 인자를 자동으로 Windows 경로로 변환한다.

**해결**:

```bash
# 방법 1: 환경변수로 경로 변환 비활성화
MSYS_NO_PATHCONV=1 claude

# 방법 2: .bashrc에 영구 설정
echo 'export MSYS_NO_PATHCONV=1' >> ~/.bashrc

# 방법 3 (권장): WSL2 사용
# Git Bash 대신 WSL2에서 Claude Code를 실행하면 이 문제가 없다.
```

## `/plugin` 명령은 사용자가 직접 실행해야 한다

**증상**: AI 어시스턴트에게 "sonmat 설치해줘"라고 하면 `claude plugin install`을 실행하지 못한다.

**원인**: `claude plugin` 등 CLI 명령과 `/plugin` 등 슬래시 명령은 사용자가 터미널에서 직접 입력해야 한다. VSCode 확장 등 에이전트 환경에서는 어시스턴트가 이를 대신 실행할 수 없다.

**해결 — 사용자가 직접 실행** (아래 단계를 따라하세요):

1. **터미널 열기**
   - VS Code: `Ctrl + `` ` (백틱) 또는 상단 메뉴 → Terminal → New Terminal
   - 일반: OS 터미널 앱 실행 (Windows: PowerShell/Git Bash, Mac/Linux: Terminal)

2. **아래 명령어를 한 줄씩 복사 → 터미널에 붙여넣기 → Enter**:
   ```bash
   claude plugin marketplace add jun0-ds/sonmat
   ```
   ```bash
   claude plugin install sonmat@sonmat
   ```

3. **새 세션 시작**: 현재 대화를 닫고 다시 열어야 스킬이 로드된다.

## 업데이트했는데 옛날 버전이 깔릴 때

**증상**: `claude plugin uninstall` → `install` 했는데 이전 버전이 다시 설치된다.

**원인**: 로컬 마켓플레이스 캐시가 오래된 상태. `claude plugin install`은 로컬에 캐시된 마켓플레이스 소스에서 가져오므로, 리포에 새 버전을 릴리즈해도 각 기기의 마켓플레이스를 먼저 갱신해야 한다.

**해결 — 3단계 순서**:

```bash
# 1. 마켓플레이스 소스 최신화 (이게 빠지면 옛날 버전이 다시 깔림)
claude plugin marketplace update sonmat

# 2. 기존 플러그인 제거
claude plugin uninstall sonmat

# 3. 재설치
claude plugin install sonmat@sonmat
```

재설치 후 **새 세션을 시작**해야 변경사항이 반영된다.

> **참고**: `claude plugin update sonmat`도 있지만, marketplace update + clean reinstall이 가장 확실하다.

## 일반 진단 체크리스트

문제가 위 항목에 해당하지 않을 때:

1. **플러그인 목록 확인**: `claude plugin list`
2. **manifest 검증**: `~/.claude/plugins/marketplaces/sonmat/` 디렉토리에 `skills/`, `agents/`, `hooks/` 존재 확인
3. **installed_plugins.json 확인**:
   ```bash
   cat ~/.claude/plugins/installed_plugins.json | grep sonmat
   ```
   sonmat 항목이 없으면 `claude plugin install sonmat@sonmat` 재실행.
4. **hooks 동작 확인**: 새 세션 시작 시 `~/.claude/CLAUDE.md`에 sonmat 섹션이 자동 삽입되는지 확인
5. **Claude Code 버전**: `claude --version` — 최신 버전에서 플러그인 시스템 동작이 달라질 수 있음
6. **새 세션 시작**: 설치/수정 후에는 항상 새 세션에서 테스트
