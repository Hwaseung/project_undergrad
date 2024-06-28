## 1. 데이터 전처리 ################
# 1-1. 투수 데이터 ##########################
#데이터 불러오기
library(readxl)
a <- read_excel("./투수 원본.xlsx")

#데이터 확인하기
head(a)
summary(a)

#불필요한 행 제거
library(dplyr)
a <- select(a, -순위, -G, -W, -L, -WPCT, -H, -HR, - R, -ER)

#사사구(볼넷+사구) 행 생성
a <- mutate(a, 사사구=BB+HBP)

#연도별 데이터 그룹화 및 할당
years <- unique(a$연도별)
pitcher <- data.frame()
for(year in years){
  assign(paste0("pitcher_", year), data.frame())
  year_data <- a[a$연도별 == year,]
  assign(paste0("pitcher_", year), year_data)
  pitcher <- rbind(pitcher,data.frame(year = year, count = nrow(year_data)))
}

#연도별 데이터 확인
print(pitcher)
for (year in years) {
  print(paste("Data for year", year))
  print(get(paste0("pitcher_", year)))
}

# 결측치 개수 확인
for(year in years){
  print(sum(is.na(paste0("pitcher_",year))))
}



# 1-2. 타자 데이터 ##########################
#데이터 불러오기
library(readxl)
b <- read_excel("./타자 원본.xlsx")

#데이터 확인하기
head(b)
summary(b)

#불필요한 행 제거
b <- select(b, -순위, -G, -PA, -AB, -R, -H, -'2B', -'3B', -HR, -SAC, -SF)

#연도별 데이터 그룹화 및 할당
years <- unique(b$연도별)
hitter <- data.frame()
for(year in years){
  assign(paste0("hitter_", year), data.frame())
  year_data <- b[b$연도별 == year,]
  assign(paste0("hitter_", year), year_data)
  hitter <- rbind(hitter,data.frame(year = year, count = nrow(year_data)))
}

#연도별 데이터 확인
print(hitter)
for (year in years) {
  print(paste("Data for year", year))
  print(get(paste0("hitter_", year)))
}

# 결측치 개수 확인
for(year in years){
  print(sum(is.na(paste0("hitter_",year))))
}



# 1-3. 팀성적 데이터 ########################
#데이터 불러오기
e <- read_excel("./팀성적.xlsx")

#데이터 확인하기
head(e)
summary(e)

#불필요한 행 제거
e <- select(e, -c(경기, 승, 패, 무, 타율, 평균자책점))

#연도별 데이터 그룹화 및 할당
years <- unique(e$연도별)
team <- data.frame()
for(year in years){
  assign(paste0("team_", year), data.frame())
  year_data <- e[e$연도별 == year,]
  assign(paste0("team_", year), year_data)
  team <- rbind(team,data.frame(year = year, count = nrow(year_data)))
}

#연도별 데이터 확인
print(team)
for (year in years) {
  print(paste("Data for year", year))
  print(get(paste0("team_", year)))
}

# 결측치 개수 확인
for(year in years){
  print(sum(is.na(paste0("team_",year))))
}



# 1-4. 팀 별 연도 종합 데이터 프레임 ########################
# 타자 ##############################################################
#팀명이 계속 유지된 팀 -> "KIA","삼성","LG","롯데", "NC","두산","한화", 'KT'
team_names <- c("KIA","삼성","LG","롯데", "NC","두산","한화", 'KT')
for (team_name in team_names) {
  team_data <- data.frame()
  for (year in 2010:2022) {
    var_name <- paste0("hitter_", year)
    data <- get(var_name)
    filtered_data <- data %>% filter(`팀명` == team_name)
    filtered_data <- filtered_data %>% mutate(연도 = year)
    team_data <- bind_rows(team_data, filtered_data)
    team_data <- team_data %>% select(-순위 , -팀명 ) 
    #팀명은 모두 동일하고 순위는 매년 바뀌기 때문에 제거함
  }
  var_name <- paste0("hitter_", team_name)
  assign(var_name, team_data)
}

#확인
hitter_KT
hitter_KIA

# 키움 
#2019년에 넥센에서 키움으로 이름 바뀜
hitter_키움 <- data.frame()
for (year in 2010:2022) {
  var_name <- paste0("hitter_", year)
  data <- get(var_name)
  if (year < 2019) {
    filtered_data <- data %>% filter(`팀명` == "넥센")
  } else {
    filtered_data <- data %>% filter( `팀명` == "키움")
  }
  filtered_data <- filtered_data %>% mutate(연도 = year)
  hitter_키움 <- bind_rows(hitter_키움, filtered_data)
}
hitter_키움 <- hitter_키움 %>% select(-순위, -`팀명`)
print(hitter_키움)

#SK 2021년부터 SSG 로 바뀜
hitter_SSG <- data.frame()
for (year in 2010:2022) {
  var_name <- paste0("hitter_", year)
  data <- get(var_name)
  if (year < 2021) {
    filtered_data <- data %>% filter(`팀명` == "SK")
  } else {
    filtered_data <- data %>% filter( `팀명` == "SSG")
  }
  filtered_data <- filtered_data %>% mutate(연도 = year)
  hitter_SSG <- bind_rows(hitter_SSG, filtered_data)
}
hitter_SSG <- hitter_SSG %>% select(-순위, -`팀명`)
print(hitter_SSG)

# 파일저장 [시트 명을 팀명으로 지정]
library(writexl)
library(openxlsx)
wb <- createWorkbook()
data_frames <- list(hitter_KIA, hitter_삼성, hitter_LG, hitter_롯데, 
                    hitter_NC,hitter_두산,hitter_한화,  hitter_KT, hitter_키움, hitter_SSG)
sheet_names <- c("KIA","삼성","LG","롯데",'NC',"두산","한화", 'KT', '키움', 'SSG')

for (i in seq_along(data_frames)) {
  addWorksheet(wb, sheet_names[i])  
  writeData(wb, sheet_names[i], data_frames[[i]])
}

saveWorkbook(wb, "타자_팀별_data.xlsx")

# 투수 ##############################################################
# 연도별로 할당
sheet_names <- excel_sheets('투수.xlsx')
for (sheet_name in sheet_names) {
  data <- read_excel('투수.xlsx', sheet = sheet_name)
  var_name <- paste0("pitcher_", sheet_name)
  assign(var_name, data)
}

# 팀의 연도별 데이터 프레임 만들기
team_names <- c("KIA","삼성","LG","롯데", "NC","두산","한화", 'KT')

for (team_name in team_names) {
  team_data <- data.frame()
  for (year in 2010:2022) {
    var_name <- paste0("pitcher_", year)
    data <- get(var_name)
    filtered_data <- data %>% filter(`팀명` == team_name)
    filtered_data <- filtered_data %>% mutate(연도 = year)
    team_data <- bind_rows(team_data, filtered_data)
    team_data <- team_data %>% select(-순위 , -팀명 )
  }
  var_name <- paste0("pitcher_", team_name)
  assign(var_name, team_data)
}


#SK 2021년부터 SSG 로 바뀜
pitcher_SSG <- data.frame()
for (year in 2010:2022) {
  var_name <- paste0("pitcher_", year)
  data <- get(var_name)
  if (year < 2021) {
    filtered_data <- data %>% filter(`팀명` == "SK")
  } else {
    filtered_data <- data %>% filter( `팀명` == "SSG")
  }
  filtered_data <- filtered_data %>% mutate(연도 = year)
  pitcher_SSG <- bind_rows(pitcher_SSG, filtered_data)
}
pitcher_SSG <- pitcher_SSG %>% select(-순위, -`팀명`)
print(pitcher_SSG)



#2019년에 넥센에서 키움으로 이름 바뀜 
pitcher_키움 <- data.frame()
for (year in 2010:2022) {
  var_name <- paste0("pitcher_", year)
  data <- get(var_name)
  if (year < 2019) {
    filtered_data <- data %>% filter(`팀명` == "넥센")
  } else {
    filtered_data <- data %>% filter( `팀명` == "키움")
  }
  filtered_data <- filtered_data %>% mutate(연도 = year)
  pitcher_키움 <- bind_rows(pitcher_키움, filtered_data)
}
pitcher_키움 <- pitcher_키움 %>% select(-순위, -`팀명`)
print(pitcher_키움)

# 파일로 저장
library(writexl)
library(openxlsx)
wb <- createWorkbook()

