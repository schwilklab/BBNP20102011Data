# Code by Elizabeth Waring
# Code for BBNP Drought project with Dylan Scwhilk
# data collected in 2010 and 2011 at Big Bend National Park
# this code was used for statistical analysis
# please see WaringSchwilk_dataShape.R for variables

source("./WaringSchwilk_dataShape.R")

# Statistical Analysis
library(nlme)
library(ggplot2)

# for all species and gf together
# Nested transects when looking at effects of elevation and year on varible

# Total cover

# Test including GF in analysis ADDED 12-5
# testing for normality.  Using a Shapiro-Wilk test
shapiro.test(plants.tcover2$tcover)

# mixed effects model

lme.plants.tcover <- lme(tcover ~ elev*year, random = ~ 1|elev,
                          data=plants.tcover)


summary(lme.plants.tcover)
anova(lme.plants.tcover)
qplot(elev, tcover, data=plants.tcover, color=year) + geom_smooth(method="lm")

plot(plants.tcover2$elev, resid(lme.plants.tcover2))

# Living Cover
# testing for normality.  Using a Shapiro-Wilk test
shapiro.test(plants.tcover$lcover)
# mixed effects model
lme.plants.lcover <- lme(lcover ~ elev*year, random = ~1|elev,
                         data=plants.tcover)
summary(lme.plants.lcover)
anova(lme.plants.lcover)
qplot(elev, lcover, data=plants.tcover, color=year) + geom_smooth(method="lm")

plot(plants.tcover$elev, resid(lme.plants.lcover))


#For relative cover including gf
lme.plants.relcover <- lme(logPrelcover ~ elev*year*gf, random = ~1|elev,
                           data=plants.relcover)
summary(lme.plants.relcover)
anova(lme.plants.relcover)
qplot(elev, relcover, data=plants.relcover, color=year, shape=gf) + geom_smooth(method="lm")

plot(plants.tcover$elev, resid(lme.plants.lcover))


# logit transformed proportional dieback
# testing for normality.  Using a Shapiro-Wilk test
shapiro.test(totalDieback$logPdieback)
# mixed effects model
lme.logPdieback <-lme(logPdieback ~elev, random=~1|elev, data=totalDieback)
summary(lme.logPdieback)
anova(lme.logPdieback)
qplot(elev, logPdieback, data=totalDieback) +  geom_smooth(method="lm")
plot(totalDieback$elev, resid(lme.logPdieback))


# mixed effects model
lme.logPdieback2 <-lme(logPdieback ~elev*gf, random=~1|elev, data=dieback.2011)
summary(lme.logPdieback2)
anova(lme.logPdieback2)
qplot(elev, logPdieback, data=dieback.2011) +  geom_smooth(method="lm")
plot(dieback.2011$elev, resid(lme.logPdieback2))




#### TRAITS ##################################################################


# We will exclude succulents from the weighted LMA calculations, also these 
# data are from 2010 only
# using dieback.traits from source("./WaringSchwilk_dataShape.R")


traits.die <- merge(traits, dieback.traits, by="spcode")
Suc<-traits.die
traits.die <- subset(traits.die, gf=="shrub" | gf=="subshrub" | gf == "tree")

# code to remove conifer species from dataset
noConifer<-subset(traits.die, spcode!="JUDEP")
noConifer<-subset(traits.die, spcode!="JUFLA") 
noConifer<-subset(traits.die, spcode!="JUPIN")
noConifer<-subset(traits.die, spcode!="PICEM")


## calculate mean weighted LMA at each site

traits.die1 <- ddply(traits.die, .(elev,felev, ttrans), summarize,
                     tdieback =mean(tdieback),
                     pdieback = mean(pdieback),
                     wLMA = weighted.mean(LMA, cover, na.rm = TRUE)
                    )
traits.die1$logPdieback <- log((traits.die1$pdieback - epsilon)/
                                 (1-(traits.die1$pdieback - epsilon)))

# with Suc
Suc <- ddply(Suc, .(elev,felev, ttrans), summarize,
             tdieback =mean(tdieback),
             pdieback = mean(pdieback),
             wLMA = weighted.mean(LMA, cover, na.rm = TRUE))
Suc$logPdieback <- log((Suc$pdieback - epsilon)/
                         (1-(Suc$pdieback - epsilon)))


# separate the elevations into two groups
highTraits<-subset(traits.die1, elev=="1920" | elev=="1690" |elev=="1411")
lowTraits<-subset(traits.die1, elev=="1132" | elev=="871" |elev=="666")
highTraits$group="high"
lowTraits$group="low"

allT<-merge(highTraits, lowTraits, all=T)

allT.lme<-lme(logPdieback ~ wLMA*group, random = ~ 1 | elev, 
              data = allT)
summary(allT.lme)
anova(allT.lme)
qplot(wLMA, logPdieback, shape=group, data=allT) + geom_smooth(method="lm")
# separate the elevations into two groups


#traits by gf
traits.die2 <- ddply(traits.die, .(elev,felev, gf), summarize,
                     tdieback =mean(tdieback),
                     pdieback = mean(pdieback),
                     wLMA = weighted.mean(LMA, cover, na.rm = TRUE))

traits.die2$logPdieback <- log((traits.die2$pdieback - epsilon)/
                                 (1-(traits.die2$pdieback - epsilon)))
traits.die2<-na.omit(traits.die2)                         
# Statistics for traits data



logptraits.lme<-lme(logPdieback ~ wLMA*elev, random = ~ 1 | elev, 
                    data = traits.die1)
summary(logptraits.lme)
anova(logptraits.lme)
qplot(wLMA, logPdieback, data=traits.die1) + geom_smooth(method="lm")


# traits without conifers
noCon <- ddply(noConifer, .(elev,felev, ttrans), summarize,
               tdieback =mean(tdieback),
               pdieback = mean(pdieback),
               wLMA = weighted.mean(LMA, cover, na.rm = TRUE),
               wLLMA=weighted.mean(LMA, lcover, na.rm = TRUE))
noCon$logPdieback <- log((noCon$pdieback - epsilon)/
                           (1-(noCon$pdieback - epsilon)))

noCon.lme<-lme(logPdieback ~ wLMA*elev, random = ~ 1 | elev, 
               data = noCon)
summary(noCon.lme)
anova(noCon.lme)
qplot(wLMA, logPdieback, data=noCon) + geom_smooth(method="lm")

#no Conifers in two groups
highTraitsC<-subset(noCon, elev=="1920" | elev=="1690" |elev=="1411")
lowTraitsC<-subset(noCon, elev=="1132" | elev=="871" |elev=="666")
highTraitsC$group="high"
lowTraitsC$group="low"

allTC<-merge(highTraitsC, lowTraitsC, all=T)

allTC.lme<-lme(logPdieback ~ wLMA*group, random = ~ 1 | elev, 
               data = allTC)
summary(allTC.lme)
anova(allTC.lme)
qplot(wLMA, logPdieback, shape=group, data=allTC) + geom_smooth(method="lm")

# Trait stats by species

#need to add in the logP of dieback on species level in traits.die
traits.die$logPdieback <- log((traits.die$pdieback - epsilon)/
                                 (1-(traits.die$pdieback - epsilon)))
traits.die<-na.omit(traits.die)

sptraits.lme<-lme(logPdieback~ spcode , random = ~ 1 | elev, 
                  data = traits.die)
summary(sptraits.lme)
anova(sptraits.lme)

qplot(pdieback, spcode, data=traits.die) + geom_smooth(method="lm")

