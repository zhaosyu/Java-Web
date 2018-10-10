library(rgl)
library(openxlsx)
library(fields)
library(data.table)
Sys.time()
pathObj<-"F:\\Clou_Word\\Data\\battery_module_6p12sim1.obj"
pathcoords<-"F:\\Clou_Word\\Data\\温度梯度测试\\温度坐标点.xlsx"
pathAllT_Data<-'F:\\Clou_Word\\Data\\温度梯度测试\\温度梯度测试40摄氏度.csv'
ceshiT<-"40"#测试温度
Lmin<-20#显示图例的最小值
Lmax<-45#显示图例的最大值
skip<-0.1#多大温差一个颜色区分，推荐0.1℃
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
locate$T<-t(ALLT[1,1:19])
Tmean=mean(locate$T);
df[,4]<-rep(Tmean,1000000)#Tmean
colnames(df)[4]='T';
locate2<-locate$x+(locate$y-1)*100+(locate$z-1)*100*100;#测量点相对坐标找实际坐标
df[locate2,4]=c(locate$T);



z_ind=locate[c(1,10,13),4]#ACB面
#z_ind=locate[c(1,1,13,10,13,10,10),4]#这也是7个数，对应y_ind的z坐标
y_ind=locate[c(1,2,7,10,13,16,18),3]

combination1=c(1,4,5);
combination2=c(2,3,6);
combination3=c(7,8,9);
combination4=c(10,11,12);
combination5=c(13,14,15);
combination6=c(16,17);
combination7=c(18,19);
x_ind1=locate[combination1,2];
x_ind2=locate[combination2,2];
x_ind3=locate[combination3,2];
x_ind4=locate[combination4,2];
x_ind5=locate[combination5,2];
x_ind6=locate[combination6,2];
x_ind7=locate[combination7,2];

T_ind1=locate[c(1,4,5),5];
T_ind2=locate[c(2,3,6),5];
T_ind3=locate[c(7,8,9),5];
T_ind4=locate[c(10,11,12),5];
T_ind5=locate[c(13,14,15),5];
T_ind6=locate[c(16,17),5];
T_ind7=locate[c(18,19),5]

