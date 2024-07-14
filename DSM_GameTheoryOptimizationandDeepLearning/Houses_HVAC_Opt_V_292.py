version='_V_288'

##############################
##############################
##############################

print('\n\n')
import tensorflow as tf
## keras
import keras 
from keras.models import Sequential
from keras.layers.core import Dense, Activation, Dropout, Flatten
from keras.layers import TimeDistributed
from keras.layers.recurrent import LSTM
from keras.callbacks import EarlyStopping, TensorBoard, ModelCheckpoint
from keras.layers.normalization import BatchNormalization
from time import time
from keras.layers.advanced_activations import LeakyReLU, PReLU, ReLU
from keras.layers import Bidirectional
from keras.layers import Input,Dropout
from keras.layers import BatchNormalization
from keras.callbacks import EarlyStopping, TensorBoard, ModelCheckpoint
from keras.optimizers import Adam, SGD, Nadam
import matplotlib as mpl
##############################################################from mpl_toolkits.mplot3d import Axes3D
##############################################################import seaborn as sns
##############################################################
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from sklearn.metrics import mean_squared_error,mean_absolute_error, r2_score
from sklearn import preprocessing
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score
##############################################################from tqdm import tqdm
##############################################################
##############################################################
from numpy import nan
import numpy as np
import numpy as num
import pandas as pd
from pandas import Series
##############################################################import tensorflow as tf
##############################################################from tensorflow.python.client import device_lib
##############################################################
import matplotlib
import matplotlib.pyplot as plt
from matplotlib.ticker import NullFormatter  # useful for `logit` scale
from matplotlib.ticker import MaxNLocator
##############################################################
##############################################################
##############################################################
import time
import math
#import sympy as sym
import io
from PIL import Image, ImageDraw
#from google.colab import files
from livelossplot import PlotLossesKeras
import subprocess
import datetime
from datetime import date
import dateutil.parser
import os
import csv
############
import datetime
import sys
import joblib
from array import array



###############
###############            
###############          

# split a univariate dataset into train/test sets
def make_Necessary_daysForPre():
     print('\n\n********** Prediction for one week, what is input day s ???   ********* \n **********  Please Determine Date by format dd-mm-yyyy for starting prediction: *********\n')
     while True :
        DOB = input('Date for starting a week of prediction ')
        try :
            DOB = datetime.datetime.strptime(DOB, '%d-%m-%Y')
            break
        except ValueError:
            print('Error: must be format dd-mm-yyyy ')
            userkey = input('press 1 to try again or 0 to exit:')
            if userkey == '0':
                sys.exit()
     InputDay_byKeybord=DOB
     print (f'Prediction input day is {DOB}\n')
     ######
     print('\n\n********** Please determine Verbose Situatiion (1 for On, and 0 for Off) *********\n')
     while True :
        DOB_Verbose = input('Verbose Situatiion=  ')
        DOB_Verbose=int(DOB_Verbose)
        try :
            if (1==DOB_Verbose or 0==DOB_Verbose):
                DOB_Verbose = DOB_Verbose
                break
        except ValueError:
            print('Error: must be format (1 for On, and 0 for Off) ')
            userkey = input('press 1 to try again or 0 to exit:')
            if userkey == '0':
                sys.exit()
     verbose_Figs=DOB_Verbose
     print (f'\nVerbose selected : {verbose_Figs}\n')
     ######
     ######        make format for of first day
     ######
     if (InputDay_byKeybord.month) >= 10:
      month=str(InputDay_byKeybord.month)
     else:
      month='0'+str(InputDay_byKeybord.month)
      
     if (InputDay_byKeybord.day) >= 10:
      day=str(InputDay_byKeybord.day)
      InputDay=str(InputDay_byKeybord.year)+'-'+month+'-'+day
     else:
      day='0'+str(InputDay_byKeybord.day)
      InputDay=str(InputDay_byKeybord.year)+'-'+month+'-'+day
     
     ##print(' InputDay', InputDay, '\n')
     ################
     ################             Make dates for one week
     ################
     print(' \n\n')
     date8=date7=date6=date5=date4=date3=date2=date = datetime.datetime.strptime( InputDay, '%Y-%m-%d')
     date += datetime.timedelta(days=1)
     date2 += datetime.timedelta(days=2)
     date3 += datetime.timedelta(days=3)
     date4 += datetime.timedelta(days=4)
     date5 += datetime.timedelta(days=5)
     date6 += datetime.timedelta(days=6)
     date7 += datetime.timedelta(days=7)
     date8 += datetime.timedelta(days=8)######### adding 7day later
     n = 0
     n2 = 1
     year='{0:.{1}f}'.format(date.year, n)
     UpdateYear=int(year)-2000## for julia
     month='{0:.{1}f}'.format(date.month, n)
     day='{0:.{1}f}'.format(date.day, n)
     day2='{0:.{1}f}'.format(date2.day, n)
     day3='{0:.{1}f}'.format(date3.day, n)
     day4='{0:.{1}f}'.format(date4.day, n)
     day5='{0:.{1}f}'.format(date5.day, n)
     day6='{0:.{1}f}'.format(date6.day, n)
     day7='{0:.{1}f}'.format(date7.day, n)
     day8='{0:.{1}f}'.format(date8.day, n)

     if int(month) >= 10:
       month=month
     else:
      month='0'+month

     if int(day) >= 10:
      day=day
     else:
      day='0'+day
     if int(day2) >= 10:
      day2=day2
     else:
      day2='0'+day2
     if int(day3) >= 10:
      day3=day3
     else:
      day3='0'+day3
     if int(day4) >= 10:
      day4=day4
     else:
      day4='0'+day4
     if int(day5) >= 10:
      day5=day5
     else:
      day5='0'+day5
     if int(day6) >= 10:
      day6=day6
     else:
      day6='0'+day6
     if int(day7) >= 10:
      day7=day7
     else:
      day7='0'+day7

     ############
     ############ make a list of days
     ############
     Pred_Days_list= []
     Pred_Days_list.append(InputDay)
     Day_1=year+'-'+month+'-'+day
     Pred_Days_list.append(Day_1)
     Day_2=year+'-'+month+'-'+day2
     Pred_Days_list.append(Day_2)
     Day_3=year+'-'+month+'-'+day3
     Pred_Days_list.append(Day_3)
     Day_4=year+'-'+month+'-'+day4
     Pred_Days_list.append(Day_4)
     Day_5=year+'-'+month+'-'+day5
     Pred_Days_list.append(Day_5)
     Day_6=year+'-'+month+'-'+day6
     Pred_Days_list.append(Day_6)
     Day_7=year+'-'+month+'-'+day7
     Pred_Days_list.append(Day_7)

     ###############
     ############### make start and stoptime of girdlabD
     ###############
     #### for one week predict
     ####for i in Pred_Days_list:
     #### print(i)
     make_Actual_Day=make_stop_Day=make_simulation_start_Day=datetime.datetime.strptime( InputDay, '%Y-%m-%d')
     make_Actual_Day += datetime.timedelta(days=1)
     make_simulation_start_Day -= datetime.timedelta(days=1)
     make_stop_Day += datetime.timedelta(days=2)
     year='{0:.{1}f}'.format(make_stop_Day.year, n)
     month='{0:.{1}f}'.format(make_stop_Day.month, n)
     start_simulation_Day='{0:.{1}f}'.format(make_simulation_start_Day.day, n)
     stop_Day='{0:.{1}f}'.format(make_stop_Day.day, n)
     Actual_Day='{0:.{1}f}'.format(make_Actual_Day.day, n)


     if int(month) >= 10:
      month=month
     else:
      month='0'+month
      
     if int(start_simulation_Day) == 31:
      start_simulation_Day= '01'
     elif int(start_simulation_Day) >= 10:
      start_simulation_Day=start_simulation_Day
     else:
       start_simulation_Day='0'+start_simulation_Day

     if int(stop_Day) >= 10:
      stop_Day=stop_Day
     else:
      stop_Day='0'+stop_Day
      
     if int(Actual_Day) >= 10:
      Actual_Day=Actual_Day
     else:
      Actual_Day='0'+Actual_Day

     starttime_Date=year+'-'+month+'-'+start_simulation_Day
     stoptime_Date=year+'-'+month+'-'+stop_Day
     Act_Date=year+'-'+month+'-'+Actual_Day
     Act_Date_ForOptJulia=month+'/'+Actual_Day+'/'+str(UpdateYear)
  
     starttime_glmRun='starttime='+starttime_Date+' '+'00:00:00'
     if (1==verbose_Figs):print(starttime_glmRun+'\n')

     stoptime_glmRun='stoptime='+stoptime_Date+' '+'00:00:00'
     if (1==verbose_Figs):print(stoptime_glmRun+'\n')
     return verbose_Figs,starttime_glmRun,starttime_Date,stoptime_glmRun,stoptime_Date,Act_Date_ForOptJulia,Act_Date,Pred_Days_list,InputDay,month


def Run_gridlabd(starttime_glmRun, stoptime_glmRun,version):
    print(' \n Start Running gridlabd-D \n')
    subprocess.run(['gridlabd', 'Python_IEEE_15_Houses_distribution_system'+ version +'.glm', '--define', starttime_glmRun, '--define', stoptime_glmRun])
    print(' \n Stop Running gridlabd-D \n')
    
def Run_gridlabd_BaseOn_DR_Signal(starttime_glmRun, stoptime_glmRun,version):
    print(' \n Start Running gridlabd_BaseOn_DR_Signal \n')
    subprocess.run(['gridlabd', 'Python_IEEE_15_Houses_distribution_system_BaseOn_DR_Signal'+ version +'.glm', '--define', starttime_glmRun, '--define', stoptime_glmRun])
    print(' \n Stop Running gridlabd_BaseOn_DR_Signal\n')

def Change_SetPointsDate_FromInitial(starttime_Date, Input_Date,Act_Date,stoptime_Date,Pred_Date_Num,verbose_Figs):
    print(' \n find in From Initial  \n')

    if (Pred_Date_Num)==1:
     time_exec='s/'+'2000-01-01'+'/'+starttime_Date+'/g'
     if (1==verbose_Figs):print(' \n if 1 and starttime_Date in player become =', starttime_Date)
     All_exec='(find . -type f \( -name "*.player" -o -name  "*setpoints" \) -readable -writable -exec sed -i '+time_exec+' {} \;)'
     subprocess.call(All_exec, shell=True)
     
     time_exec='s/'+'2000-01-02'+'/'+Input_Date+'/g'
     if (1==verbose_Figs):print(' \n if 1 and starttime_Date in player become =', Input_Date)
     All_exec='(find . -type f \( -name "*.player" -o -name  "*setpoints" \) -readable -writable -exec sed -i '+time_exec+' {} \;)'
     subprocess.call(All_exec, shell=True)
     
     time_exec='s/'+'2000-01-03'+'/'+Act_Date+'/g'
     if (1==verbose_Figs):print(' \n if 1 and starttime_Date in player become =', Act_Date)
     All_exec='(find . -type f \( -name "*.player" -o -name  "*setpoints" \) -readable -writable -exec sed -i '+time_exec+' {} \;)'
     subprocess.call(All_exec, shell=True)
     
     time_exec='s/'+'2000-01-04'+'/'+stoptime_Date+'/g'
     if (1==verbose_Figs):print(' \n if 1 and starttime_Date in player become =', stoptime_Date)
     All_exec='(find . -type f \( -name "*.player" -o -name  "*setpoints" \) -readable -writable -exec sed -i '+time_exec+' {} \;)'
     subprocess.call(All_exec, shell=True)
    print(' \n find From Initial is done \n')
    
def Change_SetPointsDate_ToInitial(starttime_Date, Input_Date,Act_Date,stoptime_Date,Pred_Date_Num,verbose_Figs):
    print(' \n find in  To Initial \n')
    if (Pred_Date_Num) == 1:# should be 7, since after 7 Dates we want make intila file agin
     time_exec='s/'+starttime_Date+'/'+'2000-01-01'+'/g'
     if (1==verbose_Figs):print(' \n if 2 and starttime_Date in player become = 2000-01-01')
     All_exec='(find . -type f \( -name "*.player" -o -name  "*setpoints" \) -readable -writable -exec sed -i '+time_exec+' {} \;)'
     subprocess.call(All_exec, shell=True)
     
     time_exec='s/'+Input_Date+'/'+'2000-01-02'+'/g'
     if (1==verbose_Figs):print(' \n if 2 and starttime_Date in player become = 2000-01-02')
     All_exec='(find . -type f \( -name "*.player" -o -name  "*setpoints" \) -readable -writable -exec sed -i '+time_exec+' {} \;)'
     subprocess.call(All_exec, shell=True)
     
     time_exec='s/'+Act_Date+'/'+'2000-01-03'+'/g'
     if (1==verbose_Figs):print(' \n if 2 and starttime_Date in player become = 2000-01-03')
     All_exec='(find . -type f \( -name "*.player" -o -name  "*setpoints" \) -readable -writable -exec sed -i '+time_exec+' {} \;)'
     subprocess.call(All_exec, shell=True)
     
     time_exec='s/'+stoptime_Date+'/'+'2000-01-04'+'/g'
     if (1==verbose_Figs):print(' \n if 2 and starttime_Date in player become = 2000-01-04')
     All_exec='(find . -type f \( -name "*.player" -o -name  "*setpoints" \) -readable -writable -exec sed -i '+time_exec+' {} \;)'
     subprocess.call(All_exec, shell=True)
    print(' \n find To Initial is done \n')
    
