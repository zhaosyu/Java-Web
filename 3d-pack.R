library(rgl)
library(openxlsx)
library(fields)
library(data.table)

pathObj<-"C:/Users/Administrator/Desktop/battery_model_4p12s/battery_module_6p12sim1.obj"
pathcoords<-"C:/Users/Administrator/Desktop/battery_model_4p12s/温度坐标点.xlsx"
pathAllT_Data<-'C:/Users/Administrator/Desktop/battery_model_4p12s/温度梯度测试/温度梯度测试20摄氏度.csv'
ceshiT<-"20"#测试温度
Lmin<-20#显示图例的最小值
Lmax<-45#显示图例的最大值
skip<-0.1#多大温差一个颜色区分，推荐0.1℃
cnum<-(Lmax-Lmin)/skip#则至少需要颜色种数

pm<-readOBJ(pathObj)
pk<-c(394,560,300.7)
X = pk[1]
Y = pk[2]
Z = pk[3]
x<-seq(0,X,length=100)
y<-seq(0,Y,length=100)
z<-seq(0,Z,length=100)
df_AT <- expand.grid(x=x,y=y,z=z)

df_T<-read.xlsx(pathcoords)
df_T<-subset(df_T,select = -c(X1))
ALLT<-read.csv(pathAllT_Data)

