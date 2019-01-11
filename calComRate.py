# -*- coding: utf-8 -*-
'''
Created on 2018年12月5日
读取日志文件，抓取其中时间，并计算时间间隔...
@author: Administrator
'''
import numpy as np
import pandas as pd
import datetime
import os
import requests
import suds
import time
import json
import zipfile
import sys
from bSoup_v2 import MyClass
from suds.client import Client

now = datetime.datetime.today()
err_str=""#错误信息
#加这条语句，可以把路径相对位置都定位到当前代码位置的目录下，从而不会导致不同运行环境下，保存到不同位置
os.chdir(sys.path[0])
#查询目录下所有ext类型的文件        
def file_Path(file_dir,ext):
    files=os.listdir(file_dir)
    files_bak=files[:]#加[:]这样才可以,否则删一个bak也会变
    #先移除不符合后缀的文件
    for file in files_bak:
        if len(file.split('.'))>1:
            exts=file.split('.')[-1]
            flag=True
            for e in ext:
                if exts.find(e)>=0:
                    flag=False
            if flag:
                files.remove(file)
#     print(files)
    path=[]
    for file in files:
        path.append(file_dir+"\\"+file)
    return path
#解析日志里的时间间隔
def getRs(_dir="",saveHead="",tps=["log"]):
    paths=file_Path(_dir,tps)
    bms_delta=[]
    lograngs=[]
    infos=[]
    mytime=[]
    global err_str
    for path in paths:
        with open(path) as f1:
            fl1=f1.readlines()
        fl1=list(filter(lambda x:"time=" in x,fl1))
#         print(path.split('/\\')[-1])
        # print(fl1)
        s=[fl.split("time=")[1][1:20] for fl in fl1]
        #对时间排序
        s.sort()
        #注意这里，如果时间少于2个，不判断后面则会报错
        if len(s)==1:
            mytime.append(s[0])
            err_str=err_str+"这个日志"+path+"只有一个时间!"
        elif len(s)!=0:
            mytime.append(s[:-1])
#         print([path.split('/\\')[-1],s[0],s[-1]])
        lograngs.append([path.split('/\\')[-1],s[0],s[-1]])
    #     fl1=list(filter(lambda x:"WARN  [" in x,fl1))
    #     s=[fl.split("WARN  [")[1][:8] for fl in fl1]
    #     print(s)
    #     ds=list(map(lambda x:datetime.datetime.strptime(x, '%H:%M:%S'),s))
        ds=list(map(lambda x:datetime.datetime.strptime(x, '%Y-%m-%d %H:%M:%S'),s))
        dd=np.array(ds[1:])-np.array(ds[:-1])
        for i in range(len(dd)):
            bms_delta.append(dd[i].seconds)
            if dd[i].seconds>=30:
                infos.append([path.split('/\\')[-1],ds[i],ds[i+1],dd[i].seconds])
    mytime=eval('['+str(mytime).replace('[', '').replace(']', '')+']')
    df_bms=pd.DataFrame([mytime,bms_delta]).T
#     print(df_bms)
    df_bms.columns=["time","bms"]
    df_rang=pd.DataFrame(lograngs)

#     df_rang.columns=['文件',"开始时间","结束时间"]
    sum_err_time=sum([it[3] for it in infos])
    sta_err_times.append([sum_err_time,df_rang.shape[0]])
    infos.append(["","","总故障时长/秒",sum_err_time])
    df_infos=pd.DataFrame(infos)
#     print(df_infos)
#     df_infos.columns=['文件',"时间1","时间2","间隔"]
    df_bms=pd.concat([df_bms,df_rang,df_infos],axis=1)
 
    if df_infos.shape[0]>1:
        df_bms.to_excel(_dir+"▲"+saveHead+"报文上传时间间隔.xlsx",sheet_name="采集时间间隔",index=False)
        print(_dir+saveHead+"保存成功！注意查看问题！")
    else:
        df_bms.to_excel(_dir+saveHead+"报文上传时间间隔.xlsx",sheet_name="采集时间间隔",index=False)
        print(_dir+saveHead+"保存成功！没有异常")
#通过webservers获取电站的所有编码
def getbaCodes(sta_code):
    clouId="CNSYB1"
    url = "http://10.13.3.20:7031/DmsService?wsdl"
    client = suds.client.Client(url)
    nowTime = int(round(time.time()*1000))
    code=clouId+str(nowTime)
    methods=["100001","100002",'100003',"100004",'100005','100006']
    strJson=str({'station_code':sta_code})
    bmsJson=json.loads(client.service.getDoc(code,methods[0],strJson))
    bmsCodes=bmsJson["data"][0]["bmss_data"]
    return bmsCodes
