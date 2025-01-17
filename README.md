### 참고사항
!! An error occured Using nbformat v5.10.4 and nbconvert v7.16.1 이라는 오류가 계속해서 떠서 코드 파일은 밖에 꺼내뒀습니다. !!
<br/>!! 최근에 깃허브를 시작해서 서툰 부분이 있을수도 있습니다. 양해 부탁드립니다:)

## #1 중앙대학교 코딩 커뮤니티 COSADAMA conference COCO_**3위**
### (1) subject
문과 대학생들을 위한 구직 정보 시각화  
### (2) tools
python, tableau  
### (3) data collection  
통계청 구인구직 통계, 신규채용현황, 복리후생비, 재무상태표
### (4) summary
코로나 이후 여행, 호텔 등의 산업 크게 타격 받았음을 실제 데이터로 확인
### (5) review / feedback
- 첫 프로젝트인만큼 서툰 점이 많았다
- 간단한 코드도 일일이 노가다로 채움
- 비교적 쉬운 주제를 선택하여 당연한 결론을 도출함. 주제 측면에서 창의성이 필요함

---

## #2 BDA 내부 CJ 공모전_track 1 시각화 인사이트 및 마케팅 전략 도출_**우수상**
### (1) subject
CJ 제일제당 제품 데이터를 통한 시각화 인사이트 도출 및 마케팅 전략 수립
### (2) tools
python
### (3) data collection
CJ 제일제당 측에서 내부 데이터(네이버, 11번가) 제공
### (4) data preprocessing
- 불필요한 컬럼 제거 (결측치, 단일값, 유의미하지 않은 값 등)
- 문자형 변수 -> 수치형 변수
- 파생변수 생성 : 월(from 주문일) / 출고날짜오차(운송장등록날짜-출고예정일) / 예상출고소요기간(출고예정일-주문일) / 실제출고소요기간(운송장등록날짜 - 주문일) / 묶음수량(초기자재수량/상품수량)
### (5) data analysis
- 거래처, 주문일 등에 따라 시각화
- 각 제품별 묶음수량의 주문수량 변곡점을 파악하여 제품별로 묶음수량이 몇 개일 때 최대의 수요를 얻어내는 지 파악
- 매출이 발생하지 않은 데이터를 sub data 로 드고 주문취소, 취소완료, 반품 등의 데이터 분석
### (6) result
- 거래처마다 다른 상품에 포커싱
- 할인행사 진행 시 행사 간격과 할인 금액 적극 고려
- 동시 구매 데이터를 통한 복합상품 마케팅 전략
- 예상출고소요기간을 최대한 줄일 수 있는 배송 방법 고안
### (7) review
- 두번째 프로젝트여서 파이썬을 다루는 능력이 늘었음
- 스스로 데이터 분석을 통해 전략 수립하는 것에 흥미를 느낀다는 것을 알게 됨
- 다만 여전히 툴을 완벽히 다루지 못했기 때문에 팀원들의 도움을 많이 받음

---

## #3 본교 통계프로그래밍 수업 기말 팀 프로젝트_**A+**
### (1) subject
KBO 연도별 승리방정식 
### (2) tools
R
### (3) data collection
- KBO 공식 홈페이지 기록실
- TV 집계 KBO 팀별 누적 시청률
### (4) data preprocessing
- 신생팀 NC, KT 
- 팀 이름 변경한 경우, 최근 팀
명으로 통일
### (5) data analysis 
- 팀별 분석에 앞서, 연도별 전체적인 투타 밸런스 확인 (타고투저, 투고타저 등)
- 다중회귀분석 실시
- 다중공선성 확인 후 pca 분석 진행
- 자책점, 타율과 같은 기본적인 데이터뿐만 아니라 수비율, 실책 등 경기 운영에 영향을 미치는 다양한 요소 추가
- 추가적으로 팀내 연도별 승리방정식을 살펴봄
### (6) review / feedback
- 수업 중 진행 프로젝트여서 모든 팀원이 열심히 참여해서 좋았음
- 다들 파이썬에 더 익숙했기 때문에 R로 코딩하는 것에 약간의 어려움을 겪음
- 같은 시기에 회귀분석 수업을 들었는데 이 때 배운 다중공선성의 증상 및 해결 방법을 바로 프로젝트에 적용해볼 수 있는 좋은 경험이었음
- 다른 팀원들보다 연구 주제에 더 익숙하고 분석 방법을 더 잘 알고 있어서 많이 참여했음
- 웹크로링 학습에 대한 필요성을 느낌

---
## #4 중앙대학교 응용통계학과 분석공모전_**장려상**
### (1) subject
투자심리지수 어쩌구
### (2) data collection
- VKOSPI, CPI 등 경제지표 활용
### (3) data preprocessing 
- standard scaling 진행
- IQR의 2.5배를 이상치 제거 범위로 설정
### (4) data analysis
- 변수선택법 : best selection(AIC, F 통계량 사용) & stepwise selection 
- 여러 모델에 적합 시도 : OLS, Ridge, Lasso, Elastic Net
- 4가지 모델 결과 비교
### (5) result
OLS 모델이 가장 적합
### (6) review & feedback
- 팀원 중 한 명이 금융에 관심이 많아 진행하게 된 분석이었는데, 잘 모르는 지표도 많아 많이 헤맸음
- 각 모델에 대해 정확히 이해하지 못해 그 특성을 제대로 고려하지 못한 것이 아쉬움
- 더 나은 모델을 찾는 과정에서 다양함 모델을 새롭게 알게 되었고 이후 이것들을 더 자세히 공부해야겠다고 생각함

---

## #5 데이콘 제주 특산물 가격 예측 공모전_**상위 4%**
### (1) subject
제주 특산물 가격 예측 모델 구축
### (2) data collection
DACON에서 제공한 데이터만 사용 (이외 외부데이터 사용 금지)
### (3) data preprocessing
- EDA를 통해 감귤이 다른 특산물에 비해 압도적인 생산량을 갖고 있는 것을 확인하여 데이터를 두 개로 분리
- 일요일, 공휴일에는 생산하지 않지만, 공휴일이 길어지는 경우, 공휴일 중 하루는 생산하는 것을 확인함. 하지만 모델이 요일을 제대로 인식하지 못하기 때문에 해당 날짜 생산량이 0이라고 판단 -> 공휴일, 일요일의 경우 앞뒤 3,4일의 평균값으로 채워두고 나중에 결과값에서 공휴일은 0으로 수정하기로 함

### (4) data analysis
- 여러 모델 활용
- autogluon에 대한 제재가 없었기에 해당 모델 활용
### (5) result
사이트에 업로드하여 RMSE가 낮은 순으로 score를 매기는 방식으로 최종 score는 상위 4프로였음 
### (6) review
- 제공된 데이터 중 하나였던 무역데이터를 적극적으로 활용하지 못한 것이 아쉬움
- 새로 나오는 모델에 대한 공부가 필요함을 느낌
- eda하고 데이터 전처리하는 과정에서 데이터의 특징을 찾아내는 것이 재밌었음
