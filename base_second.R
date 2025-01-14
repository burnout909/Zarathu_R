###Vector###

x <- c(1,2,3,4,5,1)
y <- c(7,8,9,10,11,12)

x+y
x*y
sqrt(x)
sum(x)
diff(x) #difference
mean(x)
var(x)
sd(x)
median(x)
IQR(x) ## inter-quantile range
max(x)
which.max(x)
max(x,y)
length(x)
x[2]
x[-2] ##뒤에서 2번째가 아닌 2번째만 빼고 라는 점 주의
x[1:3]

x[1,2,3]
x[c(1,2,3)] # 이 방식으로 실행
x[c(1,2,3,4,5,6,7)]

x >= 4 #각 항목이 True인지 False인지 결정
sum(x>=4) #True 1, False 0 인식
x[x>=4] #True만 반환
sum(x[x>=4])
x %in% c(1,3,5) # 1,3,5중 하나에 속하는지 TRUE/FALSE 표현 
x[x %in% c(1,3,5)]

###Vector 만들기###
v1 <- seq(-5,5,by=.2); ##-5부터 5까지 0.2를 등차로 수열형성
v1

v2 <- rep(1,3); v2 ## 1 3번 반복
v3<- rep(c(1,2,3),2); v3
v4 <- rep(c(1,2,3), each = 2); v4 #각각 2번씩 반복
v5<- rep(c(1,2,3,4), each=2); v5

### 반복문 ###
for (i in 1:3){
  print(i)
}
i <- 0 
for (j in c(1,2,3,4,5,6)){
  i <- i+j
}
i
#R에서는 a:b 또는 c(n1,n2,n3,n4) 식으로 sequence를 iterable을 설계하는 경향이 있는가 보다.
##gpt say 1.a:b syntax, 2.seq(), rep(), c()

### 조건문 ###
#else나 else if 문은 선행 조건문의 마지막 줄과 같은 줄이어야 함
x <- 5 
if(x>=3) {
  x <- x+3
}
x

x <- 5
if(x>=10) {
  print("High")
} else if (x >=5) {
  print("Medium")
} else {
  print("Low")
}

x <- 1:6
y <- ifelse(x>=4, "Yes", "No")
y

###함수 만들기###
x <- c(1:10, 12,13,NA,NA,15,17)
mean(x) #결측값 포함 시 NA로 출력
var(x) #결측값 포함 시 NA로 출력
sd(x) #결측값 포함 시 NA로 출력

mean0 <- function(x){
  mean(x, na.rm=T)
}

mean0 <- function(x){mean(x,na.rm=T)} ##na.rm=T로 설정하면 결측값 제거함
mean0(x)

var0 <- function(x){var(x,na.rm=T)} ##na.rm=T로 설정하면 결측값 제거함
var0(x)

sd0 <- function(x){sd(x,na.rm=T)} #na.rm=T로 설정하면 결측값 제거함
sd0(x)

twomean <- function(x1,x2){
  a <- (x1+x2)/2
  a
}
twomean(4,6)

###Apply문###
#apply
#sapply
#apply
mat <- matrix(1:20, nrow = 4, byrow = T)
mat

out <- NULL
for (i in 1:nrow(mat)){
  out <- c(out, mean(mat[i,]))
}
out

sapply(1:nrow(mat), function(x){mean(mat[x,])}) #return vector
lapply(1:nrow(mat), function(x){mean(mat[x,])}) #return list type

unlist(lapply(1:nrow(mat),function(x){mean(mat[x,])})) #Same to sapply

apply(mat,1,mean) ##1은 행
rowMeans(mat)
rowSums(mat)

apply(mat,2,mean) ##2는 열
colMeans(mat)
colSums(mat)

