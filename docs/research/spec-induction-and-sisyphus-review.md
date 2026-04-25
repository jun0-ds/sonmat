# 스펙 귀납 스터디 + Sisyphus 재검토

> 시작: 2026-04-24 (larchive-gpu-prod)
> 상태: **Phase 2 research wave 완료 (2026-04-24)** — 생애주기 프레임(S0~S9) + 축 11(임기응변 정당성) 추가, 라이프사이클 풍부 8개 사례 조사 완료. Phase 3(Sisyphus RFC·AI 포팅 프로토콜 구체화) 대기.

## 0. 이 문서의 목적

AI가 "새로 만들기"와 "기존 고치기"는 잘하는데 **"기존 것을 다른 언어/매체에 재구현"** 할 때 자꾸 놓친다는 문제에서 출발. 논의를 타고 가다 "스펙을 잘 만들고 고치는 능력"이 핵심 레버라는 결론 → Phase 1에서 스펙 6개 전통 + 마스터 10여명 작업방식 귀납 → Phase 2에서 **스펙은 정적 artifact가 아니라 살아서 움직이는 프로세스** 라는 재인식 → 생애주기 프레임 + 임기응변(매뉴얼이 못 잡는 범위)을 중심축으로 재조직.

스펙 ≠ 소프트웨어만의 산물. 인류가 **의도를 매체·시간·사람을 건너 보존시키는 과제** 를 수천 년간 풀어온 결과물이 여러 갈래. 이 문서는:

1. 극단 사례에서 공통 축을 귀납 (11축)
2. 스펙을 시간상 움직이는 객체로 보는 생애주기 모델 (S0~S9)
3. 매뉴얼이 깨지는 순간과 임기응변·AAR·스펙 역류의 고리
4. Sisyphus 최신 설계를 위 3개 프레임으로 감사
5. AI 재구현 포팅 프로토콜로 역매핑

---

## Part 1. Sisyphus 2026-04-24 재검토

(2026-04-16 첫 검토 대비 변화 요약. `memory/domain/sonmat_portability_exploration.md` 참조.)

### 축 이동: 태스크 중심 → artifact 중심

> "the center is a controlled work world... Intelligence is allowed to act on that world, but it is not allowed to become the authority over that world." (`docs/architecture.md`)

- `TaskSpec` / `TaskRun` 분리 강제
- `Artifact` / `CompositeArtifact`, `VerificationArtifact`, `PromotionDecision` 1급 객체화
- **Hard state** (복구·검증·diff·승격) vs **Soft cognition** (계획·분해·요약·재시도) 법적 구분 — 지능은 soft에만

### Verification 3계층

local(내부 유효) / cross(관계 유효) / composite(합성 의무 충족). 상위가 하위에서 **함의되지 않음**.

### Reconstruction envelope

artifact = `payload` + `envelope`. envelope에 참여 자식, TaskSpec/Run, edge, composition rule, verification claim 전부 기록. 사후 재구성 가능.

### Invalidation precedes change

입력 바뀌면 → stale 먼저 계산 → 그다음 재검증/재조립/재계획/신규 change request 결정.

### Adaptive Planning Protocol

`design_mode: none/light/full` + `layer_impact: preserving/touching/reshaping/adding`. **스펙 깊이가 1급 결정**.

### Break / Cross / Ground

`philosophy.md`에 사고 discipline 명시 (sonmat 축 차용).

### Evolution 서브시스템 (read-only)

자기 작업 승인 금지, 스펙 freeze·promotion 금지, live repo change는 정상 lifecycle 필수.

### Conformance 신호등

green / yellow / red. 스펙-구현 편차 상시 노출.

---

## Part 2. 스펙 귀납 스터디

### Framework A. 분석 축 11개

| # | 축 | 내용 |
|---|----|----|
| 1 | Intent–Mechanism 분리 | 의도와 구현 레이어를 구조적으로 가르는가 |
| 2 | 경계 vs 내부 | 인터페이스만 고정 vs 내부까지 고정 |
| 3 | 예제 주도 vs 공리 주도 | 판례 누적 vs 공리 연역 |
| 4 | Modal 어휘 | 필수/권고/허용 강제력 계층이 언어로 구분되는가 |
| 5 | 해석층의 제도화 | 본문 옆에 권위 주석·도구 체계 |
| 6 | 개정 의례 | 고치는 절차 자체 명문화 |
| 7 | 검증 가능성 | 제3자 확인 가능 구조 |
| 8 | 실패 피드백 | incident가 다음 판에 역류 |
| 9 | 여백 설계 | 의도적 빈 공간 |
| 10 | 전달 매체 | 매체 속성이 수명·권위에 미치는 영향 |
| **11** | **임기응변 정당성** | **매뉴얼 밖 현장 재량이 기대·처벌 중 어느 쪽인가. 성공한 임기응변이 스펙에 역류하는 의례가 있는가. 실패한 임기응변이 처벌 없이 분석되는가** |

### Framework B. 스펙 생애주기 스테이지

스펙은 정적 artifact가 아니라 **시간상 움직이는 객체**. 각 스테이지에 전통마다 다른 강점·구멍이 있음.

| # | 스테이지 | 핵심 질문 | 이 단계에 강한 전통 |
|---|---------|----------|------------------|
| S0 | **Genesis** | 쓰기 전에 뭐가 있나? 필요가 어떻게 식별되나? | IETF BOF, USPSTF topic nomination, FMFM 1 commissioning |
| S1 | **Drafting** | 비권위 초안. 누가 쓰고 누가 보나 | `draft-individual-*`, PEP drafting, systematic review |
| S2 | **Ratification** | 권위 획득 의례 | IETF Last Call+IESG ballot, IPCC SPM line-by-line, ALI Restatement 통과 |
| S3 | **Operation** | 안정 권위 상태. 해석 요청·모호성 계속 발생 | RFC errata, 판례 citation, 임상 가이드라인 배포 |
| S4 | **In-flight amendment** | **권위 유지하면서 수정** (가장 빠지는 단계) | Common Law *distinguishing*, RFC `Updates:`, USPSTF 플립, 전투 중 부사관 재량 |
| S5 | **Branching** | 병행 버전 공존 | Linux stable/mainline, circuit split, Rust edition, 다국적 의료 가이드라인 |
| S6 | **Deprecation** | 살아있는 조항 죽이기 | `Updates:` via Historic, Python `DeprecationWarning`, Linux userspace ABI 불변 |
| S7 | **Supersession** | 후속자로 대체 | RFC `Obsoletes:`, *Brown v Board* 뒤집기, PEP 404 Python 2 종료 |
| S8 | **Reconstruction** | 전면 재구축 | Agranat 개혁, ALI Restatement Third, IETF IPR 정책 재작성, *Nature of Order* |
| S9 | **Archaeology** | 작성자 떠난 뒤 의도 재구성 | RFC 2555/8700 회고, 원전 비평, 법 해석사 — **AI 재구현이 여기 직격** |

**횡단 역학**: 스펙 ↔ 구현 비동기 / 스펙 ↔ 현실 비동기 / 스펙 ↔ 스펙 충돌 / 다자 협업 병합.

