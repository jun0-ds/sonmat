# 문제 해결 (Troubleshooting)

sonmat을 설치하거나 실행할 때 생기는 문제와 해결 방법을 모았다.

## Codex 훅이 `Review 1`로 남을 때

Codex는 플러그인에 딸린 비관리 훅을 처음부터 실행하지 않는다. 새 세션에서 `/hooks`를 열고 sonmat의 SessionStart 정의와 실제 명령을 검토한 뒤 신뢰해야 한다. 훅 파일이 바뀌면 해시도 바뀌므로 다시 검토하는 것이 정상이다.

신뢰하기 전에도 스킬은 설치될 수 있다. 다만 SessionStart가 규율(`discipline`)을 연결하거나 네이티브 에이전트 설치를 안내하지는 않는다.

## Codex에서 `sonmat_witness`가 보이지 않을 때

Codex 플러그인은 스킬과 훅은 찾아 등록하지만, 플러그인 안에 있는 Claude Code용 `agents/*.md`를 `~/.codex/agents/`로 복사하지는 않는다. 새 세션에서 sonmat 훅이 출력한 설치 명령을 검토한 뒤 실행한다.

개발 체크아웃에서는 다음처럼 직접 실행할 수 있다.

```bash
bash scripts/install-codex-agents.sh
```

기존 TOML이 패키지 원본과 다르면 설치기는 파일을 쓰기 전에 멈춘다. 차이를 검토하고, 패키지 버전으로 바꿀 의도가 분명할 때만 `--force`를 붙인다. 설치한 뒤에는 새 세션을 시작해야 에이전트 구성이 로드된다.

## Codex가 `CLAUDE.md`를 만들거나 고칠 때

v0.17.0부터 Codex 분기는 `PLUGIN_DATA`로 하네스를 구분하고 Claude 파일을 건드리지 않는다. 이런 변경이 보이면 먼저 설치된 버전을 확인한다.

```bash
codex plugin list
```

v0.16.1 이하라면 마켓플레이스를 갱신하고 플러그인을 다시 설치한다. v0.17.0 이상인데도 재현되면 `/hooks`에 표시된 source path와 hook definition을 함께 확인한다.

## 스킬이 보이지 않을 때

**증상**: `/sonmat:autoloop` 같은 스킬이 자동완성에 나타나지 않거나, 실행하면 "unknown skill" 오류가 난다.

**진단**:

```bash
claude plugin list
```

목록에 sonmat이 없으면 플러그인 등록이 깨진 것이다.

**해결**:

1. 먼저 기존 설치를 지워 본다.
   ```bash
   claude plugin uninstall sonmat
   ```

2. 터미널에서 직접 다시 설치한다.
   ```bash
   claude plugin marketplace add jun0-ds/sonmat
   claude plugin install sonmat@sonmat
   ```

3. 그래도 안 되면 저장소를 손으로 복제한 뒤 등록한다.
   ```bash
   rm -rf ~/.claude/plugins/marketplaces/sonmat
   git clone https://github.com/jun0-ds/sonmat.git ~/.claude/plugins/marketplaces/sonmat
   claude plugin install sonmat@sonmat
   ```

4. 다시 설치한 뒤 **새 세션을 시작**해야 스킬이 로드된다.

**확인**: `claude plugin list`에 sonmat이 나오고, 새 세션에서 `/sonmat:`을 입력하면 자동완성 목록이 뜬다.

> **참고**: `/plugin install` 같은 슬래시 명령은 Claude Code 대화창에 입력하는 명령이다.
> 터미널에서는 `claude plugin install` 꼴로 실행한다.

## Windows Git Bash에서 MSYS2가 경로를 바꿀 때

**증상**: Git Bash에서 `/plugin install` 같은 슬래시 명령이 `C:/Program Files/Git/plugin` 같은 Windows 경로로 바뀌어 실패한다.

**원인**: Git for Windows의 바탕인 MSYS2가 `/`로 시작하는 인자를 자동으로 Windows 경로로 바꾸기 때문이다.

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

**증상**: AI 어시스턴트에게 "sonmat 설치해줘"라고 해도 어시스턴트가 `claude plugin install`을 실행하지 못한다.

**원인**: `claude plugin` 같은 CLI 명령과 `/plugin` 같은 슬래시 명령은 사용자가 터미널이나 대화창에 직접 입력해야 하기 때문이다. VS Code 확장 같은 에이전트 환경에서는 어시스턴트가 이 명령을 대신 실행할 수 없다.

**해결 — 사용자가 직접 실행한다** (아래 단계를 따라 한다):

1. **터미널을 연다**
   - VS Code: `Ctrl + `` ` (백틱)을 누르거나 상단 메뉴에서 Terminal → New Terminal을 고른다.
   - 그 밖의 환경: OS의 터미널 앱을 실행한다(Windows는 PowerShell이나 Git Bash, Mac·Linux는 Terminal).

2. **아래 명령을 한 줄씩 복사해 터미널에 붙여 넣고 Enter를 누른다**:
   ```bash
   claude plugin marketplace add jun0-ds/sonmat
   ```
   ```bash
   claude plugin install sonmat@sonmat
   ```

3. **새 세션을 시작한다**: 지금 대화를 닫고 다시 열어야 스킬이 로드된다.

## 업데이트했는데 예전 버전이 깔릴 때

**증상**: `claude plugin uninstall`을 하고 `install`을 다시 했는데 이전 버전이 또 설치된다.

**원인**: 로컬 마켓플레이스 캐시가 오래됐기 때문이다. `claude plugin install`은 로컬에 캐시된 마켓플레이스 소스에서 플러그인을 가져오므로, 리포에 새 버전을 릴리스했더라도 기기마다 마켓플레이스를 먼저 갱신해야 한다.

**해결 — 세 단계를 순서대로**:

```bash
# 1. 마켓플레이스 소스 최신화 (이게 빠지면 옛날 버전이 다시 깔림)
claude plugin marketplace update sonmat

# 2. 기존 플러그인 제거
claude plugin uninstall sonmat

# 3. 재설치
claude plugin install sonmat@sonmat
```

다시 설치한 뒤 **새 세션을 시작**해야 바뀐 내용이 반영된다.

> **참고**: `claude plugin update sonmat`도 있지만, 마켓플레이스를 갱신한 뒤 새로 설치하는 편이 가장 확실하다.

## 일반 진단 체크리스트

위 항목에 해당하지 않으면 다음을 차례로 확인한다.

1. **플러그인 목록**: `claude plugin list`로 sonmat이 등록됐는지 본다.
2. **설치 파일**: `~/.claude/plugins/marketplaces/sonmat/` 디렉터리에 `skills/`, `agents/`, `hooks/`가 있는지 본다.
3. **installed_plugins.json**:
   ```bash
   cat ~/.claude/plugins/installed_plugins.json | grep sonmat
   ```
   sonmat 항목이 없으면 `claude plugin install sonmat@sonmat`을 다시 실행한다.
4. **훅 동작**: 새 세션을 시작했을 때 `~/.claude/CLAUDE.md`에 sonmat 절이 자동으로 들어가는지 본다.
5. **Claude Code 버전**: `claude --version`으로 확인한다. 최신 버전에서는 플러그인 시스템의 동작이 달라졌을 수 있다.
6. **새 세션**: 설치하거나 고친 뒤에는 늘 새 세션에서 시험한다.