def Initial_Process_ToMake_Net_Total_H_data(verbose_Figs,House_N):
  print(' \n  *****************  Initial   process '+House_N+'  *****************\n')
  #HVAC_File_CSV='IEEE13_'+House_N+'_HVAC.csv'
  Net_Total_File_CSV='GLM_Files/OutPut_of_glm/TriplexMeterS/IEEE13_triplex_meter_'+House_N+'.csv'
  Net_Total_Gen_ByGridlabD= pd.read_csv(Net_Total_File_CSV, skiprows=8)
  Net_Total_Gen_ByGridlabD=Net_Total_Gen_ByGridlabD.rename(columns={'# timestamp': 'Timestamp', 'measured_real_energy': ''+House_N+'_measured_real_energy'})
  Net_Total_Gen_ByGridlabD = pd.DataFrame(Net_Total_Gen_ByGridlabD)
  Variable_name_1=''+House_N+'_measured_real_energy'
  Net_Total_Gen_ByGridlabD_1 = Net_Total_Gen_ByGridlabD['Timestamp'].str.split(n=2, expand=True)
  Net_Total_Gen_ByGridlabD_2=Net_Total_Gen_ByGridlabD_1.rename(columns={0: 'day', 1: 'time', 2: 'zone'})
  Net_Total_Gen_ByGridlabD['Timestamp']=Net_Total_Gen_ByGridlabD_2['day'] + ' ' + Net_Total_Gen_ByGridlabD_2['time']
  Net_Total_Gen_ByGridlabD_3=Net_Total_Gen_ByGridlabD.rename(columns={'Timestamp': 'data_time'})
  ##print(' After making  '+House_N+' HVAC_energy and Timestamp : data_time',HVAC_Gen_ByGridlabD_GridlabD_3.shape ,'\n')
  Net_Total_Gen_ByGridlabD_nubmerOfData=Net_Total_Gen_ByGridlabD.shape[0]-1
  Net_Total_Gen_ByGridlabD_LastDay=Net_Total_Gen_ByGridlabD_2['day'][Net_Total_Gen_ByGridlabD_nubmerOfData]
  Net_Total_Gen_ByGridlabD_dataset_1 = Net_Total_Gen_ByGridlabD_3.set_index('data_time')
  Net_Total_Gen_ByGridlabD_dataset_1.index = pd.to_datetime(Net_Total_Gen_ByGridlabD_dataset_1.index)
  Net_Total_Gen_ByGridlabD_dataHour_1=Net_Total_Gen_ByGridlabD_dataset_1.resample('H').first()
  if (1==verbose_Figs):print('shape of Net_Total_Gen_ByGridlabD Data when it became base on Hours  \n',Net_Total_Gen_ByGridlabD_dataHour_1.shape ,'\n')
  Net_Total_Gen_ByGridlabD_dataHour_2=Net_Total_Gen_ByGridlabD_dataHour_1
  Comulative_Net_Total_Gen_ByGridlabD_energy_real=Net_Total_Gen_ByGridlabD_dataHour_2[Variable_name_1]##true vaule # Comulative energy
  H_Net_Total_Gen_ByGridlabD_energy_real = []
  j_Comulative=0
  Number_OFF_hours=0
  for i_Comulative in Comulative_Net_Total_Gen_ByGridlabD_energy_real:
      if j_Comulative>=1 :
        if (Comulative_Net_Total_Gen_ByGridlabD_energy_real[j_Comulative] > Comulative_Net_Total_Gen_ByGridlabD_energy_real[j_Comulative-1]):
          H_Net_Total_Gen_ByGridlabD_energy_real.append(Comulative_Net_Total_Gen_ByGridlabD_energy_real[j_Comulative]- Comulative_Net_Total_Gen_ByGridlabD_energy_real[j_Comulative-1])
        else:
          #print('H_HVAC_Gen_ByGridlabD_energy_real * HVAC OFF * ')   
          H_Net_Total_Gen_ByGridlabD_energy_real.append(0.00)
          Number_OFF_hours=Number_OFF_hours+1
      else:
        H_Net_Total_Gen_ByGridlabD_energy_real.append(Comulative_Net_Total_Gen_ByGridlabD_energy_real[j_Comulative])
      j_Comulative=j_Comulative+1
  Net_Total_Gen_ByGridlabD_Number_Total_hours=len(H_Net_Total_Gen_ByGridlabD_energy_real)
  Net_Total_Gen_ByGridlabD_Percent_OFF=Number_OFF_hours/Net_Total_Gen_ByGridlabD_Number_Total_hours
    ##print('##########General information about '+House_N+'_data######## ')
    ##print('{} is Number OFF Hours for Net_Total between {} total hours for Net_Total_Gen_ByGridlabD_data'.format(Number_OFF_hours, Net_Total_Gen_ByGridlabD_Number_Total_hours) ,'\n')
    ##print('Therefore {} % of hours are OFF for '+House_N+'_data '.format(Net_Total_Gen_ByGridlabD_Percent_OFF) ,'\n')

  D_H_Net_Total_Gen_ByGridlabD_energy_real=Comulative_Net_Total_Gen_ByGridlabD_energy_real########## dataset_ = D_## initialize with incorrect numbers
  x_Net_Total_Gen_ByGridlabD=range(len(D_H_Net_Total_Gen_ByGridlabD_energy_real))
  for n_day in x_Net_Total_Gen_ByGridlabD:
      D_H_Net_Total_Gen_ByGridlabD_energy_real[n_day]=H_Net_Total_Gen_ByGridlabD_energy_real[n_day]
    ##print(type(D_H_Net_Total_Gen_ByGridlabD_energy_real))
    ##print(type(H_Net_Total_Gen_ByGridlabD_energy_real))
  D_H_Net_Total_Gen_ByGridlabD_energy_real = pd.DataFrame([D_H_Net_Total_Gen_ByGridlabD_energy_real])
  D_H_Net_Total_Gen_ByGridlabD_energy_real=D_H_Net_Total_Gen_ByGridlabD_energy_real.T

    ##print(' \n\n\n\n')
    # max should be equal to last acceptable number
  Net_Total_Gen_ByGridlabD_dataHour_2[Variable_name_1]=D_H_Net_Total_Gen_ByGridlabD_energy_real[Variable_name_1]
  Net_Total_Gen_ByGridlabD_dataHour_2[Variable_name_1]=Net_Total_Gen_ByGridlabD_dataHour_2[Variable_name_1]/1000########### KWh
  Net_Total_Gen_ByGridlabD_dataHour_2=Net_Total_Gen_ByGridlabD_dataHour_2.iloc[:,[0,1,2,3]]## removing unneccessary columns
  if (1==verbose_Figs):print(' \n',Net_Total_Gen_ByGridlabD_dataHour_2 ,'\n')
  print('\nInitial_Process_ToMake_Net_Total_H_data is done \n')
  return Net_Total_Gen_ByGridlabD_dataHour_2
    

def Process_ToMake_H_data_BasedON_DR_Signals(verbose_Figs,House_N):
  print(' \n  *****************  Process_ToMake_H_data_BasedON_DR_Signals '+House_N+'  *****************\n')
  #############################
  #############################      HVAC
  #############################        
  HVAC_opt_File_CSV='GLM_Files/OutPut_of_glm/HVACs/IEEE13_HVAC_'+House_N+'_opt.csv'
  HVAC_opt_Gen_ByGridlabD= pd.read_csv(HVAC_opt_File_CSV, skiprows=8)
  HVAC_opt_Gen_ByGridlabD=HVAC_opt_Gen_ByGridlabD.rename(columns={'# timestamp': 'Timestamp', 'energy': ''+House_N+'_HVAC_energy'})
  HVAC_opt_Gen_ByGridlabD = pd.DataFrame(HVAC_opt_Gen_ByGridlabD)
   ##print(''+House_N+'_HVAC shape ',HVAC_opt_Gen_ByGridlabD.shape ,'\n')
  ## Modify data i ----> j
  HVAC_opt_Gen_ByGridlabD[''+House_N+'_HVAC_energy'] = HVAC_opt_Gen_ByGridlabD[''+House_N+'_HVAC_energy'].str.replace('i','j').apply(lambda x: np.complex(x))
  ##print('\n\n .iloc[:,1:] \n\n',HVAC_opt_Gen_ByGridlabD.iloc[:,1:],'\n\n\n\n')
  ##print('\n\n .iloc[:,2] \n\n',HVAC_opt_Gen_ByGridlabD.iloc[:,2],'\n\n\n\n')
  #seperate Real and Imag  
  HVAC_opt_Gen_ByGridlabD[''+House_N+'_HVAC_energy_imag'] = np.imag(HVAC_opt_Gen_ByGridlabD.iloc[:,2])
  HVAC_opt_Gen_ByGridlabD[''+House_N+'_HVAC_energy_real'] = np.real(HVAC_opt_Gen_ByGridlabD.iloc[:,2])
  Variable_name_1='Timestamp'
  Variable_name_2='mass_temperature'
  Variable_name_3=' air_temperature'
  Variable_name_4='outdoor_temperature'
  Variable_name_5=''+House_N+'_HVAC_energy_imag'
  Variable_name_6=''+House_N+'_HVAC_energy_real'
  Variable_name_7=''+House_N+'_HVAC_energy'
  HVAC_opt_Gen_ByGridlabD_1 = HVAC_opt_Gen_ByGridlabD['Timestamp'].str.split(n=2, expand=True)
  HVAC_opt_Gen_ByGridlabD_2=HVAC_opt_Gen_ByGridlabD_1.rename(columns={0: 'day', 1: 'time', 2: 'zone'})
  HVAC_opt_Gen_ByGridlabD['Timestamp']=HVAC_opt_Gen_ByGridlabD_2['day'] + ' ' + HVAC_opt_Gen_ByGridlabD_2['time']
  HVAC_opt_Gen_ByGridlabD_3=HVAC_opt_Gen_ByGridlabD.rename(columns={'Timestamp': 'data_time'})
  ##print(' After making  '+House_N+' HVAC_energy and Timestamp : data_time',HVAC_Gen_ByGridlabD_GridlabD_3.shape ,'\n')
  HVAC_opt_Gen_ByGridlabD_nubmerOfData=HVAC_opt_Gen_ByGridlabD.shape[0]-1
  HVAC_opt_Gen_ByGridlabD_LastDay=HVAC_opt_Gen_ByGridlabD_2['day'][HVAC_opt_Gen_ByGridlabD_nubmerOfData]
  HVAC_opt_Gen_ByGridlabD_dataset_1 = HVAC_opt_Gen_ByGridlabD_3.set_index('data_time')
  HVAC_opt_Gen_ByGridlabD_dataset_1.index = pd.to_datetime(HVAC_opt_Gen_ByGridlabD_dataset_1.index)
  # each Hour.
  HVAC_opt_Gen_ByGridlabD_dataHour_1=HVAC_opt_Gen_ByGridlabD_dataset_1.resample('H').first()
  if (1==verbose_Figs):print('shape of HVAC_opt_Gen_ByGridlabD Data when it became base on Hours  \n',HVAC_opt_Gen_ByGridlabD_dataHour_1.shape ,'\n')
  HVAC_opt_Gen_ByGridlabD_dataHour_2=HVAC_opt_Gen_ByGridlabD_dataHour_1
  HVAC_opt_Gen_ByGridlabD_dataHour_2[Variable_name_7]=HVAC_opt_Gen_ByGridlabD_dataHour_1[Variable_name_6]
  Comulative_HVAC_opt_Gen_ByGridlabD_energy_real=HVAC_opt_Gen_ByGridlabD_dataHour_1[Variable_name_6]##true vaule # Comulative energy
  H_HVAC_opt_Gen_ByGridlabD_energy_real = []
  j_Comulative=0
  Number_OFF_hours=0
  for i_Comulative in Comulative_HVAC_opt_Gen_ByGridlabD_energy_real:
      if j_Comulative>=1 :
        if (Comulative_HVAC_opt_Gen_ByGridlabD_energy_real[j_Comulative] > Comulative_HVAC_opt_Gen_ByGridlabD_energy_real[j_Comulative-1]):
          H_HVAC_opt_Gen_ByGridlabD_energy_real.append(Comulative_HVAC_opt_Gen_ByGridlabD_energy_real[j_Comulative]- Comulative_HVAC_opt_Gen_ByGridlabD_energy_real[j_Comulative-1])
        else:
          #print('H_HVAC_Gen_ByGridlabD_energy_real * HVAC OFF * ')   
          H_HVAC_opt_Gen_ByGridlabD_energy_real.append(0.00)
          Number_OFF_hours=Number_OFF_hours+1
      else:
        H_HVAC_opt_Gen_ByGridlabD_energy_real.append(Comulative_HVAC_opt_Gen_ByGridlabD_energy_real[j_Comulative])
      j_Comulative=j_Comulative+1
  HVAC_opt_Gen_ByGridlabD_Number_Total_hours=len(H_HVAC_opt_Gen_ByGridlabD_energy_real)
  HVAC_opt_Gen_ByGridlabD_Percent_OFF=Number_OFF_hours/HVAC_opt_Gen_ByGridlabD_Number_Total_hours
    ##print('##########General information about '+House_N+'_data######## ')
    ##print('{} is Number OFF Hours forHVAC_opt between {} total hours for HVAC_opt_Gen_ByGridlabD_data'.format(Number_OFF_hours, HVAC_opt_Gen_ByGridlabD_Number_Total_hours) ,'\n')
    ##print('Therefore {} % of hours are OFF for '+House_N+'_data '.format(HVAC_opt_Gen_ByGridlabD_Percent_OFF) ,'\n')

  D_H_HVAC_opt_Gen_ByGridlabD_energy_real=Comulative_HVAC_opt_Gen_ByGridlabD_energy_real########## dataset_ = D_## initialize with incorrect numbers
  x_HVAC_opt_Gen_ByGridlabD=range(len(D_H_HVAC_opt_Gen_ByGridlabD_energy_real))
  for n_day in x_HVAC_opt_Gen_ByGridlabD:
      D_H_HVAC_opt_Gen_ByGridlabD_energy_real[n_day]=H_HVAC_opt_Gen_ByGridlabD_energy_real[n_day]
    ##print(type(D_H_HVAC_opt_Gen_ByGridlabD_energy_real))
    ##print(type(H_HVAC_opt_Gen_ByGridlabD_energy_real))
  D_H_HVAC_opt_Gen_ByGridlabD_energy_real = pd.DataFrame([D_H_HVAC_opt_Gen_ByGridlabD_energy_real])
  D_H_HVAC_opt_Gen_ByGridlabD_energy_real=D_H_HVAC_opt_Gen_ByGridlabD_energy_real.T
    ##print(' \n\n\n\n')
    # max should be equal to last acceptable number
  HVAC_opt_Gen_ByGridlabD_dataHour_2[Variable_name_7]=D_H_HVAC_opt_Gen_ByGridlabD_energy_real[Variable_name_6]
  HVAC_opt_Gen_ByGridlabD_dataHour_2=HVAC_opt_Gen_ByGridlabD_dataHour_2.iloc[:,[0,1,2,3,4,5,12,13]]## removing unneccessary columns
  if (1==verbose_Figs):print(' \nHVAC_opt_Gen_ByGridlabD_dataHour_2 \n',HVAC_opt_Gen_ByGridlabD_dataHour_2 ,'\n')

  #############################
  #############################      Net_Total
  #############################

  Net_Total_opt_File_CSV='GLM_Files/OutPut_of_glm/TriplexMeterS/IEEE13_triplex_meter_'+House_N+'_opt.csv'
  Net_Total_opt_Gen_ByGridlabD= pd.read_csv(Net_Total_opt_File_CSV, skiprows=8)
  Net_Total_opt_Gen_ByGridlabD=Net_Total_opt_Gen_ByGridlabD.rename(columns={'# timestamp': 'Timestamp', 'measured_real_energy': ''+House_N+'_measured_real_energy'})
  Net_Total_opt_Gen_ByGridlabD = pd.DataFrame(Net_Total_opt_Gen_ByGridlabD)
  Variable_name_1=''+House_N+'_measured_real_energy'
  Net_Total_opt_Gen_ByGridlabD_1 = Net_Total_opt_Gen_ByGridlabD['Timestamp'].str.split(n=2, expand=True)
  Net_Total_opt_Gen_ByGridlabD_2=Net_Total_opt_Gen_ByGridlabD_1.rename(columns={0: 'day', 1: 'time', 2: 'zone'})
  Net_Total_opt_Gen_ByGridlabD['Timestamp']=Net_Total_opt_Gen_ByGridlabD_2['day'] + ' ' + Net_Total_opt_Gen_ByGridlabD_2['time']
  Net_Total_opt_Gen_ByGridlabD_3=Net_Total_opt_Gen_ByGridlabD.rename(columns={'Timestamp': 'data_time'})
  ##print(
  Net_Total_opt_Gen_ByGridlabD_nubmerOfData=Net_Total_opt_Gen_ByGridlabD.shape[0]-1
  Net_Total_opt_Gen_ByGridlabD_LastDay=Net_Total_opt_Gen_ByGridlabD_2['day'][Net_Total_opt_Gen_ByGridlabD_nubmerOfData]
  Net_Total_opt_Gen_ByGridlabD_dataset_1 = Net_Total_opt_Gen_ByGridlabD_3.set_index('data_time')
  Net_Total_opt_Gen_ByGridlabD_dataset_1.index = pd.to_datetime(Net_Total_opt_Gen_ByGridlabD_dataset_1.index)
  Net_Total_opt_Gen_ByGridlabD_dataHour_1=Net_Total_opt_Gen_ByGridlabD_dataset_1.resample('H').first()
  if (1==verbose_Figs):print('shape of Net_Total_opt_Gen_ByGridlabD Data when it became base on Hours  \n',Net_Total_opt_Gen_ByGridlabD_dataHour_1.shape ,'\n')
  Net_Total_opt_Gen_ByGridlabD_dataHour_2=Net_Total_opt_Gen_ByGridlabD_dataHour_1
  Comulative_Net_Total_opt_Gen_ByGridlabD_energy_real=Net_Total_opt_Gen_ByGridlabD_dataHour_2[Variable_name_1]##true vaule # Comulative energy
  H_Net_Total_opt_Gen_ByGridlabD_energy_real = []
  j_Comulative=0
  Number_OFF_hours=0
  for i_Comulative in Comulative_Net_Total_opt_Gen_ByGridlabD_energy_real:
      if j_Comulative>=1 :
        if (Comulative_Net_Total_opt_Gen_ByGridlabD_energy_real[j_Comulative] > Comulative_Net_Total_opt_Gen_ByGridlabD_energy_real[j_Comulative-1]):
          H_Net_Total_opt_Gen_ByGridlabD_energy_real.append(Comulative_Net_Total_opt_Gen_ByGridlabD_energy_real[j_Comulative]- Comulative_Net_Total_opt_Gen_ByGridlabD_energy_real[j_Comulative-1])
        else:
          #print('
          H_Net_Total_opt_Gen_ByGridlabD_energy_real.append(0.00)
          Number_OFF_hours=Number_OFF_hours+1
      else:
        H_Net_Total_opt_Gen_ByGridlabD_energy_real.append(Comulative_Net_Total_opt_Gen_ByGridlabD_energy_real[j_Comulative])
      j_Comulative=j_Comulative+1
  Net_Total_opt_Gen_ByGridlabD_Number_Total_hours=len(H_Net_Total_opt_Gen_ByGridlabD_energy_real)
  Net_Total_opt_Gen_ByGridlabD_Percent_OFF=Number_OFF_hours/Net_Total_opt_Gen_ByGridlabD_Number_Total_hours
    ##print('##########General information about '+House_N+'_data######## ')
    ##print('{} is Number OFF Hours for Net_Total_opt between {} total hours for Net_Total_opt_Gen_ByGridlabD_data'.format(Number_OFF_hours, Net_Total_opt_Gen_ByGridlabD_Number_Total_hours) ,'\n')
    ##print('Therefore {} % of hours are OFF for '+House_N+'_data '.format(Net_Total_opt_Gen_ByGridlabD_Percent_OFF) ,'\n')

  D_H_Net_Total_opt_Gen_ByGridlabD_energy_real=Comulative_Net_Total_opt_Gen_ByGridlabD_energy_real########## dataset_ = D_## initialize with incorrect numbers
  x_Net_Total_opt_Gen_ByGridlabD=range(len(D_H_Net_Total_opt_Gen_ByGridlabD_energy_real))
  for n_day in x_Net_Total_opt_Gen_ByGridlabD:
      D_H_Net_Total_opt_Gen_ByGridlabD_energy_real[n_day]=H_Net_Total_opt_Gen_ByGridlabD_energy_real[n_day]
    ##print(type(D_H_Net_Total_opt_Gen_ByGridlabD_energy_real))
    ##print(type(H_Net_Total_opt_Gen_ByGridlabD_energy_real))
  D_H_Net_Total_opt_Gen_ByGridlabD_energy_real = pd.DataFrame([D_H_Net_Total_opt_Gen_ByGridlabD_energy_real])
  D_H_Net_Total_opt_Gen_ByGridlabD_energy_real=D_H_Net_Total_opt_Gen_ByGridlabD_energy_real.T

    ##print(' \n\n\n\n')
    # max should be equal to last acceptable number
  Net_Total_opt_Gen_ByGridlabD_dataHour_2[Variable_name_1]=D_H_Net_Total_opt_Gen_ByGridlabD_energy_real[Variable_name_1]
  Net_Total_opt_Gen_ByGridlabD_dataHour_2[Variable_name_1]=Net_Total_opt_Gen_ByGridlabD_dataHour_2[Variable_name_1]/1000########### KWh
  Net_Total_opt_Gen_ByGridlabD_dataHour_2=Net_Total_opt_Gen_ByGridlabD_dataHour_2.iloc[:,[0,1,2,3]]## removing unneccessary columns
  if (1==verbose_Figs):print(' \nNet_Total_opt_Gen_ByGridlabD_dataHour_2 \n',Net_Total_opt_Gen_ByGridlabD_dataHour_2 ,'\n')
  print('\nInitial_Process_ToMake_Net_Total_H_data is done \n')
  return Net_Total_opt_Gen_ByGridlabD_dataHour_2,HVAC_opt_Gen_ByGridlabD_dataHour_2
    
    
    
    
    

