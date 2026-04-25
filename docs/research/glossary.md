# 용어집 — 스펙 귀납 스터디 + Sisyphus 재검토

> 컴패니언 문서: [spec-induction-and-sisyphus-review.md](spec-induction-and-sisyphus-review.md)
> 새 용어가 본문에 등장하면 여기에 1줄 풀이 추가. 본문 첫 등장 시 풀이 동반 원칙.

---

## 0. 이 프로젝트 자체 정의 용어

| 용어 | 풀이 |
|------|------|
| **축 1~10** | Phase 1에서 도출한 스펙 분석 10축 (Intent–Mechanism 분리, 경계 vs 내부, 예제 vs 공리, Modal 어휘, 해석층 제도화, 개정 의례, 검증 가능성, 실패 피드백, 여백 설계, 전달 매체) |
| **축 11** | Phase 2에서 추가한 11번째 축 — **임기응변 정당성**. 매뉴얼 밖 현장 재량이 기대인가 처벌인가, 성공 임기응변이 스펙으로 역류하는 의례가 있는가 |
| **S0~S9** | Phase 2에서 도입한 스펙 생애주기 10단계 — Genesis · Drafting · Ratification · Operation · In-flight amendment · Branching · Deprecation · Supersession · Reconstruction · Archaeology |
| **Conceptzia** | 원래 이스라엘 정보부의 1973 Yom Kippur 실패를 설명한 히브리어 "the Concept". 우리 문서에선 일반화 → **명시 스펙 아닌데 스펙처럼 작동하는 암묵 가정**. AI 재구현 시 가장 위험한 것 |
| **Conceptzia audit** | 설계 시 암묵 가정을 명시화하는 의례. Sisyphus RFC 후보 |
| **Improvisation Log** | 임기응변 사실·판단·결과·역류 여부를 기록하는 artifact 후보. Wenzel의 *Gefechtsbericht* 디지털 버전 |
| **임기응변 × AAR × 스펙 역류 3단 고리** | 매뉴얼 → 현실 불일치 → 임기응변 → AAR → 교본 amendment의 닫힌 루프. Phase 2 핵심 발견 |
| **rank-matched amendment altitude** | 스펙 amendment 루프는 제도가 허용한 고도에서만 살아있음. Wenzel(분대) 살아있고 Stalingrad(군집단) 죽은 이유 |

---

## 1. 프로세스·조직

| 용어 | 풀이 |
|------|------|
| **AAR (After-Action Review)** | 작전·작업 종료 후 **처벌 없이** 수행하는 복기 의례. 미군 공식 제도. 의도/실제/차이/다음의 4단 |
| **BOF (Birds-of-a-Feather)** | IETF에서 새 작업그룹 만들 수 있을지 가늠하는 비공식 첫 모임 |
| **errata** | 공표된 문서의 오류 정정 기록. RFC에선 본문 못 고치고 errata DB에 별도 |
| **I-D (Internet-Draft)** | IETF 초안 문서. 6개월 만료. RFC 후보 |
| **IESG** | Internet Engineering Steering Group. RFC 발행 전 최종 검토 |
| **IETF** | Internet Engineering Task Force. 인터넷 표준 만드는 단체 |
| **PR (Pull Request)** | 깃허브에서 "내 변경 메인에 합쳐주세요" 요청 |
| **RFC (Request For Comments)** | (1) IETF 표준 문서 (2) 일반 의미: 조직에 제안하는 변경 초안 — 우리 문서에선 두 용법 혼용 |
| **rough consensus** | IETF 의사결정 원칙. 만장일치 아니라 "기술적 반대 모두 addressed" |
| **WG (Working Group)** | IETF에서 특정 표준 만드는 작업팀 |

---

## 2. 군사

| 용어 | 풀이 |
|------|------|
| **Auftragstaktik** | 독일어 "임무형 지휘". 부하에게 "무엇을 / 왜"만, "어떻게"는 현장 재량 |
| **Befehlstaktik** | Auftragstaktik의 반대 — "명령형 지휘". 위에서 모든 방법 지시 |
| **Feldwebel / Unteroffizier** | 독일군 부사관 계급. Wenzel이 *Feldwebel* |
| **Gefechtsbericht** | 독일어 "전투 보고". Wenzel이 Eben-Emael 후 작성, *Merkblatt* 개정 근거 |
| **Haltebefehl** | "정지 명령". Hitler가 Stalingrad 6군에 내려 전멸 직접 원인 |
| **Kreta** | 1941 독일 공수 작전. Eben-Emael 교훈 일부 반영, 다른 실패 노출 |
| **Kriegsakademie** | 프로이센 참모대학. Auftragstaktik이 작동하려면 장교 판단력에 10년 투자 |
| **Kritik** | 독일군 훈련의 복기 세션. "정답 하나" 없이 여러 판단 검토. AAR의 선조격 |
| **OKH / OKW** | Oberkommando des Heeres / der Wehrmacht. 육군/국방군 최고사령부 |
| **Sichelschnitt** | "낫질". Manstein의 1940 Ardennes 돌파 작전 |
| **staff ride** | 실제 전장 답사하며 의사결정 훈련하는 학습법 |
| **Truppenführung** | 1933 독일 육군 야전교범. Auftragstaktik 정전 |

