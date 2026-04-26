# 건축 방법론과 스펙 discipline — Phase 3 research

> 시작: 2026-04-26 (larchive-gpu-prod)
> 상태: **5 agent research wave 완료**. 통합·sonmat 적용 후보 도출.
> 컴패니언: [spec-induction-and-sisyphus-review.md](spec-induction-and-sisyphus-review.md), [glossary.md](glossary.md), [hunsugun-identity.md](hunsugun-identity.md)

## 0. 이 문서의 목적

v0.11.0 + 14 ADR 점검 결과 sonmat에 빠진 것 명확:

- **스펙이 자동 실행되지 않음** — sonmat은 사고 discipline·가드·기록 영역이지 사용자 프로젝트 스펙 문서를 권위로 인식·자동 추적·검증하지 않음
- **단순 투두 ≠ 통합 정의문서** — Claude 내장 todo는 단기·휘발. 프론트/백 통합 개발정의문서를 유도하는 의례 부재

준선생 제안: **건축은 IT의 origin** — Christopher Alexander 패턴 → GoF Design Patterns처럼 직접 차용 사례 다수. 건축이 IT보다 수천 년 먼저 같은 문제(설계 의도 ↔ 실제 시공 괴리)를 풀어왔으므로, **고대~현대 건축 방법론 + 실무자 괴리 해결 의례**를 조사해 sonmat에 박을 패턴 도출.

5 agent 병렬:
- A1. Ancient → Medieval (이집트·그리스·로마·중세 cathedral)
- A2. Renaissance → Modernism (Alberti·Palladio·Beaux-Arts·Bauhaus·Le Corbusier·CIAM)
- A3. 현대 공식 spec + BIM (CSI MasterFormat·UniFormat·IFC·ISO 19650·COBie)
- A4. Lean Construction + IPD + Design-Build + parametric
- A5. 실무자 괴리 의례 (RFI·Submittal·Change Order·Punch list·As-built·Hidden Conditions·Constructability)

---

## Part 1. 5 Case 정리 (1차/권위 자료 인용)

### A1. Ancient → Medieval architecture spec

**핵심 5 bridge mechanism** (설계 의도 → 실제 시공 사이를 메우는 물리적 artifact):

1. **Templates / *gabarits* / *Schablonen*** — 얇은 목재·금속 cutout. mason이 측정 안 하고 traced. Strasbourg lodge book (1485), Villard de Honnecourt portfolio (~1230). **이게 cathedral 공사가 수백 명 작업자에 parallelize 가능했던 기제**
2. **Tracing floors (*chambres aux traits*)** — Wells, York, Reims에서 plaster 바닥에 1:1 setting-out drawings. 여기서 gabarit 잘라냄. **CAD의 중세 등가물 — canonical geometric source-of-truth**
3. **Full-scale mock-ups in soft material** — Brunelleschi 벽돌 모델. centring scaffolding이 동시에 spec 역할
4. **Module / proportional system as compression** — Vitruvius *modulus*, 인도 *Mānasāra*, Song *Yingzao Fashi* (1103) 8 *cai* 등급 목재. **"Grade 4" 한 마디로 모든 dougong 치수가 확정** — 분량 압축
5. **Lodge oral tradition + secrets** — 독일 lodge Regensburg 조례 (1459). 기하 비밀(compass·straightedge constructions) 도제 전수

**RFI/Change Order 원형**: 1391 Milan Cathedral expert conference — local masters 의견 충돌 시 외부 전문가(Heinrich Parler, Jean Mignot) 소환. Mignot의 *"ars sine scientia nihil est"* — 직관 vs 계산 논쟁의 가장 오래된 기록.

**전송 실패 사례**: Beauvais Cathedral choir 붕괴 (1284, vault 높이가 lodge tacit knowledge 초과), Hagia Sophia 첫 돔 붕괴 (558, 비율 문서로 복원 불가능 — 폐허에서만), Siena Duomo Nuovo 중단 (1339-57, 비례 시스템 scale-up 실패).