d<-function(x0,y0,z0){#线的函数
  for (ii in 1:100){
    i=ii+(y_ind[1]-1)*100+(z_ind[1]-1)*10000;#145线
    if (x0[i]<x[x_ind1[2]]){
      x1=x[x_ind1[2]];
      x2=x[x_ind1[3]];
      T1=T_ind1[2];
      T2=T_ind1[3];
      T=(x0[i]-x1)/(x2-x1)*(T2-T1)+T1
    }else{
      x1=x[x_ind1[2]];
      x2=x[x_ind1[1]];
      T1=T_ind1[2];
      T2=T_ind1[1];
      T=(x0[i]-x1)/(x2-x1)*(T2-T1)+T1
    }
    df$T[i]=T
    
    
    i=ii+(y_ind[2]-1)*100+(z_ind[1]-1)*10000;#236线
    if (x0[i]<x[x_ind2[2]]){
      x1=x[x_ind2[2]];
      x2=x[x_ind2[3]];
      T1=T_ind2[2];
      T2=T_ind2[3];
      T=(x0[i]-x1)/(x2-x1)*(T2-T1)+T1
    }else{
      x1=x[x_ind2[2]];
      x2=x[x_ind2[1]];
      T1=T_ind2[2];
      T2=T_ind2[1];
      T=(x0[i]-x1)/(x2-x1)*(T2-T1)+T1
    }
    df$T[i]=T
    
    i=ii+(y_ind[3]-1)*100+(z_ind[3]-1)*10000;#789线
    if (x0[i]>=x[x_ind3[2]]){
      x1=x[x_ind3[2]];
      x2=x[x_ind3[3]];
      T1=T_ind3[2];
      T2=T_ind3[3];
      T=(x0[i]-x1)/(x2-x1)*(T2-T1)+T1
    }else{
      x1=x[x_ind3[2]];
      x2=x[x_ind3[1]];
      T1=T_ind3[2];
      T2=T_ind3[1];
      T=(x0[i]-x1)/(x2-x1)*(T2-T1)+T1
    }
    df$T[i]=T

    
    i=ii+(y_ind[4]-1)*100+(z_ind[2]-1)*10000;#101112线
    if (x0[i]>=x[x_ind4[2]]){
      x1=x[x_ind4[2]];
      x2=x[x_ind4[3]];
      T1=T_ind4[2];
      T2=T_ind4[3];
      T=(x0[i]-x1)/(x2-x1)*(T2-T1)+T1
    }else{
      x1=x[x_ind4[2]];
      x2=x[x_ind4[1]];
      T1=T_ind4[2];
      T2=T_ind4[1];
      T=(x0[i]-x1)/(x2-x1)*(T2-T1)+T1
    }
    df$T[i]=T

    
    i=ii+(y_ind[5]-1)*100+(z_ind[3]-1)*10000;#131415线
    if (x0[i]>=x[x_ind5[2]]){
      x1=x[x_ind5[2]];
      x2=x[x_ind5[3]];
      T1=T_ind5[2];
      T2=T_ind5[3];
      T=(x0[i]-x1)/(x2-x1)*(T2-T1)+T1
    }else{
      x1=x[x_ind5[2]];
      x2=x[x_ind5[1]];
      T1=T_ind5[2];
      T2=T_ind5[1];
      T=(x0[i]-x1)/(x2-x1)*(T2-T1)+T1
    }
    df$T[i]=T

    
    i=ii+(y_ind[6]-1)*100+(z_ind[2]-1)*10000;#1617线
    x1=x[x_ind6[1]];
    x2=x[x_ind6[2]];
    T1=T_ind6[1];
    T2=T_ind6[2];
    T=(x0[i]-x1)/(x2-x1)*(T2-T1)+T1
    df$T[i]=T

    i=ii+(y_ind[7]-1)*100+(z_ind[2]-1)*10000;#1819线
    x1=x[x_ind7[1]];
    x2=x[x_ind7[2]];
    T1=T_ind7[1];
    T2=T_ind7[2];
    T=(x0[i]-x1)/(x2-x1)*(T2-T1)+T1
    df$T[i]=T

  }
  return(df$T)
}

e<-function(x0,y0,z0){#面的函数
  for (ii in 1:100) {
    #1面--A面
    y1=y_ind[1];
    y2=y_ind[2];
    T1=df$T[(1:100)+(y1-1)*100+(z_ind[1]-1)*10000];
    T2=df$T[(1:100)+(y2-1)*100+(z_ind[1]-1)*10000];
    T=(ii-y1)/(y2-y1)*(T2-T1)+T1;
    df$T[(1:100)+(ii-1)*100+(z_ind[1]-1)*10000]<-T
    #B面
    y1=y_ind[3];
    y2=y_ind[5];
    T1=df$T[(1:100)+(y1-1)*100+(z_ind[3]-1)*10000];
    T2=df$T[(1:100)+(y2-1)*100+(z_ind[3]-1)*10000];
    T=(ii-y1)/(y2-y1)*(T2-T1)+T1;
    df$T[(1:100)+(ii-1)*100+(z_ind[3]-1)*10000]<-T

    # 
    #C面
    if (ii<y_ind[4]){
      y1=y_ind[4];#50
      y2=y_ind[7];#1
      T1=df$T[(1:100)+(y1-1)*100+(z_ind[2]-1)*10000];
      T2=df$T[(1:100)+(y2-1)*100+(z_ind[2]-1)*10000];
      T=(ii-y1)/(y2-y1)*(T2-T1)+T1;
      df$T[(1:100)+(ii-1)*100+(z_ind[2]-1)*10000]<-T
      if(ii==1){print(T)}
    }else{
      y1=y_ind[4];
      y2=y_ind[6];#100
      T1=df$T[(1:100)+(y1-1)*100+(z_ind[2]-1)*10000];
      T2=df$T[(1:100)+(y2-1)*100+(z_ind[2]-1)*10000];
      T=(ii-y1)/(y2-y1)*(T2-T1)+T1;
      df$T[(1:100)+(ii-1)*100+(z_ind[2]-1)*10000]<-T
    }

  }
  return(df$T)
}

