# -*- coding: utf-8 -*-
'''
Created on 2018年10月26日
爬虫获取v2.0版本云平台登录后页面的内容
@author: ZhaoShangYu
'''
import json
import sys
import time
import hashlib
import numpy as np
from bs4 import BeautifulSoup
import requests
import os
import pandas as pd
import pickle
import calendar
import datetime


class MyClass(object):
    #外部可以自己定义赋值
    cookie = ''
    
    userName="18970399113"
    password="399113"
    pt_data=""
    #password="2c66469a82a07b6b0bc6daefff6cc53c"
    __header = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36',
        'Connection': 'keep-alive',
        'accept': 'application/json, text/javascript, */*; q=0.01',
        'Cookie': cookie
    }
    #默认查询天的
    __queryDict={
        'stationId':22,
        'date':'2018-07-01',
        'queryType':'month',
        'distributeCycle':'year'
    }
    __type=['getSurveyData','getIncomeData','getTrendData','getAlarmCycle']

    __queryStr="?"
    __url_prefix = 'http://ess.clouyun.com/operatePandectAction!'
    #是否可以获取数据，完全没有运行的什么都没有，调频项目只有告警信息，默认可以获取
    __isGetAll=True

    def __init__(self,date="2018-12"):
        self.__queryDict["date"]=date
        for key, value in self.__queryDict.items():
            self.__queryStr+="%s=%s&"%(key,value)
    
    #根据用户名和密码获取正确的Cookie
    #设计一个存到内存里的Cookie
    def getCookie(self):
        md5=hashlib.md5()
        md5.update(str.encode(self.password))
        md5_pass=md5.hexdigest()
        #print(md5_pass)
        post_data={"userName":self.userName,"password":md5_pass}
        self.pt_data=post_data
        url="http://ess.clouyun.com/Login1"

        #这几行只特别针对这个Login1返回的内容来过滤判断的
        r = requests.post(url,data=post_data)
#         print(r.content.decode())    
        soup = BeautifulSoup(r.content.decode(), "html.parser")
        try:
            js=soup.select("script")[-1]
        except:
#             print("网络或服务器异常！")
            return False
        #获取的是无效Cookie，提示“用户名或密码错误”
        if str(js).find("false")>0:
            return False
        
        session=requests.session()
        result=session.post(url,data=post_data)
        cookies=requests.utils.dict_from_cookiejar(session.cookies)
        cookies=[value+"="+key for (value,key) in cookies.items()][0]
        return cookies
    #set存储cookie到tmp.txt
    def setSaveCookie(self,path):
        try:
            cookie=self.getCookie()
            #有网且用户名和密码正确
            if cookie != False:
                self.__header["Cookie"]=cookie
                print("成功刷新了Cookie:"+self.__header["Cookie"]+"并将存入"+path+"文件中")
                value = {'cookie':cookie,'dateTime':time.time()}
                pickle.dump(value, open(path, 'wb'))
                return True
            else:
                print("用户名或密码错误!请修改后重新获取Cookie")
                return False
        except:
            print("获取Cookie失败，请网络是否有问题!")
            return False
    def freshHeader(self):
        self.__header["Cookie"]=self.cookie
    #自动获取电站Id和电站名[{"stationId":1,'stationName':'xxx','stationType':'YFTG/TP'},...]
    def getStationId(self,cookie=""):
        url="http://ess.clouyun.com/getTableBody"
        post_data={"total":24,
                   "nodeType":"commonStation",
                   "unitId":78 #暂时不知道这个参数啥意思，但缺或换一个都不可以
                   }
        if(cookie!=""):
            self.__header['Cookie']=cookie
        wbdata = requests.post(url,data=post_data,headers=self.__header).content.decode()