---

## 3. 항공·안전

| 용어 | 풀이 |
|------|------|
| **AC 120-51** | FAA의 CRM 의무화 advisory circular (1989) |
| **ASAP (Aviation Safety Action Program)** | 항공사·FAA·노조 3자 비처벌 신고 |
| **ASRS (Aviation Safety Reporting System)** | NASA 운영 비처벌 자발 신고. 10일 내 신고 시 대부분 처벌 면책 |
| **AQP (Advanced Qualification Program)** | FAA 시간 기반에서 시나리오 기반 훈련으로 전환 |
| **CFIT** | Controlled Flight Into Terrain. 정상 비행 중 지형 충돌 |
| **CRM (Crew Resource Management)** | Tenerife(1977) 이후 만들어진 조종실 권한·소통 훈련 체계 |
| **CUS words** | CRM 3단 escalation 토큰: "I'm **C**oncerned / **U**ncomfortable / this is a **S**afety issue" |
| **CVR (Cockpit Voice Recorder)** | 조종실 음성 기록기. 사고 후 대화 복원 |
| **F/O (First Officer)** | 부조종사 |
| **FOQA** | Flight Operations Quality Assurance. 익명 비행 데이터 모니터링 |
| **LOFT (Line-Oriented Flight Training)** | 실제 시나리오 기반 훈련. 실패 사례를 훈련으로 역류 |
| **LOSA (Line Operations Safety Audit)** | peer 관찰자가 정상 비행에서 위협·오류·관리를 코딩 |
| **PIC (Pilot In Command)** | 기장. 최종 권한 |
| **QRH** | Quick Reference Handbook. 비상 절차 빠른 참조 |
| **TEM (Threat and Error Management)** | CRM 6세대. 위협(외부)과 오류(내부) 분리 관리 |
| **Two-Challenge Rule** | 부조종사가 2회 이의에 응답 없으면 기장 무능력 전제 → 통제권 인수 |

---

## 4. 소프트웨어

| 용어 | 풀이 |
|------|------|
| **ABI (Application Binary Interface)** | 컴파일된 바이너리 수준 인터페이스 계약. Linux는 userspace ABI 절대 불변 원칙 |
| **API (Application Programming Interface)** | 소스 수준 인터페이스 계약 |
| **BDFL (Benevolent Dictator For Life)** | "자비로운 종신 독재자". Guido van Rossum이 파이썬에서 가졌던 최종 결정권. 2018 폐지 |
| **CVE (Common Vulnerabilities and Exposures)** | 보안 취약점 공개 ID 체계 |
| **MCP (Model Context Protocol)** | Anthropic의 AI ↔ 도구 연결 프로토콜. Sisyphus가 MCP gateway로 외부에 표면 노출 |
| **`Obsoletes:`** | RFC 메타데이터. "이 RFC는 이전 RFC를 폐기" |
| **PEP (Python Enhancement Proposal)** | 파이썬 변경 제안 문서. PEP 1이 메타 규약 |
| **PR/FAQ** | Amazon 식 의사결정 문서. 가상 보도자료 + 예상 질문 |
| **SemVer (Semantic Versioning)** | `MAJOR.MINOR.PATCH` 3부호 버전 규칙. 자리 의미 약속 |
| **SDK** | Software Development Kit |
| **`Updates:`** | RFC 메타데이터. "이 RFC는 이전 RFC를 보완·일부수정 (대체 아님)" |

---

## 5. 법률

