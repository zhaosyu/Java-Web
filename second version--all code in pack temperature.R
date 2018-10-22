library(rgl)
library(openxlsx)
library(fields)
library(data.table)
library(parallel)
library(rmarkdown)

pathObj <- "F:\\Clou_Word\\Data\\battery_module_6p12sim1.obj"
#pathcoords <- "F:\\Clou_Word\\Data\\温度梯度测试\\温度坐标点 - 副本.xlsx"
pathcoords <- "F:\\Clou_Word\\Data\\温度梯度测试\\温度坐标点_1.xlsx"
ceshiT <- "40"#测试温度
{
  pathAllT_Data <- 'F:\\Clou_Word\\Data\\温度梯度测试\\4p12S-240Ah-1C温度数据.csv'
  pathTemp <- unlist(strsplit(pathAllT_Data, "[.]"))
  #titleRgl <- unlist(strsplit(pathTemp[1], "[\\,/]"))
  #titleRgl <- titleRgl[length(titleRgl)]
  titleRgl <-paste0("6p12S-288Ah-",ceshiT,"C测试温度分布模型")
}

ALLT <- read.csv(pathAllT_Data)
ALLT<-subset(ALLT,select = c(时间,T9,T10,T11,T12,T16,T15,T14,T13,T8,T18,T19,T20,T21,T22,T23,T24,T26,T25,T1,T2,T3,T17,T5,T6,T7,T8))

{
  #修改这个后bg函数要运行一次
  Lmin <- 20#显示图例的最小值
  #温度最大值max(ALLT[,2:19])
  Lmax <- max(ALLT[,2:27])+5#50#显示图例的最大值
  skip <- 0.1#多大温差一个颜色区分，推荐0.1℃
  Tdiff = 1#温差
  cnum <- (Lmax - Lmin) / skip#则至少需要颜色种数
  mypal <- rev(rainbow(cnum, start = 0, end = 1 / 3))
  #bg(1)
}
pm <- readOBJ(pathObj)
A = pk <- c(394, 560, 300.7)
X = pk[1]
Y = pk[2]
Z = pk[3]
x <- seq(0, X, length = 100)
y <- seq(0, Y, length = 100)
z <- seq(0, Z, length = 100)
df <- expand.grid(x = x, y = y, z = z)#网格坐标
locate <- read.xlsx(pathcoords)
#物理坐标
locate$T <- t(ALLT[4100, 2:27])
Tmean = mean(locate$T)

df[, 4] <- rep(Tmean, 1000000)#Tmean
colnames(df)[4] = 'T'

locate2 <-
  locate$x + (locate$y - 1) * 100 + (locate$z - 1) * 100 * 100
#物理坐标下的温度找实际坐标
df[locate2, 4] = c(locate$T)


A = levels(factor(locate$y))#读入原始数据中y的因子水平，即找到有几个xz面
B = as.numeric(A)#A中为字符型，转换为数字型存入B,排序为从小到大
n = length(B)

