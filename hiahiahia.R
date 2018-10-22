library(rgl)
library(openxlsx)
library(fields)
library(data.table)
library(parallel)
pathObj<-"F:\\Clou_Word\\Data\\battery_module_6p12sim1.obj"
pathcoords<-"F:\\Clou_Word\\Data\\温度梯度测试\\温度坐标点.xlsx"
pathAllT_Data<-'F:\\Clou_Word\\Data\\温度梯度测试\\温度梯度测试40摄氏度.csv'
ceshiT<-"40"#测试温度
Lmin<-25#显示图例的最小值
Lmax<-45#显示图例的最大值
skip<-0.1#多大温差一个颜色区分，推荐0.1℃
Tdiff=1#温差
cnum<-(Lmax-Lmin)/skip#则至少需要颜色种数


ALLT<-read.csv(pathAllT_Data)
pm<-readOBJ(pathObj)
pk<-c(394,560,300.7)
X = pk[1]
Y = pk[2]
Z = pk[3]
x<-seq(0,X,length=100)
y<-seq(0,Y,length=100)
z<-seq(0,Z,length=100)
df <- expand.grid(x=x,y=y,z=z)#网格坐标
locate<-read.xlsx(pathcoords);#实际测量点的相对坐标
#locate$T<-t(ALLT[1,1:19])
locate$T<-c(46.799,46.314,46.03,47.756,46.036,45.828,4.913,45.458,44.584,46.84,47.431,47.303,47.375,46.76,48.184,40.772,40.942,46.262,46.76)
Sys.time()
df["T"]<-mean(locate$T)
locate<-subset(locate,select = -c(X1))
locate2<-locate$x+(locate$y-1)*100+(locate$z-1)*100*100 #测量点相对坐标找实际坐标
df$T[locate2]=c(locate$T)
A=levels(factor(locate$y))#读入原始数据中y的因子水平，即找到有7个xz面,从小到大排
B=as.numeric(A)#A中为字符型，转换为数字型存入B（转成了一个数组）
n=length(B)
kuai=c(3,3)#分成3*3块
C=array(0,dim=c(n,kuai[1]*kuai[2]))#7*9,每一行代表一个面块的温度
P1=seq(0,X,length.out = kuai[1]+1)
P2=seq(0,Z,length.out = kuai[2]+1)
M=array(0,dim =c(kuai[1]*kuai[2],4))
for (i in seq(1,kuai[1])){#将单个面划分成9个区域,ki第一列是x坐标范围，第二列是z坐标范围
  for (j in seq(1,kuai[2])){
    #前边两数是x范围，后边两数是z范围
    M[(i-1)*kuai[2]+j,]=c(P1[i],P1[i+1],P2[j],P2[j+1])
  }
}

#找到一个温度点位面中哪一区域
getTonIndex<-function(wX,wZ){
  for(i in seq(kuai[1]*kuai[2])){
    if(x[wX]>=M[i,1] && x[wX]<M[i,2]){
      if(z[wZ]>=M[i,3] && z[wZ]<M[i,4]){
        return(i)
      }
    }
  }
}
#this is simple model:后期不断修改这面的温度扩散模型 update
getTonFace<-function(k){
  #先找出第一个面中的温度点有哪几个,x,z相对坐标
  windex=which(locate$y==B[k])
  wT=locate$T[windex]
  wX=locate$x[windex]
  wZ=locate$z[windex]
  T=rep(mean(wT),kuai[1]*kuai[2])
  if(max(wT)-min(wT)>=Tdiff){
    #判断他们的位于面中9个区域哪里
    for(i in seq(length(windex))){
      T[getTonIndex(wX[i],wZ[i])]=wT[i]
    }    
  }
  return(T)
}
getAllFaceT<-function(i){
  #先找出第一个面中的温度点有哪几个,x,z相对坐标
  C[i,]<<-getTonFace(i) #C为各个面的平均温度
  #print(C[i,])
  if(max(C[i,])-min(C[i,])<Tdiff){
    #温差较小时
    df$T[which(df$y==y[B[i]])]<<-C[i,1]
    #print(C[i,1])
  }else{
    #扩展到一个面的所有点温度
    #将C[i,j]赋到每一区域所有点中
    for(j in seq(kuai[1]*kuai[2])){
      df$T[which(df$x>=M[i,1] & df$x<M[i,2] & df$z>=M[i,3] & df$z<M[i,4] & df$y==y[B[i]])]<<-C[i,j]
    }
  }
}

getAllT<-function(i){
  x0=df$x
  y0=df$y
  z0=df$z
  n0<<-i
  n1<<-i+1
  
  #n1面的温度减去n0面的温度
  #一段一段立方体上点温度计算
  for(j in seq(kuai[1]*kuai[2])){
    E=which(y0>=y[B[n0]] & y0<=y[B[n1]] & x0>=M[j,1] & x0<=M[j,2] & z0>=M[j,3] & z0<=M[j,4])
    df$T[E]<<-(df$y[E]-y[B[n0]])/(y[B[n1]]-y[B[n0]])*(C[n1,j]-C[n0,j])+C[n0,j]
  }
}