data_frames <- list(pitcher_KIA, pitcher_삼성,pitcher_LG, pitcher_롯데, pitcher_NC,pitcher_두산,pitcher_한화,  pitcher_KT, pitcher_키움, pitcher_SSG)
sheet_names <- c("KIA","삼성","LG","롯데",'NC',"두산","한화", 'KT', '키움', 'SSG')

for (i in seq_along(data_frames)) {
  addWorksheet(wb, sheet_names[i])
  writeData(wb, sheet_names[i], data_frames[[i]])
}

saveWorkbook(wb, "투수_팀별_data.xlsx")

# 수비 ##############################################################
# 연도별로 할당
sheet_names <- excel_sheets('수비.xlsx')
for (sheet_name in sheet_names) {
  data <- read_excel('수비.xlsx', sheet = sheet_name)
  var_name <- paste0("defense_", sheet_name)
  assign(var_name, data)
}

# 팀의 연도별 데이터 프레임 만들기
team_names <- c("KIA","삼성","LG","롯데", "NC","두산","한화", 'KT')

for (team_name in team_names) {
  team_data <- data.frame()
  for (year in 2010:2022) {
    var_name <- paste0("defense_", year)
    data <- get(var_name)
    filtered_data <- data %>% filter(`팀명` == team_name)
    filtered_data <- filtered_data %>% mutate(연도 = year)
    team_data <- bind_rows(team_data, filtered_data)
    team_data <- team_data %>% select(-순위 , -팀명 )
  }
  var_name <- paste0("defense_", team_name)
  assign(var_name, team_data)
}


#SK 2021년부터 SSG 로 바뀜
defense_SSG <- data.frame()
for (year in 2010:2022) {
  var_name <- paste0("defense_", year)
  data <- get(var_name)
  if (year < 2021) {
    filtered_data <- data %>% filter(`팀명` == "SK")
  } else {
    filtered_data <- data %>% filter( `팀명` == "SSG")
  }
  filtered_data <- filtered_data %>% mutate(연도 = year)
  defense_SSG <- bind_rows(defense_SSG, filtered_data)
}
defense_SSG <- defense_SSG %>% select(-순위, -`팀명`)
print(defense_SSG)

# 파일로 저장 
library(writexl)
library(openxlsx)
wb <- createWorkbook()

data_frames <- list(defense_KIA, defense_삼성, defense_LG, defense_롯데, defense_NC, defense_두산, defense_한화,  defense_KT, defense_키움, defense_SSG)
sheet_names <- c("KIA","삼성","LG","롯데",'NC',"두산","한화", 'KT', '키움', 'SSG')

for (i in seq_along(data_frames)) {
  addWorksheet(wb, sheet_names[i])
  
  writeData(wb, sheet_names[i], data_frames[[i]])
}

saveWorkbook(wb, "수비_팀별_data.xlsx")

# 주루 ##############################################################
# 연도별로 할당
sheet_names <- excel_sheets('주루.xlsx')
for (sheet_name in sheet_names) {
  data <- read_excel('주루.xlsx', sheet = sheet_name)
  var_name <- paste0("base_", sheet_name)
  assign(var_name, data)
}

# 팀의 연도별 데이터 프레임 만들기
team_names <- c("KIA","삼성","LG","롯데", "NC","두산","한화", 'KT')

for (team_name in team_names) {
  team_data <- data.frame()
  for (year in 2010:2022) {
    var_name <- paste0("base_", year)
    data <- get(var_name)
    filtered_data <- data %>% filter(`팀명` == team_name)
    filtered_data <- filtered_data %>% mutate(연도 = year)
    team_data <- bind_rows(team_data, filtered_data)
    team_data <- team_data %>% select(-순위 , -팀명 )
  }
  var_name <- paste0("base_", team_name)
  assign(var_name, team_data)
}


#SK 2021년부터 SSG 로 바뀜
base_SSG <- data.frame()
for (year in 2010:2022) {
  var_name <- paste0("base_", year)
  data <- get(var_name)
  if (year < 2021) {
    filtered_data <- data %>% filter(`팀명` == "SK")
  } else {
    filtered_data <- data %>% filter( `팀명` == "SSG")
  }
  filtered_data <- filtered_data %>% mutate(연도 = year)
  base_SSG <- bind_rows(base_SSG, filtered_data)
}
base_SSG <- base_SSG %>% select(-순위, -`팀명`)
print(base_SSG)


#2019년에 넥센에서 키움으로 이름 바뀜 
base_키움 <- data.frame()
for (year in 2010:2022) {
  var_name <- paste0("base_", year)
  data <- get(var_name)
  if (year < 2019) {
    filtered_data <- data %>% filter(`팀명` == "넥센")
  } else {
    filtered_data <- data %>% filter( `팀명` == "키움")
  }
  filtered_data <- filtered_data %>% mutate(연도 = year)
  base_키움 <- bind_rows(base_키움, filtered_data)
}
base_키움 <- base_키움 %>% select(-순위, -`팀명`)
print(base_키움)

# 파일로 저장
library(writexl)
library(openxlsx)
wb <- createWorkbook()

data_frames <- list(base_KIA, base_삼성, base_LG, base_롯데, base_NC, base_두산, base_한화,  base_KT, base_키움, base_SSG)
sheet_names <- c("KIA","삼성","LG","롯데",'NC',"두산","한화", 'KT', '키움', 'SSG')

for (i in seq_along(data_frames)) {
  addWorksheet(wb, sheet_names[i])
  
  writeData(wb, sheet_names[i], data_frames[[i]])
}

saveWorkbook(wb, "주루_팀별_data.xlsx")

# 1-6. 지표 별 데이터 프레임 ########################
# 타자 ##############################################################
# 타자의 대표지표 AVG 사용
data_frame_names <- c( 'hitter_삼성', 'hitter_LG', 'hitter_롯데', 'hitter_NC', 
                       'hitter_두산','hitter_한화',  'hitter_KT', 'hitter_키움', 'hitter_SSG')
total_hitter <- data.frame()
total_hitter <- hitter_KIA %>% select(연도, AVG)
for (name in data_frame_names) {
  current_data <- select(get(name), 연도, AVG)
  total_hitter <- left_join(total_hitter, current_data, by = "연도")
}
names(total_hitter)<- c('연도', "KIA","삼성","LG","롯데",'NC',"두산",
                        "한화", 'KT', '키움', 'SSG')

#확인
total_hitter


# 투수 ##############################################################
# 투수 ERA 지표 사용 
data_frame_names <- c( 'pitcher_삼성', 'pitcher_LG', 'pitcher_롯데', 'pitcher_NC', 'pitcher_두산','pitcher_한화',  'pitcher_KT', 'pitcher_키움', 'pitcher_SSG')
total_pitcher <- data.frame()
total_pitcher <- pitcher_KIA %>% select(연도, ERA)
for (name in data_frame_names) {
  current_data <- select(get(name), 연도, ERA)
  total_pitcher <- left_join(total_pitcher, current_data, by = "연도")
}
names(total_pitcher)<- c('연도', "KIA","삼성","LG","롯데",'NC',"두산","한화", 'KT', '키움', 'SSG')

# 확인
total_pitcher


# 수비 ##############################################################
# 수비 PO 지표 사용
data_frame_names <- c( 'defense_삼성', 'defense_LG', 'defense_롯데', 'defense_NC', 'defense_두산','defense_한화',  'defense_KT', 'defense_키움', 'defense_SSG')
total_defense <- data.frame()
total_defense <- defense_KIA %>% select(연도, PO)
for (name in data_frame_names) {
  current_data <- select(get(name), 연도, PO)
  total_defense <- left_join(total_defense, current_data, by = "연도")
}
names(total_defense)<- c('연도', "KIA","삼성","LG","롯데",'NC',"두산","한화", 'KT', '키움', 'SSG')

#확인
total_defense


# 주루 ##############################################################
# 주루 SB 지표 사용
data_frame_names <- c( 'base_삼성', 'base_LG', 'base_롯데', 'base_NC', 'base_두산','base_한화',  'base_KT', 'base_키움', 'base_SSG')
total_base <- data.frame()
total_base <- base_KIA %>% select(연도, 'SB%')
for (name in data_frame_names) {
  current_data <- select(get(name), 연도, 'SB%')
  total_base <- left_join(total_base, current_data, by = "연도")
}

names(total_base)<- c('연도', "KIA","삼성","LG","롯데",'NC',"두산","한화", 'KT', '키움', 'SSG')

# 확인
total_base



