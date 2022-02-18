library(dismo)
library(randomForest)
library(mgcv)
library(ggplot2)
library(gbm)
library(randomForest)  # for fitting random forests
library(pdp)           # for partial dependence plots
library(vip)           # for variable importance plots
library(data.table)

data_dir <- file.path("..", "data")
dat_path <- file.path(data_dir, "rdnbr_samples_20210811_v2.csv")
dat<-read.csv(dat_path, header=TRUE)


data(dat)
head(dat)
dat$struccond<-as.factor(dat$struccond)
levels(dat$struccond)

levels(dat$struccond)<-c("Sparse", "Open", "Sapling/Pole", "Small/Medium", "Large", "Large/Giant")
setnames(dat$struccond, "1", "Sparse", "2", "Open", "3", "Sapling/Pole", "4","Small/Medium", "5", "Large", "6", "Large/Giant")
table(dat$struccond)


# set up cut-off values 
breaks <- c(-30000,100,235,649,850,  300000)
# specify interval/bin labels
tags <- c("Unburned/Low)","Low", "Mod", "High", "Very High")
# bucketing values into bins
dat$sev <- cut(dat$comp, 
                  breaks=breaks, 
                  include.lowest=TRUE, 
                  right=FALSE, 
                  labels=tags)



#par(mfrow=c(3,1)),,,
#boxplot(RdNBR_update~struccond, data=dat, notch=TRUE, ylim=c(-200, 1500))
#boxplot(RdNBR_early~struccond, data=dat, outline=FALSE, notch=TRUE, ylim=c(-200, 1500))
boxplot(comp~struccond, data=dat, outline=FALSE, xlab="Structural Class",ylab="RdNBR",notch=TRUE, ylim=c(-200, 1800), boxwex=.570)

library(scales) # ! important
library(ggplot2)
ggplot(dat, aes(x=comp)) +
  geom_histogram(aes(y = (..count..)/sum(..count..)), position = "identity",
                 colour="black", fill="white", cex = 0.8) +
  xlim(-200, 1700) + facet_grid(struccond ~ .) +
  geom_density(fill="grey",cex = 0.8, alpha = 0.5) +
  scale_y_continuous(labels = percent_format(accuracy = 1))


ggplot(dat, aes(x=comp)) + 
  geom_histogram(binwidth=75, aes(y=(..density..)*10000), colour="black", fill="white")+
  xlim(-200, 1700) + facet_grid(struccond ~ .) + ylab("% of Area Burned") +
  geom_density(alpha=.2, fill="#FF6666", aes(y=..density..) ) +theme_bw() 

+ 
  geom_vline(xintercept=235, linetype="dashed", color = "black", size=2) + 
  geom_vline(xintercept=649, linetype="dashed", color = "black", size=2) + 
  annotate(geom="text", x=0, y=15, label="Low",color="blue")

ggplot(dat, aes(x=comp)) + 
  geom_histogram(binwidth=100, aes(y=(..density..)), colour="black", fill="white")+
  xlim(-200, 1700) + xlab("RdNBR")+ ylab("% of Area Burned") + facet_grid(struccond ~ .) +
  geom_density(color="red",fill="red",alpha=.2, fill="#FF6666", aes(y=..density..) ) +theme_bw() + 
  geom_vline(xintercept=235, linetype="dashed", color = "black", size=2) + 
  geom_vline(xintercept=649, linetype="dashed", color = "black", size=2) 


abline(h=235, col="black", lwd=1.5)
abline(h=749, col="black", lwd=1.5)
#abline(h=850, col="black", lwd=3)
text(.625,100, "Low",
     cex = .95, col="blue")
text(.625,00, "(<25%)",
     cex = .95, col="blue")
text(.635,550, "Moderate", col="orange",
     cex = .95)
text(.635,450, "(25 to 75%)", col="orange",
     cex = .95)
text(.625,1350, "High",col="red",
     cex = .95)
text(.625,1250, "(>75%)",col="red",
     cex = .95)
stripchart(dat$comp~dat$struccond,              # Data
           method = "jitter", # Random noise
           pch = 19,          # Pch symbols
           col = comp,           # Color of the symbol
           vertical = TRUE,   # Vertical mode
           add = TRUE)  

#plot

boxplot<- ggplot(dat, aes(x=struccond,y=comp, )) + 
                   geom_boxplot() + ylim(-200, 1500) +
  geom_jitter(aes(colour = sev))

boxplot
#dat$high <- ifelse(dat$comp >=649, 1, 0)
#dat$high<-as.factor(dat$high)

##### 6= comp and 19=high
new_dat<-dat[ c(2,3, 6, 8:12 , 15: 17) ]

new_dat$Structural.Class<-as.factor(new_dat$Structural.Class)
#sev<-randomForest(high~ ., data=new_dat, importance=TRUE, mtry=3)
#sev
table(new_dat$Structural.Class)
library(caret)

pred<-new_dat[ c(1:2,4:11) ]

resp<-new_dat[ c(3) ]

tuneRF(new_dat[,-3], new_dat[,3], ntreeTry=500, stepFactor=5, improve=0.05,
       trace=TRUE, plot=TRUE, doBest=FALSE)

sev<-randomForest(comp~ ., data=new_dat, importance=TRUE, mtry=3)
sev

varImpPlot(sev)
# Variable importance plot (compare to randomForest::varImpPlot(boston_rf))


library(pdp)
library(ggplot2)




partialPlot(sev, pred.data = new_dat, x.var = "Max.Gust", ylab="RdNBR" ,  plot=TRUE, xlab="Max. Gust",main="", ylim=c(600,900))

partialPlot(sev, pred.data = new_dat, x.var = "Slope", ylab="RdNBR" ,  plot=TRUE, xlab="Slope",main="", ylim=c(600,900))