#         sorted(dict.items(), key=lambda d: d[1]) #按value排序
        #print(wbdata)
        json_wb=json.loads(wbdata)['rows']
        json_wb.sort(key=lambda x:int(x["stationId"]))
        return json_wb
        #首先统计      电站容量(MWh)、总投资额(万元)、峰谷差价（元）、累计放电量（MWh）、回收周期（年）、
        #BMS总数、电站类型、累计充电量MWh、运行天数（天）、累计收益（万元）
    def getSurveyData(self):
        url=self.__url_prefix+self.__type[0]+self.__queryStr[:-1]
        wbdata = requests.get(url,headers=self.__header).text
        json_wb=json.loads(wbdata)['topData']
        profit=json_wb['INCOME']
        total_invest=json_wb['THRESHOLD_VALUE']
#         capacity=json_wb['STATION_CAPACITY'] #电站容量
#         type=json_wb['STATION_TYPE'] #电站类型
        if total_invest==0:
            self.__isGetAll=False
            return False
        else:
#             print('--------------------------------------')
#             print(json_wb)
            json_wb.setdefault('FXYGZ','')
            json_wb.setdefault('ZXYGZ','')
            #如果是空的，可能是调频项目或者一直停运的项目
            fxygz=json_wb['FXYGZ'] #累计放电Mwh
            zxygz=json_wb['ZXYGZ'] #累计充电 Mhh
            run_days=json_wb['RUN_DAYS'] #运行天数
            result={"profit":profit,"total_invest":total_invest
                    ,"run_days":int(run_days),"zxygz":zxygz,"fxygz":fxygz}
            return result
    #获取一个月的日最高收益。最低收益，以及月总收益
    def getIncomeData(self):
        if self.__isGetAll:
            url=self.__url_prefix+self.__type[1]+self.__queryStr[:-1]
            wbdata = requests.get(url,headers=self.__header).text
#             print(wbdata)
            #总收益0，单位容量收益是1
            json_wb=json.loads(wbdata)['option']['series'][0]['data']
            
            json_wb2=list(filter(lambda x:x!='',json_wb))
#             print(json_wb2)
            #当月没有运行数据，直接返回
            if len(json_wb2) ==0:
                self.__isGetAll=False
                return {"max_ind":30,"max_profix":0,"min_ind":30,"min_profix":0,"mon_profix":0}
            else:
                max_profix=max(json_wb2)
                
                if max_profix > 0:
                    max_ind=json_wb.index(max_profix)
                else:
                    #最高收益为0,- 或者负的，不进行统计，查看短板就看该月最后一天
                    return {"max_ind":30,"max_profix":0,"min_ind":30,"min_profix":0,"mon_profix":0}
                
                min_profix=min(json_wb2)      
                if abs(min_profix) > 30 and min_profix >0 :
                    pass
                else:
                    min_profix=min(filter(lambda x: x > 30,json_wb2))
                
    #             print([min_profix,max_profix])
                min_ind=json_wb.index(min_profix)
                
                result={"max_ind":max_ind+1,"max_profix":max_profix,"min_ind":min_ind+1,"min_profix":min_profix,"mon_profix":round(sum(json_wb2),2)}
                return result
        else:
            return False
    #获取充放趋势板块数据
    def getTrendData(self):
        if self.__isGetAll:
            queryDict=self.__queryDict.copy()
            arr_date=self.__queryDict["date"].split('-')
            queryDict['date']=arr_date[0]
            monum=int(arr_date[-1])
    
            queryStr="?"
            for key, value in queryDict.items():
                queryStr+="%s=%s&"%(key,value)
            url=self.__url_prefix+self.__type[2]+queryStr[:-1]
    
            wbdata = requests.get(url,headers=self.__header).text
            json_wb=json.loads(wbdata)['option']['series']
            result={}
            for it in json_wb:
    #             it['name'],it['data']
                result.setdefault(it['name'],it['data'][monum-1])
            return result
        else:
            return False
    #获取告警报文历史数据,当date传了一个日期时表示只查询这一天的告警信息
    def getAlarmCycle(self,date=""):
        url="http://ess.clouyun.com/getTableBody"
        post_data={ "total":10,
                    "nodeId":self.__queryDict['stationId'],#电站Id
                    "sta":self.__queryDict["date"]+"-01 00:00:00",
                    'equiType': -1,#设备类型PCS/BMS/BCMS/DMU
                    'fileName': '报文历史数据',
                    'eventLevel': -1,#事件级别
                    'actionId': 2060,
                    'nodeType': 'EventPast',
                    'end': self.__queryDict["date"]+"-30 23:53:53",
                    'bmsCode': -1,#堆编码
                    'pageSize': 20000,
                    'page': 1,
                    'rows': 100
                }
        if date!="":
            post_data["sta"]=date+" 00:00:00"
            post_data["end"]=date+" 23:59:59"
        wbdata = requests.post(url,data=post_data,headers=self.__header).content.decode()
        json_wb=json.loads(wbdata)['rows']
        #给没有event_level的告警默认加上0级
        [it.setdefault('event_level','0') for it in json_wb]