---

### Phase 1 — Canonical 6 cases

#### A. Talmud / Rabbinic 주석

Mishnah (Judah the Prince, ~200 CE) + Gemara + Rashi + Tosafot. 1523 Bomberg 인쇄판 레이아웃 500년 고정. **Judah the Prince**는 소수 의견을 명시적으로 보존 ("미래에 법이 바뀔 수 있으니"). **Rashi**는 구두점 부여·Old French 번역·일부 tractate 의도적 미주석.

Modal 어휘 풍부(*chayav / patur aval assur / mutar / reshut / middat chassidut*). 해석층(5) 극단 — 페이지 레이아웃이 해석 장치. 개정(6)은 **본문 불변 + append-only**. 여백(9): minority 의견을 미래 optionality로.

**유니크**: 패자 의견을 스펙에 남겨 **미래 조건 변화 대비**. 본문 불변 + 무한 주석 = 보수적·응답적 동시.

#### B. Auftragstaktik (Moltke/Scharnhorst)

*Truppenführung* (1933), Moltke *Instructions* (1869). "명령은 부하가 자력으로 결정 불가한 것만"; "작전 계획은 주력 조우 이후로는 확실히 연장되지 않는다" — **즉흥 가능한 상태로 군을 조우점에 데려가는 게 계획의 임무**. Scharnhorst Kriegsakademie(1810) — 암기 드릴 대신 판단 훈련.

Intent/Mechanism(1) 최강 분리. 해석층(5)이 **General Staff 자체** — 10년 훈련된 독자. 여백(9) load-bearing: "전쟁술은 규정으로 exhaustive 편찬 불가" §2.

**유니크**: 문서에 정밀도를 담지 않고 **독자 훈련에 투자**. 매칭 제도(Kriegsakademie) 없으면 위험한 모호함으로 변함.

#### C. TLA+ / Lamport

"Think, then code." 95%는 영어. 동시성·분산에서 TLA+로 escalate. 스펙=수학 공식, TLC/TLAPS로 기계 검증. "글이 곧 생각 — 글 없이 생각하면 생각한다고 생각할 뿐."

Intent/Mechanism **사다리**(같은 언어의 다른 고도). 공리(3) 극단. Modal(4) temporal(□/◇). 해석층(5) **기계화**. 검증(7) 최대.

**유니크**: 스펙이 기계 검증 가능 수학 객체. 사다리 발상 — intent/mechanism이 장르가 아니라 고도.

#### D. IETF RFC / Postel / Bradner

RFC 2119 두 핵심: (1) MUST/SHOULD/MAY 명명 (2) **자기 한정** — "상호운용 필요 시에만, 구현 방법 강요 금지". RFC 8174: uppercase만 해당. **RFC 9413 (2023)**: 20년 deployment 경험이 Postel 관대 수용 원칙을 비판 — 스펙 전통이 자기 격언 수정.

Postel: 품질 기준 안 맞으면 공개 거부, WG 교착 시 arbitrate. Bradner: 의미 발명 안 하고 관행 consolidate + 자기 한정 clause.

Modal(4) 대표 강축. 해석층(5) errata DB 3단. 개정(6) `Updates:`/`Obsoletes:` 체인. 검증(7) **2+ 독립 구현체 interop** 요구.

**유니크**: 타입드 imperative + 외부 검증 게이트 쌍. 본문 불변 + 메타데이터 체인 = 결정 이력 숨기지 않음. 창시 격언도 normative 수정 가능.

#### E. Toyota A3 / Ohno / Shook / Deming

A3 한 장(11×17). **Ohno 초크 원 그리기** — 엔지니어를 원 안에 몇 시간 세워 "뭘 봤냐" 반복. 표피적 답 거절. Shook: A3는 대화 구실, deliverable 아님. Deming: PDCA → PDSA ("Check"→"Study"). **Nemawashi**: hanko 거꾸로 찍는 의례화된 반대.

해석층(5) 극강 — Toyota Kata 5개 coaching 질문. 여백(9) 극강 — **A3 한 장 제약**. 매체(10) 제약 = 본질 — 팩스 통과 최대 + 연필.

**유니크**: **제약이 곧 스펙**. 좋은 포맷은 "속이는 게 생각하는 것보다 비싸야 함". artifact는 리뷰 의례와 분리되면 가치 없음.

#### F. Christopher Alexander

253 patterns. name + **★ 신뢰도** + context + "Therefore:" + solution + resulting context. **Eishin Campus**(1982-1989): 1,200시간 인터뷰, 현장 말뚝·깃발로 배치 반복, full-scale soft mockup. **자기 부정** OOPSLA 1996: "패턴은 *sequence* 를 담지 못한다" → *Nature of Order* 25년 재구축.

"Therefore:" = conjecture. 별점 = epistemic honesty 장치. 해석층(5) 상위/하위 패턴 네트워크. 여백(9) 관계적 제약만.

**유니크**: (1) 스펙 유닛이 자기 적용 조건 + 인접 유닛 명시 — 의미는 관절에 산다. (2) confidence marker 부착. (3) 카탈로그만으론 부족 — 순서 없이는 whole을 못 만듦.

---

### Phase 1 extras — 역사적 마스터 5인

- **Euclid** *Elements*: 6부 구조(enunciation → setting-out → definition → construction → proof → conclusion). **front matter의 타입 분리**(definition / postulate / common notion) — 전제도 타입을 갖는다.
- **Brunelleschi**: 문서 없음. 템플릿 + plumb bob + herringbone 벽돌. **전역 계획 숨김, 실행 시점 투명성**. 스펙이 "도구"일 수 있음 — 컴파일아웃된 스펙.
- **Leonardo**: ~7,000장 Codex. 거울문자, 도해+텍스트 공존, **끝내 출판 정리 안 함**. un-promoted 스펙 — 전달보다 포획 최적화.
- **Newton** *Principia*: 8 Definitions → Scholium → 3 Axioms → 3 Books. **제시=기하, 유도=fluxion**. General Scholium = 사후 해석 패치. normative vs Scholia 타이포그래픽 분리.
- **Stradivari**: 12 몰드 + 350 템플릿, 텍스트 없이 변이는 새 몰드로 등록. 물리 artifact 스펙 = **치수 완벽, 절차 없음** — 바니시·세팅이 공방과 함께 소실.

**교차 관찰**: 3/5인이 load-bearing 정보를 숨김. 낯선 사람 전달 의도는 Euclid/Newton만 — 동일 구조적 움직임(타입드 preamble → 증명 체인). Euclid 외 모두 도해+텍스트 통합.

### Phase 1 extras — 현대 CS 마스터 5인 (Lamport 제외)