##연습문제1
#sapply나 lapply를 이용해 아래 두 벡터의 최대값을 각각 구하여라. 
x <- 1:6
y <- 7:12
matxy <- matrix(c(x,y),nrow=2, byrow=T); matxy # nrow -> row 개수 확인, 기본값 column로 값 배열이니 byrow=T 설정
sapply(1:nrow(matxy), function(x){max(matxy[x,])}) #1에서 2 반복
sapply(c(1:nrow(matxy)), function(x){max(matxy[x,])}) #sapply(iterable한 int,function에 int 대입)

lapply(1:nrow(matxy), function(x){max(matxy[x,])})
unlist(lapply(1:nrow(matxy), function(x){max(matxy[x,])})
)

#### 파일 읽어오기 ####
ex <- read.csv("https://raw.githubusercontent.com/jinseob2kim/lecture-snuhlab/master/data/example_g1e.csv")
ex;

#### 읽은 데이터 살펴보기 ### -> 여기부터가 핵심
#column만 추출하기
names(ex)
#notion에 각 column이 뜻하는 바 적어둠
head(ex)
tail(ex)
str(ex) #자료형도 살펴볼 수 있음 : int는 정수, num은 실수형
dim(ex) #row column
nrow(ex) #row number
ncol(ex) #column number

class(ex) #data.frame은 행렬이면서 데이터에 특화된 list임
summary(ex) #모든 변수들의 평균, 중위수, 결측치 등 한 번에 확인 가능

###특정 변수 보기###
ex$EXMD_BZ_YYYY ##data.frame style
ex[1:50,1] ##matrix style
ex[[1]][1:50] ##list style
unique(ex$EXMD_BZ_YYYY) ##unique value: 어떤 값들로 이루어져있는지 확인 가능
#몇개의 값인지 파악하기 
length(unique(ex$EXMD_BZ_YYYY))
table(ex$EXMD_BZ_YYYY) ##각 unique value당 몇 개의 값이 존재하는지 확인 가능

##새로운 변수 만들기##
mean(ex$BMI)
BMI_high <- (ex$BMI >= 25) ##TRUE of FALSE
table(BMI_high)

rows <- which(ex$BMI>=25) ##BMI가 25가 넘는 환자들의 row 번호
#BMI가 25 이상인 환자들의 rn_indi(연습)
RN_INDI_BMI_HIGH <- ex$RN_INDI[(ex$BMI>=25)]; RN_INDI_BMI_HIGH

#BMI가 25 이상인 환자들의 values
values <- ex$BMI[ex$BMI>=25]
summary(values)

length(values)

#BMI가 25이상이고 키가 175 이상인 사람들
BMI_HGHT_and <- (ex$BMI>=25 & ex$HGHT>=175)
table(BMI_HGHT_and)
       
#BMI가 25이상이거나 키가 175 이상인 사람들
BMI_HGHT_or <- (ex$BMI>=25 | ex$HGHT>=175 )
table(BMI_HGHT_or)

###데이터에 새로운 변수 추가하기
ex$BMI_HIGH <- (ex$BMI>=25) #TRUE/FALSE
ex$BMI_HIGH <- as.integer(ex$BMI>=25) #1/0
ex$BMI_HIGH <- as.character(ex$BMI>=25)
ex$BMI_HIGH <- ifelse(ex$BMI>=25, "1", "0")
table(ex$BMI_HIGH)

##matrix style 접근
ex[,"BMI_HIGH"]
변수 추가 
ex[,"zero"] <- 0

##list style 접근
ex[["BMI_HIGH"]] 

### 변수 클래스 설정 ###
vars.cat <- c("RN_INDI", "Q_PHX_DX_STK", "Q_PHX_DX_HTDZ", "Q_PHX_DX_HTN", "Q_PHX_DX_DM", "Q_PHX_DX_DLD", "Q_PHX_DX_PTB", "Q_HBV_AG","Q_SMK_YN","Q_DRK_FRQ_V09N")
vars.cat <- names(ex)[c(2, 4:12)] ##same
vars.cat <- c("RN_INDI", grep("Q_", names(ex), value = T)) ##same: extract variables starting with "Q_"

