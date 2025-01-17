#install.packages("data.table")
#install.packages("fst")
#install.packages("lubridate")

#import library
library(haven)
library(data.table)
library(magrittr)
library(fst)
library(lubridate)
library(parallel)

# Set core number when data.table 
setDTthreads(0) ## 0 : using all core

## SAS to csv
for (v in c("bnc", "bnd", "m20", "m30", "m40", "m60", "inst", "g1e_0208", "g1e_0915")){
  read_sas(file.path("data", paste0("nsc2_", v, "_1000.sas7bdat"))) %>% 
    fwrite(file.path("data", paste0("nsc2_", v, "_1000.csv")))
}

# csv 파일 읽어오기
inst <- fread("data/nsc2_inst_1000.csv")
bnc <- fread("data/nsc2_bnc_1000.csv")
bnd <- fread("data/nsc2_bnd_1000.csv")
m20 <- fread("data/nsc2_m20_1000.csv")
m30 <- fread("data/nsc2_m30_1000.csv")
m40 <- fread("data/nsc2_m40_1000.csv")
m60 <- fread("data/nsc2_m60_1000.csv")
g1e_0915 <- fread("data/nsc2_g1e_0915_1000.csv")

#데이터 전처리
##bnd에서 새로운 변수 Deathdate 만들기
bnd <- bnd[, Deathdate := (lubridate::ym(DTH_YYYYMM) %>% lubridate::ceiling_date(unit = "month") - 1)][]

##m40에서 SICK_CLSF_TYPE가 3인 데이터 제외
# 1: 주상병, 2: 부상병, 3: 배제된 상병
m40 <- m40[SICK_CLSF_TYPE %in% c(1,2,NA)]

#Inclusion
##Hypertensive disease
code.HTN <- paste(paste0("I", 10:15), collapse = "|")
code.HTN

data.start <- m20[like(SICK_SYM1, code.HTN) & (MDCARE_STRT_DT >= 20060101), .(Indexdate = min(MDCARE_STRT_DT)), keyby = "RN_INDI"]
# 사람 별로 첫 진단일만 뽑음

#Exclusion
#제외대상
excl <- m40[MCEX_SICK_SYM %like% code.HTN & (MDCARE_STRT_DT < 20060101), .SD[1], .SDcols = c("MDCARE_STRT_DT"), keyby = "RN_INDI"]

#anti-join으로 excl 제외 후 Indexdate의 타입을 character에서 date로 변경
data.incl <- data.start[!excl, on = "RN_INDI"][, Indexdate := as.Date(as.character(Indexdate), format = "%Y%m%d")][]

##data.incl에 age, sex, death 변수 추가
data.asd <- merge(bnd, bnc[, .(SEX = SEX[1]), keyby = "RN_INDI"], by = "RN_INDI") %>% 
  merge(data.incl, by = "RN_INDI") %>%
  .[, ':='(Age = year(Indexdate) - as.integer(substr(BTH_YYYY, 1, 4)), 
           Death = as.integer(!is.na(DTH_YYYYMM)), 
           Day_FU = as.integer(pmin(as.Date("2015-12-31"), Deathdate, na.rm = T) - Indexdate))] %>% 
  .[, -c("BTH_YYYY", "DTH_YYYYMM", "Deathdate")]

data.asd

#CCI 계산 
code.cci <- list(
  MI = c("I21", "I22", "I252"),
  CHF = c(paste0("I", c("099", 110, 130, 132, 255, 420, 425:429, 43, 50)), "P290"),
  Peripheral_VD = c(paste0("I", c(70, 71, 731, 738, 739, 771, 790, 792)), paste0("K", c(551, 558, 559)), "Z958", "Z959"),
  Cerebro_VD = c("G45", "G46", "H340", paste0("I", 60:69)),
  Dementia = c(paste0("F0", c(0:3, 51)), "G30", "G311"),
  Chronic_pulmonary_dz = c("I278", "I279", paste0("J", c(40:47, 60:67, 684, 701, 703))),
  Rheumatologic_dz = paste0("M", c("05", "06", 315, 32:34, 351, 353, 360)),
  Peptic_ulcer_dz = paste0("K", 25:28),
  Mild_liver_dz = c("B18", paste0("K", c(700:703, 709, 713:715, 717, 73, 74, 760, 762:764, 768, 769)), "Z944"),
  DM_no_complication = paste0("E", c(100, 101, 106, 108:111, 116, 118:121, 126, 128:131, 136, 138:141, 146, 148, 149)),
  DM_complication = paste0("E", c(102:105, 107, 112:115, 117, 122:125, 127, 132:135, 137, 142:145, 147)),
  Hemi_paraplegia = paste0("G", c("041", 114, 801, 802, 81, 82, 830:834, 839)),
  Renal_dz = c("I120", "I131", paste0("N", c("032", "033", "034", "035", "036", "037", "052", "053", "054", "055", "056", "057", 18, 19, 250)), paste0("Z", c(490:492, 940, 992))),
  Malig_with_Leuk_lymphoma = paste0("C", c(paste0("0", 0:9), 10:26, 30:34, 37:41, 43, 45:58, 60:76, 81:85, 88, 90, 97)),
  Moderate_severe_liver_dz = c(paste0("I", c(85, 859, 864, 982)), paste0("K", c(704, 711, 721, 729, 765:767))),
  Metastatic_solid_tumor = paste0("C", 77:80),
  AIDS_HIV = paste0("B", c(20:22, 24)))