# 1-7. 팀 별 종합 데이터 프레임 ########################
#팀 별로 total_ 데이터 프레임 생성
teams <- c("KIA","삼성","LG","롯데",'NC',"두산","한화", 'KT', '키움', 'SSG')

teams <- c("KIA","삼성","LG","롯데",'NC',"두산","한화", 'KT', '키움', 'SSG')
for (team in teams) {
  total_data <- data.frame()
  total_data <- get(paste0("hitter_", team)) %>% select(연도, AVG)
  
  current_data <- get(paste0("pitcher_", team)) %>% select(연도, ERA)
  total_data <- left_join(total_data, current_data, by = "연도")
  
  current_data <- get(paste0("defense_", team)) %>% select(연도, PO)
  total_data <- left_join(total_data, current_data, by = "연도")
  
  current_data <- get(paste0("base_", team)) %>% select(연도, 'SB%')
  total_data <- left_join(total_data, current_data, by = "연도")
  var_name <- paste0("total_", team)
  assign(var_name, total_data)
  
}

#확인
total_LG


## 2. 시각화 ################
# 2-1. 순위 지표 ##########################
# 역대 1위 ##############################################################
rank <- read_excel('팀성적.xlsx')

# 순위가 1 위였던 팀 비중을 나타내는 파이차트
rank_1 <- rank[rank$순위 == 1, '팀명']
team <- table(rank_1)
team <- sort(table(rank_1), decreasing = TRUE)

library(RColorBrewer)
colors <- brewer.pal(length(team), "Set3")
pie(team, labels = names(team), col = colors, main = "역대 1위 팀들 비중")

# 역대 2위 ##############################################################
# 순위가 2 위였던 팀 비중을 나타내는 파이차트
library(RColorBrewer)
rank_2 <- rank[rank$순위 == 2, '팀명']
team <- table(rank_2)
team <- sort(table(rank_2), decreasing = TRUE)

colors <- brewer.pal(length(team), "Set3")
pie(team, labels = names(team), col = colors, main = "역대 2위 팀들 비중")

# 역대 꼴찌 ##############################################################
#순위가 꼴지였던 팀 비중을 나타내는 파이차트
lowest_rank <- rank %>%
  group_by(연도별) %>%
  filter(순위== max(순위)) %>% 
  # 해당 기간동안 새로운 팀이 추가되어 꼴지 순위에 변동이 있어 순위가 최대가 될 때로 사용
  ungroup()

team <- table(lowest_rank$팀명)
team <- rev(team)
colors <- brewer.pal(length(team), "Set3")
pie(team, labels = names(team), col = colors, main = "역대 꼴지 팀들 비중")

# 평균 순위 ##############################################################
#데이터 전처리
#2010년도부터 2022년도까지 순위의 평균

rank$팀명[rank$팀명 == "넥센"] <- "키움"
rank$팀명[rank$팀명 == "SK"] <- "SSG"
avg_rank <- rank %>%
  group_by(팀명) %>%
  summarise(avg_rank = round(mean(순위), digits = 2)) %>%
  arrange(avg_rank)

avg_rank$팀명 <- factor(avg_rank$팀명, levels = rev(avg_rank$팀명))
# 확인
avg_rank

# 막대도표
library(ggplot2)
library(RColorBrewer)
colors <- brewer.pal(10, "Set3")

ggplot(avg_rank, aes(x = avg_rank, y = 팀명, fill = 팀명 )) +
  geom_bar(stat = "identity", orientation = "y") +
  geom_text(aes(label = paste(avg_rank, "위")),  hjust = -0.3,color = "black") +
  scale_fill_manual(values = colors) +
  labs(x = "평균 순위", y = "팀명", title = "2010년 ~ 2022년 팀별 평균 순위") +
  coord_cartesian(xlim = c(1, 9)) +
  theme_minimal()+
  theme(legend.position = "none",
        plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
        plot.title.position = "plot")

# 2-2. 항목 별 지표 ##########################
# AVG ##############################################################
# 전처리
data_frame_names <- c( 'hitter_삼성', 'hitter_LG', 'hitter_롯데', 'hitter_NC', 'hitter_두산','hitter_한화',  'hitter_KT', 'hitter_키움', 'hitter_SSG')
total_hitter <- data.frame()
total_hitter <- hitter_KIA %>% select(연도, AVG)
for (name in data_frame_names) {
  current_data <- select(get(name), 연도, AVG)
  total_hitter <- left_join(total_hitter, current_data, by = "연도")
}

names(total_hitter)<- c('연도', "KIA","삼성","LG","롯데",'NC',"두산","한화", 'KT', '키움', 'SSG')
total_hitter

# hitter의 AVG 변수로 팀별로 boxplot 그리기
library(RColorBrewer)
colors <- brewer.pal(10, "Set3") #10개의 팀에 대한 색상 지정

boxplot(total_hitter[, c("KIA","삼성","LG","롯데",'NC',"두산","한화", 
                         'KT', '키움', 'SSG')], 
        col = colors,
        main = "AVG의 박스 그림",
        xlab = "팀명",
        ylab = "Values")

# ERA ##############################################################
#데이터 전처리
data_frame_names <- c( 'pitcher_삼성', 'pitcher_LG', 'pitcher_롯데', 'pitcher_NC', 'pitcher_두산','pitcher_한화',  'pitcher_KT', 'pitcher_키움', 'pitcher_SSG')
total_pitcher <- data.frame()
total_pitcher <- pitcher_KIA %>% select(연도, ERA)
for (name in data_frame_names) {
  current_data <- select(get(name), 연도, ERA)
  total_pitcher <- left_join(total_pitcher, current_data, by = "연도")
}

names(total_pitcher)<- c('연도', "KIA","삼성","LG","롯데",'NC',"두산","한화", 'KT', '키움', 'SSG')
total_pitcher

#pitcher의 ERA 변수로 팀별로 boxplot 그리기
library(RColorBrewer)
colors <- brewer.pal(10, "Set3")

boxplot(total_pitcher[, c("KIA","삼성","LG","롯데",'NC',"두산","한화", 
                          'KT', '키움', 'SSG')], 
        col = colors,
        main = "ERA의 박스 그림",
        xlab = "팀명",
        ylab = "Values")

# PO ##############################################################
#데이터 전처리
data_frame_names <- c( 'defense_삼성', 'defense_LG', 'defense_롯데', 'defense_NC', 'defense_두산','defense_한화',  'defense_KT', 'defense_키움', 'defense_SSG')
total_defense <- data.frame()
total_defense <- defense_KIA %>% select(연도, PO)
for (name in data_frame_names) {
  current_data <- select(get(name), 연도, PO)
  total_defense <- left_join(total_defense, current_data, by = "연도")
}

names(total_defense)<- c('연도', "KIA","삼성","LG","롯데",'NC',"두산","한화", 'KT', '키움', 'SSG')
total_defense

#수비 -po 지표로 boxplot 만들기
library(RColorBrewer)
colors <- brewer.pal(10, "Set3")

boxplot(total_defense[, c("KIA","삼성","LG","롯데",'NC',"두산","한화", 
                          'KT', '키움', 'SSG')], 
        col = colors,
        main = "PO의 박스 그림",
        xlab = "팀명",
        ylab = "Values")

# SB% ##############################################################
#데이터 전처리
base_삼성

data_frame_names <- c( 'base_삼성', 'base_LG', 'base_롯데', 'base_NC', 'base_두산','base_한화',  'base_KT', 'base_키움', 'base_SSG')
total_base <- data.frame()
total_base <- base_KIA %>% select(연도, 'SB%')
for (name in data_frame_names) {
  current_data <- select(get(name), 연도, 'SB%')
  total_base <- left_join(total_base, current_data, by = "연도")
}

names(total_base)<- c('연도', "KIA","삼성","LG","롯데",'NC',"두산","한화", 'KT', '키움', 'SSG')
total_base

#주루 -SB 지표로 boxplot 만들기
library(RColorBrewer)
colors <- brewer.pal(10, "Set3")

boxplot(total_base[, c("KIA","삼성","LG","롯데",'NC',"두산","한화", 
                       'KT', '키움', 'SSG')], 
        col = colors,
        main = "SB%의 박스 그림",
        xlab = "팀명",
        ylab = "Values")