def Initial_Process_ToMake_HVAC_H_data(verbose_Figs,House_N):
  print(' \n  *****************  Initial   process '+House_N+'  *****************\n')
  #HVAC_File_CSV='IEEE13_'+House_N+'_HVAC.csv'
  HVAC_File_CSV='GLM_Files/OutPut_of_glm/HVACs/IEEE13_HVAC_'+House_N+'.csv'
  HVAC_Gen_ByGridlabD= pd.read_csv(HVAC_File_CSV, skiprows=8)
  HVAC_Gen_ByGridlabD=HVAC_Gen_ByGridlabD.rename(columns={'# timestamp': 'Timestamp', 'energy': ''+House_N+'_HVAC_energy'})
  HVAC_Gen_ByGridlabD = pd.DataFrame(HVAC_Gen_ByGridlabD)
  ##print(''+House_N+'_HVAC shape ',HVAC_Gen_ByGridlabD.shape ,'\n')
  ## Modify data i ----> j
  HVAC_Gen_ByGridlabD[''+House_N+'_HVAC_energy'] = HVAC_Gen_ByGridlabD[''+House_N+'_HVAC_energy'].str.replace('i','j').apply(lambda x: np.complex(x))
  ##print('\n\n .iloc[:,1:] \n\n',HVAC_Gen_ByGridlabD.iloc[:,1:],'\n\n\n\n')
  ##print('\n\n .iloc[:,2] \n\n',HVAC_Gen_ByGridlabD.iloc[:,2],'\n\n\n\n')
  #seperate Real and Imag  
  HVAC_Gen_ByGridlabD[''+House_N+'_HVAC_energy_imag'] = np.imag(HVAC_Gen_ByGridlabD.iloc[:,2])
  HVAC_Gen_ByGridlabD[''+House_N+'_HVAC_energy_real'] = np.real(HVAC_Gen_ByGridlabD.iloc[:,2])
  Variable_name_1='Timestamp'
  Variable_name_2='mass_temperature'
  Variable_name_3=' air_temperature'
  Variable_name_4='outdoor_temperature'
  Variable_name_5=''+House_N+'_HVAC_energy_imag'
  Variable_name_6=''+House_N+'_HVAC_energy_real'
  Variable_name_7=''+House_N+'_HVAC_energy'
  HVAC_Gen_ByGridlabD_1 = HVAC_Gen_ByGridlabD['Timestamp'].str.split(n=2, expand=True)
  HVAC_Gen_ByGridlabD_2=HVAC_Gen_ByGridlabD_1.rename(columns={0: 'day', 1: 'time', 2: 'zone'})
  HVAC_Gen_ByGridlabD['Timestamp']=HVAC_Gen_ByGridlabD_2['day'] + ' ' + HVAC_Gen_ByGridlabD_2['time']
  HVAC_Gen_ByGridlabD_3=HVAC_Gen_ByGridlabD.rename(columns={'Timestamp': 'data_time'})
  ##print(' After making  '+House_N+' HVAC_energy and Timestamp : data_time',HVAC_Gen_ByGridlabD_GridlabD_3.shape ,'\n')
  HVAC_Gen_ByGridlabD_nubmerOfData=HVAC_Gen_ByGridlabD.shape[0]-1
  HVAC_Gen_ByGridlabD_LastDay=HVAC_Gen_ByGridlabD_2['day'][HVAC_Gen_ByGridlabD_nubmerOfData]
  HVAC_Gen_ByGridlabD_dataset_1 = HVAC_Gen_ByGridlabD_3.set_index('data_time')
  HVAC_Gen_ByGridlabD_dataset_1.index = pd.to_datetime(HVAC_Gen_ByGridlabD_dataset_1.index)
  # each Hour.
  HVAC_Gen_ByGridlabD_dataHour_1=HVAC_Gen_ByGridlabD_dataset_1.resample('H').first()
  if (1==verbose_Figs):print('shape of HVAC_Gen_ByGridlabD Data when it became base on Hours  \n',HVAC_Gen_ByGridlabD_dataHour_1.shape ,'\n')
  HVAC_Gen_ByGridlabD_dataHour_2=HVAC_Gen_ByGridlabD_dataHour_1
  HVAC_Gen_ByGridlabD_dataHour_2[Variable_name_7]=HVAC_Gen_ByGridlabD_dataHour_1[Variable_name_6]
  Comulative_HVAC_Gen_ByGridlabD_energy_real=HVAC_Gen_ByGridlabD_dataHour_1[Variable_name_6]##true vaule # Comulative energy
  H_HVAC_Gen_ByGridlabD_energy_real = []
  j_Comulative=0
  Number_OFF_hours=0
  for i_Comulative in Comulative_HVAC_Gen_ByGridlabD_energy_real:
      if j_Comulative>=1 :
        if (Comulative_HVAC_Gen_ByGridlabD_energy_real[j_Comulative] > Comulative_HVAC_Gen_ByGridlabD_energy_real[j_Comulative-1]):
          H_HVAC_Gen_ByGridlabD_energy_real.append(Comulative_HVAC_Gen_ByGridlabD_energy_real[j_Comulative]- Comulative_HVAC_Gen_ByGridlabD_energy_real[j_Comulative-1])
        else:
          #print('H_HVAC_Gen_ByGridlabD_energy_real * HVAC OFF * ')   
          H_HVAC_Gen_ByGridlabD_energy_real.append(0.00)
          Number_OFF_hours=Number_OFF_hours+1
      else:
        H_HVAC_Gen_ByGridlabD_energy_real.append(Comulative_HVAC_Gen_ByGridlabD_energy_real[j_Comulative])
      j_Comulative=j_Comulative+1
  HVAC_Gen_ByGridlabD_Number_Total_hours=len(H_HVAC_Gen_ByGridlabD_energy_real)
  HVAC_Gen_ByGridlabD_Percent_OFF=Number_OFF_hours/HVAC_Gen_ByGridlabD_Number_Total_hours
    ##print('##########General information about '+House_N+'_data######## ')
    ##print('{} is Number OFF Hours for HVAC between {} total hours for HVAC_Gen_ByGridlabD_data'.format(Number_OFF_hours, HVAC_Gen_ByGridlabD_Number_Total_hours) ,'\n')
    ##print('Therefore {} % of hours are OFF for '+House_N+'_data '.format(HVAC_Gen_ByGridlabD_Percent_OFF) ,'\n')

  D_H_HVAC_Gen_ByGridlabD_energy_real=Comulative_HVAC_Gen_ByGridlabD_energy_real########## dataset_ = D_## initialize with incorrect numbers
  x_HVAC_Gen_ByGridlabD=range(len(D_H_HVAC_Gen_ByGridlabD_energy_real))
  for n_day in x_HVAC_Gen_ByGridlabD:
      D_H_HVAC_Gen_ByGridlabD_energy_real[n_day]=H_HVAC_Gen_ByGridlabD_energy_real[n_day]
    ##print(type(D_H_HVAC_Gen_ByGridlabD_energy_real))
    ##print(type(H_HVAC_Gen_ByGridlabD_energy_real))
  D_H_HVAC_Gen_ByGridlabD_energy_real = pd.DataFrame([D_H_HVAC_Gen_ByGridlabD_energy_real])
  D_H_HVAC_Gen_ByGridlabD_energy_real=D_H_HVAC_Gen_ByGridlabD_energy_real.T

    ##print(' \n\n\n\n')
    # max should be equal to last acceptable number
  HVAC_Gen_ByGridlabD_dataHour_2[Variable_name_7]=D_H_HVAC_Gen_ByGridlabD_energy_real[Variable_name_6]
  HVAC_Gen_ByGridlabD_dataHour_2=HVAC_Gen_ByGridlabD_dataHour_2.iloc[:,[0,1,2,3,4,5,12,13]]## removing unneccessary columns
  print('\nInitial_Process_ToMake_HVAC_H_data is done \n')
  return HVAC_Gen_ByGridlabD_dataHour_2

  
def HVAC_H_data_prepration_for_LSTM(verbose_Figs,HVAC_Gen_ByGridlabD_dataHour_2,House_N,Input_Date,Act_Date):
    #####       Hourly  data prepration for  HVAC_Gen_ByGridlabD    ###########################################################################
    ########
    ##print('\n\n\n\n')
  HVAC_Gen_ByGridlabD_dataHour_1=HVAC_Gen_ByGridlabD_dataHour_2
    ##print('input for prediction  in HVAC_Gen_ByGridlabD \n',HVAC_Gen_ByGridlabD_dataHour_1,'\n\n',HVAC_Gen_ByGridlabD_dataHour_1['HVAC_Gen_ByGridlabD_HVAC_energy'],'\n')

  HVAC_Gen_ByGridlabD_data_prediction=HVAC_Gen_ByGridlabD_dataHour_1.loc[ Input_Date: Input_Date, :][''+House_N+'_HVAC_energy']##true vaule (today)using for predict 
  HVAC_Gen_ByGridlabD_data_prediction=np.array(HVAC_Gen_ByGridlabD_data_prediction).astype('float32')

    ######################          Normalize HVAC_Gen_ByGridlabD data for_prediction 

    ##print('\n\n\n\n')
  HVAC_Gen_ByGridlabD_values=HVAC_Gen_ByGridlabD_data_prediction
  HVAC_Gen_ByGridlabD_values=HVAC_Gen_ByGridlabD_values.reshape((len(HVAC_Gen_ByGridlabD_values), 1))

    ########
    #######         Preparing HVAC_Gen_ByGridlabD Actual data which prdiction have done it based on a day before on that         #####
    ########
    ##print('\n\n HVAC_Gen_ByGridlabD Actual vaule \n')
  HVAC_Gen_ByGridlabD_Act_DateData=HVAC_Gen_ByGridlabD_dataHour_1.loc[Act_Date:Act_Date, :][''+House_N+'_HVAC_energy']##Actual vaule for comparing predict
    ##print(HVAC_Gen_ByGridlabD_Act_DateData,'\n')
  HVAC_Gen_ByGridlabD_Act_DateData=np.array(HVAC_Gen_ByGridlabD_Act_DateData).astype('float32')
  HVAC_Gen_ByGridlabD_values_Actual=HVAC_Gen_ByGridlabD_Act_DateData
  HVAC_Gen_ByGridlabD_values_Actual = HVAC_Gen_ByGridlabD_values_Actual.reshape((len(HVAC_Gen_ByGridlabD_values_Actual), 1))

    #   normalization       
  if (month) == '01':
      print('normalization '+House_N+' for Jan \n')
      Jans_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_Jans_'+House_N+'_scaler_loaded.gz')######
      HVAC_Gen_ByGridlabD_normalized = Jans_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values)
      print('Actual data normalization '+House_N+' for Jans \n')
      HVAC_Gen_ByGridlabD_normalized_2 = Jans_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values_Actual)
  elif(month) == '02':
      print('normalization '+House_N+' for Feb \n')
      Feb_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_Feb_'+House_N+'_scaler_loaded.gz')
      HVAC_Gen_ByGridlabD_normalized = Feb_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values)
      print('Actual data normalization '+House_N+' for Feb \n')
      HVAC_Gen_ByGridlabD_normalized_2 = Feb_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values_Actual)
  elif(month) == '03':
      print('normalization '+House_N+' for March \n')
      March_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_March_'+House_N+'_scaler_loaded.gz')
      HVAC_Gen_ByGridlabD_normalized = March_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values)
      print('Actual data normalization '+House_N+' for March \n')
      HVAC_Gen_ByGridlabD_normalized_2 = March_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values_Actual)
  elif(month) == '04':
      print('normalization '+House_N+' for April \n')                                                                                                                                                                 
      April_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_April_'+House_N+'_scaler_loaded.gz')
      HVAC_Gen_ByGridlabD_normalized = April_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values)
      print('Actual data normalization '+House_N+' for April \n')
      HVAC_Gen_ByGridlabD_normalized_2 = April_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values_Actual)
  elif(month) == '05':
      print('normalization '+House_N+' for May \n')                                            
      May_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_May_'+House_N+'_scaler_loaded.gz')
      HVAC_Gen_ByGridlabD_normalized = May_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values)
      print('Actual data normalization '+House_N+' for May \n')
      HVAC_Gen_ByGridlabD_normalized_2 = May_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values_Actual)
  elif(month) == '06':
      print('normalization '+House_N+' for Jun \n')
      Jun_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_Jun_'+House_N+'_scaler_loaded.gz')
      HVAC_Gen_ByGridlabD_normalized = Jun_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values)
      print('Actual data normalization '+House_N+' for Jun \n')
      HVAC_Gen_ByGridlabD_normalized_2 = Jun_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values_Actual)
  elif(month) == '07':
      print('normalization '+House_N+' for July \n')
      July_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_July_'+House_N+'_scaler_loaded.gz')
      HVAC_Gen_ByGridlabD_normalized = July_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values)
      print('Actual data normalization '+House_N+' for July \n')
      HVAC_Gen_ByGridlabD_normalized_2 = July_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values_Actual)
  elif(month) == '08':
      print('normalization '+House_N+' for Aug \n')  
      Aug_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_Aug_'+House_N+'_scaler_loaded.gz')
      HVAC_Gen_ByGridlabD_normalized = Aug_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values)
      print('Actual data normalization '+House_N+' for Aug \n')
      HVAC_Gen_ByGridlabD_normalized_2 = Aug_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values_Actual)
  elif(month) == '09':
      print('normalization '+House_N+' for Sep \n')  
      Sep_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_Sep_'+House_N+'_scaler_loaded.gz')
      HVAC_Gen_ByGridlabD_normalized = Sep_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values)
      print('Actual data normalization '+House_N+' for Sep \n')
      HVAC_Gen_ByGridlabD_normalized_2 = Sep_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values_Actual)
  elif(month) == '10':
      print('normalization '+House_N+' for Oct \n')  
      Oct_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_Oct_'+House_N+'_scaler_loaded.gz')
      HVAC_Gen_ByGridlabD_normalized = Oct_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values)
      print('Actual data normalization '+House_N+' for Oct \n')
      HVAC_Gen_ByGridlabD_normalized_2 = Oct_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values_Actual)
  elif(month) == '11':
      print('normalization '+House_N+' for Nov \n')  
      Nov_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_Nov_'+House_N+'_scaler_loaded.gz')
      HVAC_Gen_ByGridlabD_normalized = Nov_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values)
      print('Actual data normalization '+House_N+' for Nov \n')
      HVAC_Gen_ByGridlabD_normalized_2 = Nov_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values_Actual)
  elif(month) == '12':
      print('normalization '+House_N+' for Dec \n')  
      Dec_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_Dec_'+House_N+'_scaler_loaded.gz')#
      HVAC_Gen_ByGridlabD_normalized = Dec_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values)
      print('Actual data normalization '+House_N+' for Dec \n')  
      HVAC_Gen_ByGridlabD_normalized_2 = Dec_HVAC_Gen_ByGridlabD_scaler.transform(HVAC_Gen_ByGridlabD_values_Actual)

  HVAC_Gen_ByGridlabD_normalized = HVAC_Gen_ByGridlabD_normalized.reshape((len(HVAC_Gen_ByGridlabD_normalized)))
  HVAC_Gen_ByGridlabD_input_x1=HVAC_Gen_ByGridlabD_normalized
  HVAC_Gen_ByGridlabD_input_x1=np.array(HVAC_Gen_ByGridlabD_input_x1).astype('float32')
    ################
  HVAC_Gen_ByGridlabD_normalized_2 = HVAC_Gen_ByGridlabD_normalized_2.reshape((len(HVAC_Gen_ByGridlabD_normalized_2), ))
  HVAC_Gen_ByGridlabD_Actula_output=HVAC_Gen_ByGridlabD_normalized_2
  HVAC_Gen_ByGridlabD_Actula_output=np.array(HVAC_Gen_ByGridlabD_Actula_output).astype('float32')
  if (1==verbose_Figs):print('\n RAW '+House_N+' data for prediction is ready : \n input', Input_Date ,'\n',  HVAC_Gen_ByGridlabD_data_prediction,'\n RAW '+House_N+' Actual  data  day \n ',Act_Date_ForOptJulia,'\n', HVAC_Gen_ByGridlabD_Act_DateData)
  return HVAC_Gen_ByGridlabD_Actula_output,HVAC_Gen_ByGridlabD_input_x1,HVAC_Gen_ByGridlabD_Act_DateData,HVAC_Gen_ByGridlabD_data_prediction

  