- **Dijkstra**: Montblanc 만년필 EWD 손글씨 **교정 없이 1회 완성**. `wp(S,Q)` = 프로그램·증명 **공동 유도**. "테스트는 인식론적 양보."
- **Knuth**: WEB — 1 source → Pascal + typeset 책. **스펙 = 프로그램**, 사람 위해 linear 재조직. 오류 로그 850+ 항목 15 카테고리. 현상금 $2.56 hex dollar → Bank of San Serriffe 가공 증서.
- **Parnas**: A-7E OFP 재사양. **condition/event/mode-transition 표**. "likely changes를 모듈 경계 뒤로" — module guide는 **결정 encapsulation inventory**.
- **Brooks**: **conceptual integrity** — 단일 architect + **원칙적 거절**이 저술만큼. *No Silver Bullet*: essence vs accident.
- **Meyer**: `require`/`ensure`/`invariant` **언어 구문화**. 상속 시 pre 약화만, post 강화만 — Liskov 기계화. 스펙이 **코드 안에**.

**교차 관찰**: 조기 코딩 적대감 보편. **독자가 1급 시민**. 수학적 추론이 척추. 각자 개정 의례 소유. 매체가 load-bearing.

---

### Phase 2 — 라이프사이클 풍부 8 cases

#### Ω1. WWII Wehrmacht — Auftragstaktik 전투 검증 (전쟁)

Phase 1 doctrine 버전을 **실제 사례로 결박**. 핵심 발견: **임기응변 정당성이 rank 고도 따라 깨짐**.

**Eben-Emael (1940.5.10)** — 85명 글라이더 요새 점령. Witzig 중위 글라이더 tow-rope 끊어져 60km 뒤. **Feldwebel Helmut Wenzel**이 책에 없던 3가지 결정: (1) 장교 없이 지휘 장악 (2) Hohlladung 재할당(9 vs 11 squad) (3) 요새 장악 전에 "Objekt in unserer Hand" 송신해 Stuka 지원 유지. 성공 후 Witzig 도착(08:30), Wenzel 재할당 유지. **이틀 뒤 Ritterkreuz 수여**. Gefechtsbericht → *Merkblatt 151/4 Der Fallschirmjäger* 재작성. "designated redundant command" 원칙 박힘.

**Stalingrad (1942.11-1943.2)** — 역전된 경우. Hitler Haltebefehl(1942.11.24)로 Paulus 탈출 금지. Seydlitz-Kurzbach 11.25에 탈출 독단 권고 memo, Paulus 거부. **Manstein도 Führer 명령에 법적 근거 없다며 명령 안 함** (전후 *Verlorene Siege* 자기 변호). Stalingrad 낙하 후 **AAR 금지** — Hitler가 Kritik 불허. 이 실패 모드가 **말할 수 없으므로** 교본 수정 불가.

**계층표**:

| 고도 | 임기응변 → AAR → 스펙 역류 | 상태 |
|------|---------------------------|------|
| 분대·소대 (Wenzel) | 수 주 만에 Merkblatt 수정 | 건강 |
| 연대·사단 (Guderian 1940 Sedan) | 본인 사임 담보로 관철 | 긴장 |
| 군집단 (Manstein Sichelschnitt) | 히틀러 우회로만 | 깨짐 |
| OKH/OKW (Stalingrad) | AAR 억압, 교본 수정 불가 | 사망 |

**교훈**: 스펙 amendment 고리는 **제도가 허용하는 고도에서만 살아있음**. 그 이상은 스펙이 죽는다.

#### Ω2. USMC FMFM 1 *Warfighting* + Boyd OODA (전쟁)

General Al Gray 1987 위임, Captain John Schmitt 저술. **91쪽** (cf. FM 100-5 192쪽). **매뉴얼이 임기응변을 명령한 드문 사례**.

**텍스트 장치 6가지**:

1. **Modal 대체** — 원칙에 "shall/must" 거의 안 씀. "is/requires/demands". 의무를 세계 묘사로 프레이밍.
2. **Aphorism as carrier** — "War is a clash of opposing wills." 짧은 경구는 under-specified by design.
3. **Mission tactics 명명** — "senior tells *what to do and why* but not *how*"
4. **Error valorization** — "errors by junior leaders stemming from overboldness are a necessary part of learning. We should deal with such errors leniently." 스펙이 **임기응변 실패를 사전 사면**.
5. 4장 ~20쪽씩, 표·체크리스트·부록 0개. 한 번에 읽히는 분량.
6. Hemingway-length 문장.

**Boyd *Destruction and Creation* (1976)**: Gödel + Heisenberg + 열역학 2법칙 → 닫힌 형식 시스템은 현실과의 mismatch 누적 → 지속적 destruct/create. **OODA loop = tempo**. Boyd는 **공개 출판 거부** — 6시간 briefing만 허용(정지된 문서로는 dialectic이 못 산다). FMFM 1은 **Boyd가 글로 쓰지 않은 것을 글로 쓰는 역설** — aphorism이 open-endedness 모방.

**훈련 연동**: TBS 개편, TDG(tactical decision games) 핵심 교육법 — **school solution 없는 시간 제한 시나리오**. *Marine Corps Gazette* 매월 TDG 복수 정답 게재. Gray가 초급 장교(Schmitt)에게 capstone doctrine 쓰게 한 것 자체가 승진 신호.

**실전 검증**: 1st MarDiv 2003 Iraq (Mattis) — "Be polite, be professional, but have a plan to kill everybody you meet" 3줄 mission order. Fallujah 2004 counter-insurgency에선 균열.

**유니크**: 문서가 improvisational culture를 성공적으로 전달한 **드문 사례**. 텍스트 features + TDG 훈련 + 인사 신호 3각 조합.

#### Ω3. Yom Kippur 1973 → Agranat Commission (전쟁, S8 극단)

**Conceptzia**: "이집트는 공군 장거리 타격력 확보 전엔 공격 안 함, 시리아는 단독 공격 안 함" — 정식 doctrine 아니지만 Aman의 **해석 필터**로 작동. 1973.4 Blue-White alert에서 공격 없자 Zeira가 "입증"됐다며 재강화 — **null 이벤트를 가설 증거로**. 10.3 Siman-Tov 중령의 반대 memo는 상관 Bandman 선에서 매몰.

**S4 in-flight**: 10.9 Southern Command에서 무질서 재편, Bar-Lev를 Gonen 위에 **형식 절차 없이** 삽입.

**Sharon 수에즈 도하 (10.15-16)**: 10.9에 봉합선 식별, 10.12부터 즉시 도하 주장 → Gonen/Bar-Lev 거부 → 10.15 작전 *Abiray-Lev* 인가. Sharon 구체 불복종: (1) 회랑 미확보 상태에서 Matt 공수단 도하 (Chinese Farm 피 흘림), (2) Ismailia 북쪽으로 교두보 확장(명령은 남쪽), (3) 무단 언론 브리핑(머리 붕대 사진).

**사후 처리 양면**: Agranat은 Sharon 제재 없음(조사 고도 아래). Elazar 미공개 증언에서 **"군법회의 경계선"** 언급. 작전 성공으로 기소 정치적 불가능. 축 11의 **암묵 정당성** — 공식 합법화도 처벌도 불가, 침묵 판례.

**S8 재구축 구체물**:

1. Aman *Yechida le-Bikoret*(Control Unit) 신설 — 평가 감사
2. **Ipcha Mistabra** 절차 공식화 — 소수의견을 PMO 보고 시 **반드시 전달** 의무. "tenth man 룰"은 이후 신화화, 실제는 revision memo 절차
3. Mossad·외교부 독립 국가 추정 권한 — Aman 독점 해체
4. CoS가 Aman 가공 말고 **raw alert data 직접** 받도록 재구조화
5. 기갑 doctrine 재작성(Tal, Adan) — 기갑대 보병 task force, Merkava 가속

**2023.10.7 재발**: 8200부대 "Jericho Wall" 문서(2022-23) 소수의견 → 고위 평가에서 여과. **절차는 남았으나 senior override 재출현**. Kuperwasser(2023) 분석: 절차적 reform은 **문화적 전제 없이 공동(空洞)화**.

**유니크**: S8 재구축 후에도 **cultural prerequisite 없으면 hollowing out** — 인식(cognition)에 관한 스펙은 지속 재비준 필요.

#### Ω4. Aviation CRM post-Tenerife (비상 대응)

**Tenerife 1977.3.27 CVR**: Van Zanten(KLM 수석 교관, 안전 광고 모델) takeoff 진행. F/O Meurs "Wait a minute, we don't have an ATC clearance." → Van Zanten "No, I know that. Go ahead, ask." → Meurs 비표준 phrasing "We are now at takeoff" (준비 vs 진행 모호). F/E Schreuder 충돌 직전 "Is hij er niet af dan?" → Van Zanten "Jawel." 강조. **F/O와 엔지니어 둘 다 의심 있었고, 매뉴얼상 거부 권한 있었으나 문화적 허가 없음** — 축 11 런타임 실패.

**NASA Ames 1979 CRM workshop** (Lauber, Foushee): cockpit을 소집단 심리 문제로 재프레임. 1981 UAL 첫 CRM 프로그램. 1989 FAA AC 120-51(현 120-51E)로 규제화. 14 CFR 121.404 (1995) 의무화.

**핵심 런타임 artifact** (추상이 아니라 실제 구문):

- **Two-Challenge Rule**: 2회 이의에 응답 없으면 PIC 무능력 전제, 통제권 인수 의무
- **CUS words**: "I'm **Concerned**" / "I'm **Uncomfortable**" / "This is a **Safety** issue" — captain 인정 의무 트리거 토큰
- **Standard assertive**: "Captain, you must listen" (Delta·UAL·BA SOP)
- **Sterile Cockpit** 14 CFR 121.542 — 10,000 ft 미만 비본질 대화 금지
- **Standard callouts**: "V1"/"Rotate"/"Positive rate"/"1000 to go"/"Minimums → Continue/Go-around" — **침묵 자체가 이상 신호**
- **Monitored approach** (BA/KLM 사후): F/O 조종, Captain 감시·land/go-around 결정 — 최종 권한 재분배

**Helmreich 6 세대 진화**: Gen1 성격심리 → Gen2 team dynamics+LOFT → Gen3 자동화·조직 문화 → Gen4 AQP·LLC 행동 평가 → Gen5 **error management** → Gen6 **TEM** (Threat and Error Management, LOSA).

**S8 기계**: ASRS(NASA, 1976) **비처벌 confidential** — 10일 내 신고 시 대부분 면책. ASAP 3자(항공사/FAA/노조). FOQA 익명 비행 데이터. LOSA peer 관찰. 피드백 루프: 신고 → NASA Callback → 항공사 안전 bulletin → 다음 LOFT 시나리오 → 재훈련.

**임기응변 성공이 스펙 역류**: UAL 232(1989) 유압 완전 상실, throttle-only 제어 → UAL LOFT 시나리오 편입. US Airways 1549(2009) Sullenberger가 QRH 순서 override → Airbus checklist에 즉시 착수 분기 추가. QF32(2010) de Crespigny **inverse logic** ("작동하는 것에서 역추론") → Airbus/Qantas non-normal 훈련 자료 편입.

**Asiana 214 (2013)**: CRM 형식 있었으나 **instructor pilot이 오른쪽 좌석, 승격 중 captain 감독 중** — 정상 seniority gradient 뒤집혀 challenge 마비. 카고-컬트 CRM — 스펙은 있으나 cultural substrate 부재.

**유니크**: 임기응변 **protocol 자체를 스펙에 박음**. 구체 문구, 의무 escalation, 비처벌 신고, 실패+성공 시나리오를 지속 LOFT로. "Legitimacy of improvisation이 trained, callable subroutine이 됨 — with its own syntax. Tenerife는 그 null pointer."

#### Ω5. IETF RFC 풀 라이프사이클 (시빌리언 기술)

S0~S9 전 구간 문서화. Phase 1에서 다룬 RFC 2119/Postel과 중복 없음.

- **S0 Genesis**: 메일링 리스트 불만 → I-D (`draft-<author>-<topic>-00.txt`, 6개월 만료) → **BOF** (RFC 5434 네 조건: 문제 명확, 스코프, 구현자, 기존 WG 부재) → WG charter. QUIC 2016 Berlin BOF 성공, HTTPBIS 2012 re-charter는 BOF 없이.
- **S1 Drafting**: `draft-individual-*` → **WG adoption call** → `draft-ietf-*`. TLS 1.3은 `draft-rescorla-tls13-00`(2014.4)으로 시작, 28판 후 RFC 8446 공표(2018).
- **S2 Ratification**: WG chairs consensus call → IETF Last Call (4주) → IESG evaluation → AD ballot (Yes/No Objection/**Discuss**/Abstain/Recuse). Discuss 1건이 publication 차단. RFC 7282(Resnick 2014): **rough consensus = 기술적 반대 addressed, 만장 아님**. hum은 voting 아니라 sampling.
- **S3 Operation**: **RFC 불변**. errata DB 4단(Verified/Held/Rejected/Reported). "Held for Document Update"는 "틀렸으나 errata로 못 고침 — 새 RFC 필요" 신호.
- **S4 In-flight amendment**: `Updates: NNNN` 메타데이터. **TCP RFC 793**이 `Updated by` ~12건 (RFC 1122, 3168 ECN, 6093, 6528, 6691, 7323, 7414 로드맵...). 2020년 현재 TCP 스펙을 찾으려면 ~20개 문서 재구성 필요.
- **S5 Branching**: 4 streams — IETF / IAB / IRTF / Independent Submission (RFC 8729).
- **S6 Deprecation**: **RFC 6410** (2011)이 3단 → 2단 축소 (Proposed → Internet Standard, Draft Standard 폐지) — **IETF가 자기 프로세스 실제 사용 관찰해 법제화**. Historic status 전환: RFC 6176 (SSLv2), 7568 (SSLv3), 8996 (TLS 1.0/1.1).
- **S7 Supersession**: **RFC 9293** (2022) = TCP 통합판. `Obsoletes: 793, 879, 2873, 6093, 6429, 6528, 6691`. **9년 작업 28판**. HTTP: 1945 → 2068 → 2616 → 7230-7235 → 9110-9114. 각 단계 명시 체인.
- **S8 Reconstruction**: IPR 정책 3978 → 5378 → 8179. "pre-5378 problem" — 2008 이전 저자가 당시 없던 권한을 나중에 승인 못 함, 새 draft에 boilerplate disclaimer 필수.
- **S9 Archaeology**: RFC 2555(30주년) / 8700(50주년) 회고 모음. Datatracker 문서 history(~2005부터 풀 커버), 메일 아카이브, Scott Bradner plenary talks(구전).