| 용어 | 풀이 |
|------|------|
| **ALI (American Law Institute)** | *Restatement* 발간 단체. 미국 법학자 권위 조직 |
| **common law** | 판례 누적으로 만들어진 법 전통. 영미권 |
| **civil law** | 성문 법전 중심 전통. 대륙권 |
| **distinguishing** | 기존 판례 공식 폐기 안 하고 "이 사건은 그것과 달라"로 적용 범위를 좁혀 사실상 무력화하는 기법. signature S4 기제 |
| **overruling** | 기존 판례 정식 폐기 |
| **Practice Statement [1966]** | House of Lords가 자기 선례 거부 가능하다고 선언. 영국에 S7 기능 도입 |
| **Restatement** | ALI가 흩어진 판례법을 정리해 "현재 법은 이렇다"로 편찬한 준권위 문서 |
| **stare decisis** | "선례 따름" 원칙. common law의 뼈대 |

---

## 6. 유대 문헌

| 용어 | 풀이 |
|------|------|
| **Aman (אמ"ן)** | 이스라엘 군 정보국 |
| **Bomberg 인쇄판** | 1523 베네치아에서 Daniel Bomberg가 출판한 Talmud. 본문+주석 페이지 레이아웃 500년 고정 |
| **Eilu v'eilu** | "이것도 저것도 살아있는 신의 말씀이다" — Talmud Bavli Eruvin 13b. 소수 의견 보존 정당화 격언 |
| **Gemara** | Mishnah에 대한 주석 층 (~500 CE) |
| **Ipcha Mistabra (איפכא מסתברא)** | "반대로 읽는 게 맞다". Yom Kippur 1973 후 이스라엘 정보부가 제도화한 **소수 의견 필수 전달** 절차. 우리 devil skill 기원 |
| **Mishnah** | Rabbi Judah the Prince가 ~200 CE 편찬한 Talmud 본문 층 |
| **responsa (she'elot u-teshuvot)** | "질의응답". 랍비가 새 상황에 답한 결정문 축적. 살아있는 법 메커니즘 |
| **Sedarim** | Mishnah의 6개 큰 분류 (농업·축제·여성·손해·성물·정결) |
| **Talmud Bavli / Yerushalmi** | 바빌론판/예루살렘판 두 Talmud |
| **tannaim** | Mishnah 시기 랍비들 (~70-200 CE) |
| **Tosafot** | Rashi 이후 12-14세기 프랑스·독일 학자들의 Talmud 주석. Bomberg 페이지 외측 |

---

## 7. 의료·과학·기후

| 용어 | 풀이 |
|------|------|
| **AGREE II** | 가이드라인 품질 평가 국제 도구 |
| **AR (Assessment Report)** | IPCC 종합 보고서 (AR1 1990 → AR6 2021-23) |
| **CISNET** | 미국 NCI 암 모델링 컨소시엄. mammography 가이드라인 근거 |
| **GRADE** | Grading of Recommendations Assessment, Development and Evaluation. 근거 수준 + 권고 강도 평가 프레임워크 |
| **IPCC** | Intergovernmental Panel on Climate Change |
| **NICE** | National Institute for Health and Care Excellence (영국). 의료 가이드라인 + 비용효과 |
| **PSA** | 전립선 특이항원. screening 가이드라인 플립의 대표 사례 |
| **QALY** | Quality-Adjusted Life Year. NICE 비용효과 단위 (~£20,000-30,000/QALY) |
| **RCT** | Randomized Controlled Trial. 무작위 대조 임상시험 |
| **SPM (Summary for Policymakers)** | IPCC AR의 정책결정자용 요약. **정부가 한 줄씩 승인** |
| **USPSTF** | US Preventive Services Task Force. 예방의학 권고 위원회. A/B/C/D/I 등급 |
| **WG (IPCC Working Group)** | I 물리과학 / II 영향·적응·취약성 / III 완화 |
| **WHI (Women's Health Initiative)** | 2002 HRT 가이드라인 반전 트리거 임상 |

---

## 8. 인물·작품 (자주 인용)

| 이름·작품 | 핵심 |
|----------|------|
| **Brunelleschi** | Firenze 두오모 돔. 문서 없이 템플릿+plumb bob+herringbone으로 시공. 전체 계획 비밀 |
| **Cardozo** | *MacPherson v. Buick* (1916), *The Nature of the Judicial Process* (1921). distinguishing 대가 |
| **Casey** | *Planned Parenthood v. Casey* (1992). stare decisis 4 요인 (workability/reliance/coherence/factual) |
| **Dijkstra** | EWD 손글씨 1300+, *A Discipline of Programming* (1976). wp(S,Q) 술어 변환 |
| **Dobbs** | *Dobbs v. Jackson* (2022). *Roe*/*Casey* 폐기. *Casey* 4 요인을 *Casey*에 역적용 |
| **Eben-Emael** | 1940.5.10 독일 공수 요새 점령. Wenzel 임기응변 사례 |
| **FMFM 1 / MCDP 1 *Warfighting*** | USMC 1989/1997 교본. **매뉴얼이 임기응변을 명령** |
| **Knuth** | Literate Programming, TeX, 오류 현상금 ($2.56 hex dollar) |
| **Lamport** | TLA+ 창시자. "Think, then code", "글이 곧 생각" |
| **Manstein** | *Verlorene Siege* (1955). Sichelschnitt 입안자 |
| **Meyer (Bertrand)** | Eiffel, Design by Contract. `require`/`ensure`/`invariant` 언어 구문 |
| **Moltke (the Elder)** | Helmuth von Moltke (1800-1891). 프로이센 참모총장. Auftragstaktik 정형화 |
| **Ohno** | 도요타 TPS. **초크 원**, 5 whys |
| **Parnas** | A-7E OFP 재사양, "On the Criteria..." (1972). Information hiding |
| **Postel** | RFC 791/793 등 저자. RFC 편집자. "관대한 수용 / 보수적 송신" — RFC 9413(2023)에서 비판됨 |
| **Rashi** | Rabbi Shlomo Yitzhaki (1040-1105). Talmud 주석 표준 |
| **RFC 2119** | MUST/SHOULD/MAY 6단 modal 정의. Bradner 1997 |
| **RFC 6410** | 2011 IETF 표준 트랙 3→2단 축소 |
| **RFC 8174** | 2017. RFC 2119 키워드는 대문자일 때만 그 의미 |
| **RFC 9293** | 2022. TCP 통합 (793 등 7개 obsoletes). 9년 작업 |
| **RFC 9413** | 2023. Postel robustness principle 비판·수정 |
| **Ross King** | *Brunelleschi's Dome* (2000). Brunelleschi 표준 영문 사료 |
| **Schmitt (John)** | FMFM 1 주 저자 (Captain) |
| **Sharon** | Ariel Sharon. Yom Kippur 1973 수에즈 도하 임기응변 |
| **Shook** | John Shook, *Managing to Learn* (2008). A3 멘토링 정전 |
| **Sullenberger** | US Airways 1549 Hudson 착수 (2009). QRH 일부 override |
| **Tenerife** | 1977.3.27 KLM-Pan Am 충돌. 583명 사망. CRM 탄생 트리거 |
| **Truppenführung** | 1933 독일 육군 야전교범 |
| **UAL 232** | 1989 Sioux City. 유압 완전 상실, throttle만으로 착륙. CRM 성공 사례 |
| **Witzig** | Oberleutnant Rudolf Witzig. Eben-Emael 작전 본디 지휘관 |
| **Yom Kippur 1973 / Agranat** | 이스라엘 정보 실패 → 위원회 → 정보부 개혁 → Ipcha Mistabra 제도화 |

---

## 9. 약어 빠른 색인

A-Z 순:

ABI · AC 120-51 · AGREE II · ALI · API · AR · ASAP · ASRS · AQP · BDFL · BOF · CFIT · CISNET · CRM · CUS · CVE · CVR · F/O · FAA · FOQA · GRADE · I-D · IESG · IETF · IPCC · LOFT · LOSA · MCP · NICE · OKH · OKW · PEP · PIC · PR · PR/FAQ · PSA · QALY · QRH · RCT · RFC · SDK · SemVer · SPM · TEM · USPSTF · WG · WHI

한글·로마자 혼용:

Auftragstaktik · BDFL · Befehlstaktik · Bomberg · Conceptzia · distinguishing · Eilu v'eilu · errata · Feldwebel · Gefechtsbericht · Gemara · Haltebefehl · Ipcha Mistabra · Kreta · Kriegsakademie · Kritik · Mishnah · Obsoletes · overruling · Practice Statement · Restatement · responsa · rough consensus · Sedarim · Sichelschnitt · staff ride · stare decisis · Tosafot · Truppenführung · Two-Challenge Rule · Updates

---

## 메모

- 본 용어집은 working doc 본문이 길어지는 것을 방지. 본문은 첫 등장 시 1줄 풀이만, 자세한 정의는 여기로 link
- 새 사례·용어 추가 시 적절한 섹션에 알파벳/가나다 순 삽입
- 우리 자체 정의 용어(§0)는 **명확한 출처 명시 필요** — Phase 3 귀납 결과로 정의 다듬어질 가능성 있음
