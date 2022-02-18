
##set directory
setwd("C:/Users/mreilly/working/east wind manuscript/severity_analysis")

##read in data
dat<-read.csv("rdnbr_samples_cascadiaburning.csv", header=TRUE)

###make struccond a factorand change names to classes
dat$struccond<-as.factor(dat$struccond)
levels(dat$struccond)<-c("Sparse", "Open", "Sapling/Pole", "Small/Medium", "Large", "Large/Giant")
table(dat$struccond)

####plot boxplots for rdnbr by Structural Class (struccond)
boxplot(rdnbr~struccond, data=dat, outline=FALSE, xlab="Structural Class",ylab="RdNBR",notch=TRUE, ylim=c(-200, 1800), boxwex=.570)



####select data for random forest analysis
new_dat<-dat[ c(2:13) ]

#new_dat$Structural.Class<-as.factor(new_dat$StructuralClass)
#sev<-randomForest(high~ ., data=new_dat, importance=TRUE, mtry=3)
#sev
#table(new_dat$StructuralClass)


#pred<-new_dat[ c(1:2,4:14) ]

#resp<-new_dat[ c(3) ]
library(randomForest)
tuneRF(new_dat[,-3], new_dat[,3], ntreeTry=500, stepFactor=3, improve=0.05,
       trace=TRUE, plot=TRUE, doBest=FALSE)


##run random forest model
sev<-randomForest(rdnbr~ ., data=new_dat, importance=TRUE, mtry=3)
sev


###variable imortance plot
varImpPlot(sev)

##create partial dependence plots
library(pdp)

###select predictor variables
pred<-new_dat[ c(1:2,4:12) ]

resp<-new_dat[ c(3) ]

###create graph
par(mfrow = c(3, 2))

partialPlot(sev, pred.data = new_dat, x.var = "Max.Gust", ylab="RdNBR" ,  plot=TRUE, xlab="Max. Gust",main="", ylim=c(600,900))
partialPlot(sev, pred.data = new_dat, x.var = "Burning.Index", ylab="RdNBR" ,  plot=TRUE, xlab="Burning Index",main="", ylim=c(600,900))
partialPlot(sev, pred.data = new_dat, x.var = "FM100", ylab="RdNBR" ,  plot=TRUE, xlab="100-hour Fuel Moisture (%)",main="", ylim=c(600,900))
partialPlot(sev, pred.data = new_dat, x.var = "Slope", ylab="RdNBR" ,  plot=TRUE, xlab="Slope",main="", ylim=c(600,900))
partialPlot(sev, pred.data = new_dat, x.var = "struccond", ylab="RdNBR" ,  plot=TRUE, xlab="Structural Class", main="", ylim=c(0,1000))
partialPlot(sev, pred.data = new_dat, x.var = "Aspect", ylab="RdNBR" ,  plot=TRUE, xlab="Aspect",main="", ylim=c(600,900))