**핵심 발견**: 고대-중세 건축은 spec→build gap을 **더 자세한 문서가 아니라 craftsman이 traced 가능한 물리 artifact**(gabarit, tracing floor, centring, paradeigma)로 메움. **문서는 contract와 ratio 운반, 물리 jig가 form 운반**. 현대 sw의 자연어 spec vs 코드 간극은 부분적으로 **gabarit 레이어를 잃은 회귀** — 우리는 이걸 scaffold·generator·golden test로 재발명 중.

**소프트웨어 매핑**:
- Vitruvian *modulus* / Yingzao Fashi 8단계 → design tokens / tier 시스템 (`tailwind.config`)
- *Gabarit* → code generator / scaffold (`create-react-app`, cookiecutter)
- Lodge book → 팀 wiki / pattern library (Storybook)
- Tracing floor → schema source-of-truth / OpenAPI / Figma master
- *Paradeigma* → reference implementation / golden test fixture
- Milan 1391 conference → architecture review board / RFC adjudication
- Eleusis stele contract → Statement of Work / 인수 기준

### A2. Renaissance → Modernism

**Alberti 1485 *De Re Aedificatoria*** — 인쇄된 첫 architectural treatise. **결정적 이동**: *lineamenta* (의도, 추상, 마음 속) vs *materia* (물질, 실행). 건물은 lineament로 완성 후 물질 만짐. **architecture-as-spec의 founding move — design은 information artifact, 어떤 단일 실행과 독립**.

**Palladio 1570 *Quattro Libri*** — 인쇄 woodcut plates로 자기 건물 publication. piedi vicentini 단위 명기. **현실 건물을 표준화된 reusable reference로** — Inigo Jones (1614), Jefferson이 200년 후 책으로 re-execute. **plate가 곧 spec, spec이 세기·대륙 횡단 가능**.

**Boullée·Ledoux** (1780s) — 그려진 적 없는 cenotaph. drawing이 standalone designed artifact. **이 순간 architecture가 construction으로부터 정식 separable** — architect 결과물 = document, 실행은 위임. 5세기 spec/build gap의 시작점.

**Beaux-Arts École** (1671 charter, 1819-1968 peak) — *esquisse* method: 12시간 *en loge* (개별 cubicle 잠금), 작은 parti diagram 고정. 이후 몇 달의 *projet rendu*는 esquisse에서 벗어날 수 없음. **time-boxed commitment 이후 detail만 negotiable**. → 현대 SW analog: time-boxed spike + ADR fix.

**Bauhaus Vorkurs** — Itten·Albers·Moholy-Nagy. 모든 학생 6개월 material handling (paper folded under stress, wood under tension, metal under heat). **"specify form for a material whose behavior you have not felt 불가"**. → SW analog: "learn the runtime before you architect".

**Le Corbusier Five Points** (1927) — pilotis / free plan / free facade / ribbon window / roof garden. **5줄 constraint set, style 아님**. 독립·결합 가능. *Modulor* (1948/55) — 인체+황금비+Fibonacci 차원 시스템. **copyability = 압축**.

**CIAM Athens Charter** (1933) — 95 points. functional city: dwelling/work/recreation/circulation. **세계 최초 international building spec 시도**. 작동: 공유 분석 어휘. 실패: zoning separation이 street life 죽임. **measurable quantity 최적화, emergent social texture 무시**.

**Pruitt-Igoe** (1954-72) — CIAM-compliant towers-in-park, 15년 만에 unlivable. **spec methodology 깨짐 — geometry는 specify, maintenance economics·tenant agency·ground-floor surveillance 무시**. Banham: 모더니스트는 *image* 만 specify, *operating condition* 무시. 

**핵심 발견**: 건축은 1485-1570 인쇄된 orthographic conventions로 spec/build separation 달성, **drawing과 matter 간 영구 feedback gap** 비용 지불, 500년간 pedagogy(Vorkurs, esquisse) + document genres(charter, treatise) 발명해 gap 보완. SW는 1968 (Dijkstra) separation 상속하되 **pedagogy는 상속 안 함** — 그게 부채.

### A3. 현대 공식 spec + BIM

**가장 직접 매핑되는 case** — 이미 작동 중인 살아있는 통합 spec 모델.

**CSI MasterFormat** — 50 Divisions (00-49). 6 digit 번호 (`27 21 13` = Div 27 Communications → Level 2 Data Comm 21 → Level 3 Data Comm Network Equipment 13). 4 level granularity.

