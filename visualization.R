#install.packages('rmarkdown')
library(rmarkdown)
library(dplyr)

data <- read.csv("https://raw.githubusercontent.com/jinseob2kim/R-skku-biohrs/main/data/example_g1e.csv")
#pagination
rmarkdown::paged_table(head(data))

##Histogram
#분포를 확인해볼 수 있음
hist(data$HGHT, main="Distribution of height", xlab="height(cm)")
#breaks = n : 계급 구간의 수를 설정할 수 있고, freq=F로 설정하면 빈도수가 아닌 확률 밀도로 계산 가능
hist(data$HGHT, main = "Distribution of height", xlab="height(cm)", breaks = 30, freq = F, col = "grey", border="white")

##Barplot
#변수가 이산형일 때 빈도수를 바 그래프로 표현 가능
table <- table(data$Q_SMK_YN)
table
barplot(table, main = "Distribution of smoking", names.arg = c("Never", "Ex-smoker", "Current"))

table <- table(data$Q_SMK_YN, data$EXMD_BZ_YYYY)
barplot(table, main = "Distribution of smoking by year", ylab="frequence", legend=c("Never", "Ex-smoker", "Current"))

#적층형이 아닌 그룹형으로 설정 : beside = T
barplot(table, main = "Distribution of smoking by year", ylab = "frequency", legend=c("Never", "Ex-smoker", "Never"), beside=T)

##Boxplot
#분포, 중앙값, 사분위수, 이상치 등 확인 가능 : 범주형 변수에 따른 연속형 변수의 분포 나타냄
boxplot(BP_SYS~Q_SMK_YN, data = data, names = c("Never", "Ex-smoker", "Current"), main = "SBP average by smoking", ylab = "SBP(mmHg)", xlab= "Smoking")

##Scatterplot
#두 연속형 변수의 관계, 상관관계 표현 가능, pch = n 은 점의 모양, cex = n 은 점의 크기 지정
plot(HGHT ~ WGHT, data = data, ylab = "Height(cm)", xlab = "Weight(kg)", pch=20, cex=0.5)

#년도에 따라서도 구분 가능함
data2 <- data %>% filter(EXMD_BZ_YYYY %in% c(2009, 2015))
plot(HGHT~WGHT, data = data2, col=factor(EXMD_BZ_YYYY), ylab = "Height(cm)", xlab = "Weight(kg)", pch = 16, cex = 0.5)
legend(x="bottomright", legend = c("2009", "2015"), col = 1:2, pch = 20)

##LinePlot : plot() 함수에 type = "l" 옵션 사용하면 선 그래프 그릴 수 있음. 
table <- data %>% group_by(EXMD_BZ_YYYY) %>%
  summarize(smoker = mean(Q_SMK_YN ==3, na.rm=T))
table

plot(table$EXMD_BZ_YYYY, table$smoker, type="l", main="proportion of current smoker by year", xlab= "Year", ylab= "prop of current smoker")

#install.packages("ggplot2")
library(ggplot2)

##Scatter plot 
ggplot(data = data2, aes(x=HGHT, y=WGHT, col=factor(EXMD_BZ_YYYY))) #aesthetic mapping : x, y, color-mapping

##점 표현
ggplot(data = data2, aes(x=HGHT, y=WGHT)) +
  geom_point(aes(col=factor(EXMD_BZ_YYYY)), alpha = 0.5) + xlab("Height(cm)") + ylab("Weight(kg)") + ggtitle("Height and Weight in year 2009 and 2015") +
  scale_color_manual(
    values = c("orange", "skyblue"), 
    labels = c("Year 2009", "Year 2015"), 
    name = "Exam Year") +
  geom_smooth(color="brown", size=0.8)

##Boxplot 표현
data2 <- data %>% filter(!is.na(Q_SMK_YN))
ggplot(data = data2, aes(x=factor(Q_SMK_YN), y = BP_SYS)) + 
  geom_boxplot() +
  ggtitle("SBP average by smoking") + ylab("SBP(mmHg)") + xlab("Smoking") +
  scale_x_discrete(labels = c("Never", "Smoking", "Current"))

data2 <- data2 %>% filter(!is.na(Q_PHX_DX_HTN))
ggplot(data = data2, aes(x=factor(Q_SMK_YN), y = BP_SYS)) + 
  geom_boxplot() +
  ggtitle("SBP average by smoking") + ylab("SBP(mmHg)") + xlab("Smoking") +
  scale_x_discrete(labels = c("Never", "Smoking", "Current")) +
  facet_wrap(~Q_PHX_DX_HTN, labeller = label_both)

data2 <- data2 %>% filter(!is.na(Q_PHX_DX_DM))
HTN.labs <- c("No HTN", "HTN")
names(HTN.labs) <- c("0", "1")
DM.labs <- c("No DM", "DM")
names(DM.labs) <- c("0", "1")

ggplot(data = data2, aes(x=factor(Q_SMK_YN), y = BP_SYS)) + geom_boxplot() +
  ggtitle("SBP average by smoking") + ylab ("SBP(mmHg)") + xlab("Smoking") + 
  scale_x_discrete(labels = c("Never", "Ex-smoker", "Current")) + 
  facet_grid(Q_PHX_DX_DM ~ Q_PHX_DX_HTN,
             labeller = labeller(Q_PHX_DX_HTN = HTN.labs, Q_PHX_DX_DM = DM.labs))


