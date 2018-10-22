library(rgl)
library(openxlsx)
library(fields)
library(data.table)
#library(parallel)
pathObj <- "F:\\Clou_Word\\Data\\battery_module_6p12sim1.obj"
pathcoords <- "F:\\Clou_Word\\Data\\温度梯度测试\\温度坐标点_1.xlsx"
#pathcoords <- "F:\\Clou_Word\\Data\\温度梯度测试\\温度坐标点.xlsx"
#pathAllT_Data <- 'F:\\Clou_Word\\Data\\温度梯度测试\\温度梯度测试40摄氏度.csv'
#pathAllT_Data <- 'F:\\Clou_Word\\Data\\温度梯度测试\\4p12S-240Ah-0.5C温度数据.csv'
ceshiT <- "100%转速1"#测试温度
{
  pathAllT_Data <- 'F:\\Clou_Word\\Data\\温度梯度测试\\4p12S-240Ah-1C温度数据.csv'
  pathTemp <- unlist(strsplit(pathAllT_Data, "[.]"))
  #titleRgl <- unlist(strsplit(pathTemp[1], "[\\,/]"))
  #titleRgl <- titleRgl[length(titleRgl)]
  titleRgl <-paste0("6p12S-288Ah-",ceshiT,"C测试温度分布模型")
}
ALLT <- read.csv(pathAllT_Data)
ALLT<-subset(ALLT,select = c(时间,T9,T10,T11,T12,T16,T15,T14,T13,T8,T18,T19,T20,T24,T23,T22,T21,T26,T25))

{
  #修改这个后bg函数要运行一次
  Lmin <- 20#显示图例的最小值
  #温度最大值max(ALLT[,2:19])
  Lmax <- max(ALLT[,2:19])+5#50#显示图例的最大值
  skip <- 0.1#多大温差一个颜色区分，推荐0.1℃
  Tdiff = 1#温差
  cnum <- (Lmax - Lmin) / skip#则至少需要颜色种数
  mypal <- rev(rainbow(cnum, start = 0, end = 1 / 3))
  #bg(1)
}


pm <- readOBJ(pathObj)
pk <- c(394, 560, 300.7)
X = pk[1]
Y = pk[2]
Z = pk[3]
x <- seq(0, X, length = 100)
y <- seq(0, Y, length = 100)
z <- seq(0, Z, length = 100)
df <- expand.grid(x = x, y = y, z = z)#网格坐标
locate <- read.xlsx(pathcoords)
#实际测量点的相对坐标
locate$T <- t(ALLT[1, 2:19])
Sys.time()
df["T"] <- mean(locate$T)
locate <- subset(locate, select = -c(X1))
locate2 <-
  locate$x + (locate$y - 1) * 100 + (locate$z - 1) * 100 * 100 #测量点相对坐标找实际坐标
df$T[locate2] = c(locate$T)
A = levels(factor(locate$y))#读入原始数据中y的因子水平，即找到有7个xz面,从小到大排
B = as.numeric(A)#A中为字符型，转换为数字型存入B（转成了一个数组）
n = length(B)
kuai = c(4, 4)#分成3*3块
C = array(0, dim = c(n, kuai[1] * kuai[2]))#7*9,每一行代表一个面块的温度
P1 = seq(0, X, length.out = kuai[1] + 1)
P2 = seq(0, Z, length.out = kuai[2] + 1)
M = array(0, dim = c(kuai[1] * kuai[2], 4))
for (i in seq(1, kuai[1])) {
  #将单个面划分成9个区域,ki第一列是x坐标范围，第二列是z坐标范围
  for (j in seq(1, kuai[2])) {
    #前边两数是x范围，后边两数是z范围
    M[(i - 1) * kuai[2] + j,] = c(P1[i], P1[i + 1], P2[j], P2[j + 1])
  }
}