partialPlot(sev, pred.data = new_dat, x.var = "Aspect", ylab="RdNBR" ,  plot=TRUE, xlab="Aspect",main="", ylim=c(600,900))

partialPlot(sev, pred.data = new_dat, x.var = "Structural.Class", ylab="RdNBR" ,  plot=TRUE, xlab="Structural Class", main="", ylim=c(0,1000))


par(mfrow = c(3, 2))

partialPlot(sev, pred.data = new_dat, x.var = "Max.Gust", ylab="RdNBR" ,  plot=TRUE, xlab="Max. Gust",main="", ylim=c(600,900))

partialPlot(sev, pred.data = new_dat, x.var = "Burning.Index", ylab="RdNBR" ,  plot=TRUE, xlab="Burning Index",main="", ylim=c(600,900))
partialPlot(sev, pred.data = new_dat, x.var = "FM100", ylab="RdNBR" ,  plot=TRUE, xlab="100-hour Fuel Moisture (%)",main="", ylim=c(600,900))

partialPlot(sev, pred.data = new_dat, x.var = "Slope", ylab="RdNBR" ,  plot=TRUE, xlab="Slope",main="", ylim=c(600,900))

partialPlot(sev, pred.data = new_dat, x.var = "Structural.Class", ylab="RdNBR" ,  plot=TRUE, xlab="Structural Class", main="", ylim=c(0,1000))

partialPlot(sev, pred.data = new_dat, x.var = "Aspect", ylab="RdNBR" ,  plot=TRUE, xlab="Aspect",main="", ylim=c(600,900))




partialPlot(sev, pred.data = new_dat, x.var = "Aspect", ylab="RdNBR" ,  plot=TRUE, xlab="Aspect",main="", ylim=c(600,900))

partialPlot(sev, pred.data = new_dat, x.var = "Structural.Class", ylab="RdNBR" ,  plot=TRUE, xlab="Structural Class", main="", ylim=c(0,1000))




pd_SC <- partial(sev, train=new_dat, pred.var = c("Structural.Class"))
pd_sc
pd_mg <- partial(sev, train=new_dat, pred.var = c("Max.Gust"))
pd_mg
pdp1_tpi <- plotPartial(pd_tpi, smooth=TRUE, ylab="RdNBR", lwd = 2, xlab="TPI", main="Topogprahic Position Index" )
pdp1_tpi

pd_asp_slp <- partial(sev, train=new_dat, pred.var = c("struccond", "max_gust"))

pdp_asp_slp_1 <- plotPartial(pd_asp_slp, ylab="RdNBR", smooth=TRUE)
pdp_asp_slp_1




vip(try, bar = FALSE, horizontal = FALSE, size = 1.5)  # Figure 1

sc_plot<-partialPlot(try, pred.data=new_dat, x.var="struccond", ylim=c(649, 1000))
sc_plot<-partialPlot(try, pred.data=new_dat, x.var="struccond", ylim=c(783.6, 783.7))
sc_plot<-partialPlot(try, pred.data=new_dat, x.var="struccond", ylim=c(749, 750))
sc_plot<-partialPlot(try, pred.data=new_dat, x.var="struccond", ylim=c(769.0, 769.5))
sc_plot<-partialPlot(try, pred.data=new_dat, x.var="struccond", ylim=c(770, 770.4))


par(mfrow=c(2,2))
wind_plot<-partialPlot(try, pred.data=new_dat, x.var="Max_Gust", ylim=c(649, 900))

slope_plot<-partialPlot(try, pred.data=new_dat, x.var="erc", ylim=c(649, 900))
aspect_plot<-partialPlot(try, pred.data=new_dat, x.var="aspect",  ylim=c(649, 900))
sc_plot<-partialPlot(try, pred.data=new_dat, x.var="struccond", ylim=c(0, 1000))

library(plotmo)
plotmo(try, pmethod="partdep") # plot partial dependencie

set.seed(1)
boost.try=gbm(comp~.,data=new_dat,distribution="gaussian",n.trees=5000,interaction.depth=4)
summary(boost.try)


plot(boost.try,i="struccond", ylim=c(0, 1200))
plot(boost.try,i="max_gust")


brt <- gbm.step(data=new_dat, gbm.x = 1:2, 4:13, gbm.y = 3, family="bernoulli",tolerance.method='auto',
                
                tree.complexity = 4,
                learning.rate = 0.01, bag.fraction = 0.5)
warningssummary(brt)

gbm.plot(brt, n.plots=13, plot.layout=c(5, 3), write.title = FALSE)

try_gam <- gam(RdNBR ~ struccond + max_gust + max_FRP + slope, data=new_dat)
summary(try_gam)

summary(mod_lm)


brt <- gbm.step(data=new_dat, gbm.x = 1:13, gbm.y = 14, family="bernoulli",
                             tree.complexity = 5,
                            learning.rate = 0.01, bag.fraction = 0.5)
summary(brt)

gbm.plot(brt, n.plots=13, plot.layout=c(5, 3), write.title = FALSE)

angaus.tc5.lr005 <- gbm.step(data=Anguilla_train, gbm.x = 3:13, gbm.y = 2,
                             family = "bernoulli", tree.complexity = 5,
                             learning.rate = 0.005, bag.fraction = 0.5)

angaus.simp <- gbm.simplify(angaus.tc5.lr005, n.drops = 5)
angaus.tc5.lr005.simp <- gbm.step(Anguilla_train,
                                  gbm.x=angaus.simp$pred.list[[1]], gbm.y=2,
                                  tree.complexity=5, learning.rate=0.005)

gbm.plot(angaus.tc5.lr005, n.plots=11, plot.layout=c(4, 3), write.title = FALSE)