##Barplot
ggplot(data=data2, aes(x=factor(Q_SMK_YN))) + 
  geom_bar(fill="grey", color="black") + 
  xlab("smoking") + scale_x_discrete(labels = c("Never", "Ex-smoker", "Current")) +
  ggtitle("Distribution of smoking")

ggplot(data=data2, aes(x=EXMD_BZ_YYYY, fill = factor(Q_SMK_YN))) + 
  geom_bar(position="fill", color="grey") + 
  xlab("Year") + ggtitle("Distribution of smoking by year") +
  ylab("proportion") + 
  scale_x_continuous(breaks=2009:2015) + 
  scale_fill_manual(
    values = c("orange", "skyblue", "navy"), 
    labels = c("Never", "Ex-smoker", "Current"), 
    name = "Smoking")

#누적비율이 아닌 count 나타내기 : position = "stack"으로 나타냄. 
ggplot(data=data2, aes(x=EXMD_BZ_YYYY, fill = factor(Q_SMK_YN))) + 
  geom_bar(position="stack", color="grey") + 
  xlab("Year") + ggtitle("Distribution of smoking by year") +
  ylab("proportion") + 
  scale_x_continuous(breaks=2009:2015) + 
  scale_fill_manual(
    values = c("orange", "skyblue", "navy"), 
    labels = c("Never", "Ex-smoker", "Current"), 
    name = "Smoking")

#적층형이 아닌 그룹형 그래프로 나타냄 : position = 'dodge'
ggplot(data=data2, aes(x=EXMD_BZ_YYYY, fill = factor(Q_SMK_YN))) + 
  geom_bar(position="dodge", color="grey") + 
  xlab("Year") + ggtitle("Distribution of smoking by year") +
  ylab("proportion") + 
  scale_x_continuous(breaks=2009:2015) + 
  scale_fill_manual(
    values = c("orange", "skyblue", "navy"), 
    labels = c("Never", "Ex-smoker", "Current"), 
    name = "Smoking") + coord_flip() #coord_flip 으로 x축, y축 회전 가능

#ggpurb
library(ggpubr)
#그래프 위에 자동으로 p-value나 통계적 유의성 표시하고 여러 종류 그래프 한 페이지로 보여주도록 배열가능
## Histogram
data3 <- data2 %>% mutate(HTN = as.factor(ifelse(Q_PHX_DX_HTN==1, "Yes", "No")))
p <- gghistogram(data = data3, x="WGHT", color = "HTN", fill = "HTN", add= "mean", bins = 20)
plot1 <- ggpar(p, main = "Weight distribution by HTN hihstory", 
               xlab = "Weight(kg)", 
               legend.title = "HTN Dx history")
plot1

##Boxplot
###stat_compare_means() 함수를 활용하면 고혈압 병력군 간 체중 평균에 통계적으로 유의한 차이가 있는지 확인 가능
p <- ggboxplot(data = data3, x= "HTN", y= "WGHT", color="HTN") + stat_compare_means(method="t.test", label.x.npc= "middle")
plot2 <- ggpar(p, 
               main = "Weight distirbution by HTN history", 
               ylab = "Weight(kg)", 
               xlab = "HTN Dx history", 
               legend = "none")
plot2

my_comparisons <- list(c("1", "2"), c("2", "3"), c("1", "3"))
p <- ggboxplot(data = data3, x= "Q_SMK_YN", y="WGHT", color = "Q_SMK_YN") + 
  stat_compare_means(comparisons = my_comparisons) + 
  stat_compare_means(label.y = 150) + 
  scale_x_discrete(labels = c("Never", "Ex-smoker", "Current"))

plot3 <- ggpar(p, 
               main = "Weight Distirbution by Smoking", 
               ylab = "Weight(kg)", 
               xlab = "Smoking", 
               legend = "none")

plot3

##Scatterplot
p <- ggscatter(data = data3, x= "HGHT", y="WGHT", add= "reg.line", conf.int = TRUE,
               add.params = list(color = "navy", fill = "lightgray")) +
  stat_cor(method="pearson")
plot4 <- ggpar(p, 
               ylab = "Weight(kg)", 
               xlab = "Height(cm)")

p <- ggscatter(data = data3, x="HGHT", y = "WGHT", color = "HTN", alpha = 0.5, add = "reg.line", conf.int = TRUE) +
  stat_cor(aes(color=HTN))

plot5 <- ggpar(p, ylab = "Weight(kg)", xlab = "Height(cm)")
plot5

ggarrange(plot2, plot3, labels = c("A", "B"), ncol = 2, nrow=1)

install.packages(c("rvg", "officer"))
library(rvg); library(officer)

plot_file <- read_pptx() %>%
  add_slide() %>% ph_with(dml(ggobj = plot1), location=ph_location_type(type="body")) %>%
  add_slide() %>% ph_with(dml(ggobj = plot4), location=ph_location_type(type="body")) %>%
  add_slide() %>% ph_with(dml(ggobj = plot5), location=ph_location_type(type="body"))

print(plot_file, target = "plot_file.pptx")