#         events=[it['event'] for it in json_wb]
        el=[[it['event_level'],it['event']] for it in json_wb]
        if len(el)>0:
            df=pd.DataFrame(el)
            pd.set_option('display.max_rows', None)#列
            df.columns =["e_level","event"]
            levelsNum=df.groupby(['e_level'],as_index=False).count()
            levelsNum.columns =['e_level','number']
    #         print(levelsNum)
            es=[]
            for (k1, k2), group in df.groupby(["e_level",'event']):
                es.append([k1,k2,len(group)])
            df=pd.DataFrame(es)
            df.columns =["e_level","event","number"]
    #         print(df)
            #返回[df,levelsNum]
            return [df,levelsNum]
        else:
            return False
    #下一步，获取运行状况,放在getInComeData后面执行,max_profit作为阈值设定的参考值
    def getIsRunEveryDay(self,max_profit=0):
#         self.__header["Cookie"]= self.cookie
        if self.__isGetAll and max_profit!=0: #有日运行数据
            url=self.__url_prefix+self.__type[1]+self.__queryStr[:-1]
            wbdata = requests.get(url,headers=self.__header).text
            json_wb=json.loads(wbdata)['option']['series'][0]['data']
#             print('--------------------')
#             print(json_wb)
            result=[]#长度是该月长度的一个list
            for d in json_wb:
                #目前判定是不低于最高收益的1/20，具体设置多少还需修改
                if d!='' and abs(float(d)) >float(max_profit)/20:
                    result.append("√")  
                else:
                    result.append("×")
            if len(result) ==0:
                return False
            else:
                mons=len(result)
                runD=result.count("√")
                #最后一项加上运行的天数
                result.append(runD)
                #最后一项计算投入率
                result.append(round(runD/mons*100,1))
                return result            
        else:
            return False #表示根本没有总投资额的项目（包括了调频项目）
    #设置self.__queryDict并循环查询所有电站的信息，最后导入excel
    def exportToExcel(self):
        if self.cookie =="":
            try:
                getback=pickle.load(open('tmp.txt', 'rb'))
                self.__header["Cookie"]=getback["cookie"]
                lastTime=getback["dateTime"]
                #假定cookie有效时间为4小时
                if (time.time()-lastTime) >= 3600*1:
                    if self.setSaveCookie('tmp.txt')==False:
                        return
            except:
                print("本地文件存储Cookie的tmp.txt异常")
                if self.setSaveCookie('tmp.txt')==False:
                    return
        else:
            self.__header["Cookie"]= self.cookie       
        try:
            stationInfo=self.getStationId()
        except:
            print("您设置的Cookie无效或者网络有问题！")
            return
        #{'stationId': 1, 'stationName': '力源不锈钢', 'stationType': 'YFTG'}