**Three-Part Format** (CSI PRM 5th ed.) — 모든 spec section:
- **Part 1 General** — scope·references·submittals·QA·delivery·warranty
- **Part 2 Products** — manufacturers·materials·equipment·fabrication·source QC
- **Part 3 Execution** — examination·preparation·installation·field QC·cleaning·protection

**UniFormat** — 직교 분류, building element 기준 (A Substructure / B Shell / C Interiors / D Services / E Equipment / F Special / G Sitework). 같은 벽이 MasterFormat "09 29 00 Gypsum Board" + UniFormat "C1010 Partitions" — 두 view.

**ISO 12006-2:2015** — 국제 메타 표준. 국가별 시스템(MasterFormat, UniFormat, UK Uniclass, 스웨덴 BSAB)이 매핑.

**IFC (Industry Foundation Classes)** — buildingSMART. ISO 16739-1:2024. EXPRESS-schema. `IfcRoot` → `IfcObject` → `IfcProduct` → `IfcElement` → `IfcWall`, `IfcSlab`, `IfcDoor`. **속성이 entity 타입에 박히지 않고 `IfcRelDefinesByProperties` 통해 attach** — `IfcPropertySet` (Pset_WallCommon: IsExternal, LoadBearing, FireRating, AcousticRating, ThermalTransmittance). **schema가 open, custom property set 허용**. 분류 참조(MasterFormat·Uniclass)도 별도 relationship으로 attach.

**ISO 19650** (2018-22, PAS 1192 진화). **Common Data Environment (CDE)** WIP→Shared→Published→Archived 상태 game. **Information Container** — discrete·named·versioned 패키지 + metadata. **Level of Information Need (LOIN)** — per-deliverable, per-purpose, per-actor 요구 명세. **EIR/BEP** — 발주자 요구 ↔ supply chain 응답.

**COBie** — IFC subset. 운영 단계 인계용 spreadsheet. Contact / Facility / Floor / Space / Zone / Type / Component / System / Assembly / Connection / Spare / Resource / Job / Document / Attribute. **건축의 deployment manifest** — 설계/시공 → 운영 시설관리(CMMS/CAFM) 인계.

**MacLeamy curve** (HOK CEO, 2005) — 4 곡선 시각화: (1) cost·기능 영향력 ↓ over time (2) 변경 비용 ↑ (3) traditional design 노력은 CD 단계에 peak (4) BIM-enabled 노력은 SD/DD로 shift-left. **= sw shift-left + Boehm cost-of-defect curve**.

**작동하지 않는 부분** (Eastman *BIM Handbook* 3rd ed.): IFC interop lossy (Revit→IFC→ArchiCAD round-trip이 parametric 동작·custom families 누락), Pset proliferation, NBS 2020 — 73% 인지하나 40%만 일관 사용, CDE의 published container stale, 분류 시스템 중복(MasterFormat·UniFormat·OmniClass·Uniclass).

**핵심 발견**: CSI 50 Divisions × spec sections × BIM property sets = **categorical schema** — 건물의 모든 측면을 분류 가능. SW에 codebase scale에서 부재. buildingSMART (IFC) + CSI/CSC (MasterFormat) + ISO/TC 59/SC 13 (19650)이 multi-decade 공개 governance — sw에 비교 가능한 commons 없음.

### A4. Lean Construction + IPD + Design-Build + Parametric

**Koskela 1992 TFV theory** — construction = Transformation + Flow + Value generation. 전통 PM은 1/3만 봄. **"spec 실패"의 대부분이 실제로는 flow 실패** — drawing은 옳지만 잘못된 순간 도착. spec이 *artifact로는* OK, *flow event로는* 깨짐.

**Last Planner System (Ballard 2000 PhD)** — 4 horizon × 5 conversation:

| Plan | Horizon | 대화 | 결정 |
|------|---------|------|------|
| Master Schedule | project | SHOULD | 계약 의무 |
| Phase Schedule | months | SHOULD→CAN | milestone-pulled handoff |
| Lookahead Plan | 6 weeks | CAN | constraint removal |
| Weekly Work Plan | 1 week | WILL | last planners 개인 약속 |
| Daily standup / PPC | day-week | DID + LEARN | 완료·root cause |

