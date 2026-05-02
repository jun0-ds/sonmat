---
title: devil "기둥-건물" 메타포 참고자료 메모
status: note (not adopted)
date: 2026-05-02
related: skills/devil/SKILL.md §2 (CCT), §Design rationale
---

# devil 기둥-건물 메타포 — 참고자료 메모

devil의 핵심 동작(load-bearing assumption을 찾고 거기 한 점만 친다)을 사용자가 **"기둥을 찾아 무너뜨릴 때 건물이 크게 무너지는 곳"**으로 직관 설명한 데서 출발. 현재 SKILL.md는 *방법*으로 chess CCT를 차용하고 있고, *상징*은 명시 자료로 깔려 있지 않음. 향후 §Design rationale에 보조 프레임으로 추가할지 검토용 메모.

## 현재 문서에 명시된 다섯 전통
surgical Time Out / aviation CRM / mindfulness noting / chess CCT / pre-mortem
→ 이 다섯 중 chess CCT가 이름까지 가져간 이유는 (1) 적대적 DNA, (2) forcing-move triage 구조, (3) discovery-then-depth 명시성, (4) C/C/C mnemonic + single-actor.

## "기둥-건물" 쪽 후보 자료 (가까운 순)

### 1. Clausewitz — Schwerpunkt / Center of Gravity
- 출처: 『전쟁론』(Vom Kriege, 1832)
- 정의: "the hub of all power and movement, on which everything depends"
- 현대 활용: 미군 합참 교범 Joint Publication 5-0 — Center of Gravity Analysis. NATO 전략 기획 핵심 도구.
- devil과의 매핑: 적대적 + 단일 중심추 공격 + 분산 공격을 무능으로 정의 = devil의 병렬 공격 false-depth와 동치
- 위치: chess CCT가 *압축 triage의 형식*이라면, Schwerpunkt은 *기둥-공격의 전략적 정당화*. 보완 관계.
- **가장 강한 이론 후보**

### 2. Karl Popper — Falsifiability / experimentum crucis
- 출처: 『과학적 발견의 논리』(Logik der Forschung, 1934)
- 정의: 과학 이론은 단 하나의 결정적 실험에 의해 무너질 수 있어야 한다
- devil과의 매핑: Claim-crux("이게 거짓이면 주장이 뒤집히는 그 한 가지") = experimentum crucis의 거의 직역
- 위치: 인식론적 기둥론. 무엇이 기둥인가의 *정의* 측면.

### 3. Samson과 두 기둥 (사사기 16장)
- 다곤 신전 두 중심 기둥을 양손으로 밀어 건물 전체 붕괴
- 이론 자료 아닌 **상징적 앵커**
- 서구 문화에서 "기둥 무너뜨림 = 전체 붕괴"의 원형 이미지
- 사용자가 "와닿는다"고 한 이미지의 출처에 가장 가까움
- 위치: §Design rationale에 짧게 한 줄 인용으로 시각화 강화 가능

### 4. Single Point of Failure (SPOF) / 카오스 엔지니어링
- 분산 시스템·신뢰성 공학 표준 용어
- Netflix Chaos Monkey — 일부러 SPOF 찾아 건드려 약점 노출
- devil과의 관계: devil이 reasoning에 하는 짓의 인프라 거울상. 거의 isomorphic.

### 5. Goldratt — Theory of Constraints
- 출처: 『The Goal』(1984)
- 시스템 처리량은 단 하나의 병목이 결정 → 다른 곳 최적화 무의미
- 양성 버전(강화 쪽)이지만 "한 점이 전체를 결정한다"는 구조 인식 동일

### 6. Progressive Collapse — Ronan Point 1968
- 런던 22층 아파트 한 모서리 가스폭발 → load-bearing wall 붕괴 → 모서리 전체 진보적 붕괴
- 구조공학 교과서 케이스
- 교훈: 결합 약한 구조에서 한 기둥 실패가 연쇄
- devil이 잡으려는 reasoning collapse 메커니즘과 동형

## 도입 검토 시 권장 페어

§Design rationale에 보조 프레임 추가한다면:
- **Clausewitz Schwerpunkt** (이론적 정당화) + **Samson** (상징·시각)
- CCT는 *방법론*으로 유지, 기둥-건물은 *이미지*로 보조
- 두 층이 부딪치지 않고 보완됨

## 미결정
- 추가 여부 자체는 보류. 현재는 메모만.
- 추가한다면 §Design rationale 내 한 단락 (5–8줄) 정도로 충분.
- 본문 §2 CCT 절은 건드리지 않음 — *방법*은 chess CCT가 그대로 정확.