#找到一个温度点位面中哪一区域
getTonIndex <- function(wX, wZ) {
  for (i in seq(kuai[1] * kuai[2])) {
    if (x[wX] >= M[i, 1] && x[wX] <= M[i, 2]) {
      if (z[wZ] >= M[i, 3] && z[wZ] <= M[i, 4]) {
        return(i)
      }
    }
  }
}
#this is simple model:后期不断修改这面的温度扩散模型 update
getTonFace <- function(k) {
  #先找出第一个面中的温度点有哪几个,x,z相对坐标
  windex = which(locate$y == B[k])
  wT = locate$T[windex]
  wX = locate$x[windex]
  wZ = locate$z[windex]
  T = rep(mean(wT), kuai[1] * kuai[2])
  #print(wT)
  if (max(wT) - min(wT) >= Tdiff) {
    #判断他们的位于面中9个区域哪里
    for (i in seq(length(windex))) {
      T[getTonIndex(wX[i], wZ[i])] = wT[i]
    }
  }
  return(T)
}
getAllFaceT <- function(i) {
  #先找出第一个面中的温度点有哪几个,x,z相对坐标
  C[i,] <<- getTonFace(i) #C为各个面的平均温度
  #print(C[i,])
  if (max(C[i,]) - min(C[i,]) < Tdiff) {
    #温差较小时
    df$T[which(df$y == y[B[i]])] <<- C[i, 1]
    #print(C[i,1])
  } else{
    #扩展到一个面的所有点温度
    #将C[i,j]赋到每一区域所有点中
    for (j in seq(kuai[1] * kuai[2])) {
      df$T[which(df$x >= M[i, 1] &
                   df$x < M[i, 2] &
                   df$z >= M[i, 3] &
                   df$z < M[i, 4] & df$y == y[B[i]])] <<- C[i, j]
    }
  }
}

getAllT <- function(i) {
  x0 = df$x
  y0 = df$y
  z0 = df$z
  n0 <<- i
  n1 <<- i + 1
  
  #n1面的温度减去n0面的温度
  #一段一段立方体上点温度计算
  for (j in seq(kuai[1] * kuai[2])) {
    E = which(y0 >= y[B[n0]] &
                y0 <= y[B[n1]] & x0 >= M[j, 1] &
                x0 <= M[j, 2] & z0 >= M[j, 3] & z0 <= M[j, 4])
    df$T[E] <<-
      (df$y[E] - y[B[n0]]) / (y[B[n1]] - y[B[n0]]) * (C[n1, j] - C[n0, j]) + C[n0, j]
  }
}