**Constraint screening** — task가 Lookahead → Weekly Work Plan 내려가려면 **모든 constraint 제거** (design info, materials, prerequisites, space, equipment, labour, permits). **Ready 안 된 task는 commit 안 함, commit 안 함이 보상**.

**PPC = completed/committed**. binary 100%. **planning reliability 측정, output 아님**. 95% PPC + 적게 commit > 60% + 다 commit. **약속 over-commit 처벌 메트릭** — sw velocity-pressured 팀의 정확한 실패 모드.

**Pull Planning ritual** — Big Room 벽. milestone 우측 끝. trade마다 색 sticky note. **right-to-left** 작업 — downstream trade에게 "내가 너에게 무엇을, 언제, 어떤 condition으로?" 묻고, downstream의 *acceptance*가 upstream commitment 정의. **handoff conditions = 다음 trade의 "definition of ready"가 first-class spec 내용**.

**IPD (AIA 2007 IPD Guide, C191 multi-party agreement)** — Owner/Architect/Contractor + 핵심 trades 단일 계약. Ashcraft 4 contractual moves:

1. **Risk/reward pool** — architect·contractor *profit*(cost 아님)이 Target Cost + outcome metrics에 묶인 shared pool. 초과 → 풀 고갈, 절감 → 풀 확장. Autodesk HQ ICL 사례
2. **Liability waivers** — 핵심 멤버 간 negligence 소송 권한 포기 (CCDC 30 GC 10.1). 방어적 documentation 본능 차단
3. **Joint Project Control** — Project Management Team 만장 또는 supermajority
4. **Combined contingencies** — Sutter Health Fairfield (2007 첫 IPD) — architect·GC contingency 합치고 모든 errors·omissions 공동 책임. **change order 0 도달**

**Big Room (Obeya)** — 공동 위치. pull plan, Lookahead, A3, BIM clash views, target-cost trackers 벽에. **shared central tables**(client/consultant 분리 안 함), **vertical wall surface > horizontal table area**.

**Target Value Design** — *design FROM cost*, *estimate FROM design 아님*. 비즈니스 케이스에서 derive된 allowable cost가 generative constraint. CRB·DPR 사례 — 시장가 15-20% under, contingency 작음.

**Set-Based Design** (Sobek/Ward/Liker MIT SMR 1999, Toyota 2nd Paradox) — Point-Based(빨리 하나 picking)와 반대. **여러 alternatives 동시 생존** — 3 façade systems, 2 structural grids, 4 mechanical concepts. **feasible sets intersection 안정될 때까지 converge 안 함**. **last responsible moment까지 결정 지연**. trade partners shared interfaces에 대해 *parallel design*.

**Parametric design** (Grasshopper/Dynamo) — 결과물 = drawing이 아니라 **parametric definition** = directed graph of components. **"spec is now the rule that produces the artifact"**. 늦은 변경(column 이동, façade panel swap)은 script 재실행으로 propagate. **= IaC, infrastructure-as-code의 직접 등가물**.

**핵심 발견**: IPD/Lean Construction이 sw가 못한 것 — **계약을 바꿈**. SW는 daily standup·retro·kanban — 표면 ritual만 import, **separate Product/Design/Eng silos + separate OKRs는 그대로**. Sutter Fairfield 결과(change order 0)는 standup에서 안 옴 — architect·GC contingency 합치고 소송 권리 포기에서 옴. **Big Room은 P&L 공유 없으면 의미 없는 빈 방**.

### A5. Practitioner gap rituals

**RFI (G716)** — 평균 **9.9 RFI/$1M** 시공가. 응답 비용 $1,080. 약속 7일 vs 실제 9.7일 (Navigant 2013). 대형 institutional 1,000+ RFI. **실패 모드**:
- **Fishing RFI** — 답을 알면서 architect 응답이 inadvertently scope change 인가하기를 노림. Navigant 25-40% 분쟁 프로젝트
- **Defensive RFI** — paper trail 만들어 위험 design team에 이관
- **Late RFI** — 답이 무관해진 후, 일정 연장 청구 정당화용

**RFI volume = spec quality 신호**. <2/$M (constructability review 거침) ↔ >15/$M (안 거침).

