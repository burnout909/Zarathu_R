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
