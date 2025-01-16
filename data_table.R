
#install.packages('data.table')
#install.packages('curl')

library(data.table)
library(curl)

#Load file
url <- url <- "https://raw.githubusercontent.com/jinseob2kim/lecture-snuhlab/master/data/example_g1e.csv"
dt <- fread(url, header=T)
print(class(dt)) #data.frame에 data.table 추가 

#see file
dt

#Save file
##fwrite(dt, 'aa.csv')

#row operation
dt[c(3,5)] # row 3~5
dt[BMI>=30 & HGHT < 150]

#column operation 
dt[,c(13,14)] #순번으로 열 선택
dt [,.(Height = HGHT, Weight = WGHT)]
vars <- c("HGHT", "WGHT")
dt[, ..vars]
dt[,vars, with = F]

icols = c(1:12)
dt[,!..icols]

#opeartion
dt[HGHT>= 180 & WGHT <= 80, .(m_chol = mean(TOT_CHOL), m_TG = mean(TG))]

dt[,.(HGHT_mean=mean(HGHT), WGHT_mean=mean(WGHT), BMI_mean=mean(BMI)), by = EXMD_BZ_YYYY]

dt[,lapply(.SD,mean), by=EXMD_BZ_YYYY]

dt[HGHT>=175, .N, by=.(EXMD_BZ_YYYY, Q_SMK_YN)]

#Sorting
dt[HGHT>=175, .N, keyby=.(EXMD_BZ_YYYY, Q_SMK_YN)]

#[order()]
dt[,.(HGHT_mean=mean(HGHT), WGHT_mean = mean(WGHT), BMI = mean(BMI)), by = EXMD_BZ_YYYY][order(BMI)]

dt[,.N,by=.(Q_PHX_DX_STK>0, Q_PHX_DX_HTDZ>0)]

#Functions
##key를 이용한 탐색 setkey()
setkey(dt, EXMD_BZ_YYYY)
key(dt)

##2key
setkey(dt, EXMD_BZ_YYYY, Q_HBV_AG)
key(dt)

##키 활용
dt[.(2011)]
dt[list(2011)]
dt[EXMD_BZ_YYYY==2011]
dt[J(2011)]

dt[.(2011,2)]
dt[list(2011,2)]
dt[EXMD_BZ_YYYY==2011 & Q_HBV_AG==2]
dt[J(2011,2)]

#Merge
#dt1
dt1 <- dt[c(1,300,500,700,1000)]
setkey(dt1,EXMD_BZ_YYYY)
dt2 <- dt[c(400,600,800,1200,1500)]
setkey(dt2,EXMD_BZ_YYYY)

##inner join
ij <- dt1[dt2, on='EXMD_BZ_YYYY', nomatch=0]
merge(dt1,dt2, by='EXMD_BZ_YYYY', all=F)

#Left Outer Join
loj <- dt2[dt1,on='EXMD_BZ_YYYY']
merge(dt1,dt2,by='EXMD_BZ_YYYY', all.x = T)

#Right Outer Join
roj <- dt1[dt2, on = 'EXMD_BZ_YYYY']
merge(dt1,dt2,by='EXMD_BZ_YYYY', all.y = T)

#Full Outer Join
merge(dt1,dt2,by='EXMD_BZ_YYYY',all=T)

#데이터 테이블 수정 연산자 :=
dt[,diff:= HDL - LDL][]
dt[,':=' (HGHT = HGHT*0.9, WGHT = WGHT+5)][]

dt[,BMI:=NULL] #열 삭제
dt[,BMI] #NOT FOUND

dt[, lapply(.SD,mean), by = EXMD_BZ_YYYY]
dt[, head(.SD, 2), by = EXMD_BZ_YYYY]

dt[,lapply(.SD,mean), by = EXMD_BZ_YYYY, .SDcols = c("HGHT", "WGHT")]

dt[LDL>=150, .N] #만족하는 행의 수
dt[, c(.N, lapply(.SD, mean)), by = EXMD_BZ_YYYY, .SDcols = c("HGHT", "WGHT")]

#데이터 재구조화 melt & dcast
dt.long1 <- melt(dt,
                 id.vars = c("EXMD_BZ_YYYY", "RN_INDI", "HGHT", "WGHT"),
                 measure.vars = c("TOT_CHOL", "HDL", "LDL"),
                 variable.name = "measure",
                 value.name = "val")
dt.long1

#Enhanced melt
##list에 복수 칼럼 이름 입력하는 방법
col1 <- c("BP_SYS","BP_DIA")
col2 <- c("HDL", "LDL")
dt.long2 <- melt(dt, measure = list(col1,col2), value.name = c("BP", 'Chol'))
dt.long2
##특정 패턴을 정규 표현식으로 매칭하는 방법
dt.long3 <- melt(dt, measure = patterns("^Q_PHX_DX", "^BP"), value.name = c("Q_PHX_DX", "BP"))
dt.long3

#dcast
#long to wide
dt.wide1 <- dcast(dt.long1, EXMD_BZ_YYYY + RN_INDI + HGHT + WGHT ~ measure, value.var = "val")
dt.wide1

dt.wide2 <- dcast(dt.long1, EXMD_BZ_YYYY ~ measure, value.var = "val", fun.aggregate = mean, na.rm = T)
dt.wide2

#Enhanced dcast
dt.wide3 <- dcast(dt.long2, ...~variable, value.var = c("BP","Chol"))
dt.wide3
