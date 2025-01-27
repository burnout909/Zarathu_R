install.packages('survival')
library(survival)
veteran
names(veteran)

#연속형 변수의 선형 회귀 = 상관분석
cor.test(veteran$age, veteran$karno)

#정규분포 가정, 선형회귀
summary(lm(karno~age, data = veteran))$coefficients

#다양한 분포, 링크함수 지원
summary(glm(age~karno, data = veteran))$coefficients


#등분산 가정 t-test = 범주형 변수의 선형 회귀
t.test(time~trt, data = veteran, var.equal = T)
summary(lm(time~trt, data = veteran))$coefficients

# celltype 4개 
levels(veteran$celltype)

# 더미변수로 자동으로 바뀐 후 회귀식에 포함. 실제 변수 3개 : large 기준으로 해당 범주에 속하는지 판단
tail(model.matrix(time~celltype, data = veteran))

summary(lm(time~celltype, data = veteran))$coefficients
anova(lm(time~celltype, data = veteran))

#multiple
summary(lm(time~ age + trt + karno, data = veteran))$coefficients

#Logistic Regression
summary(glm(status ~ time + age + trt, data = veteran, family=binomial))

#Cox proportional hazard
#Time to event를 하나의 변수로 잡기

#Cox model
summary(coxph(Surv(time, status) ~ age+ trt + karno, data = veteran))

#kaplan-meier plot
#install.packages('DT')
#install.packages('jskm')
library(DT);library(survival);library(jskm)
datatable(veteran, rownames = F, caption = "Example data", options = list(scrollX=T))

sfit <- survfit(Surv(time,status)~trt, data = veteran)
summary(sfit, times = c(100,200,300,365), extend = T)

jskm(sfit)

jskm(sfit, ystrataname = "Treat", ystratalabs = c("Standard", "Test"), table = T, pval = T)

# 십자가 무늬는 mark = F로 숨길 수 있음. 
# y축이 누적발생률인 경우
jskm(sfit, ystrataname = "Treat", ystratalabs = c("Standard", "Test"), table = T, pval = T, marks = F, cumhaz = T, surv.scale = "percent")

jskm(sfit, ystrataname = "Treat", ystratalabs = c("Standard", "Test"), table = T, pval = T, 
     marks = F, pval.coord = c(100, 0.1), legendposition = c(0.85, 0.6), linecols = "black")

# Landmark analysis : 특정 시간을 기준으로 나누어봄
jskm(sfit, ystrataname = "Treat", ystratalabs = c("Standard", "Test"), table = T, pval = T, 
     marks = F, cut.landmark = 365)

# 최적의 cut-off 구하기 
library(maxstat)
mtest <- maxstat.test(Surv(time,status) ~ karno, data = veteran, smethod = "LogRank")
mtest

cut <- mtest$estimate
veteran$karno_cat <- factor(as.integer(veteran$karno >= cut))

sfit2 <- survfit(Surv(time,status) ~ karno_cat, data = veteran)
jskm(sfit2, ystrataname = "Karno", ystratalabs = paste(c("<", "≥"), cut), table = T, pval = T)

# 비례위험 가정 확인: 평행여부 확인 필요
plot(sfit, fun="cloglog", lty=1:2, col=c("Black", "Grey50"), lwd=2, font.lab=2, main="Log-log KM curves by Treat", 
     ylab="log-log survival", xlab="Time (log scale)")

legend("bottomright",lty=1:2,legend=c("Standard", "Test"), bty="n", lwd=2, col=c("Black", "Grey50"))

#Observed-expected plot
#비례위험 가정하는 cox model 예상과 비교
plot(sfit, lty="dashed", col=c("Black", "Grey50"), lwd=2, font=2, font.lab=2, main="Observed Versus Expected Plots by Treat", 
     ylab="Survival probability", xlab="Time")
par(new = T)

#expected
exp <- coxph(Surv(time, status) ~ trt, data = veteran)
new_df <- data.frame(trt = c(1, 2))
kmfit.exp <- survfit(exp, newdata = new_df)
plot(kmfit.exp, lty = "solid", col=c("Blue", "Red"), lwd=2, font.lab=2)

#Goodness of fit
cox.zph(exp)
plot(cox.zph(exp), var = "trt")
abline(h = 0, lty = 3)