vars.conti <- setdiff(names(ex), vars.cat) ##Exclude categorical columns 
vars.conti <- names(ex)[!c(names(ex) %in% vars.cat)] ##same

for (vn in vars.cat) {
  ex[,vn] <- as.factor(ex[,vn])
}

for (vn in vars.conti){
  ex[,vn] <- as.numeric(ex[,vn])
}

summary(ex) ## Factor의 경우 0, 1로 counting 되는 모습을 확인할 수 있음

addDate <- paste(ex$HME_YYYYMM, "01", sep="")
ex$HME_YYYYMM <- as.Date(addDate, format = "%Y%m%d")
summary(ex)

###그룹별 통계###
tapply(ex$LDL, ex$EXMD_BZ_YYYY, function(x){mean(x, na.rm=T)})
summary(lm(LDL~HDL, data=ex))      
### 16 observations deleted due to missingness -> LDL이 결측인 16명은 분석에서 제외

### 결측치 제거 ###
ex.naomit <- na.omit(ex)
nrow(ex.naomit)
summary(ex.naomit)

getmode <- function(v){
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}


vars.ok <- sapply(names(ex), function(x){sum(is.na(ex[,x])) < nrow(ex)/10})
ex.impute <- ex[,vars.ok]

for (v in names(ex.impute)) {
  if(is.factor(ex.impute[,v])) {
    ex.impute[,v] <- ifelse(is.na(ex.impute[,v]), getmode(ex.impute[,v]), ex.impute[,v])
  } else if (is.numeric(ex.impute[,v])){
    ex.impute[,v] <- ifelse(is.na(ex.impute[,v]), median(ex.impute[,v], na.rm=T), ex.impute[,v])
  } else {
    ex.impute[,v]
  }
}

summary(ex.impute)

### Subset ###
ex1 <- na.omit(ex)
ex1.2012 <- ex1[ex1$EXMD_BZ_YYYY>=2012,]

ex1.2012 <- subset(ex1, EXMD_BZ_YYYY>=2012) ##subset
table(ex1.2012$EXMD_BZ_YYYY)

aggregate(ex1[,c("WSTC","BMI")], list(ex1$Q_PHX_DX_HTN), mean)
aggregate(cbind(WSTC,BMI) ~ Q_PHX_DX_HTN, data = ex1, mean) ##same

aggregate(cbind(WSTC, BMI) ~ Q_PHX_DX_HTN + Q_PHX_DX_DM, data = ex1, mean)
aggregate(cbind(WSTC, BMI) ~ Q_PHX_DX_HTN + Q_PHX_DX_DM, data = ex1, function(x){c(mean = mean(x), sd = sd(x))})
aggregate(. ~ Q_PHX_DX_HTN  + Q_PHX_DX_DM, data = ex1, function(x){c(mean = mean(x), sd = sd(x))})    

ord <- order(ex1$HGHT)                                        ## 작은 순서대로 순위
head(ord)
head(ex1$HGHT[ord])

ord.desc <- order(-ex1$HGHT)
head(ord.desc)
head(ex1$HGHT[ord.desc])

### Wide Long Format ###
library(reshape2)
long <- melt(ex1, id = c("EXMD_BZ_YYYY", "RN_INDI"), measure.vars = c("BP_SYS", "BP_DIA"), variable.name = "BP_type", value.name = "BP")
long

wide <- dcast(long, EXMD_BZ_YYYY + RN_INDI ~ BP_type, value.var = "BP")
head(wide)

### Merge ###
ex1.Q <- ex1[, c(1:3, 4:12)]
ex1.measure <- ex1[, c(1:3, 13:ncol(ex1))]
head(ex1.Q)
head(ex1.measure)

ex1.merge <- merge(ex1.Q, ex1.measure, by = c("EXMD_BZ_YYYY", "RN_INDI", "HME_YYYYMM"), all = T)
head(ex1.merge)

