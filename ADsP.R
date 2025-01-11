# R의 데이터 타입
class('abc')
class(Inf)
class(2.4)
class(TRUE)

# R 기본 문법
## 대입연산자
string <- 'abc'
string
string = 'abcd'
string
string <<- 'abcde'
string
number <<- -15
number
Inf ->> number
number
logical = NA
logical

## 비교연산자
string =='abc'
string!='abcde'
string>'DATA'
is.numeric(string)
is.logical(string)
is.na(string)
is.null(string)

##산술연산자
string+'abc' # numeric type 끼리만 연산 가능함
2+3
2-2
2*10
2/Inf
12%/%12
12%%12
12**12
12**2
exp(2)
exp(0)

##기타연산자
!TRUE
!FALSE
TRUE&TRUE
TRUE&FALSE

#R 데이터 구조
##벡터:타입이 같은 여러 데이터를 하나의 행으로 저장하는 1차원 데이터 구조.
c(1,2,3) #c: concatenate
v4 = c(1,2,3)
v4
v5 = c('a','bc',TRUE,2)
v5
c(1:6)
c(-2:10,2)

##행렬:2차원 구조를 가진 벡터, 벡터 성질을 가지고 있으므로 행렬에 저장된 모든 데이터는 같은 타입이어야함.
###nrow, ncol
matrix(c(1:6), nrow=2) #기본적으로 col 방향으로 stacking됨
matrix(c(1:6), ncol=2)
matrix(c(1:6),ncol=2,byrow=T) #byrow 설정을 통해 vector가 row 방향으로 stacking되도록 함

###dim
v1 <- c(1:6)
v1
dim(v1) <- c(2,3) #v1의 차원 2,3으로 정해주기
v1

##배열: 3차원 이상의 구조를 갖는 벡터, 마찬가지로 데이터는 모두 같은 type
a1 <- array(c(1:12), dim=c(2,3,2))
a1

##리스트: 데이터 타입, 구조에 상관없이 원하는대로 모든 것을 저장할 수 있는 자료구조
L = list()
L[[1]] = 5
L
L[[2]] = '가'
L
L[1]= 50
L[2] = '가'
L
L[[2]][2] = '나'
L[[3]] = c(1,4)
L
L[[4]] = matrix(c(1:6), nrow=2)
L
L[[5]] = matrix(c(1:6), nrow=2, ncol=3, byrow = T)
L
L[[6]] = array(c(1:12),dim=c(2,3,2))
L

##데이터프레임
v1 = c('a','b','c')
v2 = c(1,2,3)
df = data.frame(v1,v2)

##R 내장함수
help()
?paste
paste('a','bc')
seq(1,2,3)
seq(1,12,3)
rep(1,2)
class(rep(1,2))
ls()
rm(a1)
ls()
print('hi')

##통계함수
v1 = c(1:9)
sum(v1)
mean(v1)
median(v1)
std(v1)
sd(v1)
var(v1)
max(v1)
min(v1)
which.max(v1)
range(v1)
class(range(v1))
summary(v1)
skewness(v1)
install.packages('fBasics') #첨도, 왜도 값 계산함수를 위한 패키지 다운로드
library(fBasics)
skewness(v1) #왜도
kurtosis(v1) #첨도

#R 데이터 핸들링
##데이터 이름 변경(행렬, 배열, 데이터프레임 같은 2차원 이상 데이터구조는 모두 colnames,  rownames 활용 가능)
###행렬
m1 <- matrix(c(1:6),nrow=2)
m1
colnames(m1) = c('c1','c2','c3')
m1
rownames(m1) = c('r1','r2')
m1
###배열
a1 = array(c(1:12),dim= c(2,3,2))
colnames(a1) = c('c1','c2','c3')
rownames(a1) = c('r1','r2')
a1
###데이터프레임
df = data.frame(c(1:5),c(6:10))
df
colnames(df) = c('c1','c2')
df
rownames(df) = c('r1','r2','r3','r4','r5','r6')
rownames(df) = c('r1','r2','r3','r4','r5')
df

##데이터추출:벡터,행렬,배열,리스트,데이터프레ㅣㅇㅁ 모두 인덱싱 지원
v1 = c(3,6,9,12)
v1[2]
m = matrix(c(3:14),nrow=3,byrow=T)
m[2,3]