**축 11 — "running code"**: David Clark 1992 plenary "kings, presidents, voting 거부. rough consensus and running code 신봉." **구현이 본문보다 선행·이탈, 본문이 따라감**. CORS/WebSockets가 사례 — 브라우저 벤더가 ship 후 RFC가 ratify. **정당한 임기응변의 규칙**: 구현자가 **작동 코드 + interop 증거 + draft 작성·수정 의사** 가져와야. 침묵 이탈은 불법(RFC 8890/9170 ossification 논의).

**유니크**: 10단계 전부 공개 문서화된 **유일한** 기술 스펙 시스템. RFC 9413이 자기 창시 격언(Postel)도 수정 — **자기 비판이 normative**.

#### Ω6. Common Law 판례 진화 (법)

- **S0 Genesis**: 예외적 사실 패턴 → 법정이 사건 필요보다 넓은 원칙 진술. *Pierson v. Post* (1805) Tompkins J가 Justinian/Bracton/Pufendorf 동원해 "추격만으론 재산권 없음" 즉흥 (Simpson: 로마법 복장은 장식, 진짜 엔진은 judicial instinct + ex post 학식).
- **S2 Ratification**: 상급심 확정 + cert 거부 + **자매 법원 인용**. Llewellyn: 첫 인용이 ratification.
- **S4 In-flight — *distinguishing***: **signature 기제**. *Winterbottom v. Wright* (1842, privity 규칙) → *MacPherson v. Buick* (1916, Cardozo) — 명시적 overrule 대신 예외 누적으로 **규칙을 껍데기만 남김**. Schauer: "narrowing construction — 규칙은 문서상 살지만 적용 범위는 0으로 수축." *Miranda* (1966) → *Quarles* (1984, 공공 안전) → *Elstad* (1985) → *Berghuis* (2010, 침묵 = 묵시 포기): 누적 distinguishing으로 교리 후퇴.
- **S5 Branching**: circuit splits, *Erie R. Co. v. Tompkins* (1938) — 연방 일반 common law 폐지, 50주 fragmenting.
- **S6 Deprecation**: "stale" 판례 — 기술적 구속력 있으나 인용 안 됨. *Lochner*-era substantive due process (1905-1937).
- **S7 Supersession**: *Casey* (1992) 4 stare decisis 요인 — (1) workability (2) reliance (3) doctrinal coherence (4) factual underpinnings. *Brown v Board* (1954) overruling *Plessy* (1896). *Lawrence* (2003) overruling *Bowers*. **Dobbs (2022)** overruling *Roe*/*Casey* — Alito가 *Casey* 요인을 *Casey* 본인에게 역적용: "egregiously wrong" 등. *Dobbs*는 최근 S7 기제 명시 사례 — 모든 *Casey* 요인을 기록에서 litigation.
- **S8 Reconstruction via Restatement**: ALI (1923~) — 보고자 편찬, ALI 회원 프로세스. 법 아닌 설득적 권위. *Restatement (Third) of Torts* (2010)는 *Second* §402A 폐기, risk-utility 프레임워크. 주기 40-60년.
- **S9 Archaeology**: Blackstone *Commentaries* (1765-69), Coke *Institutes* (1628) — 원전주의(originalism) 시 필요. *Heller* (2008) Scalia가 18세기 총기법 고고학.

**축 11**: common law 전체가 **judge-made**. improvisation legitimacy 최상. Scalia(originalism) vs Breyer(purposivism) 논쟁 = **improvisation 허용 폭**. 사후 평가 — *Marbury*(1803) 무에서 judicial review 창조는 영웅화, *Lochner*/*Dobbs*는 동일 기제로 비판받음.

**영국**: *Practice Statement* [1966] — House of Lords가 자기 선례 거부 가능 선언. *London Tramways v. LCC* [1898] 이래의 절대 구속 파기. S7 역량이 **1966에야 제도화됨**.

**유니크**: 규칙을 명시적으로 뒤집지 않고도 **distinguishing으로 hollow out** 가능. 축 6 개정 의례에 **"형식적 폐기 없이 실질 폐기"** 경로 존재.

#### Ω7. Software spec evolution — SemVer / Python PEP / Linux kernel (시빌리언 기술)

**세 철학의 breaking change 처리**:

| | 처리 방식 | 제약 위치 |
|---|---------|----------|
| **SemVer** | MAJOR 범프 + 문서화 | caller에 부담 |
| **Python** | `DeprecationWarning` 2 릴리스 + PEP | author에 부담 |
| **Linux** | userspace ABI **절대 불변** (Torvalds 2012 rant "WE DO NOT BREAK USERSPACE"), 내부 API는 자유 | **경계 기준 비대칭** |

**Python 2→3 (2008-2020, 12년 S7)**:
- PEP 3000 (2006): "cleanup release", 5년 예상
- 2014 PEP 466: 보안 기능 3에서 2.7로 **역전 backport** (S7 누수)
- 2014 PEP 373: 2.7 EOL 2020 연장
- **PEP 404 (2015)**: "Python 2.8은 존재하지 않을 것이다" — 명시적 **closure ceremony**, fork 저지
- 2020 EOL
- **RHEL 7 zombie 2024까지**

교훈: 실패 원인은 C-extension 생태계 관성. `six`/`python-future`는 비공식 **보상 improvisation 레이어**. 성공 원인은 **PEP 404의 closure 의례** — 없었으면 Perl 5/6 파국.

**Rust editions**: 3년 주기 breaking change 번들 opt-in(2015/2018/2021/2024). 옛 crate는 자기 edition으로 영원히 컴파일. **S5 lossless branching** — 누구도 버리지 않되 진보 가능.

**Go 1 compat promise**: 반대 극 — 스펙 동결, Go 2 10년째 안 나옴, breaking은 `go.mod` version으로 숨김.

**임기응변(축 11)**:

- **CSS 벤더 prefix** (-webkit-): improvisation이 de facto standard화 → W3C 2016 prefix 모델 폐기(override 인정)
- **jQuery → querySelector**: DOM에 jQuery idiom 흡수 (W3C Selectors API 2013)
- **Android/RHEL kernel backports**: 준(semi) 포크, **userspace 불변 + upstream 패치**로 정당성
- **PyPy**: 합법 fork, CPython test suite 통과
- **async/await PEP 492**: Twisted/Tornado coroutine improvisation을 **구문으로 ratify**

**실패 피드백(축 8)**:

- Heartbleed CVE-2014-0160 → LibreSSL/BoringSSL/rustls/s2n — **구현 문화 변화**, 스펙 자체 아님
- npm **left-pad** (2016): Azer Koçulu unpublish로 수천 빌드 파괴 → npm 24시간 후 unpublish 금지 정책 **S6/S8 policy patch forced**
- Linux regression = bug, `git bisect` (2007) — archaeology 도구 toolchain에 embedded
- Google SRE postmortem template — 재사용 가능 S8 artifact