# 2-3. 팀 별 지표 ##########################
#데이터 추출
# 타자, 투수, 수비, 주루 중 중요한 변수 하나씩 추출 
for (team in teams) {
  total_data <- data.frame()
  total_data <- get(paste0("hitter_", team)) %>% select(연도, AVG)
  
  current_data <- get(paste0("pitcher_", team)) %>% select(연도, ERA)
  total_data <- left_join(total_data, current_data, by = "연도")
  
  current_data <- get(paste0("defense_", team)) %>% select(연도, PO)
  total_data <- left_join(total_data, current_data, by = "연도")
  
  current_data <- get(paste0("base_", team)) %>% select(연도, 'SB%')
  total_data <- left_join(total_data, current_data, by = "연도")
  var_name <- paste0("total_", team)
  assign(var_name, total_data)
  
}

#확인
total_LG

# 모든 팀 스케일링 
library(scales)
scale_ranges <- c(0, 1)

for (team in teams) {
  df <- get(paste0("total_", team))
  scaled <- data.frame(
    연도 = df$연도, 
    AVG = rescale(df$AVG, to = scale_ranges),
    ERA = rescale(1 - df$ERA, to = scale_ranges), 
    # ERA은 평균 자책점 지표이기 때문에 숫자가 작을수록 좋다고 평가함. 
    # 따라서 시각화를 위해 1 에서 뺀값을 사용
    PO = rescale(df$PO, to = scale_ranges),
    SB  = rescale(df$'SB%', to = scale_ranges)
  )
  var_name <- paste0("total_scaled_", team)
  assign(var_name, scaled)
}

#확인
total_scaled_KIA

# 시각화 
opar <- par(no.readonly=T)
library(RColorBrewer)
colors <- brewer.pal(4, "Set2")

for (team in teams) {
  df <- get(paste0("total_scaled_", team))
  plot(df$연도, df$AVG, type = "l", lwd=2, col = colors[1], xlab = "연도", 
       ylab = "Scaled Value", ylim = c(-0.3, 1.4), 
       main = paste(team,"의 연도 별 지표 추이"), xaxt = "n")
  lines(df$연도, df$ERA, col = colors[2], lwd=2)
  lines(df$연도, df$PO, col = colors[3], lwd=2)
  lines(df$연도, df$SB, col = colors[4], lwd=2)
  legend("topright", legend = c("타자", "투수", "수비", "주루"), col = colors, 
         lty = 1, x.intersp = 0.5, y.intersp = 0.5, box.lwd = 1, box.col = "black")
  axis(side = 1, at = df$연도, labels = df$연도)
}


# 2-4. 공인구 반발계수 ##########################
#야구공 반발계수 데이터 불러오기 
ball <- read_excel('공인구 반발계수.xlsx')
str(ball)

#야구공 반발계수 선그래프
plot(ball$연도, ball$반발계수, type = "l",lty = 2, lwd=2, col = 'red', 
     xlab = "연도", ylab = "Value", main = "공인구 반발계수", xaxt = "n")
axis(side = 1, at = ball$연도, labels = ball$연도)
abline(v = 2019, col = "blue", lwd = 3)
text(2022,0.430, "반발계수 규정 변경", adj = c(0, 1), pos = 2, 
     col = "black", font = 2, cex = 0.8)

# 2-5. 지방팀/수도권 팀의 인기도 ##########################
# 데이터 불러오기 및 전처리를 위한 준비 단계
## 0. 필요한 라이브러리
library(readxl)
library(stringr)
library(dplyr)
library(car)
library(scales)

# 올스타전 데이터 ##############################################################
all <- read_excel('KBO 올스타전 베스트 12(2012-2022).xlsx', sheet='올스타전')

KIA <- sum(str_count(all, 'KIA'))
KT <- sum(str_count(all, 'KT'))
LG <- sum(str_count(all, 'LG')) 
NC <- sum(str_count(all, 'NC'))
SSG <- sum(str_count(all, 'SSG')) + sum(str_count(all, 'SK'))
두산 <- sum(str_count(all, '두산')) 
롯데 <- sum(str_count(all, '롯데'))
삼성 <- sum(str_count(all, '삼성'))
키움 <- sum(str_count(all, '키움')) + sum(str_count(all, '넥센'))
한화 <- sum(str_count(all, '한화'))

# 팀별 골든글러브 수상자 명단 합치기
all_star <- data.frame(KIA, KT, LG, NC,SSG,두산,롯데,삼성,키움,한화)

sum(all_star$all_star)

# 행열 전환
all_star <- data.frame(t(all_star))

# 팀명 붙이기
all_star$team <- rownames(all_star)

# 인덱스 초기화
rownames(all_star) <- NULL

# 컬럼명 변경
colnames(all_star) <- c('all_star','team')

# 컬럼 순서 변경
all_star <- select(all_star, team, all_star)

# scaling 0에서 1까지
scale_ranges <- c(0, 1)
all_star$all_star <- rescale(all_star$all_star, to = scale_ranges)


# 누적 시청자 수  ##############################################################
tv <- read_excel('KBO 누적 시청자 수 평균.xlsx')
tv <- as.data.frame(tv)

# scaling 0에서 1까지
tv$TV <- rescale(tv$TV, to=scale_ranges)


# 데이터 합치기 ##############################################################
popul <- left_join(all_star, tv, by=c('team'='구단'))

popul$scaled <- popul[,2] + popul[,3]
popul <- select(popul, team, scaled)

# 수도권팀 지방팀 구분하기
city <- c('두산', 'LG', 'SSG', '키움', 'NC')
non_city <- c('KIA', '삼성', '롯데', '한화', 'NC')

total_data <- popul %>%
  mutate(city = ifelse(team %in% city, '수도권', '지방'))

# 수도권 팀 인기, 지방팀 인기 평균
grouped_data <- total_data %>%
  group_by(city) %>%
  summarise(avg_scaled = mean(scaled)) %>%
  arrange(desc(row_number()))
grouped_data$city <- fct_rev(grouped_data$city) #지방팀의 강조를 위해 순서 변경
grouped_data

# 시각화
library(ggplot2)
library(forcats)
colors <-c("#1F78B4" ,"#A6CEE3") #막대 색깔지정 

ggplot(grouped_data, aes(x = city, y = avg_scaled, fill = city)) + 
  # city 별로 막대기 다르게
  geom_bar(stat = "identity") +
  scale_fill_manual(values = colors) +
  coord_cartesian(ylim = c(0.3, 1.1)) +
  labs(x = "수도권 여부", y = "인기도", title = "수도권 팀 vs 지방권 팀의 인기도 차이")+
  theme(legend.position = "none", # legend 없애기기
        plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
        plot.title.position = "plot")

# 2-6. 팀 별 연차 ##########################
#필요한 라이브러리
library(readxl)
library(dplyr)

#데이터 불러오기
team_made <- read_excel("구단창단일_data.xlsx")
team_made <- as.data.frame(team_made)
team_made$연차 <-2023-team_made$창단일
team_made$구단  <- factor(team_made$구단, levels = team_made$구단[order(team_made$연차)])

#확인
team_made
summary(team_made)
str(team_made)

#시각화
library(ggplot2)

colors <- c('black', 'steelblue', 'maroon', 'red', 'sienna1', 'dodgerblue', 
                   'red', 'midnightblue','hotpink', 'blue4')
                   ggplot(team_made, aes(x = 연차, y = 구단, fill = 구단)) +
                     geom_bar(stat = "identity") +
                     scale_fill_manual(values = colors) +
                     geom_text(aes(label = paste0(창단일,'년')), hjust = -0.3, color = "black") +
                     labs(x = "연차", y = "구단", title = "프로야구 팀별 연차") +
                     coord_cartesian(xlim = c(1, 46)) +
                     theme_minimal() +
                     theme(legend.position = "none",
                           plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
                           plot.title.position = "plot")


## 3. 승리방정식 ################
# 3-1. 공인구 반발계수 ##########################
## 3-1. 2014년 데이터 (타고투저)  ####################
pitch14 <- left_join(team_2014, pitcher_2014, by=c("팀명",'연도별'))
hit14 <- left_join(team_2014, hitter_2014, by=c("팀명",'연도별'))

dd14 <- left_join(pitch14, hit14, by=c("팀명",'연도별','승률','순위'))
dd14 <- as.data.frame(dd14)
print(dd14)

# full model : ERA, AVG
ll14 <- lm(승률~ERA+AVG,data=dd14)
summary(ll14)

# 다중공선성 여부 확인
vif(ll14)

###################################
#### 3-2. 2014년 항목별 회귀식과 비교
### 1) 투수 항목
pitch14 <- left_join(team_2014, pitcher_2014, by=c("팀명",'연도별'))

## (1) 데이터프레임화
pitch14 <- as.data.frame(pitch14)