#         print(stationInfo)
        arr_SurveyData=[]
        arr_incomeData=[]
        arr_TrendData=[]
        arr_AlarmCycle=[]
        arr_NN=[]#存储事件与等级的字典数组
        arr_isRun=[]
        for item in stationInfo:
            self.__isGetAll=True
            self.__queryDict["stationId"]=item["stationId"]
            self.__queryStr="?"
# 
            for key, value in self.__queryDict.items():
                self.__queryStr+="%s=%s&"%(key,value)
#               print(self.__queryStr)
            temp_SurveyData=self.getSurveyData()
            #
            temp_incomeData=self.getIncomeData()
            temp_TrendData=self.getTrendData()
            temp_AlarmCycle=self.getAlarmCycle()
# # 
            if temp_SurveyData == False:
                arr_SurveyData.append(["",""])
# # 
                ym=self.__queryDict["date"].split("-")
                if len(ym)>=2:
                    monDays=calendar.monthrange(int(ym[0]), int(ym[1]))[1]
                    #非调频项目打上×，(新丰的暂时空着,调频的空着 id=8,22,24,30
                    if item['stationType']=='TP':
                        arr_isRun.append([""]*(monDays+2))#打上相应个空格
                    else:
                        temp_monD=["×"]*monDays
                        temp_monD.append(0)
                        temp_monD.append(0)
                        arr_isRun.append(temp_monD)
                else: return"输入日期格式不对！"
            else:
                arr_SurveyData.append([value for (key,value) in temp_SurveyData.items()])
            if temp_incomeData == False:
                arr_incomeData.append(["","",""])
            else:
                arr_incomeData.append([value for (key,value) in temp_incomeData.items()])
                temp_isRun=self.getIsRunEveryDay(temp_incomeData["max_profix"])
                if temp_isRun !=False:
                    arr_isRun.append(temp_isRun)
                else:
                    ym=self.__queryDict["date"].split("-")
                    if len(ym)>=2:
                        monDays=calendar.monthrange(int(ym[0]), int(ym[1]))[1]
                        temp_monD=["×"]*monDays
                        temp_monD.append(0)
                        temp_monD.append(0)
                        arr_isRun.append(temp_monD)#一定是非调频项目，所以没数据应该打×
                    else: return"输入日期格式不对！"
            if temp_TrendData== False:
                arr_TrendData.append(["","","",""])
            else:
                arr_TrendData.append([value for (key,value) in temp_TrendData.items()])
            if temp_AlarmCycle:
                for i in range(temp_AlarmCycle[0].shape[0]):
                    arr_NN.append([temp_AlarmCycle[0].ix[i,"event"],temp_AlarmCycle[0].ix[i,"e_level"]])
#             print(arr_NN)
            arr_AlarmCycle.append(temp_AlarmCycle)

# 
#         for i in range(len(stationInfo)):
#             if stationInfo[i]['stationType']=='YFTG':
#                 stationInfo[i]['stationType']="移峰填谷"
#             else:
#                 stationInfo[i]['stationType']="调频"

        df1=pd.DataFrame(stationInfo)    
#         print(df1)
        df2=pd.DataFrame(arr_SurveyData)
        df3=pd.DataFrame(arr_incomeData)
        df4=pd.DataFrame(arr_TrendData)
#         print(df4)
        df5=pd.DataFrame(columns=["0","01","02","03"])#分别列出0,1,2,3等级告警，df5作为第3张表
        df5=pd.concat([df1,df5],axis=1)
#         print(df5)
        df=pd.concat([df1,df2,df3,df4],axis=1,ignore_index=True)
        pd.set_option('display.max_columns', None)#列
        df.columns = ["id","电站名称","电站类型","累计总收益/万元","总投资/万元","运行天数","累计充电量/MWh","累计放电量/MWh","月最高收益日", \
                    "月最高收益/元","月最低收益日","月最低收益/元","月总收益/元","月用户总用电/MWh","月储能充电/MWh","月储能放电/MWh","月总转换效率/%"]