**유니크**: **경계 비대칭**(Linux userspace vs 내부). **closure ceremony 부재 = 좀비 비용 무한**(Python 2.7 2020→2024). **SemVer는 얇은 문법, caller에 부담**; PEP는 두꺼운 프로세스, author에 부담.

#### Ω8. Evidence-driven amendment — 의료 가이드라인 + IPCC (과학)

**PSA 플립 (S4/S7 사례)**:
- 2008: USPSTF **I** (<75) + **D** (≥75)
- 2012: **D** 전연령. PLCO (NEJM 2009, mortality benefit 없음) + ERSPC (NEJM 2009, 11년 추적 1/1000 이익 vs 100-120/1000 과치료 해악)
- 2018: 50-69 **C** (shared decision-making), ≥70 **D**. ERSPC 13년 추적(Lancet 2014) 지속 이익 + active surveillance로 해악 감소. AUA가 2012 D에 공개 반대 → **S5 분기** → 2018에 AUA 입장으로 부분 수렴

**HRT 플립**: WHI 2002.7 (JAMA) 중간 감시로 중단 → 18개월 내 **거의 동시 S4** 전 세계. 관찰 데이터 기반 기존 지침 반전.

**Aspirin CVD 1차 예방 (2016 B → 2022 C/D)**: ASPREE/ARRIVE/ASCEND 세 대규모 RCT에서 statin 시대에 출혈 해악이 benefit 상대적 초과.

**Modal 캘리브레이션 — IPCC (가장 엄격)**:

| Likelihood | Range |
|------------|-------|
| Virtually certain | 99-100% |
| Very likely | 90-100% |
| Likely | 66-100% |
| More likely than not | >50% |
| About as likely as not | 33-66% |
| Unlikely | 0-33% |

plus Confidence(very high/high/medium/low/very low) — **evidence strength와 agreement 분리**.

**Attribution 문구 긴장 변화**:
- AR2 (1995): "**balance of evidence** suggests a **discernible** human influence"
- AR4 (2007): **unequivocal** warming, 인류 영향 **very likely** dominant since 1950
- AR6 (2021): **unequivocal** 인류 영향 → hedge 삭제. 크기만 hedge 유지.

**IPCC S2 하이브리드 (유일)**: WG 챕터는 저자 소유(정부 negotiation 불가), 검토 comment에 문서화된 대응. **Summary for Policymakers만 line-by-line 정부 승인** — AR6 WG1 SPM 5일, WG3 50+시간. 저자가 "backstop": 챕터와 모순되면 문구 변경 거부. Hulme: 이 하이브리드가 정치적 durability의 비결. **과학은 협상 불가, 해석은 공동 소유**.

**축 11**: 의료 **clinical judgment 명시적 carve-out** — NICE "does not override individual responsibility of health professionals." IPCC는 spec 레벨 improvisation 없음(AR = consensus), 그러나 minority views는 (a) cited-but-not-endorsed 문헌, (b) confidence 축이 low-agreement flag, (c) AR 사이 개별 dissent 출판, (d) **1.5°C Special Report (2018)** 가 7년 주기 사이 **interim S4** — 시스템이 smaller product 인터리브 가능.

**축 8 self-validation**: AR6 WG1 Ch.1 Box 1.3이 AR1-AR5 projection 관측 비교. 중심 예측 broadly 검증, AR1 slightly high (가정 emission path 때문). **스펙이 cycle 간 자기 검증**.

**유니크**: 10진법 calibrated modality (cf. RFC 3단). **과학·정치 거버넌스 계층화** — ratification 정치 정당성 필요 + 기술 진실 비협상일 때 **문서 분리**.

---

### Phase 2 통합 매트릭스 — 생애주기 × 사례

●=강점 / ○=중간 / △=약함 / ✗=부재 / ?=데이터 부족

| | S0 | S1 | S2 | S3 | S4 | S5 | S6 | S7 | S8 | S9 |
|---|----|----|----|----|----|----|----|----|----|----|
| Talmud | ? | ○ | ● | ● | ● | △ | △ | △ | △ | ● |
| Auftragstaktik 전투 | △ | △ | △ | ● | ● | △ | △ | △ | ● (Kreta↓Stalingrad↑) | △ |
| FMFM 1 / OODA | ● | ● | ● | ● | ● | △ | ✗ | ○ | ● (1989 재구축) | △ |
| Yom Kippur/Agranat | ○ | ● | ● | △ | ● | △ | △ | ○ | **●** | ● (Kuperwasser 2023 재참조) |
| CRM/Tenerife | ● | ● | ● | ● | ● | △ | △ | ○ | **●** | ○ |
| IETF RFC | ● | ● | ● | ● | ● | ● | ● | ● | ● | ● |
| Common Law | ● | ○ | ● | ● | **●** (distinguishing) | ● | ○ | **●** | ● (Restatement) | ● |
| Software (SemVer+PEP+Linux) | ○ | ● | ● | ● | ● | ● | ● | ● | ○ | ○ |
| Medical + IPCC | ● | ● | ● | ● | ● | ○ | ○ | ● | ● | △ |

**가장 풍부한 사례**: IETF RFC (전 구간), Common Law, Software. 연구 깊이 가장 적절.
**S8 재구축 교훈 사례**: Agranat/CRM/Alexander → 세 케이스 공통 — **절차 재설계만으론 부족, 문화 substrate 필요**.
**S4 기제 다양성**: RFC `Updates:` (append) vs Common Law distinguishing (narrowing) vs CRM CUS words (runtime escalation) vs 의료 flip (evidence-driven reversal).

---

### 임기응변 × AAR × 스펙 역류 3단 고리

이 섹션이 스터디의 **가장 실용적 중심축**. Wehrmacht + CRM + Israeli AAR + FMFM 1이 공통으로 증명.

#### 고리의 구조

```
[매뉴얼 S3]  ──실전 투입──▶  [현실 불일치 발생]
                                    │
                                    ▼
                       [임기응변: 축 11 행위]
                                    │
                            ┌──────┴──────┐
                            ▼              ▼
                         [성공]          [실패]
                            │              │
                            ▼              ▼
                       [AAR: 기록·분석]
                            │
                            ▼
                   [판단: 반복 가치?]
                         ──YES──▶ [교본 amendment S4]
                         ──NO───▶ [폐기·태그]
```

#### 작동 조건 (4사례 공통)

1. **AAR이 처벌 없이** 일어남. Kriegsakademie *Kritik* "no school solution"; NTSB/ASRS 비처벌 immunity; Ipcha Mistabra memo 필수 전달. **실패를 이름 없이 기록** 가능해야 임기응변 legitimacy 유지
2. **임기응변에 syntax 제공**. CUS words 3개, FMFM 1 aphorism, common law "distinguishing" 언어. 바닥의 "재량" 만으로는 실행 불가 — **호출 가능한 subroutine**
3. **성공 임기응변의 스펙 역류 경로 명시**. Wenzel→Merkblatt 수주, UAL232→LOFT, Sullenberger→Airbus checklist. 경로 모호하면 학습 손실
4. **Rank-matched amendment 권한**. Wenzel은 Merkblatt 수정 가능한 고도 — Stalingrad는 Hitler가 AAR 금지하는 고도. 스펙 amendment는 **제도가 허용한 altitude에서만** 살아있음