## (2) 회귀 모형 설정 
pitch14_lm_base <- lm(승률~ERA+SV+HLD+IP+사사구+WHIP, data=pitch14)
summary(pitch14_lm_base)

## (3) 독립변수들 간의 다중공선성 확인
# 1. VIF 방식 
vif(pitch14_lm_base)

## 해석 : VIFs of ERA, HLD, IP, 사사구, WHIP > 10 -> 다중공선성 의심

# 2. 주성분 방식
# 종속변수와 독립변수만 남기기
pitch14_eigen <- pitch14[,-c(1,2,3)]

# correlation matrix
cor(pitch14_eigen)

# eigen value & vector
eigen(cor(pitch14_eigen))

# condition index
colldiag(pitch14_lm_base,,center=T,scale=T)

## 해석 : 일반적으로는 15를 기준으로 잡으나, VIF 값을 고려했을 때 multicollinearity 의심
## 결론 : 주성분을 만들어서 model reduction 진행


# 3. model reduction through principal components
pca_pitch14<-prcomp(pitch14_eigen[,-c(1,6,7,8)],center=TRUE,scale=TRUE)
pca_pitch14

# pca score (for the same result with the textbook)
(data.frame(pitch14_eigen[,-1],pca_pitch14$x))

## 회귀모형 설정
# full model
pitch14_full<-lm(pitch14_eigen$승률~pca_pitch14$x)
summary(pitch14_full)
## 모든 값이 유의하지 않음 -> p-value 값이 큰 순서대로 reduce


# reduced model (1번째 항목 빼고 제거)
pitch14_reduced<-lm(pitch14_eigen$승률 ~ pca_pitch14$x[,-c(2,3,4,5,6)])  
summary(pitch14_reduced)
## 해석 : p-value 값 유의하고, adjusted R-squared = 0.45로 승률에 대한 설명력 다소 미흡

##F test for reduced model vs full model (H0 : reduced model / H1 : full model)
anova(pitch14_reduced, pitch14_full) 

## 해석 : H0 채택, 즉 reduced model 채택


###################################################################
### 2) 타자 항목
hit14 <- left_join(team_2014, hitter_2014, by=c("팀명",'연도별'))

## (1) 데이터프레임화
hit14 <- as.data.frame(hit14)

## (2) 회귀 모형 설정 
hit14_lm_base <- lm(승률~AVG+TB+RBI, data=hit14)
summary(hit14_lm_base)

## (3) 독립변수들 간의 다중공선성 확인
# 1. VIF 방식 
vif(hit14_lm_base),
## 해석 : VIF값 준수

## 2. 주성분 방식
# condition index
colldiag(hit14_lm_base,,center=T,scale=T)

## 해석 : condition number도 준수
## 결론 : 다만 full model로 분석 진행 시 계속해서 에러가 뜨기 때문에 주성분을 만들어서 적당한 model reduction 진행

## 3. step-wise 방식을 통해 model reduction
hit14_step <- step(hit14_lm_base, direction="both")
# stepwise
formula(hit14_step)
summary(hit14_step)


### 결론 : 투수 항목 - 타자 항목 비교 결과, 투수 항목의 model이 설명력이 더 높음 (0.80 > 0.45)


#### 3-2. 2022년 승리방정식 (투고타저) ##################
pitch22 <- left_join(team_2022, pitcher_2022, by=c("팀명",'연도별'))
hit22 <- left_join(team_2022, hitter_2022, by=c("팀명",'연도별'))


dd22 <- left_join(pitch22, hit22, by=c("팀명",'연도별','승률','순위'))
dd22 <- as.data.frame(dd22)
print(dd22)


# full model : ERA, AVG
ll22 <- lm(승률~ERA+AVG,data=dd22)
summary(ll22)

# 다중공선성 여부 확인
vif(ll22)

# reduced model : ERA
ll22_reduced<-lm(승률~ERA,data=dd22)
summary(ll22_reduced)
## 해석 : 수정결정계수 값이 0.77으로 승률에 대한 설명력 높음
## 해석2 : full model보다 수정결정계수가 값이 크다 -> AVG가 회귀모형에서 방해가 되고 있었다는 뜻

anova(ll22_reduced,ll22)
## 해석 : AVG 유의하지 않음, 즉 ERA가 승률에 큰 영향을 끼침

######################################################

#### 3-2. 2022년 항목별 회귀식과 비교
### 1) 투수 항목
pitch22 <- left_join(team_2022, pitcher_2022, by=c("팀명",'연도별'))

## (1) 데이터프레임화
pitch22 <- as.data.frame(pitch22)

## (2) 회귀 모형 설정 
pitch22_lm_base <- lm(승률~ERA+SV+HLD+IP+사사구+WHIP, data=pitch22)
summary(pitch22_lm_base)

## (3) 독립변수들 간의 다중공선성 확인
# 1. VIF 방식 
vif(pitch22_lm_base)

## 해석 : VIFs of ERA, WHIP > 10 -> 다중공선성 의심

# 2. 주성분 방식
# 종속변수와 독립변수만 남기기
pitch22_eigen <- pitch22[,-c(1,2,3)]

# correlation matrix
cor(pitch22_eigen)

# eigen value & vector
eigen(cor(pitch22_eigen))

# condition index
colldiag(pitch22_lm_base,,center=T,scale=T)

## 해석 : 일반적으로는 15를 기준으로 잡으나, VIF 값을 고려했을 때 multicollinearity 의심
## 결론 : 주성분을 만들어서 model reduction 진행


# 3. model reduction through principal components
pca_pitch22<-prcomp(pitch22_eigen[,-c(1,6,7,8)],center=TRUE,scale=TRUE)
pca_pitch22

# pca score (for the same result with the textbook)
(data.frame(pitch22_eigen[,-1],pca_pitch22$x))

## 회귀모형 설정
# full model
pitch22_full<-lm(pitch22_eigen$승률~pca_pitch22$x)
summary(pitch22_full)
## 1번째 주성분을 제외한 모든 값이 유의하지 않음 -> reduced model로 확인


# reduced model (1번째 항목 빼고 다 제거)
pitch22_reduced<-lm(pitch22_eigen$승률 ~ pca_pitch22$x[,-c(2,3,4,5,6)])  
summary(pitch22_reduced)
## 해석 : p-value 값 유의하고, adjusted R-squared = 0.95로 승률에 대한 설명력 매우 높음

##F test for reduced model vs full model (H0 : reduced model / H1 : full model)
anova(pitch_reduced, pitch_full) 

## 해석 : H0 채택, 즉 reduced model 채택


###################################################################
### 2) 타자 항목
hit22 <- left_join(team_2022, hitter_2022, by=c("팀명",'연도별'))

## (1) 데이터프레임화
hit22 <- as.data.frame(hit22)

## (2) 회귀 모형 설정 
hit22_lm_base <- lm(승률~AVG+TB+RBI, data=hit22)
summary(hit22_lm_base)

## (3) 독립변수들 간의 다중공선성 확인
# 1. VIF 방식 
vif(hit22_lm_base)

## 해석 : VIF of TB > 15이므로 TB가 다중공선성의 원인이라고 할 수 있다.


## 2. 주성분 방식
# 종속변수와 독립변수만 남기기
hit22_eigen <- hit22[,-c(1,2,3)]

# correlation matrix
cor(hit22_eigen)

# eigen value & vector
eigen(cor(hit22_eigen))

# condition index
colldiag(hit22_lm_base,,center=T,scale=T)

## 해석 : 일반적으로는 15를 기준으로 잡으나, VIF 값을 고려했을 때 multicollinearity 의심
## 결론 : 주성분을 만들어서 model reduction 진행


## 3. model reduction through principal components
pca_hit22<-prcomp(hit22_eigen[,-1],center=TRUE,scale=TRUE)
pca_hit22

# pca score (for the same result with the textbook)
(data.frame(hit22_eigen[,-1],pca_hit22$x))

## 회귀모형 설정
# full model
hit22_full<-lm(hit22_eigen$승률~pca_hit22$x)
summary(hit22_full)
## 3번째 항목이 유의하지 않음 -> reduced model로 확인


# reduced model (3번째 항목 제거)
hit22_reduced<-lm(hit22_eigen$승률 ~ pca_hit22$x[,-3])  
summary(hit22_reduced)
## 해석 : p-value 값 유의하고, adjusted R-squared = 0.42로 승률에 대한 설명력 약간 미흡