#각 병에 해당하는 CCI Score 지정
cciscore <- c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 6, 6, 2)   # CCI score
names(cciscore) <- names(code.cci)

#과거력 확인
info.cci <- mclapply(names(code.cci), function(x){
  data.asd[, MDCARE_STRT_DT := Indexdate]
  dt <- m40[like(MCEX_SICK_SYM, paste(code.cci[[x]], collapse = "|"))][, MDCARE_STRT_DT := as.Date(as.character(MDCARE_STRT_DT), format = "%Y%m%d")][, .(RN_INDI, MDCARE_STRT_DT, Incidate = MDCARE_STRT_DT)]  
  dt[, .SD[1], keyby = c("RN_INDI", "MDCARE_STRT_DT")][data.asd, on = c("RN_INDI", "MDCARE_STRT_DT"), roll = 365][, ev := as.integer(!is.na(Incidate))][]$ev * cciscore[x]
}, mc.cores = 4) %>%  do.call(cbind, .) %>% cbind(rowSums(.))

colnames(info.cci) <- c(paste0("Prev_", names(code.cci)), "CCI")   # set column names

#과거 약 복용 이력 확인
code.drug <- list(
  Glucocorticoids = c("116401ATB", "140801ATB", "141901ATB", "141903ATB", "160201ATB", "170901ATB", "170906ATB", "193302ATB",
                      "193305ATB", "217034ASY", "217035ASY", "217001ATB", "243201ATB", "243202ATB", "243203ATB"),
  Aspirin = c("110701ATB", "110702ATB", "111001ACE", "111001ATE", "489700ACR", "517900ACE", "517900ATE", "667500ACE"),
  Clopidogrel = c("136901ATB", "492501ATB", "495201ATB", "498801ATB", "501501ATB", "517900ACE", "517900ATE", "667500ACE")
)

info.prevmed <- mclapply(code.drug, function(x){
  data.asd[, MDCARE_STRT_DT := Indexdate]
  dt <- m60[GNL_NM_CD %in% x][, MDCARE_STRT_DT := as.Date(as.character(MDCARE_STRT_DT), format = "%Y%m%d")][, .(RN_INDI, MDCARE_STRT_DT, inidate = MDCARE_STRT_DT)] 
  dt[, .SD[1], keyby = c("RN_INDI", "MDCARE_STRT_DT")][data.asd, on = c("RN_INDI", "MDCARE_STRT_DT"), roll = 365][, ev := as.integer(!is.na(inidate))][]$ev
}, mc.cores = 3) %>% do.call(cbind, .)

colnames(info.prevmed) <- paste0("Prev_", names(code.drug))  # set column names

data.asd[, MDCARE_STRT_DT := Indexdate]

info.MI <- m40 %>% 
  .[like(MCEX_SICK_SYM, paste(code.cci[["MI"]], collapse = "|")), .(RN_INDI, MDCARE_STRT_DT = as.Date(as.character(MDCARE_STRT_DT), format = "%Y%m%d"), MIdate = as.Date(as.character(MDCARE_STRT_DT), format = "%Y%m%d"))] %>%
  .[data.asd, on = c("RN_INDI", "MDCARE_STRT_DT"), roll = -Inf] %>% 
  .[Indexdate <= MIdate] %>% 
  .[order(MIdate), .(MI = 1, MIday = as.integer(MIdate - Indexdate)[1]), keyby = "RN_INDI"]

data.final <- cbind(data.asd, info.cci, info.prevmed) %>% merge(info.MI, by = "RN_INDI", all.x = T) %>% .[, `:=`(MI = as.integer(!is.na(MI)),
                                                                                                                 MIday = pmin(Day_FU, MIday, na.rm = T))] %>% .[]