#### 실패 양상 (4가지)

| 양상 | 대표 사례 | 무엇이 깨짐 |
|------|----------|------------|
| **AAR 억압** | Stalingrad Hitler | 실패 모드가 말할 수 없어 교본 수정 불가 |
| **Cargo-cult** | Asiana 214 CRM | 절차 있으나 문화 substrate 부재 |
| **Altitude mismatch** | Israeli 2023 Jericho Wall | 소수의견 memo는 살아있었으나 senior override 재출현 |
| **Syntax 부재** | Tenerife Van Zanten | F/O 권한 있었으나 challenge 언어 없음 |

#### 교훈

- "유능한 지휘관 + 뛰어난 매뉴얼" 이분법은 틀렸음. **쌍**으로만 작동
- 매뉴얼이 좋아도 지휘관이 얼면 실패, 지휘관이 좋아도 매뉴얼이 불필요 정밀 요구하면 발목
- **전쟁이 가장 많이 가르치는 이유**: 비용이 감출 수 없을 때 AAR·역류 의례가 강제됨. 평시 조직은 "매뉴얼대로 했다"며 실패 덮을 수 있음
- **배워야 할 것은 문서만이 아니라 문서 주변 행동 의례**. 부사관 Wenzel의 결정, Moltke의 Kritik, Ohno의 원 그리기, Postel의 품질 게이트 — 이게 스펙 주변 실행 리듬

---

### Phase 1+2 통합 Cross-cutting Patterns (16개)

**Phase 1에서 도출(8)**:

1. 여백(9)과 해석층(5) 쌍 — 여백이 크면 해석층 투자 커야 안전
2. 개정 의례(6) 두 양식 — append-only (긴 수명) vs 전면 재구축
3. Modal 어휘(4) 저비용 고효과, 단 **자기 한정** 핵심
4. 제약이 곧 스펙 (A3, RFC 72-col, Newton 기하)
5. 패자 의견 가시화가 재구현 맥락에 결정적
6. 해석층 위치: artifact / 도구 / 사람 — 사람만이면 그 사람이 떠나면 스펙이 죽음
7. 독자가 1급 시민
8. 스펙은 대화의 trace, deliverable 아님

**Phase 2에서 추가(8)**:

9. **Rank-matched amendment altitude** — 스펙 loop은 제도가 허용한 고도에서만 산다 (Wenzel vs Stalingrad)
10. **임기응변에 syntax 제공** — 바닥 재량은 부족, **호출 가능 언어** 필요 (CUS, aphorism, distinguishing)
11. **Closure ceremony 필수** — PEP 404 "2.8 will never exist"류 명시적 종료 없으면 좀비가 자원 흡수 (Python 2.7 2020→2024)
12. **Calibrated modal은 stakes에 비례** — IPCC 10진법 > RFC 3단 > USPSTF 그레이드 (스테이크에 맞게)
13. **Cargo-cult 패턴** — 절차 form만 있고 cultural substrate 없으면 공동화 (Asiana / Israeli 2023)
14. **Running code / facts-on-ground** — 임기응변의 합법 버전(CORS, jQuery→querySelector) — 단, 구현자가 interop 증거 가져와야
15. **자기 비판이 스펙 건강 지표** — RFC 9413이 Postel 수정, USPSTF PSA 플립, AR6가 AR2 hedge 제거. **창시 격언도 normative 수정 가능**해야 살아있음
16. **거버넌스 계층화** — IPCC 과학-챕터(저자) vs SPM(정부) 분리가 기술 진실 + 정치 정당성 동시 달성. ratification이 정치적일 때 문서 자체 분리

---

### AI 재구현 포팅 프로토콜 (역매핑)

라카이브 리빌딩 같은 "원본 → 신 구현" 태스크에 위 전통 교훈을 운영 프로토콜로 결합.

#### 포팅 세션 구조 (per module)

**0. Pre-port**

- 원본 모듈 S9(archaeology) 수행: git log, PR 코멘트, 관련 이슈, 원 저자 in-line 주석 발굴
- **Conceptzia 탐지**: 원본 설계의 load-bearing 가정 명시화 (Israeli 1973 교훈 — 암묵 가정이 스펙처럼 작동)
- Modal 타이핑 초안: 각 항목에 MUST/SHOULD/MAY + 자기 한정 (RFC 2119)
- ★ **신뢰도 마커**(Alexander 별점): 원본의 각 디자인 결정에 "확신 / 부분적 / tentative"

**1. Drafting (S1 equivalent)**

- 명시 스펙 문서 = **대화 trace** (A3). 혼자 쓰지 말고 AI와의 Q&A 대화를 함께 기록
- 거절된 대안도 명시 (Brooks "ledger of refusal", Talmud 소수의견)
- Intent와 Mechanism 분리 (Auftragstaktik) — "원본 알고리즘"이 아니라 "원본 계약·동작"

**2. Ratification (S2)**

- 테스트 정의 = **2+ 독립 구현체 interop 기준** (RFC 2026). 원본과 신 구현 동시 실행, trace diff
- **closure ceremony**: 이 모듈 스펙은 언제 "frozen"인가 명시

**3. Operation / In-flight amendment (S3/S4)**

- 구현 중 발견되는 mismatch는 **Gefechtsbericht 형식** 임기응변 로그에 기록:
  - 스펙이 못 잡은 것
  - 내 판단
  - 결과
  - 반복 가치 여부
- **CUS escalation**: "I'm Concerned / Uncomfortable / Safety issue" 가독성 있는 3단 flag
- 스펙 amendment는 `Updates:` 메타데이터처럼 **추가 문서**로 — 원본 frozen, amendment append (RFC 모델)
- **distinguishing vs overruling** 판단 (Common Law): 원본 스펙의 적용 범위를 좁혀 해결할지, 정식 supersession 할지

**4. AAR (주기별)**

- 모듈 완료 시 3단 리뷰 (Ohno 원 그리기): 현상 · 5 whys · 다음 반복 변경
- **비처벌 reporting**: "이걸 놓쳤다"를 처벌 없이 기록 (ASRS 모델)
- 성공한 임기응변 → 스펙 역류 여부 판정

**5. Promotion (S7)**

- 신 구현이 원본을 **obsoletes** 할 준비인지 판정 — Casey 4 요인 (workability / reliance / coherence / factual) 유사 체크
- 좀비 방지 closure: 원본 sunset 일자 명시 (PEP 404)

#### 이 프로토콜이 기존 스펙 리스트와 다른 점