##F test for reduced model vs full model (H0 : reduced model / H1 : full model)
anova(hit22_reduced, hit22_full) 
## 해석 : H0 채택, 즉 reduced model 채택

### 결론 : 투수 항목 - 타자 항목 비교 결과, 투수 항목의 model이 설명력이 더 높음 (0.95 > 0.42)



## 2019년 데이터 (투고타저) : 반발계수 2번째로 낮음 
pitch19 <- left_join(team_2019, pitcher_2019, by=c("팀명",'연도별'))
hit19 <- left_join(team_2019, hitter_2019, by=c("팀명",'연도별'))

dd19 <- left_join(pitch19, hit19, by=c("팀명",'연도별','승률','순위'))
dd19 <- as.data.frame(dd19)
print(dd19)

# full model : ERA, AVG
ll19 <- lm(승률~ERA+AVG,data=dd19)
summary(ll19)

# 다중공선성 여부 확인
vif(ll19)

# reduced model : ERA
ll19_reduced<-lm(승률~ERA,data=dd19)
summary(ll19_reduced)
## 해석 : 수정결정계수 값이 0.96으로 승률에 대한 설명력 매우 높음
## 해석2 : full model과 수정결정계수가 큰 차이가 안 남 -> AVG가 중요한 변수가 아니었다는 뜻

## 해석 : AVG 유의하지 않음, 즉 ERA가 승률에 큰 영향을 끼침

anova(ll19_reduced, ll19)


#### 3-2. 2019년 항목별 회귀식과 비교
### 1) 투수 항목
pitch19 <- left_join(team_2019, pitcher_2019, by=c("팀명",'연도별'))

## (1) 데이터프레임화
pitch19 <- as.data.frame(pitch19)

## (2) 회귀 모형 설정 
pitch19_lm_base <- lm(승률~ERA+SV+HLD+IP+사사구+WHIP, data=pitch19)
summary(pitch19_lm_base)

## (3) 독립변수들 간의 다중공선성 확인
# 1. VIF 방식 
vif(pitch19_lm_base)

## 해석 : VIFs of ERA, WHIP > 10 -> 다중공선성 의심

# 2. 주성분 방식
# 종속변수와 독립변수만 남기기
pitch19_eigen <- pitch19[,-c(1,2,3)]

# correlation matrix
cor(pitch19_eigen)

# eigen value & vector
eigen(cor(pitch19_eigen))

# condition index
colldiag(pitch19_lm_base,,center=T,scale=T)

## 해석 : condition number > 15 이므로 multicollinearity 의심
## 결론 : 주성분을 만들어서 model reduction 진행


# 3. model reduction through principal components
pca_pitch19<-prcomp(pitch19_eigen[,-c(1,6,7,8)],center=TRUE,scale=TRUE)
pca_pitch19

# pca score (for the same result with the textbook)
(data.frame(pitch19_eigen[,-1],pca_pitch19$x))

## 회귀모형 설정
# full model
pitch19_full<-lm(pitch19_eigen$승률~pca_pitch19$x)
summary(pitch19_full)
## 모든 값이 유의하지 않음 -> p-value 값이 큰 순서대로 reduce


# reduced model (1,3,5번째 항목 빼고 제거)
pitch19_reduced<-lm(pitch19_eigen$승률 ~ pca_pitch19$x[,-c(2,4,6)])  
summary(pitch19_reduced)
## 해석 : p-value 값 유의하고, adjusted R-squared = 0.99로 승률에 대한 설명력 매우 높음

##F test for reduced model vs full model (H0 : reduced model / H1 : full model)
anova(pitch19_reduced, pitch19_full) 

## 해석 : H0 채택, 즉 reduced model 채택 -> 투수 관련 변수가 승률에 더 큰 영향을 끼침

###################################################################
### 2) 타자 항목
hit19 <- left_join(team_2019, hitter_2019, by=c("팀명",'연도별'))

## (1) 데이터프레임화
hit19 <- as.data.frame(hit19)

## (2) 회귀 모형 설정 
hit19_lm_base <- lm(승률~AVG+TB+RBI, data=hit19)
summary(hit19_lm_base)

## (3) 독립변수들 간의 다중공선성 확인
# 1. VIF 방식 
vif(hit19_lm_base)

## 해석 : VIF값 준수


## 2. 주성분 방식
# 종속변수와 독립변수만 남기기
hit19_eigen <- hit19[,-c(1,2,3)]

# correlation matrix
cor(hit19_eigen)

# eigen value & vector
eigen(cor(hit19_eigen))

# condition index
colldiag(hit19_lm_base,,center=T,scale=T)

## 해석 : condition number도 준수
## 결론 : full model로 분석 진행 시 계속해서 에러가 뜨기 때문에 step-wise 방식을 통해 reduced model 설정

## 3. step-wise 방식으로 reduced model 설정
hit19_step <- step(hit19_lm_base, direction="both") # stepwise
formula(hit19_step)
summary(hit19_step)


### 결론 : 투수 항목 - 타자 항목 비교 결과, 투수 항목의 model이 설명력이 더 높음 (0.99 > 0.62)

# 3-2. 팀별 승리방정식 ##########################
## 1) KIA
# 타자 데이터
df_win_KIA <- df_win[df_win$"팀명"=="KIA",]
df_win_KIA

KIA_hitter=as.data.frame(read_excel("타자_팀별_data.xlsx",sheet="KIA")) #팀별 타자 데이터에서 필요한 팀 데이터만 불러오기
KIA_hitter<- select(KIA_hitter, -G, -PA, -AB, -R, -H, -'2B', -'3B', -HR, -TB, -SF, -SAC) #다중공선성 검정으로 불필요한 변수 삭제
KIA_hitter
KIA_total<-merge(df_win_KIA,KIA_hitter,by='연도') #연도를 기준으로 dataframe 합치기
KIA_total

# 투수 데이터
df_win_KIA <- df_win[df_win$"팀명"=="KIA",]
KIA_pitcher=as.data.frame(read_excel("투수_팀별_data.xlsx",sheet="KIA"))
KIA_pitcher<- select(KIA_pitcher, -G, -W, -L, -WPCT, -H, -HR, - R, -ER)
KIA_pitcher <- mutate(KIA_pitcher, 사사구=BB+HBP)
KIA_total2<-merge(df_win_KIA,KIA_pitcher,by='연도')#연도를 기주능로 dataframe 합치기


# 승리 방정식
KIA <- left_join(KIA_total, KIA_total2, by=c('연도','순위','팀명','승률'))
lm_kia <- lm(승률~ERA+AVG, data=KIA)
summary(lm_kia)

## 해석 : y_hat = =0.07ERA + 2.65AVG

## 2) 삼성
# 타자 데이터
df_win_SS <- df_win[df_win$"팀명"=="삼성",]

SS_hitter=as.data.frame(read_excel("타자_팀별_data.xlsx",sheet="삼성"))
SS_hitter<- select(SS_hitter, -G, -PA, -AB, -R, -H, -'2B', -'3B', -HR, -TB, -SF, -SAC)
SS_hitter
SS_total<-merge(df_win_SS,SS_hitter,by='연도')
SS_total

# 투수 데이터
SS_pitcher=as.data.frame(read_excel("투수_팀별_data.xlsx",sheet="삼성"))
SS_pitcher<- select(SS_pitcher, -G, -W, -L, -WPCT, -H, -HR, - R, -ER)
SS_pitcher <- mutate(SS_pitcher, 사사구=BB+HBP)
SS_total2<-merge(df_win_SS,SS_pitcher,by='연도')#연도를 기주능로 dataframe 합치기

# 회귀식
ss <- left_join(SS_total, SS_total2, by=c('연도','순위','팀명','승률'))
lm_ss <- lm(승률~ERA+AVG, data=ss)
summary(lm_ss)

## 해석 : y_hat = -0.11ERA + 3.76AVG

## 3) LG
# 타자 데이터
df_win_LG <- df_win[df_win$"팀명"=="LG",]

LG_hitter=as.data.frame(read_excel("타자_팀별_data.xlsx",sheet="LG"))
LG_hitter<- select(LG_hitter, -G, -PA, -AB, -R, -H, -'2B', -'3B', -HR, -TB, -SF, -SAC)
LG_hitter
LG_total<-merge(df_win_LG,LG_hitter,by='연도')