**Submittal (G712 shop drawing log, G714)** — 4 카테고리: shop drawings·product data·samples·mock-ups. **inverted spec** — spec이 "AISC 360"이라 하면 submittal이 "Nucor W14x90 columns + 이 용접". architect 역할 = "design concept 부합" 확인, *redesign 안 함*. **A201 §3.12.4 — submittal 승인이 contractor 책임 면제 안 함**. "or equal" 대체 분쟁이 소송의 상당 부분.

**Change Order 3 instrument**:
- **CO (G701)** — bilateral, owner·architect·contractor 서명, 계약가·시간 변경
- **Construction Change Directive (G714)** — 가격 합의 안 될 때 owner unilateral, 작업 진행, 비용 사후 정산
- **Architect's Supplemental Instructions (G710)** — 비용·시간 영향 없는 명확화

**Claims consultant 직업** — AACE International (CCP, Certified Cost Professional). "measured mile", "modified total cost" 방법론 (AACE RP 25R-03 published doctrine).

**Differing Site Conditions doctrine (A201 §3.7.4)** — Type I (계약 문서와 materially 다름), Type II (드물게 만나는 unusual condition). **이 단일 clause가 다른 어떤 AIA suite보다 많은 소송 생성**.

**Punch list (G704 Substantial, G706 Final)** — long tail: **5-10% 기간 / 1-3% 가치**. 이유: (a) owner occupancy 중 진행 (b) 작은 scope의 multi-trade coordination (door가 안 닫혀, floor 마감 잘못 → door buck 정렬 잘못) (c) retainage 대부분 release 후 contractor 인센티브 붕괴. ASCE Manual 73 — 알려진 pathology, 계약적 countermeasure(graduated retainage, dual completion certificate) 필요.

**As-built (Record Drawings, A201 §3.11)** — contractor "red lines" 유지 → architect Record Drawings에 통합. **실제론 대부분 fiction** — 마감 압력 + 인센티브 종료. FMI/Autodesk 2019: 35% facility owner가 as-built "renovation 신뢰 불가" 평가.

**Hidden Conditions 예방 protocol**: geotechnical investigation (ASCE 56 / ASTM D420), 기존 condition surveys (laser scanning, GPR), hazmat surveys, pre-bid site walks. **잘 발달, 그러나 under-investment** — owner $50K 조사 skip해서 $500K 청구 발생.

**Constructability Review** (CII IR 34-1, 1986+) — 10:1 cost return, 채택 spotty. Pre-design + 90% CDs. **누가**: GC/CM under preconstruction services contract. **잡는 것**: trade conflicts, sequencing impossibilities, equipment access, modular alternatives. **왜 skip**: owner가 architect 권위 위협하는 second opinion에 돈 내야, design-bid-build delivery는 구조적으로 precludes.

**Constructive Change Doctrine** (*Len Co. v. United States* 1965) — formal CO 없이 architect/owner 행위(verbal direction, 모호한 응답, clarify 거부, defective spec)가 계약상 변경으로 작용. **architect 개인 책임** — jobsite 비공식 지시 ("그냥 이렇게 해")가 owner 구속 + architect unauthorized scope change 노출.

**Document Hierarchy (A201 §1.2.1)** — AIA는 strict precedence 안 정함. "더 나은 품질·많은 양" + RFI로 conflict 보고. supplementary conditions가 흔히 명시: Modifications > Addenda > Agreement > Supplementary > General > Drawings > Specifications. **specs가 material/quality controls, drawings가 dimension/location controls** (CSI PRM §3.4).

**핵심 발견**: 건축업계의 spec-reality gap 답은 **더 나은 spec이 아니다**. 2세기 시도 실패. 답은 **dialogue infrastructure가 계약에 박힘** — 모든 spec ambiguity에 번호 매긴 form (RFI), 모든 해석은 정식 propose back (submittal), 모든 scope change에 3 escalating instrument (ASI/CCD/CO), 모든 unknown에 사전 할당 risk owner (§3.7.4), 모든 document conflict에 resolution rule, 모든 paper-reality 편차 ritually surfaced (punch list, as-built).