#         print(arr_AlarmCycle[0])
#         #对等级进行一个排序，高的放前边
        arr_NN=sorted(arr_NN, key=lambda x: x[1])
#         print(arr_NN)
        for k in range(len(arr_NN)):
            df[arr_NN[k][0]]=""

        for i in range(len(arr_AlarmCycle)):
            if arr_AlarmCycle[i]:
                for j in range(arr_AlarmCycle[i][0].shape[0]):
                    df.ix[i,arr_AlarmCycle[i][0].ix[j,'event']]=arr_AlarmCycle[i][0].ix[j,'number']
                for j in range(arr_AlarmCycle[i][1].shape[0]):
                    df5.ix[i,arr_AlarmCycle[i][1].ix[j,'e_level']]=arr_AlarmCycle[i][1].ix[j,'number']
#         print(df)
        df6=pd.DataFrame(columns=df.columns)
        for i in range(len(arr_NN)):
            df6.loc[0,arr_NN[i][0]]=arr_NN[i][1]
        df5=df5.fillna("")
        df6=df6.fillna("")
        df=df6.append(df)
#         print(df)
# 
        df7=pd.DataFrame(arr_isRun)
        df8=pd.concat([df1,df7],axis=1,ignore_index=True)
#         
        temp_colsName=[]
        for i in range(len(df8.columns)):
            if i==0:temp_colsName.append("Id")
            elif i==1:temp_colsName.append("电站名称")
            elif i==2:temp_colsName.append("类型")
            elif i==len(df8.columns)-2:temp_colsName.append("运行天数")
            elif i==len(df8.columns)-1:temp_colsName.append("投入率/%")
            else:temp_colsName.append(i-2)
        df8.columns=temp_colsName
#         
#         print(df5)

        try:
            write=pd.ExcelWriter("./云平台数据"+self.__queryDict["date"]+".xlsx")
            df8.to_excel(write,self.__queryDict["date"]+"电站运行总览",index=False)
            df.to_excel(write,self.__queryDict["date"]+"数据统计",index=False)
            df5.to_excel(write,self.__queryDict["date"]+"每个电站告警次数",index=False)
            write.save()
            print("data is saved to 云平台数据"+self.__queryDict["date"]+".xlsx")
        except:
            print("数据导出失败,err:"+sys.exc_info()[0])
    #获取各堆DMU累计充放电量
    def getEngry(self):
        url="http://ess.clouyun.com/getTableBody"
        sta="2019-01-07 00:00:00"
        sta_e="2019-01-07 00:25:00"
        end="2019-01-07 12:00:00"
        end_s="2019-01-07 11:40:00"
        s_id=1337#新丰1314~1330,1335~1337
        e_id=1353#上都252~288 云河1337~1353,1357~1359
        dt=datetime.datetime.strptime(sta.split(' ')[0], '%Y-%m-%d')
        dt2=(dt+ datetime.timedelta(days = -1)).strftime("%Y-%m-%d")
        post_data={ "total":5056,
            "timeInterval": "all",
            "sta":sta,
            "check": str(dt).split(' ')[0],
            "contrast": str(dt2),
            'fileName': '电池堆历史数据',
            'actionId': 0,
            'nodeType': 'BmsPast',
            'bmsId': s_id,
            'end': sta_e,
            'pageSize': 100,
            'page': 1,
            'rows': 100,
            "checkflag": 0
        }
        ens=[]
        for c_id in range(s_id,e_id):
            post_data['sta']=sta
            post_data['end']=sta_e
            post_data['bmsId']=c_id
            wbdata = requests.post(url,data=post_data,headers=self.__header).content.decode()
            print(c_id)