def Prediction_By_LSTM_models(verbose_Figs,HVAC_Gen_ByGridlabD_input_x1, House_N):
  
    #HVAC_Gen_ByGridlabD_plot_act=HVAC_Gen_ByGridlabD_input_x2=np.array(HVAC_Gen_ByGridlabD_input_x1).astype('float32')
  HVAC_Gen_ByGridlabD_input_x2=np.array(HVAC_Gen_ByGridlabD_input_x1).astype('float32')
  HVAC_Gen_ByGridlabD_input_x3 = HVAC_Gen_ByGridlabD_input_x2.reshape((1, len(HVAC_Gen_ByGridlabD_input_x2), 1))
  if (1==verbose_Figs):print('input shape for ML model \n',HVAC_Gen_ByGridlabD_input_x3.shape,'\n ************Prediction done *************')

  os.environ['CUDA_VISIBLE_DEVICES'] = '0'
  print('\n   *****************  Start  ML  loading  *****************\n  ***************** lstm model = '+House_N+'  *****************\n')  
  if (month) == '01':
      print('Prediction '+House_N+' for Jan \n')           
      Jan_hdf5_HVAC_Gen_ByGridlabD=keras.models.load_model('Py_Files/InPut_for_py/hdf5_S/'+House_N+'/U_'+House_N+'_Jans.hdf5')
      if (1==verbose_Figs):print(Jan_hdf5_HVAC_Gen_ByGridlabD.summary(),'\n\n *************************keras.model '+House_N+' *************Loaded******\n')
      HVAC_Gen_ByGridlabD_yhat = Jan_hdf5_HVAC_Gen_ByGridlabD.predict(HVAC_Gen_ByGridlabD_input_x3, verbose=0)
  elif(month) == '02':
      print('Prediction '+House_N+' for Feb \n')
      Feb_hdf5_HVAC_Gen_ByGridlabD=keras.models.load_model('Py_Files/InPut_for_py/hdf5_S/'+House_N+'/U_'+House_N+'_Feb.hdf5')
      if (1==verbose_Figs):print(Feb_hdf5_HVAC_Gen_ByGridlabD.summary(),'\n\n *************************keras.model '+House_N+' *************Loaded******\n')
      HVAC_Gen_ByGridlabD_yhat = Feb_hdf5_HVAC_Gen_ByGridlabD.predict(HVAC_Gen_ByGridlabD_input_x3, verbose=0)
  elif(month) == '03':
      print('Prediction '+House_N+' for March \n')
      March_hdf5_HVAC_Gen_ByGridlabD=keras.models.load_model('Py_Files/InPut_for_py/hdf5_S/'+House_N+'/U_'+House_N+'_March.hdf5')
      if (1==verbose_Figs):print(March_hdf5_HVAC_Gen_ByGridlabD.summary(),'\n\n *************************keras.model '+House_N+' *************Loaded******\n')
      HVAC_Gen_ByGridlabD_yhat = March_hdf5_HVAC_Gen_ByGridlabD.predict(HVAC_Gen_ByGridlabD_input_x3, verbose=0)
  elif(month) == '04':
      print('Prediction '+House_N+' for April \n')
      April_hdf5_HVAC_Gen_ByGridlabD=keras.models.load_model('Py_Files/InPut_for_py/hdf5_S/'+House_N+'/U_'+House_N+'_April.hdf5')
      if (1==verbose_Figs):print(April_hdf5_HVAC_Gen_ByGridlabD.summary(),'\n\n *************************keras.model '+House_N+' *************Loaded******\n')
      HVAC_Gen_ByGridlabD_yhat =April_hdf5_HVAC_Gen_ByGridlabD.predict(HVAC_Gen_ByGridlabD_input_x3, verbose=0)
  elif(month) == '05':
      print('Prediction '+House_N+' for May \n')
      May_hdf5_HVAC_Gen_ByGridlabD=keras.models.load_model('Py_Files/InPut_for_py/hdf5_S/'+House_N+'/U_'+House_N+'_May.hdf5')
      if (1==verbose_Figs):print(May_hdf5_HVAC_Gen_ByGridlabD.summary(),'\n\n *************************keras.model '+House_N+' *************Loaded******\n')
      HVAC_Gen_ByGridlabD_yhat =May_hdf5_HVAC_Gen_ByGridlabD.predict(HVAC_Gen_ByGridlabD_input_x3, verbose=0)
  elif(month) == '06':
      print('Prediction '+House_N+' for Jun \n')
      Jun_hdf5_HVAC_Gen_ByGridlabD=keras.models.load_model('Py_Files/InPut_for_py/hdf5_S/'+House_N+'/U_'+House_N+'_Jun.hdf5')
      if (1==verbose_Figs):print(Jun_hdf5_HVAC_Gen_ByGridlabD.summary(),'\n\n *************************keras.model '+House_N+' *************Loaded******\n')
      HVAC_Gen_ByGridlabD_yhat =Jun_hdf5_HVAC_Gen_ByGridlabD.predict(HVAC_Gen_ByGridlabD_input_x3, verbose=0)
  elif(month) == '07':
      print('Prediction '+House_N+' for July \n')
      July_hdf5_HVAC_Gen_ByGridlabD=keras.models.load_model('Py_Files/InPut_for_py/hdf5_S/'+House_N+'/U_'+House_N+'_July.hdf5')
      if (1==verbose_Figs):print(July_hdf5_HVAC_Gen_ByGridlabD.summary(),'\n\n *************************keras.model '+House_N+' *************Loaded******\n')
      HVAC_Gen_ByGridlabD_yhat =July_hdf5_HVAC_Gen_ByGridlabD.predict(HVAC_Gen_ByGridlabD_input_x3, verbose=0)
  elif(month) == '08':
      print('Prediction '+House_N+' for Aug \n')  
      Aug_hdf5_HVAC_Gen_ByGridlabD=keras.models.load_model('Py_Files/InPut_for_py/hdf5_S/'+House_N+'/U_'+House_N+'_Aug.hdf5')
      if (1==verbose_Figs):print(Aug_hdf5_HVAC_Gen_ByGridlabD.summary(),'\n\n *************************keras.model '+House_N+' *************Loaded******\n')
      HVAC_Gen_ByGridlabD_yhat =Aug_hdf5_HVAC_Gen_ByGridlabD.predict(HVAC_Gen_ByGridlabD_input_x3, verbose=0)
  elif(month) == '09':
      print('Prediction '+House_N+' for Sep \n')  
      Sep_hdf5_HVAC_Gen_ByGridlabD=keras.models.load_model('Py_Files/InPut_for_py/hdf5_S/'+House_N+'/U_'+House_N+'_Sep.hdf5')
      if (1==verbose_Figs):print(Sep_hdf5_HVAC_Gen_ByGridlabD.summary(),'\n\n *************************keras.model '+House_N+' *************Loaded******\n')
      HVAC_Gen_ByGridlabD_yhat =Sep_hdf5_HVAC_Gen_ByGridlabD.predict(HVAC_Gen_ByGridlabD_input_x3, verbose=0)
  elif(month) == '10':
      print('Prediction '+House_N+' for Oct \n')  
      Oct_hdf5_HVAC_Gen_ByGridlabD=keras.models.load_model('Py_Files/InPut_for_py/hdf5_S/'+House_N+'/U_'+House_N+'_Oct.hdf5')
      if (1==verbose_Figs):print(Oct_hdf5_HVAC_Gen_ByGridlabD.summary(),'\n\n *************************keras.model '+House_N+' *************Loaded******\n')
      HVAC_Gen_ByGridlabD_yhat =Oct_hdf5_HVAC_Gen_ByGridlabD.predict(HVAC_Gen_ByGridlabD_input_x3, verbose=0)
  elif(month) == '11':
      print('Prediction '+House_N+' for Nov \n')  
      Nov_hdf5_HVAC_Gen_ByGridlabD=keras.models.load_model('Py_Files/InPut_for_py/hdf5_S/'+House_N+'/U_'+House_N+'_Nov.hdf5')
      if (1==verbose_Figs):print(Nov_hdf5_HVAC_Gen_ByGridlabD.summary(),'\n\n *************************keras.model '+House_N+' *************Loaded******\n')
      HVAC_Gen_ByGridlabD_yhat =Nov_hdf5_HVAC_Gen_ByGridlabD.predict(HVAC_Gen_ByGridlabD_input_x3, verbose=0)
  elif(month) == '12':
      print('Prediction '+House_N+' for Dec \n')  
      Dec_hdf5_HVAC_Gen_ByGridlabD=keras.models.load_model('Py_Files/InPut_for_py/hdf5_S/'+House_N+'/U_'+House_N+'_Dec.hdf5')
      if (1==verbose_Figs):print(Dec_hdf5_HVAC_Gen_ByGridlabD.summary(),'\n\n *************************keras.model '+House_N+' *************Loaded******\n')
      HVAC_Gen_ByGridlabD_yhat = Dec_hdf5_HVAC_Gen_ByGridlabD.predict(HVAC_Gen_ByGridlabD_input_x3, verbose=0)
  return HVAC_Gen_ByGridlabD_yhat