#E是长度为10^6的BOOL向量，a,b分别是相邻位置的索引差
#detail:E为除去边界线与原有插值的线的对应位置（TRUE表示不是），a-1,b-10000;a-1,b-100
myf<-function(E,a,b,p=1){
  if(p==1){
    AAA = (z[2] - z[1]) ^ 2 / 2 / ((z[2] - z[1]) ^ 2 + (x[2] - x[1]) ^ 2)
    BBB = (x[2] - x[1]) ^ 2 / 2 / ((z[2] - z[1]) ^ 2 + (x[2] - x[1]) ^ 2)
  }else{
    AAA = (y[2] - y[1]) ^ 2 / 2 / ((y[2] - y[1]) ^ 2 + (x[2] - x[1]) ^ 2)
    BBB = (x[2] - x[1]) ^ 2 / 2 / ((y[2] - y[1]) ^ 2 + (x[2] - x[1]) ^ 2)
  }
  
  T00=1;T0=0;n1=0
  while (max(abs(T0 - T00)) > 10^(-2)) {
    T1 = df$T[which(E)+a]
    T2 = df$T[which(E)-a]
    T3 = df$T[which(E)+b]
    T4 = df$T[which(E)-b]
    T0 = df$T[which(E)]
    T00 = T0
    T0 = AAA * (T1 + T2) + BBB * (T3 + T4)
    df$T[which(E)]=T0
    #print(max(T0 - T00))
  }
  return(df$T)
}
Sys.time()
for (j in 1:n) {
  C = mean(locate$T[which(locate$y == B[j])])#取均值
  x1 = which(df$x == x[1] & df$y == y[B[j]])
  x100 = which(df$x == x[100] & df$y == y[B[j]])
  z1 = which(df$z == z[1]  & df$y == y[B[j]])
  z100 = which(df$z == z[100]  & df$y == y[B[j]])
  #边界没有测点则用平均温度来代替
  df$T[c(x1, x100)] = C
  #每一x-z面，找平行x轴的线的已经测的点z轴坐标
  num.line.z = levels(factor(locate$z[which(locate$y == B[j])]))
  num.line.z = as.numeric(num.line.z)
  flag1=1;flag2=1;kkk=length(num.line.z);kkk0=0
  zn=array(rep(0,100*kkk),dim = c(100,kkk))
  for (i in 1:kkk) {
    #zn[,1]--xz面平行于x轴的线的索引
    zn[,i] = which(df$z == z[num.line.z[i]] & df$y == y[B[j]])
    cx=locate$x[which(locate$y == B[j])]
    ct=locate$T[which(locate$y == B[j])]
    df$T[zn[,i]]=spline(cx, ct, n = 100,method = "fmm",xmin = 1, xmax = 100, ties = mean)$y
    kkk0=0
    if(z1!=zn[,i] && flag1){
      #均值设置边界
      df$T[z1]=C
      flag1=0
      kkk0=kkk0+1
    }
    if (z100!=zn[,i] &&  flag2){
      df$T[z100]=C
      flag2=0
      kkk0=kkk0+1
    }
  }
  #总的边界线数
  num.line=kkk+kkk0+2
  
  #边界设置好后。。。
  #边界上的线df索引有(x1∪x100∪zn∪z1∪z100)
  #然后除去这几根线上的其他所有点操作，计算...
  BB <- rep(TRUE, 1000000)
  BB[x1]=FALSE
  BB[x100]=FALSE
  BB[zn]=FALSE
  BB[z1]=FALSE
  BB[z100]=FALSE
  #除去这几根线上的其他所有点
  #df$T[which(df$y== y[B[j]] & BB)]
  Sys.time()
  df$T<-myf(df$y== y[B[j]] & BB,1,10000)
  Sys.time()
}

#计算所有点（体）的温度
f <- function(x0, y0, z0) {
  #取7个面xz.的索引
  yn=array(rep(0,10000*n),dim = c(10000,n))
  for (i in 1:n) {
    yn[,i]=which(df$y==y[B[i]])
  }
  
  x1=which(df$x==x[1])
  x100=which(df$x==x[100])
  y1=which(df$y==y[1])
  y100=which(df$y==y[100])
  
  BB <- rep(TRUE, 1000000)
  BB[x1]=FALSE
  BB[x100]=FALSE
  BB[yn]=FALSE
  BB[y1]=FALSE
  BB[y100]=FALSE
  
  df$T<-myf(BB,1,100,2)
  #对x=1,yz面与x=100,yz面做插值
  for (i in 1:100) {
    cy=B
    ct=df$T[which(df$x==x[1] & df$z==z[i])][B]
    df$T[which(df$x==x[1] & df$z==z[i])]=spline(cy, ct, n = 100,method = "fmm",xmin = 1, xmax = 100, ties = mean)$y
    
    ct=df$T[which(df$x==x[100] & df$z==z[i])][B]
    df$T[which(df$x==x[100] & df$z==z[i])]=spline(cy, ct, n = 100,method = "fmm",xmin = 1, xmax = 100, ties = mean)$y
    
  }

  
  return(df$T)
}



Sys.time()
df$T <- f(df$x, df$y, df$z)
Sys.time()

#先打开一个角度，别关这个窗口
open3d(windowRect = c(20, 30, 500, 430))

bg <- function(t) {
  bgplot3d({
    plot.new()
    title(main = titleRgl, line = 2)
    image.plot(
      legend.only = TRUE,
      legend.args =
        list(
          text = '温度',
          side = 3,
          font = 1,
          line = 0.2,
          cex = 1.4
        ),
      zlim = c(Lmin, Lmax),
      col = mypal,
      legend.mar = 3.1,
      legend.shrink = 1.15,
      legend.width = 2
    )
  })
}
bg(1) 
df$T[which(df$x==x[100])]=df$T[which(df$x==x[99])]
T <- df$T
picture <- cut(c(T,Lmin , Lmax), breaks = cnum) #10~60,0.1度一区间
cols <- mypal[as.numeric(picture[1:(length(picture) - 2)])]
plot3d(
  df$x,
  df$y,
  df$z,
  aspect = c(X, Y, Z),
  xlab = "",
  ylab = "",
  zlab = "",
  col = cols,
  type = "p",
  size = 2,
  axes = FALSE
)
wire3d(translate3d(pm, X / 2, Y / 2, Z / 2),
       col = "lightgrey",
       alpha = 0.3)
Sys.time()


#playwidget, subsetControl, rglwidget(), toggleWidget, list, rglwidget