# 투수 데이터
df_win_LG <- df_win[df_win$"팀명"=="LG",]
LG_pitcher=as.data.frame(read_excel("투수_팀별_data.xlsx",sheet="LG"))
LG_pitcher<- select(LG_pitcher, -G, -W, -L, -WPCT, -H, -HR, - R, -ER)
LG_pitcher <- mutate(LG_pitcher, 사사구=BB+HBP)
LG_total2<-merge(df_win_LG,LG_pitcher,by='연도')#연도를 기주능로 dataframe 합치기

# 회귀식
lg <- left_join(LG_total, LG_total2, by=c('연도','순위','팀명','승률'))
lm_lg <- lm(승률~ERA+AVG, data=lg)
summary(lm_lg)

## 해석 : y_hat = -0.1ERA + 3.14AVG

## 3) LG
# 타자 데이터
df_win_LG <- df_win[df_win$"팀명"=="LG",]

LG_hitter=as.data.frame(read_excel("타자_팀별_data.xlsx",sheet="LG"))
LG_hitter<- select(LG_hitter, -G, -PA, -AB, -R, -H, -'2B', -'3B', -HR, -TB, -SF, -SAC)
LG_hitter
LG_total<-merge(df_win_LG,LG_hitter,by='연도')

# 투수 데이터
df_win_LG <- df_win[df_win$"팀명"=="LG",]
LG_pitcher=as.data.frame(read_excel("투수_팀별_data.xlsx",sheet="LG"))
LG_pitcher<- select(LG_pitcher, -G, -W, -L, -WPCT, -H, -HR, - R, -ER)
LG_pitcher <- mutate(LG_pitcher, 사사구=BB+HBP)
LG_total2<-merge(df_win_LG,LG_pitcher,by='연도')#연도를 기주능로 dataframe 합치기

# 회귀식
lg <- left_join(LG_total, LG_total2, by=c('연도','순위','팀명','승률'))
lm_lg <- lm(승률~ERA+AVG, data=lg)
summary(lm_lg)

## 해석 : y_hat = -0.1ERA + 3.14AVG

# 5) NC

#타자 데이터
df_win_NC <- df_win[df_win$"팀명"=="NC",]

NC_hitter=as.data.frame(read_excel("타자_팀별_data.xlsx",sheet="NC"))
NC_hitter<- select(NC_hitter, -G, -PA, -AB, -R, -H, -'2B', -'3B', -HR, -TB, -SF, -SAC)

NC_total<-merge(df_win_NC,NC_hitter,by='연도')

#투수 데이터

df_win_NC <- df_win[df_win$"팀명"=="NC",]
NC_pitcher=as.data.frame(read_excel("투수_팀별_data.xlsx",sheet="NC"))
NC_pitcher<- select(NC_pitcher, -G, -W, -L, -WPCT, -H, -HR, - R, -ER)
NC_pitcher <- mutate(NC_pitcher, 사사구=BB+HBP)
NC_total2<-merge(df_win_NC,NC_pitcher,by='연도')#연도를 기주능로 dataframe 합치기

#승리방정식
NC <- left_join(NC_total, NC_total2, by=c('연도','순위','팀명','승률'))
lm <- lm(승률~ERA+AVG, data=NC)
summary(lm)

## 해석 : y_hat = =0.04ERA + 3.89AVG

 # 6) 두산

# 타자데이터

df_win_DS <- df_win[df_win$"팀명"=="두산",]

DS_hitter=as.data.frame(read_excel("타자_팀별_data.xlsx",sheet="두산"))
DS_hitter<- select(DS_hitter, -G, -PA, -AB, -R, -H, -'2B', -'3B', -HR, -TB, -SF, -SAC)

DS_total<-merge(df_win_DS,DS_hitter,by='연도')
# 투수데이터
df_win_DS <- df_win[df_win$"팀명"=="두산",]
DS_pitcher=as.data.frame(read_excel("투수_팀별_data.xlsx",sheet="두산"))
DS_pitcher<- select(DS_pitcher, -G, -W, -L, -WPCT, -H, -HR, - R, -ER)
DS_pitcher <- mutate(DS_pitcher, 사사구=BB+HBP)
DS_total2<-merge(df_win_DS,DS_pitcher,by='연도')

#승리방정식
DS <- left_join(DS_total, DS_total2, by=c('연도','순위','팀명','승률'))
lm <- lm(승률~ERA+AVG, data=DS)
summary(lm)

## 해석 : y_hat = =0.10ERA +4.80AVG

# 7) 한화

# 타자데이터
df_win_HW <- df_win[df_win$"팀명"=="한화",]


HW_hitter=as.data.frame(read_excel("타자_팀별_data.xlsx",sheet="한화"))
HW_hitter<- select(HW_hitter, -G, -PA, -AB, -R, -H, -'2B', -'3B', -HR, -TB, -SF, -SAC)

HW_total<-merge(df_win_HW,HW_hitter,by='연도')
# 투수데이터
df_win_HW <- df_win[df_win$"팀명"=="한화",]
HW_pitcher=as.data.frame(read_excel("투수_팀별_data.xlsx",sheet="한화"))
HW_pitcher<- select(HW_pitcher, -G, -W, -L, -WPCT, -H, -HR, - R, -ER)
HW_pitcher <- mutate(HW_pitcher, 사사구=BB+HBP)
HW_total2<-merge(df_win_HW,HW_pitcher,by='연도')

#회귀식
HW <- left_join(HW_total, HW_total2, by=c('연도','순위','팀명','승률'))
lm <- lm(승률~ERA+AVG, data=HW)
summary(lm)

## 해석 : y_hat = =0.08ERA + 3.46AVG

# 8) KT
# 타자 데이터
df_win_KT <- df_win[df_win$"팀명"=="KT",]
KT_hitter=as.data.frame(read_excel("타자_팀별_data.xlsx",sheet="KT"))
KT_hitter<- select(KT_hitter, -G, -PA, -AB, -R, -H, -'2B', -'3B', -HR, -TB, -SF, -SAC)

KT_total<-merge(df_win_KT,KT_hitter,by='연도')
KT_total
# 투수 데이터
KT_pitcher=as.data.frame(read_excel("투수_팀별_data.xlsx",sheet="KT"))
KT_pitcher<- select(KT_pitcher, -G, -W, -L, -WPCT, -H, -HR, - R, -ER)
KT_pitcher <- mutate(KT_pitcher, 사사구=BB+HBP)
KT_total2<-merge(df_win_KT,KT_pitcher,by='연도')#연도를 기주능로 dataframe 합치기
# 회귀식
KT <- left_join(KT_total, KT_total2, by=c('연도','순위','팀명','승률'))
lm_KT <- lm(승률~ERA+AVG, data=KT)
summary(lm_KT)
## 해석 : y_hat = -0.11ERA + 3.47AVG

# 9) 키움
# 타자 데이터
df_win_KW <- filter(df_win, 팀명 %in% c('키움','넥센'))
KW_hitter=as.data.frame(read_excel("타자_팀별_data.xlsx",sheet="키움"))
KW_hitter<- select(KW_hitter, -G, -PA, -AB, -R, -H, -'2B', -'3B', -HR, -TB, -SF, -SAC)
KW_hitterKW_total<-merge(df_win_KW,KW_hitter,by='연도')
KW_total

# 투수 데이터
KW_pitcher=as.data.frame(read_excel("투수_팀별_data.xlsx",sheet="키움"))
KW_pitcher<- select(KW_pitcher, -G, -W, -L, -WPCT, -H, -HR, - R, -ER)
KW_pitcher <- mutate(KW_pitcher, 사사구=BB+HBP)KW_total2<-merge(df_win_KW,KW_pitcher,by='연도')

# 회귀식KW <- left_join(KW_total, KW_total2, by=c('연도','순위','팀명','승률'))
lm_KW <- lm(승률~ERA+AVG, data=KW)summary(lm_KW)

## 해석 : y_hat = -0.11ERA + 3.47AVG


## 4. 인기도 ################
## 0. 필요한 라이브러리 ###########
library(readxl)
library(stringr)
library(dplyr)
library(car)
library(randtests)
library(lmtest)
library(scales)
remotes::install_github("cran/perturb")
library(perturb)

####### 1. 종속변수 - 인기도 척도 : 올스타전, TV 누적 시청자 수 ############
## 1-1. 데이터 불러오기
# 1) 올스타전 데이터
all <- read_excel('KBO 올스타전 베스트 12(2012-2022).xlsx', sheet='올스타전')