def HVAC_H_data_prepration_from_LSTM_For_Figs_and_CSV(verbose_Figs,HVAC_Gen_ByGridlabD_yhat, HVAC_Gen_ByGridlabD_Actula_output, House_N, Act_Date_ForOptJulia,Input_Date,HVAC_Gen_ByGridlabD_Act_DateData):
    ##print('\n\n\n\n HVAC_Gen_ByGridlabD_Actula_output.shape \n ',HVAC_Gen_ByGridlabD_Actula_output.shape)
  HVAC_Gen_ByGridlabD_plot_act=HVAC_Gen_ByGridlabD_Actula_output
    ##print('Resutl of model predict(HVAC_Gen_ByGridlabD_input_x3)',HVAC_Gen_ByGridlabD_yhat.shape)
  HVAC_Gen_ByGridlabD_plot_pred = HVAC_Gen_ByGridlabD_yhat
  HVAC_Gen_ByGridlabD_plot_pred = HVAC_Gen_ByGridlabD_plot_pred.flatten()
  if (1==verbose_Figs):print('Resutl of model predict(HVAC_Gen_ByGridlabD_input_x3) after reshape',HVAC_Gen_ByGridlabD_plot_pred.shape,'\n\nDay used for prediction', Input_Date,' Actual Day  (optimizers MODEL)',Act_Date_ForOptJulia)
    #################Print arrays#########
    ##print('\n\n\n\n RAW!!  '+House_N+' Actual load',HVAC_Gen_ByGridlabD_Act_DateData)
  HVAC_Gen_ByGridlabD_Act_DateData=np.array(HVAC_Gen_ByGridlabD_Act_DateData).ravel().tolist()
    ##print(type(HVAC_Gen_ByGridlabD_Act_DateData),'\n Actual load_HVAC_Gen_ByGridlabD_normalized',HVAC_Gen_ByGridlabD_plot_act,type(HVAC_Gen_ByGridlabD_plot_act),'\n   Predicted load '+House_N+'  unscaled ')

  if (month) == '01':
      print('\n\nmake Unnormalied '+House_N+' prediction for Jan \n')
      Jans_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_Jans_'+House_N+'_scaler_loaded.gz')######
      Jans_pred_inv_HVAC_Gen_ByGridlabD=Jans_HVAC_Gen_ByGridlabD_scaler.inverse_transform(np.array(HVAC_Gen_ByGridlabD_yhat).reshape(-1,1))
      plotpred_inv_HVAC_Gen_ByGridlabD = Jans_pred_inv_HVAC_Gen_ByGridlabD.flatten()
  elif(month) == '02':
      print('\n\nmake Unnormalied '+House_N+' prediction for  Feb \n')
      Feb_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_Feb_'+House_N+'_scaler_loaded.gz')
      Feb_pred_inv_HVAC_Gen_ByGridlabD=Feb_HVAC_Gen_ByGridlabD_scaler.inverse_transform(np.array(HVAC_Gen_ByGridlabD_yhat).reshape(-1,1))
      plotpred_inv_HVAC_Gen_ByGridlabD = Feb_pred_inv_HVAC_Gen_ByGridlabD.flatten()
  elif(month) == '03':
      print('\n\nmake Unnormalied '+House_N+' prediction for  March \n')
      March_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_March_'+House_N+'_scaler_loaded.gz')
      March_pred_inv_HVAC_Gen_ByGridlabD=March_HVAC_Gen_ByGridlabD_scaler.inverse_transform(np.array(HVAC_Gen_ByGridlabD_yhat).reshape(-1,1))
      plotpred_inv_HVAC_Gen_ByGridlabD = March_pred_inv_HVAC_Gen_ByGridlabD.flatten()
  elif(month) == '04':
      print('\n\nmake Unnormalied '+House_N+' prediction for  April \n')
      April_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_April_'+House_N+'_scaler_loaded.gz')
      April_pred_inv_HVAC_Gen_ByGridlabD=April_HVAC_Gen_ByGridlabD_scaler.inverse_transform(np.array(HVAC_Gen_ByGridlabD_yhat).reshape(-1,1))
      plotpred_inv_HVAC_Gen_ByGridlabD = April_pred_inv_HVAC_Gen_ByGridlabD.flatten()
  elif(month) == '05':
      print('\n\nmake Unnormalied '+House_N+' prediction for  May \n')
      May_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_May_'+House_N+'_scaler_loaded.gz')
      May_pred_inv_HVAC_Gen_ByGridlabD=May_HVAC_Gen_ByGridlabD_scaler.inverse_transform(np.array(HVAC_Gen_ByGridlabD_yhat).reshape(-1,1))
      plotpred_inv_HVAC_Gen_ByGridlabD = May_pred_inv_HVAC_Gen_ByGridlabD.flatten()
  elif(month) == '06':
      print('\n\nmake Unnormalied '+House_N+' prediction for Jun \n')
      Jun_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_Jun_'+House_N+'_scaler_loaded.gz')
      Jun_pred_inv_HVAC_Gen_ByGridlabD=Jun_HVAC_Gen_ByGridlabD_scaler.inverse_transform(np.array(HVAC_Gen_ByGridlabD_yhat).reshape(-1,1))
      plotpred_inv_HVAC_Gen_ByGridlabD = Jun_pred_inv_HVAC_Gen_ByGridlabD.flatten()
  elif(month) == '07':
      print('\n\nmake Unnormalied '+House_N+' prediction for  July \n')
      July_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_July_'+House_N+'_scaler_loaded.gz')
      July_pred_inv_HVAC_Gen_ByGridlabD=July_HVAC_Gen_ByGridlabD_scaler.inverse_transform(np.array(HVAC_Gen_ByGridlabD_yhat).reshape(-1,1))
      plotpred_inv_HVAC_Gen_ByGridlabD = July_pred_inv_HVAC_Gen_ByGridlabD.flatten()
  elif(month) == '08':
      print('\n\nmake Unnormalied '+House_N+' prediction for  Aug \n')  
      Aug_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_Aug_'+House_N+'_scaler_loaded.gz')
      Aug_pred_inv_HVAC_Gen_ByGridlabD=Aug_HVAC_Gen_ByGridlabD_scaler.inverse_transform(np.array(HVAC_Gen_ByGridlabD_yhat).reshape(-1,1))
      plotpred_inv_HVAC_Gen_ByGridlabD = Aug_pred_inv_HVAC_Gen_ByGridlabD.flatten()
  elif(month) == '09':
      print('\n\nmake Unnormalied '+House_N+' prediction for  Sep \n')  
      Sep_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_Sep_'+House_N+'_scaler_loaded.gz')
      Sep_pred_inv_HVAC_Gen_ByGridlabD=Sep_HVAC_Gen_ByGridlabD_scaler.inverse_transform(np.array(HVAC_Gen_ByGridlabD_yhat).reshape(-1,1))
      plotpred_inv_HVAC_Gen_ByGridlabD = Sep_pred_inv_HVAC_Gen_ByGridlabD.flatten()
  elif(month) == '10':
      print('\n\nmake Unnormalied '+House_N+' prediction for  Oct \n')  
      Oct_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_Oct_'+House_N+'_scaler_loaded.gz')
      Oct_pred_inv_HVAC_Gen_ByGridlabD=Oct_HVAC_Gen_ByGridlabD_scaler.inverse_transform(np.array(HVAC_Gen_ByGridlabD_yhat).reshape(-1,1))
      plotpred_inv_HVAC_Gen_ByGridlabD = Oct_pred_inv_HVAC_Gen_ByGridlabD.flatten()
  elif(month) == '11':
      print('\n\nmake Unnormalied '+House_N+' prediction for Nov \n')  
      Nov_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_Nov_'+House_N+'_scaler_loaded.gz')
      Nov_pred_inv_HVAC_Gen_ByGridlabD=Nov_HVAC_Gen_ByGridlabD_scaler.inverse_transform(np.array(HVAC_Gen_ByGridlabD_yhat).reshape(-1,1))
      plotpred_inv_HVAC_Gen_ByGridlabD = Nov_pred_inv_HVAC_Gen_ByGridlabD.flatten()
  elif(month) == '12':
      print('\n\nmake Unnormalied '+House_N+' prediction for  Dec \n')  
      Dec_HVAC_Gen_ByGridlabD_scaler = joblib.load('Py_Files/InPut_for_py/NormalizationS/'+House_N+'/N_Dec_'+House_N+'_scaler_loaded.gz')#
      Dec_pred_inv_HVAC_Gen_ByGridlabD=Dec_HVAC_Gen_ByGridlabD_scaler.inverse_transform(np.array(HVAC_Gen_ByGridlabD_yhat).reshape(-1,1))
      plotpred_inv_HVAC_Gen_ByGridlabD = Dec_pred_inv_HVAC_Gen_ByGridlabD.flatten()
   #############
   #############  remove (-) numbers form pred
   #############
  if (1==verbose_Figs):print('\nplotpred_inv_HVAC_Gen_ByGridlabD',plotpred_inv_HVAC_Gen_ByGridlabD)
  if (1==verbose_Figs):print('\n   type plotpred_inv_HVAC_Gen_ByGridlabD',type(plotpred_inv_HVAC_Gen_ByGridlabD))
  Number_plotpred_inv_HVAC_Gen_ByGridlabD=len(plotpred_inv_HVAC_Gen_ByGridlabD)
  if (1==verbose_Figs):print('\nNumber_plotpred_inv_HVAC_Gen_ByGridlabD    ',Number_plotpred_inv_HVAC_Gen_ByGridlabD)
  modifed_HVAC_Predeicted_energy= []
  for i_Orginal in plotpred_inv_HVAC_Gen_ByGridlabD:
    if (i_Orginal > 0.00):
          modifed_HVAC_Predeicted_energy.append(i_Orginal)
    else:
          if (1==verbose_Figs):print(i_Orginal)
          modifed_HVAC_Predeicted_energy.append(0.00)
  if (1==verbose_Figs):print('\nmodifed_HVAC_Predeicted_energy',modifed_HVAC_Predeicted_energy)
  Number_modifed_HVAC_Predeicted_energy=len(modifed_HVAC_Predeicted_energy)
  if (1==verbose_Figs):print('\nNumber_modifed_HVAC_Predeicted_energy',Number_modifed_HVAC_Predeicted_energy)
  plotpred_inv_HVAC_Gen_ByGridlabD=modifed_HVAC_Predeicted_energy
  return plotpred_inv_HVAC_Gen_ByGridlabD,HVAC_Gen_ByGridlabD_plot_pred,HVAC_Gen_ByGridlabD_Act_DateData,HVAC_Gen_ByGridlabD_plot_act
  
    
def Make_Figs_and_CSVs_verbose(verbose_Figs,Act_Date_Net_Total_Gen_ByGridlabD_H,Act_Date_UnControlAble_load_Gen_ByGridlabD_H,Act_Date_ControlAble_load_Gen_ByGridlabD_H,Act_Date_WaterHeter_Gen_ByGridlabD_H,Act_Date_Dishwasher_Gen_ByGridlabD_H,plotpred_inv_HVAC_Gen_ByGridlabD, HVAC_Gen_ByGridlabD_plot_pred, House_N, Act_Date_ForOptJulia,Input_Date,Act_Date, version,HVAC_Gen_ByGridlabD_Act_DateData,HVAC_Gen_ByGridlabD_data_prediction,HVAC_Gen_ByGridlabD_plot_act):
    if (1==verbose_Figs):
          ##############Act_Date & Input_Date
          fig=plt.figure(figsize=(20,10))
          hours = list(range(0, 24))
          plt.plot( hours, HVAC_Gen_ByGridlabD_Act_DateData, marker='', color='olive', linewidth=3, label=Act_Date)
          plt.plot( hours, HVAC_Gen_ByGridlabD_data_prediction, marker='', color='blue',  linewidth=4, label=Input_Date)
          plt.title(''+House_N+'  Actual days Data',fontsize=40)
          plt.xlabel('24 Hours',fontsize=40)
          plt.ylabel('HVAC Energy Use [kWh]',fontsize=40)
          plt.legend(loc='best',fontsize=25, handlelength= 3)
          plt.xticks(np.arange(0,24, 5),fontsize=40)
          plt.yticks(fontsize=40)
          plt.grid()
          plt.savefig('Py_Files/OutPut_of_py/'+House_N+'/verbose_Figure/R_'+House_N+'_Actual days Data_'+ Input_Date+'&'+Act_Date+'_'+ version +'.png')
          plt.close(fig)

          #####*plt.show()
            ##############   Prediction result####  '+House_N+'_normalized
          print('\n')
          fig=plt.figure(figsize=(20,10))
          hours = list(range(0, 24))
          plt.plot( hours, HVAC_Gen_ByGridlabD_plot_act, marker='', color='olive', linewidth=3, label=' Act= '+Act_Date)
          plt.plot( hours, HVAC_Gen_ByGridlabD_plot_pred, marker='', color='red',  linewidth=4, linestyle='dashed', label=' Pre for '+ Act_Date)
          plt.title(''+House_N+' LSTM Resutls: Act Day, Its Pre',fontsize=40)
          plt.xlabel('24 Hours',fontsize=40)
          plt.ylabel('HVAC Energy Use',fontsize=40)
          plt.legend(loc='best',fontsize=25, handlelength= 3)
          plt.xticks(np.arange(0,24, 5),fontsize=40)
          plt.yticks(fontsize=40)
          plt.grid()
          plt.savefig('Py_Files/OutPut_of_py/'+House_N+'/verbose_Figure/R_'+House_N+'_Pred&Act_ForDay'+Act_Date+'_Norm_'+ version +'.png')
          plt.close(fig)

          #####*plt.show()

            ##############   Plot    ####    Compare input data and predictsed base on it 
          print('\n')
          fig=plt.figure(figsize=(20,10))
          hours = list(range(0, 24))
          plt.plot( hours, HVAC_Gen_ByGridlabD_data_prediction, marker='', color='blue',  linewidth=4, label=Input_Date)
          plt.plot( hours, plotpred_inv_HVAC_Gen_ByGridlabD, marker='', color='red',  linewidth=4, linestyle='dashed', label=' Pre based on_'+ Input_Date) 
          plt.title('Input Day of '+House_N+'and its result base model(Pre)',fontsize=40)
          plt.xlabel('24 Hours',fontsize=40)
          plt.ylabel('HVAC Energy Uses [kWh]',fontsize=40)
          plt.legend(loc='best',fontsize=25, handlelength= 3)
          plt.xticks(np.arange(0,24, 5),fontsize=40)
          plt.yticks(fontsize=40)
          plt.grid()
          plt.savefig('Py_Files/OutPut_of_py/'+House_N+'/verbose_Figure/R_'+House_N+'_Input_Date&ItsPre_'+ Input_Date+'_'+ version +'.png')
          plt.close(fig)
          #####*plt.show()
          ################# making data for mayself chacking     
          header = ['datetime', 'Net_Total', 'UnControlAble_load', 'HVAC', 'WaterHeter', 'Dishwasher']
          datetime_list=[]
          for x in range(0, 24):
              #print(x)
              a_list = []
              tem=Act_Date_ForOptJulia+' '+str(x)+':00'
              a_list.append(tem)
              a_list.append(Act_Date_Net_Total_Gen_ByGridlabD_H[x])
              a_list.append(Act_Date_UnControlAble_load_Gen_ByGridlabD_H[x])
              a_list.append(plotpred_inv_HVAC_Gen_ByGridlabD[x])
              a_list.append(Act_Date_WaterHeter_Gen_ByGridlabD_H[x])
              a_list.append(Act_Date_Dishwasher_Gen_ByGridlabD_H[x])
              datetime_list.append(a_list)
          with open('Py_Files/OutPut_of_py/'+House_N+'/verbose_CSVs/R_'+House_N+'_EnergyUse_H_ForDay='+ Act_Date + version +'.csv', 'w') as f:
                # create the csv writer
              writer = csv.writer(f)
               # write the headerF
              writer.writerow(header)
               # write a row to the csv file
              writer.writerows(datetime_list)
              print(' Make_Figs_and_CSVs_verbose is done \n')


              
 
def Make_Figs_and_CSVs(verbose_Figs,Net_Total_Gen_ByGridlabD_dataHour_2,plotpred_inv_HVAC_Gen_ByGridlabD, HVAC_Gen_ByGridlabD_plot_pred, House_N, Act_Date_ForOptJulia,Input_Date,Act_Date, version,HVAC_Gen_ByGridlabD_Act_DateData,HVAC_Gen_ByGridlabD_data_prediction,HVAC_Gen_ByGridlabD_plot_act):
  #Define
  Act_Date_Net_Total_Gen_ByGridlabD_H=Net_Total_Gen_ByGridlabD_dataHour_2.loc[ Act_Date: Act_Date, :][''+House_N+'_measured_real_energy']
  Act_Date_UnControlAble_load_Gen_ByGridlabD_H=Act_Date_Net_Total_Gen_ByGridlabD_H-plotpred_inv_HVAC_Gen_ByGridlabD
  Act_Date_WaterHeter_Gen_ByGridlabD_H=0*Net_Total_Gen_ByGridlabD_dataHour_2.loc[ Act_Date: Act_Date, :][''+House_N+'_measured_real_energy']
  Act_Date_Dishwasher_Gen_ByGridlabD_H=0*Net_Total_Gen_ByGridlabD_dataHour_2.loc[ Act_Date: Act_Date, :][''+House_N+'_measured_real_energy']
  Act_Date_ControlAble_load_Gen_ByGridlabD_H=plotpred_inv_HVAC_Gen_ByGridlabD+Act_Date_WaterHeter_Gen_ByGridlabD_H+Act_Date_Dishwasher_Gen_ByGridlabD_H

  ################## remove (-)
  if (1==verbose_Figs):print('\nAct_Date_UnControlAble_load_Gen_ByGridlabD_H',Act_Date_UnControlAble_load_Gen_ByGridlabD_H)
  modifed_UnControlAble_Predeicted_energy= []
  for i_UnControlAble in Act_Date_UnControlAble_load_Gen_ByGridlabD_H:
    if (i_UnControlAble > 0.00):
          modifed_UnControlAble_Predeicted_energy.append(i_UnControlAble)
    else:
          if (1==verbose_Figs):print(i_UnControlAble)
          modifed_UnControlAble_Predeicted_energy.append(0.00)
  if (1==verbose_Figs):print('\nmodifed_HVAC_Predeicted_energy',modifed_UnControlAble_Predeicted_energy)
  Act_Date_UnControlAble_load_Gen_ByGridlabD_H=modifed_UnControlAble_Predeicted_energy
  print('\n')
        ##############   Plot    ####    UN_'+House_N+'_normalized
  print('\n')
  plt.figure(figsize=(20,10))
  hours = list(range(0, 24))
  plt.plot( hours, HVAC_Gen_ByGridlabD_Act_DateData, marker='', color='olive', linewidth=3, label=' Act= '+Act_Date)
  plt.plot( hours, plotpred_inv_HVAC_Gen_ByGridlabD, marker='', color='red',  linewidth=4, linestyle='dashed', label=' Pre for '+ Act_Date)
  plt.title(' UnNorm '+House_N+' LSTM Resutls: Act Day, Its Pre',fontsize=40)
  plt.xlabel('24 Hours',fontsize=40)
  plt.ylabel('HVAC Energy Uses [kWh]',fontsize=40)
  plt.legend(loc='best',fontsize=25, handlelength= 3)
  plt.xticks(np.arange(0,24, 5),fontsize=40)
  plt.yticks(fontsize=40)
  plt.grid()
  plt.savefig('Py_Files/OutPut_of_py/'+House_N+'/R_'+House_N+'_Pred&Act_ForDay='+Act_Date+'_UnNorm_'+ version +'.png')
  plt.show()
    ###########   
    ###########             Write csv for sending to julia '+House_N+'       #################################
    ###########   
  header = ['datetime', 'Net_Total', 'UnControlAble_load', 'ControlAble_load','HVAC', 'WaterHeter', 'Dishwasher']
  datetime_list=[]
  for x in range(0, 24):
      #print(x)
      a_list = []
      tem=Act_Date_ForOptJulia+' '+str(x)+':00'
      a_list.append(tem)
      a_list.append(Act_Date_Net_Total_Gen_ByGridlabD_H[x])
      a_list.append(Act_Date_UnControlAble_load_Gen_ByGridlabD_H[x])
      a_list.append(Act_Date_ControlAble_load_Gen_ByGridlabD_H[x])
      a_list.append(plotpred_inv_HVAC_Gen_ByGridlabD[x])
      a_list.append(Act_Date_WaterHeter_Gen_ByGridlabD_H[x])
      a_list.append(Act_Date_Dishwasher_Gen_ByGridlabD_H[x])
      datetime_list.append(a_list)
    ################# making data for julia   with  version 
  with open('Py_Files/OutPut_of_py/'+House_N+'/R_'+House_N+'_EnergyUse_H'+ version +'.csv', 'w') as f:
        # create the csv writer
        writer = csv.writer(f)
        # write the header
        writer.writerow(header)
        # write a row to the csv file
        writer.writerows(datetime_list)
  ################# making data for julia without version
  with open('Py_Files/OutPut_of_py/'+House_N+'/R_'+House_N+'_EnergyUse_H.csv', 'w') as f:
        # create the csv writer
        writer = csv.writer(f)
        # write the header
        writer.writerow(header)
        # write a row to the csv file
        writer.writerows(datetime_list)
  Make_Figs_and_CSVs_verbose(verbose_Figs,Act_Date_Net_Total_Gen_ByGridlabD_H,Act_Date_UnControlAble_load_Gen_ByGridlabD_H,Act_Date_ControlAble_load_Gen_ByGridlabD_H,Act_Date_WaterHeter_Gen_ByGridlabD_H,Act_Date_Dishwasher_Gen_ByGridlabD_H,plotpred_inv_HVAC_Gen_ByGridlabD, HVAC_Gen_ByGridlabD_plot_pred, House_N, Act_Date_ForOptJulia,Input_Date,Act_Date, version,HVAC_Gen_ByGridlabD_Act_DateData,HVAC_Gen_ByGridlabD_data_prediction,HVAC_Gen_ByGridlabD_plot_act)
    
    