var.factor <- c("COD1", "COD2", "SEX", "Death", grep("Prev_", names(data.final), value = T), "MI")

##최종 데이터
data.final[, (var.factor) := lapply(.SD, factor), .SDcols = var.factor]
data.final

##Drug_exposure 1
# Set core number when data.table
setDTthreads(0)  ## 0: All

## Drug code
code.ppi <-  c("367201ACH", "367201ATB", "367201ATD", "367202ACH", "367202ATB", 
               "367202ATD", "498001ACH", "498002ACH", "509901ACH", "509902ACH", 
               "670700ATB", "204401ACE", "204401ATE", "204402ATE", "204403ATE", 
               "664500ATB", "640200ATB", "664500ATB", "208801ATE", "208802ATE", 
               "656701ATE", "519201ATE", "519202ATE", "656701ATE", "519203ATE", 
               "222201ATE", "222202ATE", "222203ATE", "181301ACE", "181301ATD", 
               "181302ACE", "181302ATD", "181302ATE", "621901ACR", "621902ACR", 
               "505501ATE")


## drug user: select max TOT_MCNT among RK_KEY
m60.drug <- m60[GNL_NM_CD %in% code.ppi][order(MDCARE_STRT_DT, TOT_MCNT), .SD[.N], keyby = "RN_KEY"] 


## Change to date
m60.drug[, MDCARE_STRT_DT := lubridate::ymd(MDCARE_STRT_DT)]
#m60.drug[, MDCARE_STRT_DT := as.Date(MDCARE_STRT_DT, format = "%Y%m%d")]

## Function- duration: Drug duration, Gap: gap
dur_conti <- function(indi, duration = 180, gap = 30){
  data.ind <- m60.drug[RN_INDI == indi, .(start = MDCARE_STRT_DT, TOT_MCNT)]
  
  ## Drug date list
  datelist <- lapply(1:nrow(data.ind), function(x){data.ind[x, seq(start, start + TOT_MCNT, by = 1)]}) %>% 
    do.call(c, .) %>% unique %>% sort
  df <- diff(datelist)
  ## Gap change
  df[df <= gap] <- 1
  
  ## New datelist
  datelist2 <- datelist[1] + c(0, cumsum(as.integer(df)))
  
  ## Conti duration 
  res <- data.table(RN_INDI = indi, 
                    start = datelist, 
                    dur_conti = sapply(seq_along(datelist2), function(v){
                      zz <- datelist2[v:length(datelist2)]
                      return(ifelse(any(diff(zz) > 1), which(diff(zz) > 1)[1] - 1, length(zz) - 1))
                    }))
  return(res[dur_conti >= duration][1])
}

## Result: Use multicore
parallel::mclapply(unique(m60.drug$RN_INDI), dur_conti, duration = 180, mc.cores = 4) %>% rbindlist() %>% .[!is.na(RN_INDI)]
dur_conti(indi = 80234)

#생존분석 실행
install.packages("survival")
install.packages("survminer")
install.packages("ggplot2")
install.packages("ggpubr")

library(ggplot2)
library(ggpubr)
library(survival)
library(survminer)
survminer::myeloma  # survminer 패키지의 myeloma 데이터 사용

##오류 해결
table(data.final$Death, useNA = "ifany")
str(data.final$Death)
#Death의 type이 factor 또는 문자형 : 숫자형으로 변경 필요 



####MI 발생 여부에 따른 생존 분석 ####
# Kaplan-Meier 생존 분석 모델 생성
km_fit <- survfit(Surv(Day_FU, Death) ~ MI, data = data.final)

# 생존 곡선 시각화
ggsurvplot(
  km_fit,
  data = data.final,
  risk.table = TRUE,       # 위험집단 표 출력
  pval = TRUE,             # p-value 출력 (그룹 간 차이 검정)
  conf.int = TRUE,         # 신뢰구간 표시
  xlab = "추적 기간 (일수)",  # X축 라벨
  ylab = "생존 확률",       # Y축 라벨
  title = "심근경색(MI) 발생 여부에 따른 Kaplan-Meier 생존 곡선",
  legend.title = "심근경색 발생 여부",
  legend.labs = c("MI 미발생", "MI 발생"),  # 그룹 라벨
  palette = c("blue", "red")  # 색상 설정
)

####성별과 MI 발병 여부 생존분석 ####

km_fit <- survfit(Surv(Day_FU, Death) ~ SEX + MI, data = data.final)
ggsurvplot(km_fit, data = data.final, pval = TRUE, risk.table = TRUE)