#自动下载日志,
'''
@parm
logType:查询日志对象
code:电站编码
_dir:日志存放目录
date:下载哪一日的日志
delext:待删除的文件类型
'''
def downfiles(code="0012",_dir="logs/星洲/",date="2018-12-21",delext=["log","xlsx"],logType="bms"):
    p=MyClass()
    p.cookie=p.getCookie()
    if p.cookie:
        p.freshHeader()
        dir_N=_dir.split('/')[1]
        all_sta=[[it['stationId'],it['stationName']]for it in p.getStationId()]
        sta_Id=list(filter(lambda x:dir_N in x[1],all_sta))[0][0]#电站id
 
        bs=getbaCodes(code)
    #     bs=bs[24:25]
        for staCode in bs:
            filename=_dir+staCode+"_"+date+".zip"
            if int(date.split('-')[-1])>2:
                te=str(int(date.split('-')[-1])-2)
                if int(date.split('-')[-1])<10:
                    te="0"+te
                oldfile=_dir+staCode+"_"+date.split('-')[0]+"-"+date.split('-')[1]+"-"+te+".zip"
                if os.path.exists(oldfile):
                    #删除前两天的压缩包
                    os.remove(oldfile)
                    #删除所有解压的日志文件
                    paths=file_Path(_dir,delext)
#                     print(paths)
                    for ps in paths:
                        os.remove(ps)
                    print("正在自动清除以往日志...")
        #     if 
            else:
                print("请手动删除上月的日志文件！")
    
            url="http://ess.clouyun.com/messagePastAction!downloadlog?logType="+logType+"&code="+staCode
            ext=""
    #             #若第一个小时内没有日志，则后面的也会下不了
    #             for i in range(0,24):
    #                 if i<10:
    #                     ext=ext+"&logName="+date+" 0"+str(i)
    #                 else:
    #                     ext=ext+"&logName="+date+" "+str(i)
            logNames=p.getlogName(sta_Id,staCode,date)
            for logName in logNames:
                ext=ext+"&logName="+logName
            url=url+ext
#             print(url)
            maxTry=20#最大尝试次数
            while(True):
                try:
                    s=requests.session()
                    result=s.post("http://ess.clouyun.com/Login1",data=p.pt_data)
                    r = s.get(url,stream=True, timeout = 3) 
                    with open(filename, "wb") as f:
                        f.write(r.content)
                    print(filename+" is finished ")
                    break
                except:
                    print('ConnectionError, this file failed to download,正在重复下载该堆中...')
                    maxTry=maxTry
                    if maxTry<1:
                        break
                    time.sleep(1)
    else:
        print("cookie 获取失败！")
try:
    codes=["0001","0002","0004","0005","DTDT","AHHR","BJJY","JDZX","LFT","TYG","0012"]
    _dirs=["平朔","上都","新丰","云河","同达","恒瑞","嘉悦","金地","拉斐特","太阳宫","星洲"]
    date=(now+ datetime.timedelta(days = -1)).strftime("%Y-%m-%d")#要下载哪天的日志
    print("开始处理"+date+"的数据中...")
    #     date="2018-12-21"
     
    for i in range(0,len(codes)):#len(codes)
        print("准备下载"+_dirs[i]+"日志...")
        downfiles(codes[i],"logs/"+_dirs[i]+"/",date)
    #     downfiles(codes[i],"logs/"+_dirs[i]+"/",date,["log","zip"])
    print(_dirs[i]+"日志下载结束...")
    #      
    print('---------------------------------------------------')
    print("所有日志下载完毕,待文件解压..")
    def un_zip(file_name):
        """unzip zip file"""
        zip_file = zipfile.ZipFile(file_name)
        for names in zip_file.namelist():
            zip_file.extract(names,file_name.split('/')[0]+"/"+file_name.split('/')[1]+"/")
        zip_file.close()
     
    # getRs("logs/"+_dirs[0]+"/")
    # print(os.listdir("logs"))
    df_all_sta_err_times=pd.DataFrame()
    for k in range(0,len(os.listdir("logs"))):
        staN=os.listdir("logs")[k]
        print(staN+" logs is prepared:")
        zips=file_Path("logs/"+staN+"/", ["zip"])
        zips=filter(lambda x:date in x,zips)
    #     print(zips)
        '''一个电站的每堆通讯故障时长'''
        sta_err_times=[] 
        for z in zips:#每一堆的
    #         print(z.split('\\')[-1].split('.')[0])
            try:
                un_zip(z)
            except:
                err_str=err_str+z+"解压失败！"
                print(err_str)
                sta_err_times.append(["",0])
                continue    
    #         print("logs/"+staN+"/",z.split('\\')[-1].split('.')[0]+"_")
            getRs("logs/"+staN+"/",z.split('\\')[-1].split('.')[0]+"_")
            dels=file_Path("logs/"+staN+"/",["log"])
            for ps in dels:
                os.remove(ps)
        print(staN+" is finished!")
        df_sta_err_times=pd.DataFrame(sta_err_times)
        df_sta_err_times.columns=[staN+'/秒',"日志数量"]
    #         print(df_sta_err_times)
        df_all_sta_err_times=pd.concat([df_all_sta_err_times,df_sta_err_times],axis=1)
    #         print(df_all_sta_err_times)
    df_all_sta_err_times.to_excel(date+"日志分析结果汇总.xlsx")
    with open(r'C:\Users\Administrator\Desktop\自动运行文件日志.log', 'a') as f:
        f.write('%s日志数据分析运行成功！\n'%str(now).split('.')[0]+err_str) 
except:
    with open(r'C:\Users\Administrator\Desktop\自动运行文件日志.log', 'a') as f:
        f.write('%s日志数据分析运行失败！请人工检查故障\n'%str(now).split('.')[0]+err_str)
    print("运行失败！")    