def Add_Opt_result_EnergyUse_CSVs(verbose_Figs,Act_Date_ForOptJulia,House_List,month):
  HVAC_Opt_House='jl_files/OutPut_of_jl/HVAC_HouseS_EnergyUse_Optimized.csv'
  HVAC_Opt_House_CSV= pd.read_csv(HVAC_Opt_House, skiprows=0)
  HVAC_Opt_House_DF = pd.DataFrame(HVAC_Opt_House_CSV)
  for House_N in House_List:
          House_loads='Py_Files/OutPut_of_py/'+House_N+'/R_'+House_N+'_EnergyUse_H.csv'
          House_loads_CSV= pd.read_csv(House_loads, skiprows=0)
          print('\n\n',House_N,'Updat HVAC_ONOFF_M_Based_Opt Done \n\n')
          House_loads_DF = pd.DataFrame(House_loads_CSV)
          House_loads_DF['HVAC_Opt']=HVAC_Opt_House_DF[House_N]
          House_loads_DF['EnergyUse_HVAC_Diff']=House_loads_DF['HVAC_Opt']-House_loads_DF['HVAC']
          House_loads_DF['Expedted_More_HVAC_ON_M']=0*House_loads_DF['EnergyUse_HVAC_Diff']
          House_loads_DF['Expedted_More_HVAC_OFF_M']=0*House_loads_DF['EnergyUse_HVAC_Diff']
          #
          Expedted_HVAC_load_House='Py_Files/InPut_for_py/HVAC_load/Expedted_'+House_N+'_HVAC_load.csv'
          Expedted_HVAC_load_House_CSV= pd.read_csv(Expedted_HVAC_load_House, skiprows=0)
          Expedted_HVAC_load_House_DF = pd.DataFrame(Expedted_HVAC_load_House_CSV)
          Expedted_HVAC_load_Value_kWh=Expedted_HVAC_load_House_DF[month].values[0]
          Expedted_HVAC_load_Value_kWs=Expedted_HVAC_load_Value_kWh/3600
          #
          i_EnergyUse_HVAC_Diff_HOur=0
          for i_EnergyUse_HVAC_Diff in House_loads_DF['EnergyUse_HVAC_Diff']:
              if (round(i_EnergyUse_HVAC_Diff, 2) > 0.00):
                       Act_Date_FromOptJulia=Act_Date_ForOptJulia+' '+str(i_EnergyUse_HVAC_Diff_HOur)+':00'
                       Tem_HVAC_MoreONOFF_S=(i_EnergyUse_HVAC_Diff/Expedted_HVAC_load_Value_kWs)
                       Tem_HVAC_MoreONOFF_M=Tem_HVAC_MoreONOFF_S/60##Make Min
                       Make_NesseccaryChange_SetPointsDate_onPlayer=Act_Date_ForOptJulia+' '+str(i_EnergyUse_HVAC_Diff_HOur-1)+':00'
                       if (1==verbose_Figs):print("\n Expedted_More_HVAC_ON_InMints "+Make_NesseccaryChange_SetPointsDate_onPlayer+"=  ",Tem_HVAC_MoreONOFF_M)
                       House_loads_DF["Expedted_More_HVAC_ON_M"][i_EnergyUse_HVAC_Diff_HOur-1]=Tem_HVAC_MoreONOFF_M
              else:
                      if (abs(round(i_EnergyUse_HVAC_Diff, 2))> 0.00):
                        Act_Date_FromOptJulia=Act_Date_ForOptJulia+' '+str(i_EnergyUse_HVAC_Diff_HOur)+':00'
                        Tem_HVAC_MoreONOFF_S=(i_EnergyUse_HVAC_Diff/Expedted_HVAC_load_Value_kWs)
                        Tem_HVAC_MoreONOFF_M=Tem_HVAC_MoreONOFF_S/60##Make Min
                        Make_NesseccaryChange_SetPointsDate_onPlayer=Act_Date_ForOptJulia+' '+str(i_EnergyUse_HVAC_Diff_HOur-1)+':00'
                        if (1==verbose_Figs):print("\n Expedted_More_HVAC_ON_InMints "+Make_NesseccaryChange_SetPointsDate_onPlayer+"=  ",Tem_HVAC_MoreONOFF_M)
                        House_loads_DF["Expedted_More_HVAC_OFF_M"][i_EnergyUse_HVAC_Diff_HOur-1]=Tem_HVAC_MoreONOFF_M
              i_EnergyUse_HVAC_Diff_HOur+=1
          #
          House_loads_DF.to_csv('Py_Files/OutPut_of_py/'+House_N+'/R_'+House_N+'_EnergyUse_H_Opt.csv', encoding='utf-8', index=False)
          
              
