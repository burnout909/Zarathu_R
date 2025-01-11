install.packages("tidyverse")

library(readr)
#coltype 역시 수정 가능
file <- read_csv("https://raw.githubusercontent.com/jinseob2kim/R-skku-biohrs/master/data/smc_example1.csv", col_types = cols(HTN="c"))
class(file) #tibble라는 클래스 추가됨

#Ctrl + Shift + M으로 %>% 입력 가능.
library(magrittr)
file %>% head
file %>% head(10)

##head(subset(file, Sex == "M"))
file %>% subset(Sex == "M") %>% head

##남자만 뽑아 회귀분석을 수행하고 그 계수와 p-value 값 구하는 예
man <- subset(file, Sex == "M")
model <- glm(DM ~ Age + Weight + BMI, data = man, family = binomial)
summ.model <- summary(model)
summ.model$coefficients

## %>% 이용
file %>%
  subset(Sex == "M") %>% 
  glm(DM~ Age + Weight + BMI, data = ., family = binomial ) %>% 
  summary %>% 
  .$coefficients

####dplyr:데이터 정리#####
library(dplyr)
###filter###
file %>% filter(Sex == "M")
file %>% filter(between(Age,50,60))
file %>% filter(Age >= 50, Age <= 60)

###Arrange###
file %>% arrange(Age, desc(BMI))
file %>% arrange_("Age")

###Select###
file %>% select(Sex,Age,Height)
file %>% select(Sex:Height)
file %>% select("Sex":"Height")
file %>% select(2,3,4)
file %>% select(c(2,3,4))
file %>% select(2:4)

file %>% select(-Sex,-Age,-Height)
file %>% select(-2,-3,-4)
file %>% select(ends_with("date"))
file %>% select(contains("MACCE"))

###Mutate###
file %>% mutate(Old = as.integer(Age>=65), Overweight = as.integer(BMI>= 27))
file %>% transmute(Overweight = as.integer(BMI>=27))

###group_by, summarize ###
file %>% 
  group_by(Sex,Smoking) %>% 
  summarize(count= n(),
            meanBMI = mean(BMI),
            sdBMI= sd(BMI))
file %>% 
  group_by(Sex,Smoking) %>% 
  summarize_all(funs(mean = mean, sd = sd))

file %>% 
  subset(Age>=50) %>% 
  .[,-c(1,14)] %>% 
  aggregate(list(Sex = .$Sex, Smoking=.$Smoking),
            FUN = function(x){c(mean=mean(x), sd = sd(x))})

######purrr : 반복문 처리#######
lapply(file, class) #모든 변수들의 형태를 살펴보는 lapply 구문

library(purrr)
map(file,class) #list 형태로 반환

map_chr(file, class)
file %>% map_chr(class)
sapply(file,class)
unlist(map(file,class))
unlist(lapply(file,class))

file %>% sapply(function(x){x[1]})
file %>% sapply('[',1) #추출연산자 '['
file %>% map_chr('[',1)

file %>% 
  group_split(Sex) %>% 
  lapply(function(x){lm(Death~Age, data=x,family=binomial)})

#map에서는 ~로 function을 대체
file %>% 
  group_split(Sex) %>% 
  map(~lm(Death~Age, data = ., family=binomial))

#회귀분석 후 Age의 p-value 추출
file %>% 
  group_split(Sex) %>% 
  sapply(function(x){
    lm(Death~Age, data = x, family=binomial) %>% 
      summary %>% 
      .$coefficients %>% 
      .[8] ##p-value: 8th value
  })

#map_dbl(실수) 활용
file %>% 
  group_split(Sex) %>% 
  map_dbl(~lm(Death~Age,data=.,family=binomial) %>% 
            summary %>% 
            .$coefficients %>% 
            .[8]
          )

#map의 적극적 활용
file %>% 
  group_split(Sex) %>% 
  map(~lm(Death~Age,data=.,family=binomial)) %>% 
  map(summary) %>% 
  map("coefficients") %>% 
  map_dbl(8)

###map2, pmap
mapply(sum, 1:5, 1:5)
sum %>% mapply(1:5,1:5)
sum %>% mapply(1:5,1:5,1:5)

map2(1:5,1:5,sum)
pmap(list(1:5,1:5,1:5),sum)
pmap_int(list(1:5,1:5,1:5),sum)
list(1:5,1:5,1:5) %>% pmap_int(sum)

###map2_chr, paste
name <- c("Alice","John")
place <- c("NewYork","LA")
map2_chr(name,place,~paste(.x,"was born at",.y))

life <- c("born","died")
list(name,life,place) %>% pmap_chr(~paste(..1,"was",..2,"at",..3))