#no_cores <- detectCores() - 1
#cl = makeCluster(no_cores)#开启4个进程
#clusterExport(cl, c("locate","B","kuai","Tdiff","df","getKK","x","y","z","M","C","getTonIndex","getTonFace"),envir = .GlobalEnv)
#目前这个函数运行时间3~4秒，所以后边考虑使用多进程同时处理的方式（未完成）
#求各个边界面的温度
f<-function(x0,y0,z0){
  sapply(1:n, getAllFaceT)
  #parSapply(cl, 1:n, getAllFaceT)
  #parSapply(cl, 1:(n-1), getAllT)
  sapply(1:(n-1), getAllT)
  return(df$T)
}
pathTemp<-unlist(strsplit(pathAllT_Data, "[.]"))
mypal<-rev(rainbow(cnum,start = 0,end=1/3))
titleRgl<-unlist(strsplit(pathTemp[1], "[\\,/]"))
titleRgl<-titleRgl[length(titleRgl)]

bg<-function(t){
  bgplot3d({
    plot.new()
    title(main = titleRgl, line = 2)
    mtext(side = 1, t, line = 3)
    image.plot( legend.only=TRUE, legend.args=
                  list(text='温度',side=3, font=1, line=0.2, cex=1.4), 
                zlim=c(Lmin,Lmax),col=mypal,legend.mar = 3.1,
                legend.shrink=1.15,legend.width=2) 
  })
}
#先打开一个角度，别关这个窗口
open3d(windowRect = c(20,30,500,430))
for (mmm in seq(719,719,by= 1)){
  locate$T=t(ALLT[mmm,1:19])
  #locate$T<-c(46.799,46.314,46.03,47.756,46.036,45.828,44.913,45.458,44.584,46.84,47.431,47.303,47.375,46.76,48.184,40.772,40.942,46.262,46.76)
  #locate$T<-c(25,20,23,30,30,23,30,45,25,33,23,30,30,23,30,45,25,20,23)
  #locate=Temp
  df["T"]<-mean(locate$T)
  bg(Sys.time())
  Sys.time()
  df$T<-f(df$x,df$y,df$z)
  Sys.time()
  picture <- cut(c(df$T,Lmin,Lmax),breaks=cnum) #10~60,0.1度一区间
  cols <- mypal[as.numeric(picture[1:(length(picture)-2)])]
  par3d(skipRedraw=TRUE)
  plot3d(df$x, df$y, df$z,aspect = c(X, Y, Z),xlab = "",ylab = "",zlab ="",col=cols,type="p",size=2,axes = TRUE)
  #wire3d(translate3d(pm,X/2,Y/2,Z/2),col = "lightgrey",alpha=0.3)
  par3d(skipRedraw=FALSE)
}
#on.exit(stopCluster(cl))
Sys.time()

plot3d(rnorm(100), rnorm(100), rnorm(100), type = "s", col = "red")
# This writes a copy into temporary directory 'webGL', and then displays it
filename <- writeWebGL(dir = file.path(tempdir(), "webGL"), 
                       width = 500, reuse = TRUE)
# Display the "reuse" attribute
attr(filename, "reuse")
Sys.time()
# Display the scene in a browser
if (interactive())
  browseURL(filename)
Sys.time()
ALLT["Tx1"]=rowMeans(ALLT[,20:23])
ALLT["Tx2"]=rowMeans(ALLT[,24:25])
dataT<-subset(ALLT,select = c(Tx1,T13))
dataT$T8_Tx1=dataT$T8-dataT$T4
dataT$T11_T4=dataT$T11-dataT$T4
dataT$T14_T4=dataT$T14-dataT$T4
library(reshape2)
df<-melt(dataT,id.vars = 'T4')

df1<-subset(dataT,select = c(T4,T8,T11,T14))
df1$time=seq(nrow(df1))
df2<-subset(dataT,select = c(T8_T4,T11_T4,T14_T4))
df2$time=seq(nrow(df2))
df1<-melt(df1,id.vars = 'time')
df2<-melt(df2,id.vars = 'time')
colnames(df1)[2]="测量点"
colnames(df2)[2]="测量点"
a<-ggplot(df1,aes(x=df1$time,y=df1$value,color=测量点))+ geom_line()+xlab("时间")+ylab("温度")+ggtitle("在测试环境40℃时，T4,T8,T11,T14温度")
b<-ggplot(df2,aes(x=df2$time,y=df2$value,color=测量点))+ geom_line()+xlab("时间")+ylab("温度")+ggtitle("在测试环境40℃时，T8,T11,T14分别与T4的温差")
pushViewport(viewport(layout = grid.layout(2,1))) ####将页面分成2*1矩阵
vplayout <- function(x,y){
       viewport(layout.pos.row = x, layout.pos.col = y)
}
print(a, vp = vplayout(1,1)) 
print(b, vp = vplayout(2,1)) 
sd(dataT$T8_T4)
sd(dataT$T11_T4)
sd(dataT$T14_T4)
ggplot(df,aes(x=df$time,y=df$value,color=df$variable))+ geom_line()
N=cor(subset(dataT,select = c(T4,T8,T11,T14)))
corrplot(N, order = "hclust", addrect = 2)
plot(dataT$T4[1:94],dataT$T8[1:94])
plot(dataT$T13,dataT$Tx1)
lines(dataT$T13,predict(lm(Tx1~T13,dataT)),lty=2,lwd=3)