**SW가 발명한 것 2개** (PR review ≈ submittal review, release checklist ≈ punch list). **버린 것**: formal change control. **빠진 5개** (Construction Change Directive, Differing Site Conditions doctrine, Constructive Change Doctrine, Document Hierarchy, Claims Profession) — sw는 1900년 건축 수준에 머묾. 강한 personality 위주 처리, 소송이 표준화 강제할 때까지.

---

## Part 2. Cross-cutting patterns (5 case 횡단)

### CC-1. 물리 jig vs 문서 — 형식 분리의 가치

A1 *gabarit*·tracing floor·centring과 A4 parametric definition은 같은 패턴. **form은 jig가 운반, 문서는 contract와 ratio 운반**. 이 분리는 craftsman/builder의 "다시 해석" 부담 제거. 현대 sw에서 scaffold/generator/IaC가 이 layer 부분 재발명.

### CC-2. Categorical schema의 governance

A3 CSI MasterFormat (50 Divisions), buildingSMART IFC (수백 entity types), ISO 19650 — 모두 **multi-decade 공개 governance commons**. SW는 OpenAPI·CNCF·OCI 등 partial commons 있으나 codebase scale에서 categorical schema 부재. 한 모듈의 "이게 어느 division/category냐"가 명시 안 됨.

### CC-3. Time-boxed commitment + 이후 detail negotiable

A2 Beaux-Arts esquisse (12시간 en loge, parti 고정) + A4 Set-Based Design (last responsible moment) — 두 패턴 결합: **early에 frame 고정, late에 detail 결정**. SW에서 ADR + feature flag 조합과 정합. esquisse는 frame, SBD는 detail decision 지연.

### CC-4. Inverted specification

A5 submittal — contractor가 "abstract spec → 구체 product" 역방향 propose. A4 pull planning — downstream이 upstream에게 acceptance condition 정의. **inversion = receiver가 sender의 의도를 자기 어휘로 다시 진술**. SW에서 vendor schema validation, consumer-driven contract testing이 이 패턴.

### CC-5. 계약/인센티브가 ritual을 작동시킴

A4 IPD의 가장 큰 발견 — **shared bonus/contingency/no-sue 없이는 Big Room·standup 모두 빈 의례**. A5 punch list 인센티브 붕괴(retainage release 후) 같은 실패도 동일 메커니즘. **SW가 ritual import에서 멈춘 이유 — 인센티브 구조 안 건드림**.

### CC-6. Claims/Constructive Change profession 부재

A5 — 건축은 CO 관리·청구 doctrine·기여책임 산정이 직업화 (AACE CCP, claims consultant). SW는 이 영역 인프라 0. **scope creep, defective spec, implied changes 모두 정합 doctrine 없이 처리**. → sw 분쟁 누적이 informal 영역에 머묾.

### CC-7. As-built fiction 패턴

A5 35% as-built unreliable — **마감 압력 + 인센티브 종료 시점 documentation**. SW에서 "deployed reality에 맞는 문서" 부재가 동일 패턴. OpenAPI auto-gen·docs-as-code가 부분 해결, 하지만 architectural-level documentation은 여전히 fiction.

### CC-8. 수천 년 일관 실패: design ↔ build 영구 gap

A1 Beauvais 1284 → A2 Pruitt-Igoe 1972 → A5 modern RFI 폭주 — **같은 gap, 같은 실패 모드**. 건축은 5세기간 dialogue infrastructure 발명으로 *관리*했지 *제거* 못 함. **SW가 spec/code gap을 "더 나은 도구로 제거 가능"이라 가정한다면, 5세기 건축 경험이 가설을 반증**. 답은 dialogue infrastructure 강화이지 gap 제거 아님.

---

## Part 3. sonmat 적용 후보 도출

원칙 (이번 세션 누적 결정 정합): 작동 중 플러그인 보호 + 단계적 적용 + 큰 변경은 ADR 선행.

### Tier 1 — 즉시 적용 가능 (텍스트 수정 only, v0.12.0 patch 후보)

#### T1-A. `discipline/hints.md` Dev 도메인 추가 항목 (5건)