#no_cores <- detectCores() - 1
#cl = makeCluster(no_cores)#开启4个进程
#clusterExport(cl, c("locate","B","kuai","Tdiff","df","getKK","x","y","z","M","C","getTonIndex","getTonFace"),envir = .GlobalEnv)
#目前这个函数运行时间3~4秒，所以后边考虑使用多进程同时处理的方式（未完成）
#求各个边界面的温度
f <- function(x0, y0, z0) {
  sapply(1:n, getAllFaceT)
  #parSapply(cl, 1:n, getAllFaceT)
  #parSapply(cl, 1:(n-1), getAllT)
  sapply(1:(n - 1), getAllT)
  return(df$T)
}

  
bg <- function(t) {
  bgplot3d({
    plot.new()
    title(main = titleRgl, line = 2)
    mtext(side = 1, t, line = 3)
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
#先打开一个角度，别关这个窗口
open3d(windowRect = c(20, 30, 500, 430))
bg(1)
ff <- function(t) {
 #  t=t*fps*100+1
  #print(t)
  locate$T <<- t(ALLT[t, 2:19])
  #print(locate$T)
  #locate$T<-c(46.799,46.314,46.03,47.756,46.036,45.828,44.913,45.458,44.584,46.84,47.431,47.303,47.375,46.76,48.184,40.772,40.942,46.262,46.76)
  # if (t == 729) {
  #   locate$T <<- c(35, 30, 33, 30, 30, 34,  31,45, 43, 33,  43,30, 40, 46, 30, 45, 47, 50, 33)
  # }
  df["T"] <<- mean(locate$T)
  bg(paste("测试时间：", ALLT$时间[t]))
  Sys.time()
  df$T <- f(df$x, df$y, df$z)
  Sys.time()
  
  picture <- cut(c(df$T, Lmin, Lmax), breaks = cnum) #10~60,0.1度一区间
  cols <- mypal[as.numeric(picture[1:(length(picture) - 2)])]
  par3d(skipRedraw = TRUE)
  #par(col = cols)
  theplot <- plot3d(
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
  
  par3d(skipRedraw = FALSE)
  #movie3d(spin3d(axis=c(0,0,1), rpm=7.5), duration=1, fps=1,convert=FALSE, clean=TRUE) 
  #snapshot3d(paste0("G:/pack_images/",ceshiT,"C_2/","front_ ",t,".png"))
  #movie3d(spin3d(axis=c(0,0,1), rpm=-7.5), duration=1, fps=1,convert=FALSE, clean=TRUE) 
  # assign(paste0("kk",t),theplot,envir = .GlobalEnv)
  # widget <<- rglwidget() %>%
  #   toggleWidget(theplot["data"], label = "是否数据")
  #df$z = df$z - 1.2 * Z
  #rglwidget(elementId = "plot3drgl")
}
for (t in seq(1000,5400,by=500)) {
  ff(t)
}
system.time(ff(4083))
system.time(ff(1))

#################
fps = 5
duration =floor(nrow(ALLT)/100)/fps
# require(installr)
#install.ImageMagick()
movie3d(
  ff,
  type = "gif",
  dir = ".",#当前路径
  movie = "mymovie",#视频名字
  duration = duration,
  startTime = 0,
  fps = fps,
  convert = TRUE,
  clean = TRUE,
  verbose = TRUE,#显示详情
  top = TRUE
)


# This writes a copy into temporary directory 'webGL', and then displays it
filename <- writeWebGL(dir = file.path(tempdir(), "webGL"),
                       width = 500,
                       reuse = TRUE)
filename <- writeWebGL(
    dir = "webGL",
    filename = file.path(dir, "index.html"),
    template = system.file(file.path("WebGL", "template.html"), package = "rgl"),
    prefix = "",
    snapshot = TRUE,
    commonParts = TRUE,
    reuse = NULL,
    font = "Arial",
    width,
    height
  )
# Display the "reuse" attribute
attr(filename, "reuse")
Sys.time()
# Display the scene in a browser
#C:\Users\Administrator\AppData\Local\Temp\RtmpGsJIhE\webGL
if (interactive())
  paste0("file://", filename)
Sys.time()

widgets <- rglwidget() %>%
  toggleWidget(ids = kk719, label = "Toggle Barrel") %>%
  toggleWidget(ids = kk729, label = "Toggle Pole")

theplot <- plot3d(rnorm(100), rnorm(100), rnorm(100), col = "red")
widget <- rglwidget(height = 300, width = 300) %>%
  toggleWidget(theplot["data"], label = "Points")
#####
if (interactive())
  widgets

library(htmltools)
theta <- seq(0, 6 * pi, len = 100)
xyz <- cbind(sin(theta), cos(theta), theta)
lineid <- plot3d(
  xyz,
  type = "l",
  alpha = 1:0,
  lwd = 5,
  col = "blue"
)["data"]
browsable(tagList(
  rglwidget(
    elementId = "example",
    width = 500,
    height = 400,
    controllers = "player"
  ),
  playwidget(
    "example",
    ageControl(
      births = theta,
      ages = c(0, 0, 1),
      objids = lineid,
      alpha = c(0, 1, 0)
    ),
    start = 1,
    stop = 6 * pi,
    step = 0.1,
    rate = 6,
    elementId = "player"
  )
))