f<-function(x0,y0,z0){#体的函数
  for (ii in 1:100) {
    x1=1;#左面
    x2=100;#右面
    y1=1;#前面
    y2=100;#后面
    z11=1;#底面
    z22=100;#顶面
    
    z1=z_ind[3];#B面
    z2=z_ind[2];#c面
    z3=z_ind[1];#A面
    #左面着色
    if (ii<z1){
      T1=df$T[x1+((1:100)-1)*100+(z1-1)*10000];
      T2=df$T[x1+((1:100)-1)*100+(z2-1)*10000];
      T=(ii-z1)/(z2-z1)*(T2-T1)+T1;
      df$T[x1+((1:100)-1)*100+(ii-1)*10000]<-T
    }else{
      T1=df$T[x1+((1:100)-1)*100+(z1-1)*10000];
      T2=df$T[x1+((1:100)-1)*100+(z3-1)*10000];
      T=(ii-z1)/(z3-z1)*(T2-T1)+T1;
      df$T[x1+((1:100)-1)*100+(ii-1)*10000]<-T
    }
    
    if (ii<z1){
      T1=df$T[x2+((1:100)-1)*100+(z1-1)*10000];#右面着色
      T2=df$T[x2+((1:100)-1)*100+(z2-1)*10000];
      T=(ii-z1)/(z2-z1)*(T2-T1)+T1;
      df$T[x2+((1:100)-1)*100+(ii-1)*10000]<-T
    }else{
      T1=df$T[x2+((1:100)-1)*100+(z1-1)*10000];
      T2=df$T[x2+((1:100)-1)*100+(z3-1)*10000];
      T=(ii-z1)/(z3-z1)*(T2-T1)+T1;
      df$T[x2+((1:100)-1)*100+(ii-1)*10000]<-T
    }
    
    if (ii<z1){
      T1=df$T[(1:100)+(y1-1)*100+(z1-1)*10000];#前面着色
      T2=df$T[(1:100)+(y1-1)*100+(z2-1)*10000];
      T=(ii-z1)/(z2-z1)*(T2-T1)+T1;
      df$T[(1:100)+(y1-1)*100+(ii-1)*10000]<-T
    }else{
      T1=df$T[(1:100)+(y1-1)*100+(z1-1)*10000];
      T2=df$T[(1:100)+(y1-1)*100+(z3-1)*10000];
      T=(ii-z1)/(z3-z1)*(T2-T1)+T1;
      df$T[(1:100)+(y1-1)*100+(ii-1)*10000]<-T
    }
    
    if (ii<z1){
      T1=df$T[(1:100)+(y2-1)*100+(z1-1)*10000];#后面着色
      T2=df$T[(1:100)+(y2-1)*100+(z2-1)*10000];
      T=(ii-z1)/(z2-z1)*(T2-T1)+T1;
      df$T[(1:100)+(y2-1)*100+(ii-1)*10000]<-T
    }else{
      T1=df$T[(1:100)+(y2-1)*100+(z1-1)*10000];
      T2=df$T[(1:100)+(y2-1)*100+(z3-1)*10000];
      T=(ii-z1)/(z3-z1)*(T2-T1)+T1;
      df$T[(1:100)+(y2-1)*100+(ii-1)*10000]<-T
    }
    

    
    
  }
  #底部着色
  T1=df$T[(1:10000)+(z1-1)*10000];
  T2=df$T[(1:10000)+(z2-1)*10000];
  T=(z11-z1)/(z2-z1)*(T2-T1)+T1;
  df$T[(1:10000)+(z11-1)*10000]<-T
  return(df$T)
}

#df$T <- d(df$x,df$y,df$z)
#df$T <- e(df$x,df$y,df$z)
#df$T <- f(df$x,df$y,df$z)

pathTemp<-unlist(strsplit(pathAllT_Data, "[.]"))
mypal<-rev(rainbow(cnum,start = 0,end=1/3))
titleRgl<-unlist(strsplit(pathTemp[1], "[\\,/]"))
titleRgl<-titleRgl[length(titleRgl)]
#先打开一个角度，别关这个窗口
open3d(windowRect = c(20,30,500,430))