d<-function(x0,y0,z0){#线的函数
  for (ii in 1:10000){
    i=ii+(z10_ind-1)*10000;
    if(z0[i]==z[z10_ind] && y0[i] %in% y[y101618_ind]){
      n=which(y[y101618_ind]==y0[i]);
      if (n==1) {
        if (x0[i]<x[df_T[11,1]]){
          T=(x0[i]-x[df_T[11,1]])/(x[df_T[10,1]]-x[df_T[11,1]])*(df_T[10,4]-df_T[11,4])+df_T[11,4]
        }else{
          T=(x0[i]-x[df_T[11,1]])/(x[df_T[12,1]]-x[df_T[11,1]])*(df_T[12,4]-df_T[11,4])+df_T[11,4]
        }
      }
      if (n==2){
        T=(x0[i]-x[df_T[16,1]])/(x[df_T[17,1]]-x[df_T[16,1]])*(df_T[17,4]-df_T[16,4])+df_T[16,4]
      }
      if (n==3){
        T=(x0[i]-x[df_T[18,1]])/(x[df_T[19,1]]-x[df_T[18,1]])*(df_T[19,4]-df_T[18,4])+df_T[18,4]
        
      }
      
      df_AT$T[i]<-c(T)
    }
  }
  return(df_AT$T)
}
#画C面点的函数
e<-function(x0,y0,z0,t0){
  for (ii in 1:10000) {
    i=ii+(z10_ind-1)*10000;
    if(z0[i]==z[z10_ind]){
      xlo=which(x==x0[i]);
      if (y0[i]<= y[y10_ind]){
        T=(y0[i]-y[y10_ind-1])/(y[y18_ind]-y[y10_ind-1])*(t0[xlo+(y18_ind-1)*100+(z10_ind-1)*10000]-t0[xlo+(y10_ind-1)*100+(z10_ind-1)*10000])+t0[xlo+(y10_ind-1)*100+(z10_ind-1)*10000]
      }
      if (y0[i]>y[y10_ind]){
        T=(y0[i]-y[y10_ind-1])/(y[y16_ind]-y[y10_ind-1])*(t0[xlo+(y16_ind-1)*100+(z10_ind-1)*10000]-t0[xlo+(y10_ind-1)*100+(z10_ind-1)*10000])+t0[xlo+(y10_ind-1)*100+(z10_ind-1)*10000]  
        #print(T)
      }
      df_AT$T[i]<-T
    }
  }
  return(df_AT$T)
}
f<-function(x0,y0,z0){
  #return(x+y+z)
  #插满B面的三条线y方向上的
  xb_ind<-c(df_T[7,1],df_T[8,1],df_T[9,1])
  yb_ind<-c(df_T[9,2],df_T[15,2])
  z_ind<-df_T[7,3]
  
  for(i in seq((z_ind-1)*10000+1,z_ind*10000)){
    
    #插满B面的两条线
    if(z[z_ind]==z0[i] && (y0[i] %in% y[yb_ind])){
      x1_ind<-df_T[which(y[yb_ind]==y0[i])*6+1,1]
      x2_ind<-df_T[which(y[yb_ind]==y0[i])*6+2,1]
      x3_ind<-df_T[which(y[yb_ind]==y0[i])*6+3,1]
      T1<-df_T[which(y[yb_ind]==y0[i])*6+1,4]
      T2<-df_T[which(y[yb_ind]==y0[i])*6+2,4]
      T3<-df_T[which(y[yb_ind]==y0[i])*6+3,4]
      
      #判断一下插[T1,T2]还是[T2,T3]
      if(x0[i]<=x[x2_ind]){
        T<-T1+(T2-T1)/(x[x2_ind]-x[x1_ind])*(x0[i]-x[x1_ind])
      }else{
        T<-T2+(T3-T2)/(x[x3_ind]-x[x2_ind])*(x0[i]-x[x2_ind])
      }
      df_AT$T[i]<-T
      #491701~491800 与 498101~498200
    }
  }
  #下面对插完的2条平行于x轴的线上所有点对进行y轴方向插值
  #找x0[i]所在y轴方向的直线（两个点坐标及其温度）
  y1_ind<-yb_ind[1]#82
  y2_ind<-yb_ind[2]#18
  for(i in seq((z_ind-1)*10000+1,z_ind*10000)){
    T1<-df_AT[which(x==x0[i])+(y1_ind-1)*100+(z_ind-1)*10000,4]
    T2<-df_AT[which(x==x0[i])+(y2_ind-1)*100+(z_ind-1)*10000,4]
    #if(i>=491701 && i<=491800){print(T1)}
    T<-T1+(T2-T1)/(y[y2_ind]-y[y1_ind])*(y0[i]-y[y1_ind])
    df_AT$T[i]<-T
  }
  
  #插满A面的所有点
  xa_ind<-c(df_T[1,1],df_T[3,1],df_T[4,1],df_T[5,1])#90,62,42,14
  ya_ind<-c(df_T[1,2],df_T[2,2])#34 66
  y1_ind<-ya_ind[1]#34
  y2_ind<-ya_ind[2]#66
  za_ind<-df_T[1,3]#100
  for(i in seq((za_ind-1)*10000+1,za_ind*10000)){
    if(z[za_ind]==z0[i] && (y0[i] %in% y[ya_ind])){
      if(y0[i]==y[y1_ind]){
        #y0[i]_ind=34
        x1_ind<-df_T[1,1]
        x2_ind<-df_T[4,1]
        x3_ind<-df_T[5,1]
        T1<-df_T[1,4]
        T2<-df_T[4,4]
        T3<-df_T[5,4]
      }else{
        #y0[i]_ind=66
        x1_ind<-df_T[2,1]
        x2_ind<-df_T[3,1]
        x3_ind<-df_T[6,1]
        T1<-df_T[2,4]
        T2<-df_T[3,4]
        T3<-df_T[6,4]
      }
      #判断一下插[T1,T2]还是[T2,T3]
      if(x0[i]>=x[x2_ind]){
        T<-T1+(T2-T1)/(x[x2_ind]-x[x1_ind])*(x0[i]-x[x1_ind])
      }else{
        T<-T2+(T3-T2)/(x[x3_ind]-x[x2_ind])*(x0[i]-x[x2_ind])
      }
      df_AT$T[i]<-T
      #print(T)
      #993301~993400 996501~996600
    }
  }
  for(i in seq((za_ind-1)*10000+1,za_ind*10000)){
    T1<-df_AT[which(x==x0[i])+(y1_ind-1)*100+(za_ind-1)*10000,4]
    T2<-df_AT[which(x==x0[i])+(y2_ind-1)*100+(za_ind-1)*10000,4]
    #if(i>=996501 && i<=996600){print(T1)}
    T<-T1+(T2-T1)/(y[y2_ind]-y[y1_ind])*(y0[i]-y[y1_ind])
    df_AT$T[i]<-T
  }
  return(df_AT$T)
}
all<-function(x0,y0,z0){
  #插表面所有点
  cc=c(1,100)
  for(ii in 1:2){
    for(j in 1:100){ #x
      for (k in 1:100) { #z
        i=cc[ii];
        index=j+(i-1)*100+(k-1)*10000
        z1_ind=100
        z2_ind=50
        z3_ind=40
        T1=df_AT[j+(i-1)*100+(z1_ind-1)*10000,4]
        T2=df_AT[j+(i-1)*100+(z2_ind-1)*10000,4]
        T3=df_AT[j+(i-1)*100+(z3_ind-1)*10000,4]
        if(k>=z2_ind){
          T<-T1+(T2-T1)/(z[z2_ind]-z[z1_ind])*(z0[index]-z[z1_ind])
          
        }else{
          T<-T2+(T3-T2)/(z[z3_ind]-z[z2_ind])*(z0[index]-z[z2_ind])
        }
        df_AT$T[index]<-T
      }
    }
  }
  for(i in 1:100){
    for(jj in 1:2){ #x
      for (k in 1:100) { #z
        j=cc[jj];
        index=j+(i-1)*100+(k-1)*10000
        z1_ind=100
        z2_ind=50
        z3_ind=40
        T1=df_AT[j+(i-1)*100+(z1_ind-1)*10000,4]
        T2=df_AT[j+(i-1)*100+(z2_ind-1)*10000,4]
        T3=df_AT[j+(i-1)*100+(z3_ind-1)*10000,4]
        if(k>=z2_ind){
          T<-T1+(T2-T1)/(z[z2_ind]-z[z1_ind])*(z0[index]-z[z1_ind])
          
        }else{
          T<-T2+(T3-T2)/(z[z3_ind]-z[z2_ind])*(z0[index]-z[z2_ind])
        }
        df_AT$T[index]<-T
      }
    }
  }
  for(i in 1:100){
    for(j in 1:100){ #x
      for (kk in seq(1)) { #z
        k=cc[kk]
        index=j+(i-1)*100+(k-1)*10000
        z1_ind=100
        z2_ind=50
        z3_ind=40
        T1=df_AT[j+(i-1)*100+(z1_ind-1)*10000,4]
        T2=df_AT[j+(i-1)*100+(z2_ind-1)*10000,4]
        T3=df_AT[j+(i-1)*100+(z3_ind-1)*10000,4]
        if(k>=z2_ind){
          T<-T1+(T2-T1)/(z[z2_ind]-z[z1_ind])*(z0[index]-z[z1_ind])
          print(paste("第",i*j,"个",",正在运行中...请不要缩放rgl图形窗口！")) 
        }else{
          T<-T2+(T3-T2)/(z[z3_ind]-z[z2_ind])*(z0[index]-z[z2_ind])
        }
        df_AT$T[index]<-T
      }
    }
  }
  return(df_AT$T)
}
#保存处理后的温度数据
pathTemp<-unlist(strsplit(pathAllT_Data, "[.]"))
mypal<-rev(rainbow(cnum,start = 0,end=1/3))
titleRgl<-unlist(strsplit(pathTemp[1], "[\\,/]"))
titleRgl<-titleRgl[length(titleRgl)]
#先打开一个角度，别关这个窗口
open3d(windowRect = c(20,30,500,430))
#打开窗口，调整视角画好图例
bgplot3d({
  plot.new()
  title(main = titleRgl, line = 2)
  image.plot( legend.only=TRUE, legend.args=
                list(text='温度',side=3, font=1, line=0.2, cex=1.4), 
              zlim=c(Lmin,Lmax),col=mypal,legend.mar = 3.1,
              legend.shrink=1.15,legend.width=2) 
})
for (mmm in seq(1,nrow(ALLT),by= 20)){
  df_T$T=t(ALLT[mmm,1:19])
  df_AT["T"]<-mean(df_T$T)
  
  z10_ind<-df_T[10,3]
  y101618_ind<-c(df_T[10,2],df_T[16,2],df_T[18,2])
  
  y18_ind<-df_T[18,2]
  y16_ind<-df_T[16,2]
  y10_ind<-df_T[10,2]
  
  df_AT$T<-d(df_AT$x,df_AT$y,df_AT$z)
  df_AT$T<-e(df_AT$x,df_AT$y,df_AT$z,df_AT$T)
  df_AT$T <- f(df_AT$x,df_AT$y,df_AT$z)
  df_AT$T<- all(df_AT$x,df_AT$y,df_AT$z)
  #将颜色数据保存追加写入csv,数据横着放，一行大概10s，一个文件50*10s~~10min
  write.table(t(df_AT$T),paste0(pathTemp[1],"_Temp.csv"),sep=",",append=TRUE,row.names=FALSE,col.names=FALSE) 
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
# 
for(i in seq(ncol(dataT))){
  T<-dataT[,i]
  picture <- cut(c(T,Lmin,Lmax),breaks=cnum) #10~60,0.1度一区间
  cols <- mypal[as.numeric(picture[1:(length(picture)-2)])]
  par3d(skipRedraw = TRUE)
  plot3d(df_AT$x, df_AT$y, df_AT$z,aspect = c(X, Y, Z),xlab = "",ylab = "",zlab ="",col=cols,type="p",size=2,axes = FALSE)
  wire3d(translate3d(pm,X/2,Y/2,Z/2),col = "lightgrey",alpha=0.3)
  par3d(skipRedraw = FALSE)
  #转到45角截图一张
  movie3d(spin3d(axis=c(0,0,1), rpm=7.5), duration=1, fps=1,convert=FALSE, clean=TRUE) 
  snapshot3d(paste0("C:/Users/Administrator/Desktop/battery_model_4p12s/images/",ceshiT,"_1/",ceshiT,"_front_ ",i,".png"))
  #转到背面截图一张
  movie3d(spin3d(axis=c(0,0,1), rpm=22.5), duration=1, fps=1,convert=FALSE, clean=TRUE) 
  snapshot3d(paste0("C:/Users/Administrator/Desktop/battery_model_4p12s/images/",ceshiT,"_2/",ceshiT,"_back_ ",i,".png"))
  #转到起始位置
  movie3d(spin3d(axis=c(0,0,1), rpm=30), duration=1, fps=1,convert=FALSE, clean=TRUE)
}
