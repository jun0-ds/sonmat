# sonmat (손맛)

> 엄마가 하면 맛있던데 왜 내가 하면...?

범용 자율 루프 플러그인 for Claude Code.
superpowers + gsd + andrej-karpathy-skills를 대체합니다.

## 특징

- **System 1/2 이중 프로세스** — 빠른 판단(스킬)과 깊은 분석(워커)을 상황에 따라 자동 전환
- **범용 루프 엔진** — 개발, ML/DL, 데이터 분석, 문서, 글쓰기 등 도메인별 자율 반복
- **경량 규율 주입** — core.md + 도메인 규율이 워커에 실제로 전달됨
- **사용자 성장 구조** — 판단 근거 투명 공개, 커스텀 표면 안내, 적시 제안

## 구조

```
sonmat/
├── skills/
│   ├── loop/        # 범용 자율 루프 프로토콜
│   ├── guard/       # 가드레일 (커밋 전 검증, 스코프 체크)
│   ├── plan/        # 마일스톤/페이즈 관리 (progress.md)
│   ├── benchmark/   # 비교실험 프레임워크
│   └── discipline/  # 도메인별 규율 파일
│       ├── core.md      # 공통 규율 (항상 적용)
│       ├── dev.md       # 개발
│       ├── ai-ml-dl.md  # ML/DL
│       ├── analysis.md  # 데이터 분석
│       ├── document.md  # 문서
│       └── general.md   # 기본값
├── agents/
│   └── sonmat-worker.md  # System 2 워커 에이전트
└── hooks/                # 세션 시작 훅 (도메인 1차 판단)
```

## 호칭 설정

세션 시작 시 글로벌 `~/.claude/CLAUDE.md`에 `## 0. 호칭` 섹션이 없으면 쌍방 호칭을 제안한다.

- **수락** — 사용자가 정한 호칭을 `CLAUDE.md`에 기록
- **거절** — `설정하지 않음`으로 기록하여 다시 묻지 않음
- **변경** — 언제든 `CLAUDE.md`를 수정하거나 대화에서 요청

관계 방향은 자유:

| 유형 | 예시 |
|------|------|
| 대등 | 친구/친구, 동료/동료 |
| 사용자 > 클로드 | 선배/막내, 형/동생 |
| 클로드 > 사용자 | 코치/선수, 스승/제자 |

## 설치

```bash
claude plugins install sonmat@sonmat
```

별도 init 과정이나 설정 파일 생성은 필요 없다.

## 사용법

설치 후 대화를 시작하면 sonmat이 자동으로 동작한다.

### 도메인 자동 판단

태스크 키워드에 따라 도메인이 자동 선택되고 해당 규율이 적용된다.

| 키워드 | 도메인 | 규율 |
|--------|--------|------|
| 테스트, 리팩토링, API, 커밋 | dev | TDD, 체계적 디버깅, 코드리뷰 |
| 학습, F1, 모델, 파인튜닝 | ai-ml-dl | 베이스라인 먼저, 한 번에 하나만 변경 |
| 데이터, 시각화, 분석, 통계 | analysis | 무결성 확인, 장식용 차트 금지 |
| 문서, 정리, 목차, 매뉴얼 | document | 용어 통일, 퇴고 규율 |
| 위에 해당 없음 | general | core.md만 적용 |

### 루프 실행

반복 작업을 요청하면 기획 질문 루프를 거쳐 루프 정의서를 생성하고 자율 반복을 시작한다.

```
[기획] → [정의] → [실행] → [평가] → [판단] → [기록] → [반복/종료]
```

판단은 keep(확정) / discard(폐기) / refine(부분 수정) 3단계.

### 에스컬레이션

예상 외 결과, 반복 실패, 참조 누락, 규율 충돌 시 자동으로 System 2로 에스컬레이션한다.

| 레벨 | 동작 |
|------|------|
| L0 | System 1 — 스킬로 바로 실행 |
| L1 | 멈추고 한 번 더 확인 |
| L2 | sonmat-worker 스폰 (규율 주입) |
| L3 | 복수 워커 병렬 스폰 |

### 규율 오버라이드

프로젝트 CLAUDE.md에 `## sonmat` 섹션을 추가하여 도메인 고정, 규율 비활성화, 추가 규율을 설정할 수 있다:

```markdown
## sonmat
domain: ai-ml-dl
discipline:
  disable:
    - "dev.md > TDD"
  add:
    - "커밋 전 ruff format 필수"
```

## superpowers / gsd / karpathy-skills에서 마이그레이션

### 제거

기존 플러그인을 비활성화한다:

```bash
claude plugins uninstall superpowers@superpowers-marketplace
claude plugins uninstall andrej-karpathy-skills@karpathy-skills
```

GSD는 훅 기반이므로 `settings.json`에서 관련 훅을 제거한다.

### 대응 관계

| 기존 | sonmat 대응 |
|------|-------------|
| superpowers TDD/디버깅/코드리뷰 | `discipline/dev.md` |
| superpowers brainstorming/writing-plans | `skills/loop/` 기획 질문 루프 |
| gsd spec → plan → execute | `skills/plan/` + `skills/loop/` |
| karpathy-skills 코딩 원칙 | `discipline/core.md` |

### 차이점

- sonmat은 규율을 워커에 실제로 주입한다. 기존 플러그인은 메인 세션에만 적용되었다.
- 루프 정의서로 반복 작업을 자율 관리한다. 기존에는 수동으로 반복을 지시해야 했다.
- 에스컬레이션이 자동이다. 기존에는 사용자가 판단하여 에이전트를 스폰했다.

## 라이선스

MIT — `LICENSE` 파일 참조.