KIA <- sum(str_count(all, 'KIA'))
KT <- sum(str_count(all, 'KT'))
LG <- sum(str_count(all, 'LG')) 
NC <- sum(str_count(all, 'NC'))
SSG <- sum(str_count(all, 'SSG')) + sum(str_count(all, 'SK'))
두산 <- sum(str_count(all, '두산')) 
롯데 <- sum(str_count(all, '롯데'))
삼성 <- sum(str_count(all, '삼성'))
키움 <- sum(str_count(all, '키움')) + sum(str_count(all, '넥센'))
한화 <- sum(str_count(all, '한화'))

# 팀별 골든글러브 수상자 명단 합치기
all_star <- data.frame(KIA, KT, LG, NC,SSG,두산,롯데,삼성,키움,한화)

sum(all_star$all_star)

# 행열 전환
all_star <- data.frame(t(all_star))

# 팀명 붙이기
all_star$team <- rownames(all_star)

# 인덱스 초기화
rownames(all_star) <- NULL

# 컬럼명 변경
colnames(all_star) <- c('all_star','team')

# 컬럼 순서 변경
all_star <- select(all_star, team, all_star)



## 2) 누적 시청자 수
tv <- read_excel('KBO 누적 시청자 수 평균.xlsx')
tv <- as.data.frame(tv)



## 1-2. 인기도 데이터 합치기
popul <- left_join(tv, all_star, by=c('구단'='team'))


## 1-3. 인기도 스케일링 
scale_ranges <- c(0, 1)
total_scaled <- data.frame(
  team = popul$구단, 
  all_star = rescale(popul$all_star, to = scale_ranges),
  TV = rescale(popul$TV, to = scale_ranges)
)

total_scaled$scaled <- total_scaled[,2] + total_scaled[,3]
total_scaled <- select(total_scaled, team, scaled)


####### 2. 독립변수 데이터 : 우승횟수, 팀 연차, 국가대표, 골든글러브 수상자, 승률 데이터 ###########
### 1) 팀별 골든글러브 수상자 명수 #############
## (1) 데이터 불러오기
golden <- read_excel('KBO 올스타전 베스트 12(2012-2022).xlsx', sheet='KBO 골든글러브')
golden

## (2) 데이터셋 삽입
KIA <- sum(str_count(golden, 'KIA')) + sum(str_count(golden, '해태'))
KT <- sum(str_count(golden, 'KT'))
LG <- sum(str_count(golden, 'LG')) + sum(str_count(golden, 'MBC'))
NC <- sum(str_count(golden, 'NC'))
SSG <- sum(str_count(golden, 'SSG')) + sum(str_count(golden, 'SK'))
두산 <- sum(str_count(golden, '두산')) + sum(str_count(golden, 'OB'))
롯데 <- sum(str_count(golden, '롯데'))
삼성 <- sum(str_count(golden, '삼성'))
키움 <- sum(str_count(golden, '키움')) + sum(str_count(golden, '넥센'))
한화 <- sum(str_count(golden, '한화')) +sum(str_count(golden, '빙그레'))

# 팀별 골든글러브 수상자 명단 합치기
gold <- data.frame(KIA, KT, LG, NC,SSG,두산,롯데,삼성,키움,한화)

# 행열 전환
gg <- data.frame(t(gold))

# 팀명 붙이기
gg$team <- rownames(gg)

# 인덱스 초기화
rownames(gg) <- NULL

# 컬럼명 변경
colnames(gg) <- c('golden','team')

# 컬럼 순서 변경
gg <- select(gg, team, golden)

### 2) 우승횟수, 팀 연차, 국가대표
## (1) 데이터 불러오기
a <- read_excel("한국시리즈 우승_data.xlsx")
b <- read_excel("구단창단일_data.xlsx")
c <- read_excel("역대국가대표_data.xlsx")
df_a <- as.data.frame(a)
df_b <- as.data.frame(b)
df_c <- as.data.frame(c)
df_b$연차 <-2023-df_b$창단일
df_b

## (2) 데이터 합치기
df_ab<-merge(df_a,df_b,by='구단')
df_total<-merge(df_ab,df_c,by='구단')
df <- select(df_total,-'창단일')
df

### 3) 승률 
rank <- read_excel('팀성적.xlsx')
rank$팀명[rank$팀명 == "넥센"] <- "키움"
rank$팀명[rank$팀명 == "SK"] <- "SSG"

avg_vic <- rank %>%
  group_by(팀명) %>%
  summarise(avg_vic = mean(승률)) %>%
  arrange(avg_vic)

## 독립변수 전부 합치기
df <- left_join(df, gg, by=c('구단'='team')) %>% 
  left_join(., avg_vic, by=c('구단' = '팀명'))

### 3) 데이터 분석
# KT는 올스타, TV 모두 0(최솟값)을 가지므로 이상점으로 분류, 따라서 분석 시 제외
total <- left_join(df, total_scaled, by=c('구단'='team'))
total <- total[-2,]

# 인덱스 초기화
rownames(total) <- NULL
colnames(total)[colnames(total) == "avg_vic"] <- "승률"


##### 3. 기본 회귀 모형 설정 ###################
## 3-1. full model
ll_full <- lm(scaled~우승횟수+연차+국가대표+golden, data=total)
summary(ll_full)
## 해석 : golden 값이 유의하지 않음 -> 빼고 회귀분석 해보자


## 3-2 reduced model
ll_reduced <- lm(scaled~우승횟수+연차+국가대표, data=total)
summary(ll_reduced)
## 해석 : 수정결정계수 값에 큰 차이가 없다 (0.93->0.92) 즉, 인기도를 설명하기에 설명력있는 독립변수가 아니었다.

## anova test
## H0 : coefficient of golden = 0 (reduced model) vs. H1 : Not H0 (full model)
anova(ll_reduced, ll_full)
## 해석 : p-value 값이 0.05보다 크다. 즉 유의하지 않으므로 H0 기각X -> reduced model 채택


## 3-3 회귀 진단
# 이상점 진단
residuals <- rstandard(ll_reduced)
plot(residuals, ylim=c(-2.2,2.2))
abline(h=2,col="red",lty=3)
abline(h=-2,col="red",lty=3)
## 해석 : (-2,2) 구간에 포진하고 있으므로 이상점 없음

# 영향점 진단
# (1) cook's distance
c <- cooks.distance(ll_full)
plot(c, ylim=c(0,1.1))
abline(h=0.965,col="red",lty=3)

## 보통 C>1 혹은 C >= F(p+1, n-p-1 ; 0.50) 이면 영향점
## 위의 경우 F 값이 0.965로, plot을 보면 알 수 있듯 모든 값이 0.965보다 작은 값을 가진다 -> 영향점 없음

# (2) DFITS
dfits <- dffits(ll_reduced)

## |DFITS| >= 2*sqrt{(p+1)/(n-p-1)} 이라는 공식에 따라 DFITS 판단 기준은 다음과 같이 +-1.79임
dff<-2*sqrt((3+1)/(9-3-1))

plot(dfits, ylim=c(-2,2))
abline(h=dff,col="red",lty=3)
abline(h=-dff,col="red",lty=3)
identify(dfits)
## plot을 통해 두산베어스의 관측치가 -2.11로 기준치 -1.79를 초과함을 알 수 있다.
## 이는 두산베어스의 국가대표값이 타 구단에 비해 월등히 높기 때문으로 생각된다.
## 그러나 cook's distance에서도 보았듯 다른 구단과 큰 차이를 보이지 않으므로, 유의한 영향점으로 판단하지 않고 현 모델 유지



####  4.오차항의 독립성 진단 #################
# 1) runs test
##양측검정
runs.test(ll_reduced$residuals,alternative="two.sided",
          threshold=0,plot=TRUE)
#### 해석 : 둘 다 p-value가 유의하지 않으므로 auto-correlation 없음


# 2) dw test
##양측검정
dwtest(ll_reduced, alternative="two.sided")
#### 해석 : auto-correlation 없음.


#### 5. 다중공선성 여부 확인 #########
## 1) VIF
vif(ll_reduced)
## 해석 : 다중공선성 문제 없음

## 2) 주성분 방식
# condition index
colldiag(ll_reduced,,center=T,scale=T)

## 해석 : condition number 이상 없음
## 결론 : 3개의 변수 간 다중 공선성 없음.


#### 추가 분석 - <인기도와 승률의 관계> ################
### 승률이 인기도에 영향을 끼치는가
### 인기도에서 제외한 것처럼 KT는 제외하고 분석
vic <- lm(scaled~승률, data=total)
summary(vic)
## 해석 : 승률에 대한 인기도 회귀 모형은 유의하지 않다. 따라서 인기도는 승률에 비례하지 않는다.