| | 기존 스펙 리스트 | 이 프로토콜 |
|---|----------------|----------|
| 스펙 성격 | 정적 checklist | 살아있는 artifact chain |
| 임기응변 처리 | 암묵, 기록 안 됨 | **명시 log + AAR + 역류 판정** |
| 모호성 | 존재만 함 | **Modal 타이핑 + 신뢰도 마커** |
| 변경 | ad hoc | **closure ceremony + Updates/Obsoletes 메타** |
| 신구현-원본 비동기 | drift가 조용히 쌓임 | **interop trace diff + Conceptzia 감사** |

---

## Part 3. Sisyphus × Phase 2 귀납 대조 (재평가)

### 11축 매트릭스

| 축 | Sisyphus | 평가 | Phase 2 기반 확장 |
|-----|---------|------|-----------------|
| 1. Intent/Mech | hard/soft 분리 | 강 | TLA+ "사다리" 차용 |
| 2. 경계/내부 | TaskSpec vs TaskRun | 강 | Parnas module guide 추가 |
| 3. 예제/공리 | VerificationArtifact 둘 다 수용 | 중 | Gherkin/BDD example row 승격 |
| 4. Modal | conformance 3단 | **저** | **RFC 2119 + 자기한정 + IPCC calibrated — 조항 단위 MUST/SHOULD/MAY 타이핑** |
| 5. 해석층 | envelope | 강 | Alexander 별점 → claim 단위 confidence |
| 6. 개정 의례 | design_mode + promotion | 중 | **RFC `Updates:`/`Obsoletes:` 메타 모델 — 결정·소수의견·거절 1급 artifact** |
| 7. 검증 | 3층 + evidence | 강 | AWS 수준 formal method 훅 + **2+ interop** |
| 8. 실패 피드백 | invalidation precedes change | 강 | **비처벌 ASRS 모델 reporting + Brooks refusal ledger** |
| 9. 여백 설계 | `design_mode: none` | 명시 | Auftragstaktik "의도만, 기제 자유" 모드 강화 |
| 10. 매체 | 파일 퍼스트 md+json | 적합 | A3식 **분량 제약** 실험 |
| **11. 임기응변 정당성** | **미구현** | **공백** | **Improvisation Log artifact 추가, CUS escalation, AAR 의례 강제** |

### 생애주기 스테이지별 Sisyphus 커버리지

| 스테이지 | Sisyphus 현재 | 구멍 |
|---------|--------------|------|
| S0 Genesis | `request` 명령 | trigger 근거 기록 부재 |
| S1 Drafting | TaskSpec 작성 | 대안·거절 이력 미기록 |
| S2 Ratification | `plan freeze` | **interop 증거 요구 없음** |
| S3 Operation | conformance 상시 | OK |
| S4 In-flight amendment | invalidation | **distinguishing/Updates 기제 부재** |
| S5 Branching | git worktree | 브랜치 간 spec 관계 미추적 |
| S6 Deprecation | (없음) | **deprecation 의례 부재** |
| S7 Supersession | PromotionDecision | **closure ceremony 미강제** |
| S8 Reconstruction | adaptive planning | OK (design_mode `full`) |
| S9 Archaeology | envelope + task docs | envelope 잘 돼있으나 **Conceptzia(암묵 가정)는 미잡음** |

### 핵심 구멍 (Phase 3 RFC 후보)

1. **RFC: Modal calibration in TaskSpec clauses** — 각 스펙 조항에 `modality: must / should / may / info` + `self_limit: interop | harm_limit | ...` + `confidence: star1 | star2` (RFC 2119 + IPCC + Alexander 혼합)
2. **RFC: Improvisation Log artifact type** — 구현 중 발견된 mismatch, 판단, 결과, 역류 여부. Wenzel Gefechtsbericht 디지털 버전
3. **RFC: Amendment chain metadata** — `updates: <artifact-id>` / `obsoletes: <artifact-id>` / `distinguishes: <clause-id>` 관계 1급화
4. **RFC: Closure ceremony requirement** — deprecation/promotion 시 sunset 일자·fork 저지 선언 필수 (PEP 404 모델)
5. **RFC: Conceptzia audit** — 설계 시 "암묵 가정" 섹션 요구. 가정 명시 안 하면 promote 불가 (Israeli 1973 교훈)
6. **RFC: Non-punitive incident report** — 실패·임기응변 실패를 처벌 언어 없이 기록하는 별도 artifact type (ASRS 모델)

---

## Phase 3 계획

1. **Phase 3 RFCs 작성** — 위 6개를 Sisyphus 리포에 PR 제안으로 구체화
2. **sonmat discipline 업데이트** — Phase 2 insights를 `discipline/core.md`에 feed (특히 축 11, 임기응변 loop, Conceptzia 감사)
3. **devil skill 업데이트** — 프로젝트 본질성 필터 이식 (별도 작업)
4. **라카이브 리빌딩 파일럿** — 위 포팅 프로토콜을 실제 모듈 1개에 적용, 결과 측정
5. **추가 사례 후보** (필요 시): FAA AD + NASA SWE 안전 critical, 한국 헌법 개정 사례, Gherkin/BDD schema evolution

---

## 작업 기록

- **2026-04-24 larchive-gpu-prod 회차 1**
  - 문서 개설, Sisyphus 04-24 재검토
  - Phase 1 seed (LLM 내부 지식): 6 canonical + 매트릭스 초벌
  - Phase 1 research wave (8 agent 병렬): 6 canonical + 2 master survey 1차 자료 기반 완료
  - 매트릭스 근거 재작성, 8 통합 관찰

- **2026-04-24 larchive-gpu-prod 회차 2**
  - 준선생 지적: "스펙 변경 상황 = end-to-end 관점 피할 수 없음" + 매뉴얼/임기응변 프레이밍
  - Framework 확장: 축 11 임기응변 정당성 추가, 생애주기 S0~S9 모델 도입
  - Phase 2 research wave (8 agent 병렬): WWII Wehrmacht / USMC FMFM 1+OODA / Yom Kippur-Agranat / CRM-Tenerife / IETF full lifecycle / Common Law evolution / Software evolution / Medical+IPCC. 모두 1차/권위 2차 자료 기반
  - 임기응변 × AAR × 스펙 역류 3단 고리 섹션 독립
  - AI 재구현 포팅 프로토콜 역매핑
  - Sisyphus 11축 + 10스테이지 커버리지 감사 → RFC 후보 6개 도출

- **다음**: Phase 3 — Sisyphus RFC 6개 구체화, sonmat discipline feed, devil skill 프로젝트 본질성 필터, 파일럿 적용

## 메모

- 이 문서는 sonmat discipline 설계에 직접 feed. 귀납 원리가 `discipline/core.md`·훅·skill의 근거
- `memory/domain/sonmat_portability_exploration.md`의 Sisyphus 항목은 04-16 스냅샷. 이후 변화는 이 문서가 최신
- Phase 1+2 research wave 16개 agent raw output은 task output 디렉토리 보존 (context 용량 문제로 직접 참조 금지, 본 문서가 canonical summary)
- 준선생의 "반박을 위한 반박" 관찰 — devil skill이 프로젝트 본질성 필터 없이 동작하는 문제. **축 11 + 프로젝트 essentiality + 스펙 생애주기 프레임**을 devil discipline에 녹이는 작업이 별도로 진행됨