#             if c_id in [273]:
#                 ens.append([0])
#                 continue
            json_wb=json.loads(wbdata)['rows'][0]
            en_sta=[float(json_wb['all_inenergy']),float(json_wb['all_outenergy'])]
            post_data['sta']=end_s
            post_data['end']=end
            wbdata = requests.post(url,data=post_data,headers=self.__header).content.decode()
            json_wb=json.loads(wbdata)['rows'][-1]
            en_end=[float(json_wb['all_inenergy']),float(json_wb['all_outenergy'])]
            en=np.array(en_end)-np.array(en_sta)
            ens.append(en)

        return pd.DataFrame(ens)
    def getAGCC(self,sta,end):
        url="http://ess.clouyun.com/getTableBody"
        post_data={ "total":20000,
            "timeInterval": "all",
            "beginTime":sta,
            'fileName': 'AGC策略数据',
            'actionId': 2094,
            'nodeType': 'PGData',
            'pgId': 1,
            'type':2,
            'endTime': end,
            'pageSize': 15000,
            'page': 1,
            'rows': 100,
        }
        wbdata = requests.post(url,data=post_data,headers=self.__header).content.decode()
        json_wb=json.loads(wbdata)['rows']
        dataTimes=[it['data_date'] for it in json_wb]
        power_cmd=[it['power_cmd'] for it in json_wb]#储能功率指令
        pz=[it['pz'] for it in json_wb]#有功功率
        res=[dataTimes,power_cmd,pz]
        df=pd.DataFrame(res).T
        df.columns=['时间','储能功率指令','有功功率']
        write=pd.ExcelWriter("云平台数据AGC机组1储能系统数据_"+sta.split(' ')[0]+".xlsx")
        df.to_excel(write,index=False,header=None)
        write.save()
        print("data is saved to 云平台数据AGC机组1储能系统数据_"+sta.split(' ')[0]+".xlsx")
    #定时获取堆的在线状态
    def getOnlineState(self,page=2,staRow=100-1):
        url="http://ess.clouyun.com/getTableBody"
        post_data={ "total":1000,
            "nodeNode": "CJD_DOC_",
            "store":"false",
            'objectTypeStr': 'KG,',
            'allUnitStr': "78, 82, 83, 84, 86, 123, 130, 152, 201, 202, 204, 243, 245, 29, 49, 52, 85, 87, 91, 94, 102, 112, 115, 116, 117, 118, 119, 120, 122, 129, 131, 136, 137, 149, 153, 162, 203, 205, 241, 244, 246",
            'unitSvgId': 78,
            'eqType': 'docCJD',
            'otPersonalStr':1,
            'menuUrl': "cjdocQuery",
            'fileName': "全部档案",
            "actionId":130202,
            "nodeType":"CJD_DOC_",
            "objectType":"QB",
            "selectType":"two",
            "unitId":78,
            'page': page,
            'rows': staRow-1
        }
        wbdata = requests.post(url,data=post_data,headers=self.__header).content.decode()
        json_wb=json.loads(wbdata)['rows']
        rs=[[it['rn'],it['online']] for it in json_wb]
        return rs
    def getlogName(self,staId="",code="",beginD="2018-12-18"):
        url="http://ess.clouyun.com/getTableBody"
        beginT=beginD+" 00:00:00"
        endT=beginD+" 23:59:59"
        post_data={ "total":10,
            "pageSize": 100,
            "fileName": '报文历史数据',
            "beginTime":beginT,
            "stationId": staId,
            "code":code,     
            "actionId": 2062,
            "nodeType": 'MessagePast',
            "logType": 'bms',
            "endTime": endT,
            "page": 1,
            "rows": 100,
        }
#         print(post_data)
        wbdata = requests.post(url,data=post_data,headers=self.__header).content.decode()