| 항목 | 근거 case |
|------|---------|
| **스펙 작성 시 modal calibration** — 각 조항 MUST/SHOULD/MAY + RFC 2119 자기 한정 | A3 CSI Three-Part Format / A2 Beaux-Arts esquisse 명료성 |
| **Intent vs Mechanism 분리** — 스펙은 "달성 상태(intent)"와 "구현 방법(mechanism)"을 별도 박기. 포팅·재구현은 mechanism 재현 아니라 contract 재현 | A2 Alberti *lineamenta* vs *materia*, A1 paradeigma |
| **거절된 대안 기록** — 스펙 작성 시 "왜 X로 안 했나"를 함께 (Brooks ledger of refusal) | A1 Milan 1391 conference adjudication + A4 Set-Based 고려된 대안 보존 |
| **스펙 closure ceremony** — 폐기 시 sunset 명시 + fork 저지 (PEP 404) | A3 ISO 19650 lifecycle status + A5 G704 Substantial Completion |
| **스펙 변경 = `Updates:`/`Obsoletes:` 메타** — 본문 직접 수정 안 하고 후속 spec으로 supersede | A3 IFC schema versioning + A5 G701 Change Order |

#### T1-B. `discipline/core.md` Action Rules 추가 1건

| 항목 | 근거 case |
|------|---------|
| **dialogue ritual 강제** — 스펙 ambiguity 발견 시 즉시 RFI 형식 질문 ("this section is unclear about X — 의도는 Y인지 Z인지?"). 추측 진행 금지. **fishing RFI 자기검열** — 답을 알면서 묻지 말 것 | A5 RFI institution 전체 |

### Tier 2 — 별도 ADR 후 적용 (큰 결정 동반, v0.13.0 candidate)

#### T2-A. 사용자 프로젝트 spec 디렉토리 권고

ADR 후속: `2026-XX-XX-project-spec-structure.md`

- 사용자 프로젝트에 `docs/specs/` 권고 (CLAUDE.md §7 docs/decisions/와 자매 디렉토리)
- A3 CSI Three-Part Format 차용한 spec section 템플릿 (General / Behavior / Verification)
- A3 ISO 19650 lifecycle status (WIP / Shared / Published / Archived) 차용
- 한 spec 단위 = 한 markdown 파일

#### T2-B. spec 자동 참조 메커니즘

ADR 후속: `2026-XX-XX-spec-auto-reference.md`

- 작업 시작 시 관련 spec 자동 Read (ADR `discipline-progressive-disclosure` 정합 — 필요한 layer만)
- guard에 "spec과 명백 충돌하는 행위 차단" 추가 (Tier 2 — guard 변경은 큰 결정)
- witness가 spec ↔ artifact 비교 (현재는 user turn ↔ artifact)

#### T2-C. 임기응변 → spec 갱신 자동 흐름

ADR 후속: `2026-XX-XX-spec-evolution-loop.md`