bgplot3d({
  plot.new()
  title(main = titleRgl, line = 2)
  image.plot( legend.only=TRUE, legend.args=
                list(text='温度',side=3, font=1, line=0.2, cex=1.4), 
              zlim=c(Lmin,Lmax),col=mypal,legend.mar = 3.1,
              legend.shrink=1.15,legend.width=2) 
})
for (mmm in seq(1,nrow(ALLT),by= 20)){#nrow(ALLT)
  locate$T=t(ALLT[mmm,1:19])
  Tmean=mean(locate$T);
  df[,4]<-rep(Tmean,1000000);#Tmean
  df[locate2,4]=c(locate$T);
  T_ind1=locate[c(1,4,5),5];
  T_ind2=locate[c(2,3,6),5];
  T_ind3=locate[c(7,8,9),5];
  T_ind4=locate[c(10,11,12),5];
  T_ind5=locate[c(13,14,15),5];
  T_ind6=locate[c(16,17),5];
  T_ind7=locate[c(18,19),5]
  
  df$T<-d(df$x,df$y,df$z)
  df$T<-e(df$x,df$y,df$z)
  df$T<-f(df$x,df$y,df$z)
  #将颜色数据保存追加写入csv,数据横着放，一行大概10s，一个文件50*10s~~10min
  write.table(t(df$T),paste0(pathTemp[1],"_Temp.csv"),sep=",",append=TRUE,row.names=FALSE,col.names=FALSE) 
  #picture <- cut(c(df_AT$T,10,60),breaks=500) #10~60,0.1度一区间
  ##cols <- rainbow(50,start = 0,end=1/3)[as.numeric(picture[1:(length(picture)-2)])]
  #cols <- mypal[as.numeric(picture[1:(length(picture)-2)])]
  ##open3d()
  #plot3d(df_AT$x, df_AT$y, df_AT$z,aspect = c(X, Y, Z),xlab = "",ylab = "",zlab ="",col=cols,type="p",size=2,axes = FALSE)
  #wire3d(translate3d(pm,X/2,Y/2,Z/2),col = "lightgrey",alpha=0.3)
  #snapshot3d(paste0("C:/Users/Administrator/Desktop/battery_model_4p12s/images/温度20度后_ ",mmm,".png"))
  #rgl.close()
}

dataT<-fread(paste0(pathTemp[1],"_Temp.csv"))
dataT<-t(dataT)

for(i in seq(ncol(dataT))){
  T<-dataT[,i]
  picture <- cut(c(T,Lmin,Lmax),breaks=cnum) #10~60,0.1度一区间
  cols <- mypal[as.numeric(picture[1:(length(picture)-2)])]
  par3d(skipRedraw=TRUE)
  plot3d(df$x, df$y, df$z,aspect = c(X, Y, Z),xlab = "",ylab = "",zlab ="",col=cols,type="p",size=2,axes = FALSE)
  wire3d(translate3d(pm,X/2,Y/2,Z/2),col = "lightgrey",alpha=0.3)
  par3d(skipRedraw=FALSE)
  #转到45角截图一张
  #movie3d(spin3d(axis=c(0,0,1), rpm=7.5), duration=1, fps=1,convert=FALSE, clean=TRUE) 
  #  snapshot3d(paste0("C:/Users/Administrator/Desktop/battery_model_4p12s/images/",ceshiT,"_1/",ceshiT,"_front_ ",i,".png"))
  #snapshot3d(paste0(ceshiT,"_front_ ",i,".png"))
  #转到背面截图一张
  #movie3d(spin3d(axis=c(0,0,1), rpm=22.5), duration=1, fps=1,convert=FALSE, clean=TRUE) 
  #  snapshot3d(paste0("C:/Users/Administrator/Desktop/battery_model_4p12s/images/",ceshiT,"_2/",ceshiT,"_back_ ",i,".png"))
  #snapshot3d(paste0(ceshiT,"_back_ ",i,".png"))
  #转到起始位置
  #movie3d(spin3d(axis=c(0,0,1), rpm=30), duration=1, fps=1,convert=FALSE, clean=TRUE)
}
Sys.time()