########################## final #   16/10/2022
def Change_SetPointsHours_BasedOnOpt_Make_DR_Signal(verbose_Figs,House_List,Act_Date,month):
    print(' \n Change_SetPointsHours_BasedOnOpt_InPlayer \n')
    DR_Signal_ForCooling_setpoints=False
    DR_Signal_ForHeating_setpoints=False
    if (month == '1' or month == '2' or month == '3'):
            if (1==verbose_Figs):print('month is ', month, 'So, signal is for Winter  :))))))  HVAC will modified base on only **Heating** set points')
            DR_Signal_ForCooling_setpoints=True
            DR_Signal_ForHeating_setpoints=True
    elif (month == '04' or month == '05' or month == '06'):
            if (1==verbose_Figs):print('month is ', month, 'So, signal is for Spring :))))))  HVAC will modified base on **Cooling**  and **Heating** set points')
            DR_Signal_ForCooling_setpoints=True
            DR_Signal_ForHeating_setpoints=True
    elif (month == '07' or month == '08' or month == '09'):
            if (1==verbose_Figs):print('month is ', month, 'So, signal is for  Summer  :))))))  HVAC will modified base on only **Cooling** set points')
            DR_Signal_ForCooling_setpoints=True
            DR_Signal_ForHeating_setpoints=True
    elif (month == '10' or month == '11' or month == '12'):
            if (1==verbose_Figs):print('month is ', month, 'So, signal is for  Fall  :))))))  HVAC will modified base  on **Cooling**  and **Heating** set points')
            DR_Signal_ForCooling_setpoints=True
            DR_Signal_ForHeating_setpoints=True
    for House_N in House_List:
        print('\n')
        House_loads_ForPlayer ='Py_Files/OutPut_of_py/'+House_N+'/R_'+House_N+'_EnergyUse_H_Opt.csv'
        House_loads_ForPlayer_CSV= pd.read_csv(House_loads_ForPlayer, skiprows=0)
        House_loads_ForPlayer_CSV_DF = pd.DataFrame(House_loads_ForPlayer_CSV)
        ##########***************#########
        ##########***************#########    DR_Signal_ForCooling_setpoints
        ##########***************#########
        i_HVAC_EngChanged_H_ON=0
        Signals_list_All_dict_HVAC_ON=[]
        Signals_list_All_dict_HVAC_OFF=[]
        if(DR_Signal_ForCooling_setpoints):
                for i_More_HVAC_ON_M in House_loads_ForPlayer_CSV_DF['Expedted_More_HVAC_ON_M']:
                         Signals_All_dict_HVAC_ON_inside={}
                         Signals_All_dict_HVAC_ON={}
                         Signals_All_dict_HVAC_OFF_inside={}
                         Signals_All_dict_HVAC_OFF={}
                         if (int(i_HVAC_EngChanged_H_ON)!=0):
                                 i_More_HVAC_ON_SetPointsChange_H=i_HVAC_EngChanged_H_ON
                         else:
                                 i_More_HVAC_ON_SetPointsChange_H=23#########a day before, before zero is 23           
                         i_More_HVAC_ON_SetPointsChange_H_str=str(i_More_HVAC_ON_SetPointsChange_H)
                         if int(i_More_HVAC_ON_SetPointsChange_H) >= 10:
                                 i_More_HVAC_ON_SetPointsChange_H_str=i_More_HVAC_ON_SetPointsChange_H_str
                         else:
                                 i_More_HVAC_ON_SetPointsChange_H_str='0'+i_More_HVAC_ON_SetPointsChange_H_str
                         if (round(i_More_HVAC_ON_M, 2) > 0.00):
                                        Signal_period_More_HVAC_ON_M=round(i_More_HVAC_ON_M)###round to close NUMBER
                                        if Signal_period_More_HVAC_ON_M ==0:
                                            Signal_period_More_HVAC_ON_M=1
                                        if Signal_period_More_HVAC_ON_M >= 10:
                                                    Signal_period_More_HVAC_ON_M_str=str(Signal_period_More_HVAC_ON_M)
                                        else:
                                                    Signal_period_More_HVAC_ON_M_str='0'+str(Signal_period_More_HVAC_ON_M)
                                        Make_glm_PlayerSynax_SetPoint_Signal_Initial_HVAC_ON=Act_Date+' '+i_More_HVAC_ON_SetPointsChange_H_str+':00'+':00,'+' '+'79'
                                        print('\n ',House_N,'Make_glm_PlayerSynax_SetPoint_Signal_More_HVAC_ON  Initial',Make_glm_PlayerSynax_SetPoint_Signal_Initial_HVAC_ON)
                                        Make_glm_PlayerSynax_SetPoint_Signal_start_replace_HVAC_ON=Act_Date+' '+i_More_HVAC_ON_SetPointsChange_H_str+':00'+':00,'+' '+'76'
                                        if (1==verbose_Figs):print('\n ',House_N,'Make_glm_PlayerSynax_SetPoint_Signal_More_HVAC_ON  start',Make_glm_PlayerSynax_SetPoint_Signal_start_replace_HVAC_ON)
                                        Make_glm_PlayerSynax_SetPoint_Signal_finish_replace_HVAC_ON=Act_Date+' '+i_More_HVAC_ON_SetPointsChange_H_str+':'+Signal_period_More_HVAC_ON_M_str+':00,'+' '+'79'
                                        if (1==verbose_Figs):print('\n ',House_N,'Make_glm_PlayerSynax_SetPoint_Signal_More_HVAC_ON finish',Make_glm_PlayerSynax_SetPoint_Signal_finish_replace_HVAC_ON)
                                        Signals_All_dict_HVAC_ON_inside['Signal_start_replace_ON']=Make_glm_PlayerSynax_SetPoint_Signal_start_replace_HVAC_ON
                                        Signals_All_dict_HVAC_ON_inside['Signal_finish_replace_ON']=Make_glm_PlayerSynax_SetPoint_Signal_finish_replace_HVAC_ON
                                        Signals_All_dict_HVAC_ON[Make_glm_PlayerSynax_SetPoint_Signal_Initial_HVAC_ON]=Signals_All_dict_HVAC_ON_inside
                                        Signals_list_All_dict_HVAC_ON.append(Signals_All_dict_HVAC_ON)
                                        ###
                                        ###
                                        ### HVAC_OFF
                         i_HVAC_EngChanged_H_OFF=i_HVAC_EngChanged_H_ON
                         i_More_HVAC_OFF_M =House_loads_ForPlayer_CSV_DF['Expedted_More_HVAC_OFF_M'][i_HVAC_EngChanged_H_OFF]
                         if (int(i_HVAC_EngChanged_H_OFF)!=0):
                                 i_More_HVAC_OFF_SetPointsChange_H=i_HVAC_EngChanged_H_OFF
                         else:
                                 i_More_HVAC_OFF_SetPointsChange_H=23#########a day before, before zero is 23           
                         i_More_HVAC_OFF_SetPointsChange_H_str=str(i_More_HVAC_OFF_SetPointsChange_H)
                         if int(i_More_HVAC_OFF_SetPointsChange_H) >= 10:
                                 i_More_HVAC_OFF_SetPointsChange_H_str=i_More_HVAC_OFF_SetPointsChange_H_str
                         else:
                                 i_More_HVAC_OFF_SetPointsChange_H_str='0'+i_More_HVAC_OFF_SetPointsChange_H_str
                         if (round(abs(i_More_HVAC_OFF_M), 2) > 0.00):
                                        Signal_period_More_HVAC_OFF_M=int(round(abs(i_More_HVAC_OFF_M)))###round to close NUMBER
                                        if Signal_period_More_HVAC_OFF_M ==0:
                                            Signal_period_More_HVAC_OFF_M=1
                                        if Signal_period_More_HVAC_OFF_M >= 10:
                                                     Signal_period_More_HVAC_OFF_M_str=str(Signal_period_More_HVAC_OFF_M)
                                        else:
                                                     Signal_period_More_HVAC_OFF_M_str='0'+str(Signal_period_More_HVAC_OFF_M)
                                        Make_glm_PlayerSynax_SetPoint_Signal_Initial_HVAC_OFF=Act_Date+' '+i_More_HVAC_OFF_SetPointsChange_H_str+':00'+':00,'+' '+'79'
                                        if (1==verbose_Figs):print('\n ',House_N,'Make_glm_PlayerSynax_SetPoint_Signal_More_HVAC_OFF Initial',Make_glm_PlayerSynax_SetPoint_Signal_Initial_HVAC_OFF)
                                        Make_glm_PlayerSynax_SetPoint_Signal_start_replace_HVAC_OFF=Act_Date+' '+i_More_HVAC_OFF_SetPointsChange_H_str+':00'+':00,'+' '+'82'
                                        if (1==verbose_Figs):print('\n ',House_N,'Make_glm_PlayerSynax_SetPoint_Signal_More_HVAC_OFF  start',Make_glm_PlayerSynax_SetPoint_Signal_start_replace_HVAC_OFF)
                                        Make_glm_PlayerSynax_SetPoint_Signal_finish_replace_HVAC_OFF=Act_Date+' '+i_More_HVAC_OFF_SetPointsChange_H_str+':'+Signal_period_More_HVAC_OFF_M_str+':00,'+' '+'79'
                                        if (1==verbose_Figs):print('\n ',House_N,'Make_glm_PlayerSynax_SetPoint_Signal_More_HVAC_OFF finish',Make_glm_PlayerSynax_SetPoint_Signal_finish_replace_HVAC_OFF)
                                        Signals_All_dict_HVAC_OFF_inside['Signal_start_replace_OFF']=Make_glm_PlayerSynax_SetPoint_Signal_start_replace_HVAC_OFF
                                        Signals_All_dict_HVAC_OFF_inside['Signal_finish_replace_OFF']=Make_glm_PlayerSynax_SetPoint_Signal_finish_replace_HVAC_OFF
                                        Signals_All_dict_HVAC_OFF[Make_glm_PlayerSynax_SetPoint_Signal_Initial_HVAC_OFF]=Signals_All_dict_HVAC_OFF_inside
                                        Signals_list_All_dict_HVAC_OFF.append(Signals_All_dict_HVAC_OFF)
                         i_HVAC_EngChanged_H_ON+=1
                                        #
                if (1==verbose_Figs):print('ON for Cooling_setpoints')
                if (1==verbose_Figs):print(Signals_list_All_dict_HVAC_ON)
                if (1==verbose_Figs):print('OFF Cooling_setpoints')
                if (1==verbose_Figs):print(Signals_list_All_dict_HVAC_OFF)
                if (1==verbose_Figs):print('\n ')
                wd_Orginal = os.getcwd()
                os.chdir('GLM_Files/InPut_for_glm/Cooling_setpoints/'+House_N+'/')
                Check_PATH_player_HVAC='ls' 
                if (1==verbose_Figs):subprocess.call(Check_PATH_player_HVAC, shell=True)
                Num_lines_In_cooling_player=1
                with open('cooling_setpoint_'+House_N+'.player') as file:
                    while (line := file.readline().rstrip()):
                         Signal_FoundMatchLine=False
                         for i_Signals_list_ON in range(len(Signals_list_All_dict_HVAC_ON)):
                          for Signal_key1, Signal_value1 in Signals_list_All_dict_HVAC_ON[i_Signals_list_ON].items():
                             if (line==Signal_key1):
                                 Signal_FoundMatchLine=True
                                 if(1==Num_lines_In_cooling_player):
                                                    From_Dic_Signal_start_replace_ON =Signal_value1['Signal_start_replace_ON']
                                                    AddLine2_Opt_player_HVAC='echo '+From_Dic_Signal_start_replace_ON+' > cooling_setpoint_'+House_N+'_opt.player'
                                                    subprocess.call(AddLine2_Opt_player_HVAC, shell=True)
                                                    From_Dic_Signal_finish_replace_ON =Signal_value1['Signal_finish_replace_ON']
                                                    AddLine3_Opt_player_HVAC='echo '+From_Dic_Signal_finish_replace_ON+' >> cooling_setpoint_'+House_N+'_opt.player'
                                                    subprocess.call(AddLine3_Opt_player_HVAC, shell=True)
                                 else:
                                                    From_Dic_Signal_start_replace_ON =Signal_value1['Signal_start_replace_ON']
                                                    AddLine2_Opt_player_HVAC='echo '+From_Dic_Signal_start_replace_ON+' >> cooling_setpoint_'+House_N+'_opt.player'
                                                    subprocess.call(AddLine2_Opt_player_HVAC, shell=True)
                                                    From_Dic_Signal_finish_replace_ON =Signal_value1['Signal_finish_replace_ON']
                                                    AddLine3_Opt_player_HVAC='echo '+From_Dic_Signal_finish_replace_ON+' >> cooling_setpoint_'+House_N+'_opt.player'
                                                    subprocess.call(AddLine3_Opt_player_HVAC, shell=True)
                                 print('Modifed line number of cooling_setpoint_ON '+House_N+'.player is ',Num_lines_In_cooling_player,'line was ', line, 'Modified to', From_Dic_Signal_start_replace_ON,' And ', From_Dic_Signal_finish_replace_ON)
                         for i_Signals_list_OFF in range(len(Signals_list_All_dict_HVAC_OFF)):
                          for Signal_key2, Signal_value2 in Signals_list_All_dict_HVAC_OFF[i_Signals_list_OFF].items():
                             if (line==Signal_key2):
                                 Signal_FoundMatchLine=True
                                 if(1==Num_lines_In_cooling_player):
                                                        From_Dic_Signal_start_replace_OFF =Signal_value2['Signal_start_replace_OFF']
                                                        AddLine4_Opt_player_HVAC='echo '+From_Dic_Signal_start_replace_OFF+' > cooling_setpoint_'+House_N+'_opt.player'
                                                        subprocess.call(AddLine4_Opt_player_HVAC, shell=True)
                                                        From_Dic_Signal_finish_replace_OFF =Signal_value2['Signal_finish_replace_OFF']
                                                        AddLine5_Opt_player_HVAC='echo '+From_Dic_Signal_finish_replace_OFF+' >> cooling_setpoint_'+House_N+'_opt.player'
                                                        subprocess.call(AddLine5_Opt_player_HVAC, shell=True)
                                 else:
                                                        From_Dic_Signal_start_replace_OFF =Signal_value2['Signal_start_replace_OFF']
                                                        AddLine4_Opt_player_HVAC='echo '+From_Dic_Signal_start_replace_OFF+' >> cooling_setpoint_'+House_N+'_opt.player'
                                                        subprocess.call(AddLine4_Opt_player_HVAC, shell=True)
                                                        From_Dic_Signal_finish_replace_OFF =Signal_value2['Signal_finish_replace_OFF']
                                                        AddLine5_Opt_player_HVAC='echo '+From_Dic_Signal_finish_replace_OFF+' >> cooling_setpoint_'+House_N+'_opt.player'
                                                        subprocess.call(AddLine5_Opt_player_HVAC, shell=True)
                                 print('Modifed line number of cooling_setpoint_OFF '+House_N+'.player is ',Num_lines_In_cooling_player,'line was ', line, 'Modified to', From_Dic_Signal_start_replace_OFF,' And ', From_Dic_Signal_finish_replace_OFF)
                         if(not(Signal_FoundMatchLine)):
                             if(1==Num_lines_In_cooling_player):
                                                AddLine6_Opt_player_HVAC='echo '+line+' > cooling_setpoint_'+House_N+'_opt.player'
                                                subprocess.call(AddLine6_Opt_player_HVAC, shell=True)
                             else:
                                                AddLine7_Opt_player_HVAC='echo '+line+' >> cooling_setpoint_'+House_N+'_opt.player'
                                                subprocess.call(AddLine7_Opt_player_HVAC, shell=True)
                         Num_lines_In_cooling_player+=1
                Check_PATH_player_HVAC='ls'
                if (1==verbose_Figs):subprocess.call(Check_PATH_player_HVAC, shell=True)
                os.chdir(wd_Orginal)
        #@
        if(not(DR_Signal_ForCooling_setpoints)):
                wd_Orginal = os.getcwd()
                os.chdir('GLM_Files/InPut_for_glm/Cooling_setpoints/'+House_N+'/')
                Check_PATH_player_HVAC='ls' 
                if (1==verbose_Figs):subprocess.call(Check_PATH_player_HVAC, shell=True)
                Num_lines_In_cooling_player=1
                with open('cooling_setpoint_'+House_N+'.player') as file:
                    while (line := file.readline().rstrip()):
                        Signal_FoundMatchLine=False
                        if(not(Signal_FoundMatchLine)):
                                     if(1==Num_lines_In_cooling_player):
                                                        AddLine6_Opt_player_HVAC='echo '+line+' > cooling_setpoint_'+House_N+'_opt.player'
                                                        subprocess.call(AddLine6_Opt_player_HVAC, shell=True)
                                     else:
                                                        AddLine7_Opt_player_HVAC='echo '+line+' >> cooling_setpoint_'+House_N+'_opt.player'
                                                        subprocess.call(AddLine7_Opt_player_HVAC, shell=True)
                        Num_lines_In_cooling_player+=1
                Check_PATH_player_HVAC='ls'
                if (1==verbose_Figs):subprocess.call(Check_PATH_player_HVAC, shell=True)
                os.chdir(wd_Orginal)
        ##########***************#########
        ##########***************#########    DR_Signal_ForHeating_setpoints
        ##########***************#########
        i_HVAC_EngChanged_H_ON=0
        Signals_list_All_dict_HVAC_ON=[]
        Signals_list_All_dict_HVAC_OFF=[]
        if(DR_Signal_ForHeating_setpoints):
                for i_More_HVAC_ON_M in House_loads_ForPlayer_CSV_DF['Expedted_More_HVAC_ON_M']:
                         Signals_All_dict_HVAC_ON_inside={}
                         Signals_All_dict_HVAC_ON={}
                         Signals_All_dict_HVAC_OFF_inside={}
                         Signals_All_dict_HVAC_OFF={}
                         if (int(i_HVAC_EngChanged_H_ON)!=0):
                                 i_More_HVAC_ON_SetPointsChange_H=i_HVAC_EngChanged_H_ON
                         else:
                                 i_More_HVAC_ON_SetPointsChange_H=23#########a day before, before zero is 23           
                         i_More_HVAC_ON_SetPointsChange_H_str=str(i_More_HVAC_ON_SetPointsChange_H)
                         if int(i_More_HVAC_ON_SetPointsChange_H) >= 10:
                                 i_More_HVAC_ON_SetPointsChange_H_str=i_More_HVAC_ON_SetPointsChange_H_str
                         else:
                                 i_More_HVAC_ON_SetPointsChange_H_str='0'+i_More_HVAC_ON_SetPointsChange_H_str
                         if (round(i_More_HVAC_ON_M, 2) > 0.00):
                                        Signal_period_More_HVAC_ON_M=round(i_More_HVAC_ON_M)###round to close NUMBER
                                        if Signal_period_More_HVAC_ON_M ==0:
                                            Signal_period_More_HVAC_ON_M=1
                                        if Signal_period_More_HVAC_ON_M >= 10:
                                                    Signal_period_More_HVAC_ON_M_str=str(Signal_period_More_HVAC_ON_M)
                                        else:
                                                    Signal_period_More_HVAC_ON_M_str='0'+str(Signal_period_More_HVAC_ON_M)
                                        Make_glm_PlayerSynax_SetPoint_Signal_Initial_HVAC_ON=Act_Date+' '+i_More_HVAC_ON_SetPointsChange_H_str+':00'+':00,'+' '+'72'
                                        print('\n ',House_N,'Make_glm_PlayerSynax_SetPoint_Signal_More_HVAC_ON  Initial',Make_glm_PlayerSynax_SetPoint_Signal_Initial_HVAC_ON)
                                        Make_glm_PlayerSynax_SetPoint_Signal_start_replace_HVAC_ON=Act_Date+' '+i_More_HVAC_ON_SetPointsChange_H_str+':00'+':00,'+' '+'75'
                                        if (1==verbose_Figs):print('\n ',House_N,'Make_glm_PlayerSynax_SetPoint_Signal_More_HVAC_ON  start',Make_glm_PlayerSynax_SetPoint_Signal_start_replace_HVAC_ON)
                                        Make_glm_PlayerSynax_SetPoint_Signal_finish_replace_HVAC_ON=Act_Date+' '+i_More_HVAC_ON_SetPointsChange_H_str+':'+Signal_period_More_HVAC_ON_M_str+':00,'+' '+'72'
                                        if (1==verbose_Figs):print('\n ',House_N,'Make_glm_PlayerSynax_SetPoint_Signal_More_HVAC_ON finish',Make_glm_PlayerSynax_SetPoint_Signal_finish_replace_HVAC_ON)
                                        Signals_All_dict_HVAC_ON_inside['Signal_start_replace_ON']=Make_glm_PlayerSynax_SetPoint_Signal_start_replace_HVAC_ON
                                        Signals_All_dict_HVAC_ON_inside['Signal_finish_replace_ON']=Make_glm_PlayerSynax_SetPoint_Signal_finish_replace_HVAC_ON
                                        Signals_All_dict_HVAC_ON[Make_glm_PlayerSynax_SetPoint_Signal_Initial_HVAC_ON]=Signals_All_dict_HVAC_ON_inside
                                        Signals_list_All_dict_HVAC_ON.append(Signals_All_dict_HVAC_ON)
                                        ###
                                        ###
                                        ### HVAC_OFF
                         i_HVAC_EngChanged_H_OFF=i_HVAC_EngChanged_H_ON
                         i_More_HVAC_OFF_M =House_loads_ForPlayer_CSV_DF['Expedted_More_HVAC_OFF_M'][i_HVAC_EngChanged_H_OFF]
                         if (int(i_HVAC_EngChanged_H_OFF)!=0):
                                 i_More_HVAC_OFF_SetPointsChange_H=i_HVAC_EngChanged_H_OFF
                         else:
                                 i_More_HVAC_OFF_SetPointsChange_H=23#########a day before, before zero is 23           
                         i_More_HVAC_OFF_SetPointsChange_H_str=str(i_More_HVAC_OFF_SetPointsChange_H)
                         if int(i_More_HVAC_OFF_SetPointsChange_H) >= 10:
                                 i_More_HVAC_OFF_SetPointsChange_H_str=i_More_HVAC_OFF_SetPointsChange_H_str
                         else:
                                 i_More_HVAC_OFF_SetPointsChange_H_str='0'+i_More_HVAC_OFF_SetPointsChange_H_str
                         if (round(abs(i_More_HVAC_OFF_M), 2) > 0.00):
                                        Signal_period_More_HVAC_OFF_M=int(round(abs(i_More_HVAC_OFF_M)))###round to close NUMBER
                                        if Signal_period_More_HVAC_OFF_M ==0:
                                            Signal_period_More_HVAC_OFF_M=1
                                        if Signal_period_More_HVAC_OFF_M >= 10:
                                                     Signal_period_More_HVAC_OFF_M_str=str(Signal_period_More_HVAC_OFF_M)
                                        else:
                                                     Signal_period_More_HVAC_OFF_M_str='0'+str(Signal_period_More_HVAC_OFF_M)
                                        Make_glm_PlayerSynax_SetPoint_Signal_Initial_HVAC_OFF=Act_Date+' '+i_More_HVAC_OFF_SetPointsChange_H_str+':00'+':00,'+' '+'72'
                                        if (1==verbose_Figs):print('\n ',House_N,'Make_glm_PlayerSynax_SetPoint_Signal_More_HVAC_OFF Initial',Make_glm_PlayerSynax_SetPoint_Signal_Initial_HVAC_OFF)
                                        Make_glm_PlayerSynax_SetPoint_Signal_start_replace_HVAC_OFF=Act_Date+' '+i_More_HVAC_OFF_SetPointsChange_H_str+':00'+':00,'+' '+'69'
                                        if (1==verbose_Figs):print('\n ',House_N,'Make_glm_PlayerSynax_SetPoint_Signal_More_HVAC_OFF  start',Make_glm_PlayerSynax_SetPoint_Signal_start_replace_HVAC_OFF)
                                        Make_glm_PlayerSynax_SetPoint_Signal_finish_replace_HVAC_OFF=Act_Date+' '+i_More_HVAC_OFF_SetPointsChange_H_str+':'+Signal_period_More_HVAC_OFF_M_str+':00,'+' '+'72'
                                        if (1==verbose_Figs):print('\n ',House_N,'Make_glm_PlayerSynax_SetPoint_Signal_More_HVAC_OFF finish',Make_glm_PlayerSynax_SetPoint_Signal_finish_replace_HVAC_OFF)
                                        Signals_All_dict_HVAC_OFF_inside['Signal_start_replace_OFF']=Make_glm_PlayerSynax_SetPoint_Signal_start_replace_HVAC_OFF
                                        Signals_All_dict_HVAC_OFF_inside['Signal_finish_replace_OFF']=Make_glm_PlayerSynax_SetPoint_Signal_finish_replace_HVAC_OFF
                                        Signals_All_dict_HVAC_OFF[Make_glm_PlayerSynax_SetPoint_Signal_Initial_HVAC_OFF]=Signals_All_dict_HVAC_OFF_inside
                                        Signals_list_All_dict_HVAC_OFF.append(Signals_All_dict_HVAC_OFF)
                         i_HVAC_EngChanged_H_ON+=1
                                        #
                if (1==verbose_Figs):print('ON for Heating_setpoints')
                if (1==verbose_Figs):print(Signals_list_All_dict_HVAC_ON)
                if (1==verbose_Figs):print('OFF or Heating_setpoints')
                if (1==verbose_Figs):print(Signals_list_All_dict_HVAC_OFF)
                if (1==verbose_Figs):print('\n ')
                wd_Orginal = os.getcwd()
                os.chdir('GLM_Files/InPut_for_glm/Heating_setpoints/'+House_N+'/')
                Check_PATH_player_HVAC='ls' 
                if (1==verbose_Figs):subprocess.call(Check_PATH_player_HVAC, shell=True)
                Num_lines_In_cooling_player=1
                with open('heating_setpoint_'+House_N+'.player') as file:
                    while (line := file.readline().rstrip()):
                         Signal_FoundMatchLine=False
                         for i_Signals_list_ON in range(len(Signals_list_All_dict_HVAC_ON)):
                          for Signal_key1, Signal_value1 in Signals_list_All_dict_HVAC_ON[i_Signals_list_ON].items():
                             if (line==Signal_key1):
                                 Signal_FoundMatchLine=True
                                 if(1==Num_lines_In_cooling_player):
                                                    From_Dic_Signal_start_replace_ON =Signal_value1['Signal_start_replace_ON']
                                                    AddLine2_Opt_player_HVAC='echo '+From_Dic_Signal_start_replace_ON+' > heating_setpoint_'+House_N+'_opt.player'
                                                    subprocess.call(AddLine2_Opt_player_HVAC, shell=True)
                                                    From_Dic_Signal_finish_replace_ON =Signal_value1['Signal_finish_replace_ON']
                                                    AddLine3_Opt_player_HVAC='echo '+From_Dic_Signal_finish_replace_ON+' >> heating_setpoint_'+House_N+'_opt.player'
                                                    subprocess.call(AddLine3_Opt_player_HVAC, shell=True)
                                 else:
                                                    From_Dic_Signal_start_replace_ON =Signal_value1['Signal_start_replace_ON']
                                                    AddLine2_Opt_player_HVAC='echo '+From_Dic_Signal_start_replace_ON+' >> heating_setpoint_'+House_N+'_opt.player'
                                                    subprocess.call(AddLine2_Opt_player_HVAC, shell=True)
                                                    From_Dic_Signal_finish_replace_ON =Signal_value1['Signal_finish_replace_ON']
                                                    AddLine3_Opt_player_HVAC='echo '+From_Dic_Signal_finish_replace_ON+' >> heating_setpoint_'+House_N+'_opt.player'
                                                    subprocess.call(AddLine3_Opt_player_HVAC, shell=True)
                                 print('Modifed line number of heating_setpoint_ON '+House_N+'.player is ',Num_lines_In_cooling_player,'line was ', line, 'Modified to', From_Dic_Signal_start_replace_ON,' And ', From_Dic_Signal_finish_replace_ON)
                         for i_Signals_list_OFF in range(len(Signals_list_All_dict_HVAC_OFF)):
                          for Signal_key2, Signal_value2 in Signals_list_All_dict_HVAC_OFF[i_Signals_list_OFF].items():
                             if (line==Signal_key2):
                                 Signal_FoundMatchLine=True
                                 if(1==Num_lines_In_cooling_player):
                                                        From_Dic_Signal_start_replace_OFF =Signal_value2['Signal_start_replace_OFF']
                                                        AddLine4_Opt_player_HVAC='echo '+From_Dic_Signal_start_replace_OFF+' > heating_setpoint_'+House_N+'_opt.player'
                                                        subprocess.call(AddLine4_Opt_player_HVAC, shell=True)
                                                        From_Dic_Signal_finish_replace_OFF =Signal_value2['Signal_finish_replace_OFF']
                                                        AddLine5_Opt_player_HVAC='echo '+From_Dic_Signal_finish_replace_OFF+' >> heating_setpoint_'+House_N+'_opt.player'
                                                        subprocess.call(AddLine5_Opt_player_HVAC, shell=True)
                                 else:
                                                        From_Dic_Signal_start_replace_OFF =Signal_value2['Signal_start_replace_OFF']
                                                        AddLine4_Opt_player_HVAC='echo '+From_Dic_Signal_start_replace_OFF+' >> heating_setpoint_'+House_N+'_opt.player'
                                                        subprocess.call(AddLine4_Opt_player_HVAC, shell=True)
                                                        From_Dic_Signal_finish_replace_OFF =Signal_value2['Signal_finish_replace_OFF']
                                                        AddLine5_Opt_player_HVAC='echo '+From_Dic_Signal_finish_replace_OFF+' >> heating_setpoint_'+House_N+'_opt.player'
                                                        subprocess.call(AddLine5_Opt_player_HVAC, shell=True)
                                 print('Modifed line number of heating_setpoint_OFF '+House_N+'.player is ',Num_lines_In_cooling_player,'line was ', line, 'Modified to', From_Dic_Signal_start_replace_OFF,' And ', From_Dic_Signal_finish_replace_OFF)
                         if(not(Signal_FoundMatchLine)):
                             if(1==Num_lines_In_cooling_player):
                                                AddLine6_Opt_player_HVAC='echo '+line+' > heating_setpoint_'+House_N+'_opt.player'
                                                subprocess.call(AddLine6_Opt_player_HVAC, shell=True)
                             else:
                                                AddLine7_Opt_player_HVAC='echo '+line+' >> heating_setpoint_'+House_N+'_opt.player'
                                                subprocess.call(AddLine7_Opt_player_HVAC, shell=True)
                         Num_lines_In_cooling_player+=1
                Check_PATH_player_HVAC='ls'
                if (1==verbose_Figs):subprocess.call(Check_PATH_player_HVAC, shell=True)
                os.chdir(wd_Orginal)
        #@
        if(not(DR_Signal_ForHeating_setpoints)):
            wd_Orginal = os.getcwd()
            os.chdir('GLM_Files/InPut_for_glm/Heating_setpoints/'+House_N+'/')
            Check_PATH_player_HVAC='ls' 
            if (1==verbose_Figs):subprocess.call(Check_PATH_player_HVAC, shell=True)
            Num_lines_In_cooling_player=1
            with open('heating_setpoint_'+House_N+'.player') as file:
                    while (line := file.readline().rstrip()):
                        Signal_FoundMatchLine=False
                        if(not(Signal_FoundMatchLine)):
                                     if(1==Num_lines_In_cooling_player):
                                                        AddLine6_Opt_player_HVAC='echo '+line+' > heating_setpoint_'+House_N+'_opt.player'
                                                        subprocess.call(AddLine6_Opt_player_HVAC, shell=True)
                                     else:
                                                        AddLine7_Opt_player_HVAC='echo '+line+' >> heating_setpoint_'+House_N+'_opt.player'
                                                        subprocess.call(AddLine7_Opt_player_HVAC, shell=True)
                        Num_lines_In_cooling_player+=1
            Check_PATH_player_HVAC='ls'
            if (1==verbose_Figs):subprocess.call(Check_PATH_player_HVAC, shell=True)
            os.chdir(wd_Orginal)
            