- v0.11.0 spec-gap AAR (After Acting #4)이 trap dispatch까지만. 후속: spec 갱신 제안까지 자동 흐름
- A4 LPS PPC 모델 — "스펙 reliability 측정" 메트릭 후보 (얼마나 자주 spec-gap 발생, 같은 spec 여러 번 위반 등)

### Tier 3 — D8 (single 본체 vs federation) 결정 후 (신규 skill 후보)

#### T3-A. `/spec` 또는 `/port` skill

- A3 Three-Part Format, A4 parametric design 정신 차용
- ADR `skill-md-template` 첫 적용 케이스
- D8 Master-Clone 결정 시 → scribe·witness 확장으로 흡수 (skill 추가 안 함)
- D8 Federation 결정 시 → 별도 skill 신설

#### T3-B. RFI 스타일 dialogue ritual

- A5 RFI infrastructure 직접 차용
- 사용자 ↔ AI 사이에 "RFI #N: 이 spec section의 의도가 X인지 Y인지" 형식 질문·답변 로그
- 답변이 binding contract part가 됨
- D8 결정 후 skill로 분리 또는 scribe 확장

---

## Part 4. AI 재구현 포팅 프로토콜 v2 (architecture insights 통합)

기존 `spec-induction-and-sisyphus-review.md` Part 2의 포팅 프로토콜을 architecture 관점으로 보강:

### 0. Pre-port (Conceptzia 탐지) — 기존 + 추가

- 기존: git log, PR 코멘트, 원 저자 in-line 주석
- **추가 (A5 hidden conditions)**: pre-bid investigation 등가물 — geotechnical equivalent: dependency graph 조사, 외부 API 의존, runtime 환경 가정 명시

### 1. Drafting (S1) — 기존 + 추가

- 기존: Modal 타이핑, 거절 원장, intent/mechanism 분리
- **추가 (A2 Beaux-Arts esquisse)**: time-boxed parti — 12시간 (또는 등가) 안에 high-level frame 고정. 이후 detail은 negotiable, frame은 freeze
- **추가 (A4 Set-Based)**: 2-3 alternative 병렬 유지 last responsible moment까지

### 2. Ratification (S2)

- 기존: 2+ 독립 구현체 interop, closure ceremony
- **추가 (A3 ISO 19650 LOIN)**: per-deliverable, per-purpose, per-actor 정보 명세 — 한 spec이 어느 stakeholder에게 어떤 지점에 어떤 detail 제공하는지 명시

### 3. Operation/In-flight (S3/S4) — 핵심 보강 영역

- 기존: Gefechtsbericht 임기응변 로그, CUS escalation, distinguishing
- **추가 (A5 RFI)**: spec 모호 발견 시 RFI 형식 명시 질문 + 응답 SLA 등가 (인간 응답 가능한 시간)
- **추가 (A5 submittal)**: 구현 시작 전 "내 해석은 이렇다 — 맞나?"를 spec author에게 propose. inverted spec
- **추가 (A4 LPS PPC)**: "이 task가 commit 가능한가? constraint 모두 제거됐나?" 자기 검토. CAN gate

### 4. AAR (주기별)

- 기존: 5 whys, 비처벌 reporting
- **추가 (A1 Milan 1391)**: 의견 충돌 시 외부 expert 조회 의례

### 5. Promotion (S7)

- 기존: 좀비 방지 closure, Casey 4 요인
- **추가 (A5 punch list)**: 5-10% 기간 / 1-3% 가치 long tail 인지. retainage 등가 — release 직전까지 incentive 유지 메커니즘

---

## Part 5. 결정 요청

준선생 두 핵심 질문에 대한 본 research 결과 답:

**Q: 스펙은 자동적으로 실행이 되는가?** — 현재 sonmat에서 NO. Tier 2 적용 후 부분적 YES (자동 참조 + 충돌 차단 + 갱신 흐름).

**Q: 단순 투두 ≠ 통합 정의문서로 유도하는가?** — 현재 sonmat에서 NO. Tier 2-A (project spec structure ADR + 권고)로 유도 시작 가능. Tier 3 (skill) 까지 가면 강제.

### 진행 옵션

1. **Tier 1 (T1-A 5건 + T1-B 1건)** — 텍스트 수정 only. v0.12.0 patch. 낮은 위험, 높은 가치. 즉시 진행 권장
2. **Tier 2 ADR 작성** (T2-A·T2-B·T2-C 3건) — 큰 결정. 전체 sonmat 정합성 검토 필요
3. **Tier 3 skill** — D8 결정 후. 본 세션 범위 밖
4. **architecture-methodology 본문 자체** — 이 working doc을 어디에 둘지 (sonmat docs/research/ 현재 위치 OK?)

이번에도 분석·문서화만. 결정 주시면 Tier 1 적용 → v0.12.0 release.

---

## 작업 기록

- **2026-04-26 larchive-gpu-prod**
  - 5 agent 병렬 dispatch (A1 Ancient-Medieval / A2 Renaissance-Modernism / A3 BIM·CSI / A4 Lean·IPD / A5 Practitioner gap)
  - 모두 1차/권위 자료 인용 기반 회수
  - Cross-cutting 8 패턴 도출
  - sonmat 적용 후보 Tier 1·2·3 분류
  - 포팅 프로토콜 v2 architecture 통합

- **다음**: Tier 1 적용 결정 후 v0.12.0, Tier 2 ADR 작성, Tier 3 D8 결정 후

## 메모

- 본 문서는 spec-induction-and-sisyphus-review.md (Phase 1+2)의 보강·확장. Phase 3 architecture 관점
- 5 agent raw output은 task output 디렉토리 보존, 본 문서가 canonical summary
- sonmat docs/research/ 디렉토리 누적: 4개 (spec-induction / glossary / hunsugun-identity / architecture-methodology)