#         print(wbdata)
        json_wb=json.loads(wbdata)['rows']
        logNames=[it['logName'] for it in json_wb]
        return logNames
    def get_cluster_ah(self):
        url="http://ess.clouyun.com/getTableBody"
        sta="2019-01-07 00:00:00"
        sta_e="2019-01-07 00:25:00"
        end="2019-01-07 12:00:00"
        end_s="2019-01-07 11:40:00"
        s_id=7311#上都1168 云河7381~7428(7429),7441~7446(7447)
        e_id=7359#上都1330 新丰7311~7359 7375~7381
        dt=datetime.datetime.strptime(sta.split(' ')[0], '%Y-%m-%d')
        dt2=(dt+ datetime.timedelta(days = -1)).strftime("%Y-%m-%d")
#         print(dt)
#         print(dt2)
        post_data={ "total":5056,
            "timeInterval": "all",
            "sta":sta,
            "check": str(dt).split(' ')[0],
            "contrast": str(dt2),
            'fileName': '电池簇历史数据',
            'actionId': 0,
            'nodeType': 'ClusterPast',
            'clusterId': s_id,
            'end': sta_e,
            'pageSize': 100,
            'page': 1,
            'rows': 100,
            "checkflag": 0
        }
        ahs=[]
        for c_id in range(s_id,e_id):
            post_data['sta']=sta
            post_data['end']=sta_e
            post_data['clusterId']=c_id
            wbdata = requests.post(url,data=post_data,headers=self.__header).content.decode()
            print(c_id)
#             if c_id in [1263,1264,1265,1266]:
#                 ahs.append([0])
#                 continue
            json_wb=json.loads(wbdata)['rows'][0]
            ah_sta=[float(json_wb['charge_ah']),float(json_wb['discharge_ah'])]
            post_data['sta']=end_s
            post_data['end']=end
            wbdata = requests.post(url,data=post_data,headers=self.__header).content.decode()
            json_wb=json.loads(wbdata)['rows'][-1]
            ah_end=[float(json_wb['charge_ah']),float(json_wb['discharge_ah'])]
            ah=np.array(ah_end)-np.array(ah_sta)
            ahs.append(ah)
        for c_id in range(7375,7381):
            post_data['sta']=sta
            post_data['end']=sta_e
            post_data['clusterId']=c_id
            wbdata = requests.post(url,data=post_data,headers=self.__header).content.decode()
            print(c_id)
#             if c_id in [1263,1264,1265,1266]:
#                 ahs.append([0])
#                 continue
            json_wb=json.loads(wbdata)['rows'][0]
            ah_sta=[float(json_wb['charge_ah']),float(json_wb['discharge_ah'])]
            post_data['sta']=end_s
            post_data['end']=end
            wbdata = requests.post(url,data=post_data,headers=self.__header).content.decode()
            json_wb=json.loads(wbdata)['rows'][-1]
            ah_end=[float(json_wb['charge_ah']),float(json_wb['discharge_ah'])]
            ah=np.array(ah_end)-np.array(ah_sta)
            ahs.append(ah)
        return pd.DataFrame(ahs)
if __name__=="__main__":
    os.chdir(sys.path[0])#加这条语句，可以把路径相对位置都定位到当前代码位置的目录下，从而不会导致不同运行环境下，保存到不同位置
    start=time.time()
    p = MyClass("2018-12")
    try:
        p.exportToExcel()
    except:
        with open(r'C:\Users\Administrator\Desktop\自动运行文件日志.log', 'a') as f:
            f.write('%s电站状态运行失败！请人工检查故障\n'%datetime.date.today())    

