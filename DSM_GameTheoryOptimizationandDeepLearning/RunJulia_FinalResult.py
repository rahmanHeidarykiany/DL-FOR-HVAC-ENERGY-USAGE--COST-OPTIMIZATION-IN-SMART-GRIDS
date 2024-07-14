version='_29'

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
  
verbose_Figs=0

def jl_Actions_FinalResult(verbose_Figs):
        if (1==verbose_Figs):print('\nRun Correction_LIB_PATH\n')
        Correction_LIB_PATH='export LD_LIBRARY_PATH=/usr/lib64'
        subprocess.call(Correction_LIB_PATH, shell=True)
        if (1==verbose_Figs):print('\nRun makeEnv\n')
        subprocess.run(['julia', 'makeEnv.jl'])######
        if (1==verbose_Figs):print('\nMakeEnv inside Julia Done\n')
        if (1==verbose_Figs):print('\nRun julia FinalResult\n')
        if (1==verbose_Figs):print('FinalResult'+version+'.jl\n')
        subprocess.run(['julia', 'FinalResult'+version+'.jl'])
        if (1==verbose_Figs):print('\nFinish Run julia FinalResult \n')

        
jl_Actions_FinalResult(verbose_Figs)