a = array(c(3:14), dim=c(3,2,2))
a
a[1,1,2] #not a[1][1][2]

v1 = c(1:6)
v2 = c(7:12)
df = data.frame(v1,v2)
df
df$v1
df$v2
df$v1[2]

##데이터결합:벡터,행렬,dataframe을 서로 결합하는 방법
v1 = c(1,2,3)
v2 = c(4,5,6)
rbind(v1,v2)
cbind(v1,v2)

#제어문
##반복문
for(i in 1:3){
  print(i)
}

data = c('a','b','c')
for(i in data){
  print(i)
}

i = 0
while(i<5){
  print(i)
  i = i+1
}

##반복문
number = -5
if(number<5) {
  print('number는 5보다 작다')
} else if(number > 5){
  print('number는 5보다 크다')
} else {
  print('number는 5와 같다')
}

##사용자 정의 함수
comparedTo5 = function(numebr){
  if(number<5) {
    print('number는 5보다 작다')
  } else if(number > 5) {
    print('number는 5보다 크다')
  } else {
    print('number는 5와 같다')
  }
}

comparedTo5(10)

#통계분석에서 자주 사용되는 R 함수
##숫자연산
sqrt(25)
abs(-25)
exp(10)
log(exp(1))
log10(10)
pi
round(2.4)
ceiling(2.3)
floor(2.3)

##문자연산
data = 'This is a pen'
tolower(data)
toupper(data)
nchar(data)
substr(data,9,13)
strsplit(data,'a')
grepl('pen',data) #문자열에 주어진 문자가 있는지 확인
gsub('pen','banana',data)

##벡터연산
v = c(1:10)
length(v)
paste(v,'+')
v1 = c(1:10)
v2 = c(11:20)
cov(v1,v2)
var(v1)
var(v2)
sd(v1)
cor(v1,v2)
cor(v1,v2/10)
v2 = c(0,2,3,12,4,1,2,3,4,5)
cor(v1,v2)

##행렬연산
m = matrix(c(1:6), ncol = 2)
###전치행렬
t(m)
###대각행렬
diag(m)
###행렬의곱
m%*%t(m)

##데이터탐색
x = c(1:12)
head(x,5)
tail(x,5)
quantile(x)

##데이터전처리
df1 = data.frame(x=c(1,1,1,2,2), y = c(2,3,4,3,3))
df2 = data.frame(x=c(1,2,3,4), z=c(5,6,7,8))
subset(df1,x==1)
merge(df1,df2)
merge(df1,df2,by=c('x'))
apply(df1,1,sum) #row방향으로 apply 적용
apply(df1,2,sum) #col방향으로 apply 적용

##정규분포(기본값은 표준정규분포 mean=0, sd=1)
###dnorm(정규분포의 주어진 값에서 함수 값 구함)
dnorm(1,mean=0,sd=1) #표준정규분포 x=0에서 확률밀도값
###rnorm(정규분포에서 주어진 개수만큼 랜덤 표본추출)
rnorm(10,mean=0,sd=1)
###정규 분포에서 주어진 값보다 작을 확률 값을 구함
pnorm(2.56,mean=0,sd=1) #x<=p 누적확률
pnorm(2.56,mean=0,sd=1,lower.tail=FALSE) #x>p
###qnorm(정규분포 분위수 계산)
qnorm(0.025,mean=0,sd=1) #누적확률 2.5%에 해당하는 값

##표본추출
runif(5,0,1) #균일분포 추출 : 주어진 범위에서 난수생성
sample(c(1:10),9) #주어진 데이터에서 주어진 개수만큼 표본추출

##날짜
Sys.Date()
Sys.time()
as.Date("2025-01-01")
format(Sys.Date(), '%Y.%M.%D')
format(Sys.Date(),'%A')
unclass(Sys.time())
as.POSIXct(unclass(Sys.time()), origin='1970-01-01')

##산점도
x = c(1:10)
y = rnorm(10)
plot(x,y)
plot(x,y,type='l',xlim=c(-2,12),ylim=c(-3,3),xlab='x axis',ylab='y axis',main='Test plot')
abline(v=c(1,10),col='blue')