#     p.cookie=p.getCookie()
#     if p.cookie:
#         p.freshHeader()
#         p.get_cluster_ah()
#         print(p.cookie)
#         print(p.getStationId())
#         print(p.getlogName("25", "AHHR-C1-0110-01", "2018-12-18"))
# #         p.getAGCC('2018-11-29 00:00:00', '2018-11-30 00:00:00')
# #         print(p.getSurveyData())
# #         print(p.getIncomeData())
# #         print(p.getTrendData())
#         for i in range(1,31):
#             rs=p.getAlarmCycle("2018-11-"+str(i))
#             if rs:
#                 print("-------"+"2018-11-"+str(i)+"---------")
#                 print(rs[1])
#         rs=p.getAlarmCycle("2018-11-"+str(18))
#         print(rs[0])
##########
#         sta=["2018-10-12 09:03:22","2018-10-09 16:20:41","2018-10-15 01:08:26","2018-10-29 16:25:44","2018-10-31 08:20:32","2018-10-28 17:43:07","2018-10-06 06:53:05","2018-11-02 07:46:37","2018-11-04 17:20:58"]
#         #4小时后s1,end1相差1s
#         s1=["2018-10-13 7:37:06","2018-10-14 19:42:06","2018-10-28 12:08:08","2018-10-24 00:10:14","2018-10-20 14:23:53","2018-10-26 5:21:26","2018-10-30 13:35:32","2018-10-25 15:18:24","2018-10-24 16:59:54","2018-10-25 15:19:54"]
#         end1=["2018-10-13 7:38:06","2018-10-14 19:43:06","2018-10-28 12:09:08","2018-10-24 00:11:14","2018-10-20 14:24:53","2018-10-26 5:22:26","2018-10-30 13:36:32","2018-10-25 15:19:24","2018-10-24 17:00:54","2018-10-25 15:20:54"]
#         #8小时
#         s2=["2018-10-13 11:37:06","2018-10-14 23:42:06","2018-10-28 16:08:08","2018-10-24 04:10:14","2018-10-20 18:23:53","2018-10-26 9:21:26","2018-10-30 17:35:32","2018-10-25 18:53:57","2018-10-24 20:59:54","2018-10-25 18:53:57"]
#         end2=["2018-10-13 11:38:06","2018-10-14 23:43:06","2018-10-28 16:09:08","2018-10-24 04:11:14","2018-10-20 18:24:53","2018-10-26 9:22:26","2018-10-30 17:36:32","2018-10-25 19:19:24","2018-10-24 21:00:54","2018-10-25 19:20:54"]
#         #12小时
#         s3=["2018-10-12 21:02:22","2018-10-10 04:19:41","2018-10-15 13:07:26","2018-10-30 04:24:44","2018-10-31 20:19:32","2018-10-29 05:42:07","2018-10-06 18:52:05","2018-11-02 19:45:37","2018-11-05 05:19:58"]
#         end3=["2018-10-12 21:03:22","2018-10-10 04:20:41","2018-10-15 13:08:26","2018-10-30 04:25:44","2018-10-31 20:20:32","2018-10-29 05:43:07","2018-10-06 18:53:05","2018-11-02 19:46:37","2018-11-05 05:20:58"]
#         res_stas=[]
#         res_end1s=[]
#         res_end2s=[]
#         res_end3s=[]
#         for i in range(len(sta)):
#             r1=p.getEngry(sta[i],end3[i])
#             if len(r1)>0:
#                 res_stas.append(r1)
#             else:
#                 print("start fail")
# #             r2=p.getEngry(s1[i],end1[i],True)
# #             if len(r2)>0:
# #                 res_end1s.append(r2)
# #             else:
# #                 print("4 fail")
# #             r3=p.getEngry(s2[i],end2[i],True)
# #             if len(r3)>0:
# #                 res_end2s.append(r3)
# #             else:
# #                 print("8 fail")
#             r4=p.getEngry(s3[i],end3[i],True)
#             if len(r4)>0:
#                 res_end3s.append(r4)
#             else:
#                 print("12 fail")
# #         e1=np.array(res_end1s)-np.array(res_stas)
# #         e2=np.array(res_end2s)-np.array(res_stas)
# #         print(res_stas)
#         e3=np.array(res_end3s)-np.array(res_stas)
# #         print(e1)
# #         print(e2)
#         print(e3)
    
    end=time.time()
    print("总共耗时:"+str(end-start)+"秒")
