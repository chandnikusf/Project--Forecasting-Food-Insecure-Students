rm(list=ls())
df = import('Week counts.xlsx')
df['time'] = 1:nrow(df)
colnames(df) = tolower(make.names(colnames(df)))
plot(df$time,df$number.of.visits, type='l', pch=19)
newdf = df[,c('time', 'number.of.visits')]

library(zoo)
#SMA
plot(newdf,main='Simple Moving Average (SMA)',ylab='Visitors', type='l')
lines(rollmean(newdf,7),col='blue')
lines(rollmean(newdf,40),col='red')
legend(x='topleft',col=c('black','blue', 'red'),legend=c('Raw', 'SMA 7', 'SMA 40'),lty=1,cex=0.4)

#Traingular moving avg
p=7
plot(rollmean(newdf,p),type='l',main='Simple vs Triangular Moving Average',ylab='Discoveries')
lines(rollmean(newdf,10),col='red')
lines(rollmean(rollmean(newdf,7),7),col='blue')
legend(x='topleft',col=c('black','red','blue'),legend=c('SMA 5', 'SMA 10','TMA 7'),lty=1,cex=0.4)

#Kernal smoothing

plot(rollmean(rollmean(newdf,4),4),main='Triangular Moving Average vs Kernel Smoothing',type='l')
lines(ksmooth(newdf$time, newdf$number.of.visits,'normal',bandwidth=4),type='l',col='blue')
legend(x='topleft',col=c('black','blue'),legend=c('TMA 5','Kernel b=4'),lty=1,cex=0.4)

#Daycounts
dc = import('Day counts.xlsx')

dc$days = 1:nrow(dc)
plot(dc$days,dc$visitnumber, type='l', pch=19)

#Kernal smoothing
newdc = dc[,c('days', 'visitnumber')]
plot(rollmean(rollmean(newdc,4),4),main='Triangular Moving Average vs Kernel Smoothing',type='l')
lines(ksmooth(newdc$days, newdc$visitnumber,'normal',bandwidth=4),type='l',col='blue')
legend(x='topleft',col=c('black','blue'),legend=c('TMA 5','Kernel b=4'),lty=1,cex=0.4)

#prophet
pdc = data.frame(ds = dc$visitdate, y = dc$visitnumber)
library(prophet)
m = prophet(pdc, daily.seasonality = TRUE)

#Prediction
future = make_future_dataframe(m, periods = 365)
tail(future)
forecast = predict(m, future)
tail(forecast[c('ds', 'yhat' ,'yhat_lower', 'yhat_upper')])
plot(m, forecast)
dyplot.prophet(m,forecast)

prophet_plot_components(m,forecast)

#handling outliers
outliers = (as.Date(pdc$ds) > as.Date('2019-08-25')
             & as.Date(pdc$ds) < as.Date('2019-09-30'))
pdc$y[outliers] = NA
m = prophet(pdc,daily.seasonality = TRUE)
forecast <- predict(m, future)
forecast$yhat = round(forecast$yhat)
rio::export(forecast,'forecast.xlsx')
plot(m, forecast)
prophet_plot_components(m,forecast)
dyplot.prophet(m,forecast)



pred.frame = make_future_dataframe(m, periods = 365)
ds=pred.frame[910:nrow(pred.frame),] #from sep 1 2022
df = data.frame(ds)

df$pred.number=predict(m,newdata=df,type="response")