def Make_Figs_and_CSVs_AfterRunWith_DR_Signal(verbose_Figs,Net_Total_opt_Gen_ByGridlabD_dataHour_2,HVAC_opt_Gen_ByGridlabD_dataHour_2,Act_Date_ForOptJulia):
  #Define
  Act_Date_Net_Total_Gen_ByGridlabD_H=Net_Total_opt_Gen_ByGridlabD_dataHour_2.loc[ Act_Date: Act_Date, :][''+House_N+'_measured_real_energy']
  plotpred_HVAC_opt_Gen_ByGridlabD=HVAC_opt_Gen_ByGridlabD_dataHour_2.loc[ Act_Date: Act_Date, :][''+House_N+'_HVAC_energy']
  Act_Date_UnControlAble_load_Gen_ByGridlabD_H=Act_Date_Net_Total_Gen_ByGridlabD_H-plotpred_HVAC_opt_Gen_ByGridlabD
  Act_Date_WaterHeter_Gen_ByGridlabD_H=0*Net_Total_opt_Gen_ByGridlabD_dataHour_2.loc[ Act_Date: Act_Date, :][''+House_N+'_measured_real_energy']
  Act_Date_Dishwasher_Gen_ByGridlabD_H=0*Net_Total_opt_Gen_ByGridlabD_dataHour_2.loc[ Act_Date: Act_Date, :][''+House_N+'_measured_real_energy']
  Act_Date_ControlAble_load_Gen_ByGridlabD_H=plotpred_HVAC_opt_Gen_ByGridlabD+Act_Date_WaterHeter_Gen_ByGridlabD_H+Act_Date_Dishwasher_Gen_ByGridlabD_H

    ###########   
    ###########             Write csv for sending to julia '+House_N+'       #################################
    ###########   
  header = ['datetime', 'Net_Total', 'UnControlAble_load', 'ControlAble_load','HVAC', 'WaterHeter', 'Dishwasher']
  datetime_list=[]
  for x in range(0, 24):
      #print(x)
      a_list = []
      tem=Act_Date_ForOptJulia+' '+str(x)+':00'
      a_list.append(tem)
      a_list.append(Act_Date_Net_Total_Gen_ByGridlabD_H[x])
      a_list.append(Act_Date_UnControlAble_load_Gen_ByGridlabD_H[x])
      a_list.append(Act_Date_ControlAble_load_Gen_ByGridlabD_H[x])
      a_list.append(plotpred_HVAC_opt_Gen_ByGridlabD[x])
      a_list.append(Act_Date_WaterHeter_Gen_ByGridlabD_H[x])
      a_list.append(Act_Date_Dishwasher_Gen_ByGridlabD_H[x])
      datetime_list.append(a_list)
    ################# making data for julia   with  version 
  with open('Py_Files/OutPut_of_py/'+House_N+'/R_'+House_N+'_EnergyUse_H'+ version +'_AfterRunWith_DR_Signal.csv', 'w') as f:
        # create the csv writer
        writer = csv.writer(f)
        # write the header
        writer.writerow(header)
        # write a row to the csv file
        writer.writerows(datetime_list)
  ################# making data for julia without version
  with open('Py_Files/OutPut_of_py/'+House_N+'/R_'+House_N+'_EnergyUse_H_AfterRunWith_DR_Signal.csv', 'w') as f:
        # create the csv writer
        writer = csv.writer(f)
        # write the header
        writer.writerow(header)
        # write a row to the csv file
        writer.writerows(datetime_list)
    
 
 
 ########################################
#######################################
def GLM_Initial_Actions():
        verbose_Figs,starttime_glmRun,starttime_Date,stoptime_glmRun,stoptime_Date,Act_Date_ForOptJulia,Act_Date,Pred_Dates_list,Input_Date,month= make_Necessary_daysForPre()
        #
        Pred_Date_Num=1
        #
        Change_SetPointsDate_FromInitial(starttime_Date, Input_Date,Act_Date,stoptime_Date,Pred_Date_Num,verbose_Figs)
        #
        Run_gridlabd(starttime_glmRun, stoptime_glmRun,version)
        #
        Change_SetPointsDate_ToInitial(starttime_Date, Input_Date,Act_Date,stoptime_Date,Pred_Date_Num,verbose_Figs)
        if (1==verbose_Figs):
            print(' \n Start Running gridlabd-D \n', starttime_glmRun)
            print(' Stop Running gridlabd-D \n', stoptime_glmRun,'\n\n\n')
            print(' starttime_Date \n', starttime_Date)
            print(' stoptime_Date \n', stoptime_Date)
            print(' Input Date as prediction Date \n', Input_Date)
            print(' Actual Date for comparing prediction \n', Act_Date)
        return Input_Date,Act_Date,Pred_Dates_list,month,Act_Date_ForOptJulia,verbose_Figs,Pred_Date_Num,starttime_Date, Input_Date,Act_Date,stoptime_Date,Pred_Date_Num,starttime_glmRun, stoptime_glmRun,


 
def Py_Especial_Actions(House_List,Input_Date,Act_Date,Pred_Dates_list,month,Act_Date_ForOptJulia,verbose_Figs,Pred_Date_Num,version):

    for House_N in House_List:
          print(House_N,'\n\n\n')
          Net_Total_Gen_ByGridlabD_dataHour_2=Initial_Process_ToMake_Net_Total_H_data(verbose_Figs,House_N)

          HVAC_Gen_ByGridlabD_dataHour_2=Initial_Process_ToMake_HVAC_H_data(verbose_Figs,House_N)
          #
          HVAC_Gen_ByGridlabD_Actula_output,HVAC_Gen_ByGridlabD_input_x1,HVAC_Gen_ByGridlabD_Act_DateData,HVAC_Gen_ByGridlabD_data_prediction=HVAC_H_data_prepration_for_LSTM(verbose_Figs,HVAC_Gen_ByGridlabD_dataHour_2,House_N,Input_Date,Act_Date)
          #
          HVAC_Gen_ByGridlabD_yhat=Prediction_By_LSTM_models(verbose_Figs,HVAC_Gen_ByGridlabD_input_x1, House_N)
          #
          plotpred_inv_HVAC_Gen_ByGridlabD,HVAC_Gen_ByGridlabD_plot_pred,HVAC_Gen_ByGridlabD_Act_DateData,HVAC_Gen_ByGridlabD_plot_act=HVAC_H_data_prepration_from_LSTM_For_Figs_and_CSV(verbose_Figs,HVAC_Gen_ByGridlabD_yhat, HVAC_Gen_ByGridlabD_Actula_output, House_N, Act_Date_ForOptJulia,Input_Date,HVAC_Gen_ByGridlabD_Act_DateData)
          #
          Make_Figs_and_CSVs(verbose_Figs,Net_Total_Gen_ByGridlabD_dataHour_2,plotpred_inv_HVAC_Gen_ByGridlabD, HVAC_Gen_ByGridlabD_plot_pred, House_N, Act_Date_ForOptJulia,Input_Date,Act_Date, version,HVAC_Gen_ByGridlabD_Act_DateData,HVAC_Gen_ByGridlabD_data_prediction,HVAC_Gen_ByGridlabD_plot_act)
    
def jl_Actions_Optimization(Pred_Date_Num,House_List,verbose_Figs):
        if (1==verbose_Figs):print('\nRun Correction_LIB_PATH\n')
        Correction_LIB_PATH='export LD_LIBRARY_PATH=/usr/lib64'
        subprocess.call(Correction_LIB_PATH, shell=True)
        if (1==verbose_Figs):print('\nRun makeEnv\n')
        subprocess.run(['julia', 'makeEnv.jl'])######
        if (1==verbose_Figs):print('\nMakeEnv inside Julia Done\n')
        if (1==verbose_Figs):print('\nRun julia\n')
        if (1==verbose_Figs):print('60_2_Max_LoadShiftingandShaving_V2.jl\n')
        subprocess.run(['julia', '60_2_Max_LoadShiftingandShaving_V2.jl'])
        #subprocess.run(['julia', '60_3_Max_LoadShiftingandShaving_8.jl', '--define', stoptime_glmRun]])
        if (1==verbose_Figs):print('\nFinish Run julia file form invironmen\n')
        
        
def jl_Actions_MakeFinalResult_BasedOnDR(verbose_Figs):
        if (1==verbose_Figs):print('\nRun Correction_LIB_PATH\n')
        Correction_LIB_PATH='export LD_LIBRARY_PATH=/usr/lib64'
        subprocess.call(Correction_LIB_PATH, shell=True)
        if (1==verbose_Figs):print('\nRun makeEnv\n')
        subprocess.run(['julia', 'makeEnv.jl'])######
        if (1==verbose_Figs):print('\nMakeEnv inside Julia Done\n')
        if (1==verbose_Figs):print('\nRun julia\n')
        if (1==verbose_Figs):print('FinalResult_31.jl\n')
        subprocess.run(['julia', 'FinalResult_31.jl'])
        #subprocess.run(['julia', '60_3_Max_LoadShiftingandShaving_8.jl', '--define', stoptime_glmRun]])
        if (1==verbose_Figs):print('\nFinish Run julia file form invironmen\n')


def Py_Especial_Actions_AfterOpt(verbose_Figs,Act_Date_ForOptJulia,House_List,month,starttime_Date, Input_Date,Act_Date,stoptime_Date,Pred_Date_Num,starttime_glmRun, stoptime_glmRun):
        Add_Opt_result_EnergyUse_CSVs(verbose_Figs,Act_Date_ForOptJulia,House_List,month)  
        Change_SetPointsDate_FromInitial(starttime_Date, Input_Date,Act_Date,stoptime_Date,Pred_Date_Num,verbose_Figs)
        #
        Change_SetPointsHours_BasedOnOpt_Make_DR_Signal(verbose_Figs,House_List,Act_Date,month)
        #
        Run_gridlabd_BaseOn_DR_Signal(starttime_glmRun, stoptime_glmRun,version)
        #
        Change_SetPointsDate_ToInitial(starttime_Date, Input_Date,Act_Date,stoptime_Date,Pred_Date_Num,verbose_Figs)

  
#################  EnergyUse_H_Opt
################# #################
#####################################################     Start  Run
################# #################
#################

Input_Date,Act_Date,Pred_Dates_list,month,Act_Date_ForOptJulia,verbose_Figs,Pred_Date_Num,starttime_Date, Input_Date,Act_Date,stoptime_Date,Pred_Date_Num,starttime_glmRun, stoptime_glmRun=GLM_Initial_Actions()

# 
print(' Pred_Dates_list \n')
for i in Pred_Dates_list:
  print(i)
#
House_List=['House_1','House_5','House_6','House_7','House_8','House_9','House_10','House_11','House_12','House_13','House_14','House_15']
#House_List=['House_15']
#
Py_Especial_Actions(House_List,Input_Date,Act_Date,Pred_Dates_list,month,Act_Date_ForOptJulia,verbose_Figs,Pred_Date_Num,version)
#
jl_Actions_Optimization(Pred_Date_Num,House_List,verbose_Figs)
#
Py_Especial_Actions_AfterOpt(verbose_Figs,Act_Date_ForOptJulia,House_List,month,starttime_Date, Input_Date,Act_Date,stoptime_Date,Pred_Date_Num,starttime_glmRun, stoptime_glmRun)
#
for House_N in House_List:
          print(House_N,'\n\n\n')
          Net_Total_opt_Gen_ByGridlabD_dataHour_2,HVAC_opt_Gen_ByGridlabD_dataHour_2=Process_ToMake_H_data_BasedON_DR_Signals(verbose_Figs,House_N)
          Make_Figs_and_CSVs_AfterRunWith_DR_Signal(verbose_Figs,Net_Total_opt_Gen_ByGridlabD_dataHour_2,HVAC_opt_Gen_ByGridlabD_dataHour_2,Act_Date_ForOptJulia)

jl_Actions_MakeFinalResult_BasedOnDR(verbose_Figs)

