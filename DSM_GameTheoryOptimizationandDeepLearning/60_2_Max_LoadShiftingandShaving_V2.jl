##version
version="_60_2_7"
verbose_Figs=1
#
Address=pwd();
OrginalFilesAddress=""*Address*"/"
println("OrginalFilesAddress = ", OrginalFilesAddress)
CurrentFiles=readdir()
import Pkg;
using Pkg

#Pkg.activate(".")
#Pkg.instantiate()
#Pkg.status()

#=
###################
Pkg.add(PackageSpec(name = "GR", version = "0.64.1"))
#https://stackoverflow.com/questions/47087509/julia-how-i-fix-a-package-at-a-particular-version
#######################
Pkg.add("JuMP")
import JuMP
Pkg.add("LinearAlgebra")
#import LinearAlgebra
Pkg.add("CSV")
Pkg.add("Ipopt")
Pkg.add("GLPK")
Pkg.add("Cbc")
#import Cbc
Pkg.add("SCS")
#import SCS

Pkg.add("InfrastructureModels")
#import InfrastructureModels
Pkg.add("Memento")
#import Memento
Pkg.add("Juniper")
#import Juniper
Pkg.add("JLD")
Pkg.add("FileIO")
Pkg.add("HDF5")
Pkg.add("DataFrames")
Pkg.add("PGFPlotsX")
Pkg.add("Distributions")
Pkg.add("CSV")
Pkg.add("Gurobi")
Pkg.add("DifferentialEquations")
Pkg.add("StatsPlots")
Pkg.add("Plots")
=#

#Pkg.add("Colors")

using Colors
#cols = range(colorant"red", stop=colorant"green",length=15)
#cols = range(LCHab(70,70,0), stop=LCHab(70,70,720), length=90)
cols = range(HSV(0,1,1), stop=HSV(-360,1,1), length=15) # inverse rotation

import DataFrames.DataFrame

using DataFrames
using Test
using JLD,HDF5,FileIO
#### declaration of utilized packages
using JuMP
using Gurobi # need to install Gurobi on your machine!
using Ipopt
using Statistics
using Dates
using Distributions
using StatsPlots
using Plots


using Cbc
#Pkg.add("GLPK")
using GLPK

#Pkg.add("Clarabel")
using Clarabel, JuMP

Pkg.activate(temp=true)
#Pkg.activate(".")

#Pkg.rm("CSV")
Pkg.add(name="Parsers", version="2.2.4")
Pkg.add(name="CSV", version="0.8.5")

#Pkg.rm("Parsers")

Pkg.add("DataFrames")

using DataFrames, CSV


Pkg.add("PyCall")
Pkg.build("PyCall")
using PyCall
#using PGFPlotsX,Distributions

# Suppress warnings during testing.
#Memento.setlevel!(Memento.getlogger(InfrastructureModels), "error")
#PowerModels.logger_config!("error")


NN=[1,5,6,7,8,9,10,11,12,13,14,15] ## list of subcribers(homes)
###  Notice, appliences are dependent to each other, when I am making numbers accordint to them
#NA=[1,2,3]  ##list of controlable appliences(only HVAC at the first step)
NA=[1]  ##list of controlable appliences(only HVAC at the first step)
IsThere_UncontrolAble_Load=true#false

##
N=collect(NN)##numbers of subcribers(homes)   #####collect(keys(NN))
A=collect(NA)##numbers of controlable appliences

NumberOfHOmes=length(NN)##numbers of subcribers(homes)   #####collect(keys(NN))

NH=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]## hours
H=collect(NH) ## Define Set of Hours!
Selected_home=[]#define variable
NotSelected_homes=[]#define parameters

## load home_load(when I make them)

##### make initial
Net_load=Dict()
UnControlAble_load=Dict()
ControlAble_load=Dict()
HVAC_load=Dict()
WaterHeter_load=Dict()
DISHWASHER_load=Dict()
for n in N
    Net_load[n]=zeros(length(NH))
    UnControlAble_load[n]=zeros(length(NH))### initialization
    ControlAble_load[n]=zeros(length(NH))### initialization
    HVAC_load[n]=zeros(length(NH))###
    WaterHeter_load[n]=zeros(length(NH))
    DISHWASHER_load[n]=zeros(length(NH))
end
TypeofHomeLoad=[Net_load,UnControlAble_load,ControlAble_load,HVAC_load,WaterHeter_load,DISHWASHER_load]


##### load
for n in N
    Str_n=string(n)
    if 1==verbose_Figs
        println("House_"*Str_n*"")
    end
    House_loads=CSV.read(""*OrginalFilesAddress*"Py_Files/OutPut_of_py/House_"*Str_n*"/R_House_"*Str_n*"_EnergyUse_H.csv", DataFrame)
    Net_load[n]=House_loads.Net_Total
    UnControlAble_load[n]=House_loads.UnControlAble_load
    ControlAble_load[n]=House_loads.ControlAble_load
    HVAC_load[n]=House_loads.HVAC
    WaterHeter_load[n]=House_loads.WaterHeter
    DISHWASHER_load[n]=House_loads.Dishwasher########DISHWASHER_load
end

## UnControlAble_load

Plot_Hourly_UnControlAble_load_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for
iter_UnControlAble_load_list=0
for n in N
    global iter_UnControlAble_load_list=iter_UnControlAble_load_list+1
    Plot_Hourly_UnControlAble_load_list[iter_UnControlAble_load_list]=UnControlAble_load[n]
end
Plot_Hourly_UnControlAble_load=plot(NH, [Plot_Hourly_UnControlAble_load_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh", title="UnControlAble load", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)

##  Making suitable  applienses


Plot_Hourly_HVAC_load_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for
Plot_Hourly_WaterHeter_load_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for
Plot_Hourly_DISHWASHER_load_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for

iter_Plot_Hourly_applienses=0
for n in N
    global iter_Plot_Hourly_applienses=iter_Plot_Hourly_applienses+1
    Plot_Hourly_HVAC_load_list[iter_Plot_Hourly_applienses]=HVAC_load[n]
    Plot_Hourly_WaterHeter_load_list[iter_Plot_Hourly_applienses]=WaterHeter_load[n]
    Plot_Hourly_DISHWASHER_load_list[iter_Plot_Hourly_applienses]=DISHWASHER_load[n]
end


Plot_Hourly_HVAC_load=plot(NH, [Plot_Hourly_HVAC_load_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="HVAC load", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
Plot_Hourly_WaterHeter_load=plot(NH, [Plot_Hourly_WaterHeter_load_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="WaterHeter load", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
Plot_Hourly_DISHWASHER_load=plot(NH, [Plot_Hourly_DISHWASHER_load_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="Dishwasher load", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
## make  net load for each home
# # in last version of code we should not have this part, only we should inport them
ControlAble_load=Dict()
Net_load=Dict()
for n in N
    ControlAble_load[n]=zeros(length(NH))
    Net_load[n]=zeros(length(NH))
    for a in A
        if a == 1
            ControlAble_load[n]=ControlAble_load[n]+HVAC_load[n]
        elseif a == 2
            ControlAble_load[n]=ControlAble_load[n]+WaterHeter_load[n]
        elseif a == 3
            ControlAble_load[n]=ControlAble_load[n]+DISHWASHER_load[n]
        end
    end
    if (IsThere_UncontrolAble_Load)
        global UnControlAble_load[n]=UnControlAble_load[n]
    else
        global UnControlAble_load[n]=UnControlAble_load[n]*0.000
    end
    Net_load[n]=ControlAble_load[n]+UnControlAble_load[n]
end
Plot_Hourly_ControlAble_load_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for
Plot_Hourly_UnControlAble_load_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for
Plot_Hourly_Net_load_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for

iter_Hourly_make_net_load=0
Hourly_Aggregate_Net_load=zeros(length(NH))

for n in N
    global iter_Hourly_make_net_load=iter_Hourly_make_net_load+1
    global Hourly_Aggregate_Net_load=Hourly_Aggregate_Net_load+Net_load[n]
    Plot_Hourly_ControlAble_load_list[iter_Hourly_make_net_load]=ControlAble_load[n]
    Plot_Hourly_UnControlAble_load_list[iter_Hourly_make_net_load]=UnControlAble_load[n]
    Plot_Hourly_Net_load_list[iter_Hourly_make_net_load]=Net_load[n]
end

Plot_Hourly_UnControlAble_load=plot(NH, [Plot_Hourly_UnControlAble_load_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="UnControlAble load", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
Plot_Hourly_ControlAble_load=plot(NH, [Plot_Hourly_ControlAble_load_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="ControlAble loads", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
Plot_Hourly_Net_load=plot(NH, [Plot_Hourly_Net_load_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="Net loads", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
Plot_Hourly_Aggregate_Net_load=plot(NH, [Hourly_Aggregate_Net_load],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="Hourly_Aggregate_Net_load loads", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)

##plot Net load and UnControlAble_load load and HVAC
###check
AllHouses_loadsSeperately=plot(Plot_Hourly_Net_load,Plot_Hourly_UnControlAble_load, Plot_Hourly_HVAC_load)
###

##
### Applience_Details according to their a number
Hourly_Applience_DetailsFor_home=Dict()
for n in N
    Hourly_Applience_DetailsFor_home[n]=Dict()
            for a in A
                if a==1
                    Hourly_Applience_DetailsFor_home[n][a]=HVAC_load[n]
                elseif a==2
                    Hourly_Applience_DetailsFor_home[n][a]=WaterHeter_load[n]
                elseif a==3
                    Hourly_Applience_DetailsFor_home[n][a]=DISHWASHER_load[n]
                end
            end
end

## Find out about details of appienes before starting the
#### Statistics on Appliences Parameters
#### Make Dict for each Parameter will be needed on our code

E_MiN=Dict()
E_MaX=Dict()
E_MaX_hour=Dict()
E_Mean=Dict()
for n in N
    E_MiN[n]=Dict()
    E_MaX[n]=Dict()
    E_MaX_hour[n]=Dict()
    E_Mean[n]=Dict()

    for a in A
        if a==1
            E_MiN[n][a]=minimum(HVAC_load[n])
            E_MaX[n][a]=maximum(HVAC_load[n])
            E_Mean[n][a]=mean(HVAC_load[n])
        elseif a==2
            E_MiN[n][a]=minimum(WaterHeter_load[n])
            E_MaX[n][a]=maximum(WaterHeter_load[n])
            E_Mean[n][a]=mean(WaterHeter_load[n])
        elseif a==3
            E_MiN[n][a]=minimum(DISHWASHER_load[n])
            E_MaX[n][a]=maximum(DISHWASHER_load[n])
            E_Mean[n][a]=mean(DISHWASHER_load[n])
        end

        E_MaX_hour[n][a]=0
        for h in H
                if (Hourly_Applience_DetailsFor_home[n][a][h]==E_MaX[n][a])#find times which is close to peak time
                    E_MaX_hour[n][a]=h
                end
        end

    end
end


Applience_Time_Can_be_scheduled=Dict()
for n in N
    Applience_Time_Can_be_scheduled[n]=Dict()
    for a in A
        Applience_Time_Can_be_scheduled[n][a]=[]
        for h in H
            if a==1
                if (E_MaX_hour[n][a] == h)
                    #append!(Applience_Time_Can_be_scheduled[n][a],h-2)
                    append!(Applience_Time_Can_be_scheduled[n][a],h-1)
                    append!(Applience_Time_Can_be_scheduled[n][a],h)
                    append!(Applience_Time_Can_be_scheduled[n][a],h+1)
                    #append!(Applience_Time_Can_be_scheduled[n][a],h+2)
                end
            elseif a==2
                if (E_MaX_hour[n][a] == h)
                    append!(Applience_Time_Can_be_scheduled[n][a],h-2)
                    append!(Applience_Time_Can_be_scheduled[n][a],h-1)
                    append!(Applience_Time_Can_be_scheduled[n][a],h)
                    append!(Applience_Time_Can_be_scheduled[n][a],h+1)
                    append!(Applience_Time_Can_be_scheduled[n][a],h+2)
                end
            elseif a==3
                if (E_MaX_hour[n][a] == h)
                    append!(Applience_Time_Can_be_scheduled[n][a],h-2)
                    append!(Applience_Time_Can_be_scheduled[n][a],h-1)
                    append!(Applience_Time_Can_be_scheduled[n][a],h)
                    append!(Applience_Time_Can_be_scheduled[n][a],h+1)
                    append!(Applience_Time_Can_be_scheduled[n][a],h+2)
                end
            end
        end
    end
end

######## to be sure every hours make sense
for n in N
    for a in A
        i_Time_Can_be_sche=0
        for h in Applience_Time_Can_be_scheduled[n][a]
            i_Time_Can_be_sche=i_Time_Can_be_sche+1
            if (Applience_Time_Can_be_scheduled[n][a][i_Time_Can_be_sche]==25)
                Applience_Time_Can_be_scheduled[n][a][i_Time_Can_be_sche]=1
            elseif (Applience_Time_Can_be_scheduled[n][a][i_Time_Can_be_sche]==26)
                Applience_Time_Can_be_scheduled[n][a][i_Time_Can_be_sche]=2
            elseif (Applience_Time_Can_be_scheduled[n][a][i_Time_Can_be_sche]==0)
                Applience_Time_Can_be_scheduled[n][a][i_Time_Can_be_sche]=24
            elseif (Applience_Time_Can_be_scheduled[n][a][i_Time_Can_be_sche]==-1)
                Applience_Time_Can_be_scheduled[n][a][i_Time_Can_be_sche]=23
            end
        end
    end
end

NumberOf_Hours_Applience_Can_be_scheduled=Dict()
for n in N
    NumberOf_Hours_Applience_Can_be_scheduled[n]=Dict()
    for a in A
        NumberOf_Hours_Applience_Can_be_scheduled[n][a]=length(Applience_Time_Can_be_scheduled[n][a])
    end
end



Applience_Times_Can_not_be_scheduled=Dict()
for n in N
    Applience_Times_Can_not_be_scheduled[n]=Dict()
    for a in A
        Applience_Times_Can_not_be_scheduled[n][a]=H
        Applience_Times_Can_not_be_scheduled[n][a]=setdiff(Applience_Times_Can_not_be_scheduled[n][a],Applience_Time_Can_be_scheduled[n][a])
    end
end


Appliences_Scheduled_total_PeakTime_Eng_consump=Dict()
Appliences_Scheduled_total_NoT_PeakTime_Eng_consump=Dict()
for n in N
    Appliences_Scheduled_total_PeakTime_Eng_consump[n]=Dict()
    Appliences_Scheduled_total_NoT_PeakTime_Eng_consump[n]=Dict()
    for a in A
        Appliences_Scheduled_total_PeakTime_Eng_consump[n][a]=0
        for h in Applience_Time_Can_be_scheduled[n][a]
            if a==1
                    Appliences_Scheduled_total_PeakTime_Eng_consump[n][a]=Appliences_Scheduled_total_PeakTime_Eng_consump[n][a]+HVAC_load[n][h]
            elseif a==2
                    Appliences_Scheduled_total_PeakTime_Eng_consump[n][a]=Appliences_Scheduled_total_PeakTime_Eng_consump[n][a]+WaterHeter_load[n][h]
            elseif a==3
                    Appliences_Scheduled_total_PeakTime_Eng_consump[n][a]=Appliences_Scheduled_total_PeakTime_Eng_consump[n][a]+DISHWASHER_load[n][h]
            end
        end

        Appliences_Scheduled_total_NoT_PeakTime_Eng_consump[n][a]=0
        for h in Applience_Times_Can_not_be_scheduled[n][a]
            if a==1
                    Appliences_Scheduled_total_NoT_PeakTime_Eng_consump[n][a]=Appliences_Scheduled_total_NoT_PeakTime_Eng_consump[n][a]+HVAC_load[n][h]
            elseif a==2
                    Appliences_Scheduled_total_NoT_PeakTime_Eng_consump[n][a]=Appliences_Scheduled_total_NoT_PeakTime_Eng_consump[n][a]+WaterHeter_load[n][h]
            elseif a==3
                    Appliences_Scheduled_total_NoT_PeakTime_Eng_consump[n][a]=Appliences_Scheduled_total_NoT_PeakTime_Eng_consump[n][a]+DISHWASHER_load[n][h]
            end
        end
    end
end


Day_Control_Able_PeakTime_Load=Dict()
Day_Control_Able_NoT_PeakTime_Load=Dict()
for n in N
    temp_1=0
    temp_2=0
    for a in A
        temp_1=temp_1+Appliences_Scheduled_total_PeakTime_Eng_consump[n][a]
        temp_2=temp_2+Appliences_Scheduled_total_NoT_PeakTime_Eng_consump[n][a]
    end
    Day_Control_Able_PeakTime_Load[n]=temp_1
    Day_Control_Able_NoT_PeakTime_Load[n]=temp_2
end


## our source for optimization is Dict
# make Dict is for haveing all details in one place
# after manking Dict our source will be only Dict
# in the this vesion we have 3 appliences, 1=HVAC, (2=WaterHeter, 3=DISHWASHER not contoling)

Hourly_loads_ForSubscriber=Dict()
Day_load_ForSubscriber=Dict()
for n in N
        Hourly_loads_ForSubscriber[n]=Dict()
        Day_load_ForSubscriber[n]=[]
        Temp_1=0
        Temp_2=0
                for h in H
                    Hourly_loads_ForSubscriber[n][h]=Dict(
                    "Hourly_HVAC_load_ForSubscriber"=>HVAC_load[n][h],
                    "Hourly_WaterHeter_load_ForSubscriber"=>WaterHeter_load[n][h],
                    "Hourly_DISHWASHER_load_ForSubscriber"=>DISHWASHER_load[n][h],
                    "Hourly_ControlAble_load_ForSubscriber"=>ControlAble_load[n][h],
                    "Hourly_ControlAble_load_ForSubscriber_Initial"=>ControlAble_load[n][h],
                    "Optimized_Hourly_ControlAble_load_ForSubscriber"=>0.00000000,
                    "Hourly_UnControlAble_load_ForSubscriber"=>UnControlAble_load[n][h],
                    )
                    Temp_2=Temp_2+Hourly_loads_ForSubscriber[n][h]["Hourly_UnControlAble_load_ForSubscriber"]
                end
                Day_load_ForSubscriber[n]=Dict(
                "Day_Control_Able_PeakTime_Load"=>Day_Control_Able_PeakTime_Load[n],
                "Day_Control_Able_NoT_PeakTime_Load"=>Day_Control_Able_NoT_PeakTime_Load[n],
                "Day_UnControl_Able_Load_ForSubscriber"=>Temp_2,
                )
end


##### update information
for n in N
    Temp_1=0
    Temp_2=0
    Temp_3=0
    for h in H
        Temp_1=Hourly_loads_ForSubscriber[n][h]["Hourly_ControlAble_load_ForSubscriber"]
        Temp_2=Hourly_loads_ForSubscriber[n][h]["Hourly_UnControlAble_load_ForSubscriber"]
        Hourly_loads_ForSubscriber[n][h]["Hourly_Net_load_ForSubscriber"]=Temp_1+Temp_2
        Hourly_loads_ForSubscriber[n][h]["Optimized_Hourly_Net_load_ForSubscriber"]=Temp_1+Temp_2
        ##
        Temp_3=Temp_3+Hourly_loads_ForSubscriber[n][h]["Hourly_Net_load_ForSubscriber"]
    end
    Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber"]=Temp_3
    Day_load_ForSubscriber[n]["Day_ControlAble_load_ForSubscriber"]=Day_Control_Able_NoT_PeakTime_Load[n]+Day_Control_Able_PeakTime_Load[n]### Make Dict for seeing all of them in one location.
end

Day_load_ForSubscriber_Control_Able_PeakTime_list=zeros(length(NN))
Day_load_ForSubscriber_Control_Able_NoT_PeakTime_list=zeros(length(NN))
Day_load_ForSubscriber_ControlAble_load_list=zeros(length(NN))
Day_load_ForSubscriber_UnControlAble_load_list=zeros(length(NN))
Day_load_ForSubscriber_Net_load_list=zeros(length(NN))

iter_Day_load_ForSubscriber=0
for n in N
    global iter_Day_load_ForSubscriber=iter_Day_load_ForSubscriber+1
    Day_load_ForSubscriber_Control_Able_PeakTime_list[iter_Day_load_ForSubscriber]=Day_load_ForSubscriber[n]["Day_Control_Able_PeakTime_Load"]
    Day_load_ForSubscriber_Control_Able_NoT_PeakTime_list[iter_Day_load_ForSubscriber]=Day_load_ForSubscriber[n]["Day_Control_Able_NoT_PeakTime_Load"]
    Day_load_ForSubscriber_ControlAble_load_list[iter_Day_load_ForSubscriber]=Day_load_ForSubscriber[n]["Day_ControlAble_load_ForSubscriber"]
    Day_load_ForSubscriber_UnControlAble_load_list[iter_Day_load_ForSubscriber]=Day_load_ForSubscriber[n]["Day_UnControl_Able_Load_ForSubscriber"]
    Day_load_ForSubscriber_Net_load_list[iter_Day_load_ForSubscriber]=Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber"]
end
#Plot_Day_load_ForSubscriber_Control_Able_PeakTime=plot(scatter(NN,[210,210,210,210], color=0:3,mode="markers"),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh", yticks=0:10:800,title=" Day_ControlAble_PeakTime", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
Plot_Day_load_ForSubscriber_Control_Able_PeakTime=plot(scatter(NN,Day_load_ForSubscriber_Control_Able_PeakTime_list,  color=cols,mode="markers",markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh",title=" Day_ControlAble_PeakTime", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
Plot_Day_load_ForSubscriber_Control_Able_NoT_PeakTime=plot(scatter(NN,Day_load_ForSubscriber_Control_Able_NoT_PeakTime_list, color=cols,mode="markers",markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh", title=" Day_Control_Able_NoT_PeakTime", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
Plot_Day_load_ForSubscriber_ControlAble_load=plot(scatter(NN,Day_load_ForSubscriber_ControlAble_load_list,  color=cols,mode="markers",markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh", title=" Day_Control_Able", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
Plot_Day_load_ForSubscriber_UnControlAble_load=plot(scatter(NN,Day_load_ForSubscriber_UnControlAble_load_list,  color=cols,mode="markers",markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh", title=" Day_UnControl_Able", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
Plot_Day_load_ForSubscriber_Net_load=plot(scatter(NN,Day_load_ForSubscriber_Net_load_list,  color=cols,mode="markers",markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh",title=" Day_Net_Load", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
Load_BeforeApplyCode=plot(Plot_Day_load_ForSubscriber_Control_Able_PeakTime,Plot_Day_load_ForSubscriber_Control_Able_NoT_PeakTime)


##
#### Make Dict for applience Details in esch Subcriber
#####################
Applience_DetailsFor_home=Dict()
for n in N
    Applience_DetailsFor_home[n]=Dict()
            for a in A
                Applience_DetailsFor_home[n][a]=Dict( #
                        "Time_Can_be_scheduleds"=>Applience_Time_Can_be_scheduled[n][a],#### suscriber determine( we consieder, these times can be different intervals
                        "Times_Can_not_be_scheduleds"=>Applience_Times_Can_not_be_scheduled[n][a],####
                        "E_MaX"=>E_MaX[n][a],#### According to Cris imagiantion, midnight, this number should be setted by ML to, howevre, We should have Histroy#### Manual determine it. e.x. Max of HVAC Heating set= 70  ---> E_max (since that is kWh) it should come form the gridlabD
                        "E_MiN_ProbablyOffTimeofApplience"=>E_MiN[n][a],#### #### Manual determine it. e.x. Min of HVAC Heating set= 60  ---> E_min (since that is kWh)
                        "E_Mean"=>E_Mean[n][a],#### #### Manual determine it. e.x. Min of HVAC Heating set= 60  ---> E_min (since that is kWh)
                        "Appliences_Scheduled_total_PeakTime_Eng_consump_Refrence"=>Appliences_Scheduled_total_PeakTime_Eng_consump[n][a],## PRE DETERMIND PARAMETERÍ 3^(1/20)
                        "Appliences_Scheduled_total_PeakTime_Eng_consump_updated"=>Appliences_Scheduled_total_PeakTime_Eng_consump[n][a]## PRE DETERMIND PARAMETERÍ 3^(1/20)
                        )
            end
end


for n in N
    for a in A
        if a==1
            Applience_DetailsFor_home[n][a]["Hourly_Applience_load"]=HVAC_load[n]
            Applience_DetailsFor_home[n][a]["Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction"]=0

        elseif a==2
            Applience_DetailsFor_home[n][a]["Hourly_Applience_load"]=WaterHeter_load[n]
            Applience_DetailsFor_home[n][a]["Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction"]=0
        elseif a==3
            Applience_DetailsFor_home[n][a]["Hourly_Applience_load"]=DISHWASHER_load[n]
            Applience_DetailsFor_home[n][a]["Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction"]=0

        end
    end
end


##
#### Network limitation
Network_Upper_limitation=[150,150,150,150,150,150,150,150,150,150,150,150,83,150,150,150,150,150,150,134,150,150,150,150]##
                      NH=[1,  2,   3,  4,  5,  6,  7,  8,  9,  10, 11, 12,13, 14, 15,16,  17, 18, 19, 20, 21, 22, 23, 24]## hours
Network_Lower_limitation=[0,0,0,0,0,0,0,0,0,0,0,0,                         81,0,0,0,0,0,0,             133,0,0,0,0]##


Utility_Network_limitation=Dict()
for h in H
        Utility_Network_limitation[h]=Dict(
        "Network_Power_Upper_limit"=>Network_Upper_limitation[h],
        "Network_Power_Lower_limit"=>Network_Lower_limitation[h]##
        )
end


# Notice "Net_load"
Homes_E_MaX=Dict()
Homes_E_MaX_hour=Dict()
for n in N
    Homes_E_MaX[n]=maximum(Net_load[n])
    Homes_E_MaX_hour[n]=0
    for h in H
        if (Homes_E_MaX[n]==Net_load[n][h])#
            Homes_E_MaX_hour[n]= h
        end
    end
end

##
########## CostFunction (Quadratic):C_h(L_h)=a_h(L_h)^2)+b_h(L_h)+c_h
####  Assumption: for simplicity b_h and c_h are 0s
####  We also have a_h= .3 cents at daytime hours, i.e., from 8:00 in the morning to 12:00 at night and
####  a_h= .2 cents during the night, i.e., from 12:00 at night to 8:00 AM the day after.

CostFunctionParameters=Dict()

for h in H
    CostFunctionParameters[h]=Dict()
    if (h<8)#### 8:00
        CostFunctionParameters[h]=Dict("a_h"=>(0.1))
    elseif(h>=8 && h<12)
        CostFunctionParameters[h]=Dict("a_h"=>(0.2))
    elseif(h>=12 && h<18)##18 ---> 6 pm
        CostFunctionParameters[h]=Dict("a_h"=>(0.3))
    elseif(h>=18 && h<22)
        CostFunctionParameters[h]=Dict("a_h"=>(0.2))
    elseif(h>=22)
        CostFunctionParameters[h]=Dict("a_h"=>(0.1))
    end
end
CostProfile=[]
for h in H
    append!(CostProfile,CostFunctionParameters[h]["a_h"])## bring out only number
end
CostProfile_mean=mean(CostProfile)

Plot_Hourly_CostProfile=plot(NH, [CostProfile],xlabel="Hours", xticks=0:1:24,ylabel="Price \$Dollar/kWh", title="Price skim", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm, label="")
savefig(Plot_Hourly_CostProfile,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Cost_Hourly_ProfileOfDistribution.png")

##
#######Defult Model and solver

pm = Model(Clarabel.Optimizer)
set_optimizer_attribute(pm, "verbose", true)
set_optimizer_attribute(pm, "max_iter", 10)
set_optimizer_attribute(pm, "time_limit", 60)

##Initialization
Error= false
iter_optimization=0 ##Iteration Number
time1= Dates.now()
time2= Dates.now()
period=time2-time1
SecPeriod=Dates.value(period)/1000
Objectives=[]


min_Scheduled_total_PeakTime_Eng_consump_Reduction=15.00### percent##
Ration_Scheduled_Loads=0
Min_ExpectConvRate=1.000## percent##### if rate go below of this number Optimization stop
ConverRate1=Min_ExpectConvRate#initial value, only for creating
ConverRate2=Min_ExpectConvRate
ConverRate3=Min_ExpectConvRate
ConverRate4=Min_ExpectConvRate
ConverRate5=Min_ExpectConvRate
ConverRate6=Min_ExpectConvRate
ConverRate7=Min_ExpectConvRate
ConverRate8=Min_ExpectConvRate
ConverRate9=Min_ExpectConvRate
ConverRate10=Min_ExpectConvRate
ConverRate11=Min_ExpectConvRate


ConverRates=[]
NecesseryItertionNumber=1000## intitaal ## that will be replaced
Repeat_ConverRate=0
Max_Repeat_ConverRate=10
Repeat_ConverRate_list=[]

##
NN=[1,5,6,7,8,9,10,11,12,13,14,15] ## list of subcribers(homes)
NN_Random_selected=[]
for homeNmber in 1:1:12
    D1= NN
    y1 = rand(D1,1)#
    Random_selected=y1[1]
    append!(NN_Random_selected,Random_selected)## bring out only number
    filter!(x->x≠Random_selected,NN)
end
println(NN_Random_selected)
save(""*OrginalFilesAddress*"jl_files/InPut_for_jl/NN_Random_selected_Optimization.jld","NN_Random_selected",NN_Random_selected)
#
NN_Random_selected_loaded=load(""*OrginalFilesAddress*"jl_files/InPut_for_jl/NN_Random_selected_Optimization.jld")
NN_Random_selected=NN_Random_selected_loaded["NN_Random_selected"]
println(typeof(NN_Random_selected))
println(NN_Random_selected)


while (true)
    for homeNmber in NN_Random_selected
        global iter_optimization=iter_optimization+1
        global time2= Dates.now()

        println("****Start**** Iteration Number")
        println(iter_optimization)

        println("      ")
        println("      ")
        global Selected_home=[]
        global NotSelected_homes=[]
        append!(Selected_home,homeNmber)## bring out only number
        for j in NN_Random_selected
            if (homeNmber!=j)
                append!(NotSelected_homes,j)## bring out only number
            end
        end
        println("Selected_home")
        println(Selected_home)
        println("      ")
        println("      ")
        println("Not_Selected_home")
        println(NotSelected_homes)
        println("      ")
        println("      ")

        ##
        ####### Eech iteration we will make a new pm accordint to the new "n" and "l_n"
        #######
        global pm = Model(Clarabel.Optimizer)
        set_optimizer_attribute(pm, "verbose", true)
        #set_optimizer_attribute(pm, "tol", 1e-12)
        set_optimizer_attribute(pm, "max_iter", 10)
        set_optimizer_attribute(pm, "time_limit", 60)


        ##
        ########## pm variable
        ########## Depend on selected home
        ##########
        JuMP.@variable(pm, Schedule_Eng_consump[n in Selected_home,a in A,h in H]>=0)
        JuMP.@variable(pm, Percentage_Reduction_Appliences_Scheduled_total_PeakTime_Eng_consump[n in Selected_home,a in A]<=0)

        ##########
        ########## constraint according to equation (14)
        ##########
        JuMP.@constraint(pm,constraint_1[n in Selected_home,a in A],
            Percentage_Reduction_Appliences_Scheduled_total_PeakTime_Eng_consump[n,a] >= - 0.15)

        JuMP.@constraint(pm,constraint_2[n in Selected_home,a in A],
            sum(Schedule_Eng_consump[n,a,S] for S in Applience_Time_Can_be_scheduled[n][a]) == Applience_DetailsFor_home[n][a]["Appliences_Scheduled_total_PeakTime_Eng_consump_Refrence"] + (Percentage_Reduction_Appliences_Scheduled_total_PeakTime_Eng_consump[n,a] * Applience_DetailsFor_home[n][a]["Appliences_Scheduled_total_PeakTime_Eng_consump_Refrence"]))

        JuMP.@constraint(pm,constraint_3[n in Selected_home,a in A,S in Applience_Times_Can_not_be_scheduled[n][a]],
            Schedule_Eng_consump[n,a,S] == Applience_DetailsFor_home[n][a]["Hourly_Applience_load"][S])#Hourly_Applience_DetailsFor_home[n][a][h]

        JuMP.@constraint(pm,constraint_4[n in Selected_home,a in A,S in Applience_Time_Can_be_scheduled[n][a]],
            Schedule_Eng_consump[n,a,S] <= Applience_DetailsFor_home[n][a]["E_MaX"])

        JuMP.@constraint(pm,constraint_5[n in Selected_home,a in A,S in Applience_Time_Can_be_scheduled[n][a]],
            Schedule_Eng_consump[n,a,S] >= Applience_DetailsFor_home[n][a]["E_MiN_ProbablyOffTimeofApplience"] - (Percentage_Reduction_Appliences_Scheduled_total_PeakTime_Eng_consump[n,a]*(2)^1 * Applience_DetailsFor_home[n][a]["E_MaX"]))

        #JuMP.@constraint(pm,constraint_6[n in Selected_home,a in A,S in Homes_E_MaX_hour[n]],(Schedule_Eng_consump[n,a,S]+(sum(Hourly_loads_ForSubscriber[m][S]["Hourly_Net_load_ForSubscriber"] for m in NotSelected_homes))) <= Utility_Network_limitation[S]["Network_Power_Upper_limit"])

        #JuMP.@constraint(pm,constraint_7[n in Selected_home,a in A,S in Homes_E_MaX_hour[n]],(Schedule_Eng_consump[n,a,S]+(sum(Hourly_loads_ForSubscriber[m][S]["Hourly_Net_load_ForSubscriber"] for m in NotSelected_homes))) >= Utility_Network_limitation[S]["Network_Power_Lower_limit"])

            ###### Objective
            ####### according to Quadratic const function seems loads should have Power 2 (^2) but that make our prolem NoTliner? therefore GLPK is not suitable
            JuMP.@objective(pm,Min,0.00001+
                sum(CostFunctionParameters[h]["a_h"]*(sum(sum(Schedule_Eng_consump[n,a,h] for n in Selected_home) for a in A))^2 for h in H)+
                sum(sum(((Percentage_Reduction_Appliences_Scheduled_total_PeakTime_Eng_consump[n,a]) * -0.0000000001) for n in Selected_home) for a in A)+
                sum(CostFunctionParameters[h]["a_h"]*sum(Hourly_loads_ForSubscriber[m][h]["Hourly_ControlAble_load_ForSubscriber"] for m in NotSelected_homes)^2 for h in H))
                # rahman1New sum(CostFunctionParameters[h]["a_h"]*sum(Hourly_loads_ForSubscriber[m][h]["Hourly_ControlAble_load_ForSubscriber"] for m in NotSelected_homes)^2 for h in H))
                # asli sum(CostFunctionParameters[h]["a_h"]*(sum(Hourly_loads_ForSubscriber[m][h]["Hourly_ControlAble_load_ForSubscriber"] for m in NotSelected_homes))^2 for h in H))

            #######
            ####### Result
            #######
            Result = optimize!(pm) # solve
            #######
            #######
            #######
        print(pm) ### to check problem

        println("   ")
        println("*****    *****")
        println("   ")
        println("*****  Result  *****")
        println("   ")
        println("*****    *****")
        println("   ")

        #solution_summary(pm,verbose=true)
        print(solution_summary(pm,verbose=true))





        #######
        ####### Creating data for plot
        #######
        #######
        println("    ")
        println("    ")
        println("    ")

        global Objectives
        append!(Objectives,JuMP.objective_value(pm))

        #######
        ####### Termination
        ####### Termination
        #######

        if iter_optimization>11
            global ConverRate1=((Objectives[iter_optimization-1]-Objectives[iter_optimization])/Objectives[iter_optimization])*100
            global ConverRate2=((Objectives[iter_optimization-2]-Objectives[iter_optimization-1])/Objectives[iter_optimization-1])*100
            global ConverRate3=((Objectives[iter_optimization-3]-Objectives[iter_optimization-2])/Objectives[iter_optimization-2])*100
            global ConverRate4=((Objectives[iter_optimization-4]-Objectives[iter_optimization-3])/Objectives[iter_optimization-3])*100
            global ConverRate5=((Objectives[iter_optimization-5]-Objectives[iter_optimization-4])/Objectives[iter_optimization-4])*100
            global ConverRate6=((Objectives[iter_optimization-6]-Objectives[iter_optimization-5])/Objectives[iter_optimization-5])*100
            global ConverRate7=((Objectives[iter_optimization-7]-Objectives[iter_optimization-6])/Objectives[iter_optimization-6])*100
            global ConverRate8=((Objectives[iter_optimization-8]-Objectives[iter_optimization-7])/Objectives[iter_optimization-7])*100
            global ConverRate9=((Objectives[iter_optimization-9]-Objectives[iter_optimization-8])/Objectives[iter_optimization-8])*100
            global ConverRate10=((Objectives[iter_optimization-10]-Objectives[iter_optimization-9])/Objectives[iter_optimization-9])*100
            global ConverRate11=((Objectives[iter_optimization-11]-Objectives[iter_optimization-10])/Objectives[iter_optimization-10])*100
        end


        if (ConverRate1<Min_ExpectConvRate && ConverRate2<Min_ExpectConvRate && ConverRate3<Min_ExpectConvRate) ### inittiated frist
            if (ConverRate4<Min_ExpectConvRate && ConverRate5<Min_ExpectConvRate && ConverRate6<Min_ExpectConvRate)
                if (ConverRate7<Min_ExpectConvRate && ConverRate8<Min_ExpectConvRate && ConverRate9<Min_ExpectConvRate) ### inittiated frist
                    if (ConverRate10<Min_ExpectConvRate && ConverRate11<Min_ExpectConvRate && ConverRate12<Min_ExpectConvRate) ### inittiated frist
                        println("   ")
                        println("*****    *****")
                        println("   ")
                        println("*****  Warning  *****")
                        println("   ")
                        println("*****    *****")
                        println("   ")
                        println("Iteration breaked because  ------>>> Convergence Rates are less than expected percentage ------>>>>  ", Min_ExpectConvRate, " %")
                        println("Convergence Rate1 (Objectives[t-1]-Objectives[t])/Objectives[t]) is = ",ConverRate1, " %")
                        global Error=true
                        break

                    end
                end
            end
        end

        ### stop reapaing
        println("*****  ConverRates list  *****")

        #println(ConverRates)


        if iter_optimization==1
            ConverRate=0.001
            global ConverRates
            append!(ConverRates,ConverRate)
        elseif iter_optimization > 1
            ConverRate=((Objectives[iter_optimization-1]-Objectives[iter_optimization])/Objectives[iter_optimization])*100
            global ConverRates
            append!(ConverRates,ConverRate)
            println("*****  ConverRates list  *****")
            #println(ConverRates)
            #println(length(ConverRates))
            global Repeat_ConverRate_list=[]
            global Repeat_ConverRate=0
            for i in 1:length(ConverRates)-1
                if ConverRates[i]==ConverRate
                    global Repeat_ConverRate=Repeat_ConverRate+1
                    #global Repeat_ConverRate_list
                    append!(Repeat_ConverRate_list,ConverRate)
                    if Repeat_ConverRate==Max_Repeat_ConverRate
                        objective_value_Min=minimum(Objectives)
                        objective_value_Min_Iter=0
                        for Min_Iter in 1:1:iter_optimization
                                if (Objectives[Min_Iter]==objective_value_Min)#find times which is close to peak time
                                    objective_value_Min_Iter=Min_Iter
                                    break
                                end
                        end
                        println("   ")
                        println("*****    *****")
                        println("   ")
                        println("*****  Warning  *****")
                        println("   ")
                        println("*****  Repeat_ConverRate_list  *****")
                        println("   ")
                        NumberOfReapeat=length(Repeat_ConverRate_list)
                        println(Repeat_ConverRate_list)
                        println("   ")
                        println("Iteration breaked because  ------>>> Convergence Rate is Repeated ------>>>>  ", NumberOfReapeat, " times")
                        #println("Iteration  ",i, " had same Convergence Rate")
                        global NecesseryItertionNumber=objective_value_Min_Iter
                        println("   ")
                        println("   ")
                        println("   ")
                        println("Minimum Itertion Number * We needed * for Min Objective ---->>>    ",NecesseryItertionNumber)
                        println("   ")
                        println("Min Objective is ---->>>    ",objective_value_Min)
                        global Error=true
                        break
                    end
                end
            end
        end


        if termination_status(pm) != OPTIMAL
            println("   ")
            println("*****    *****")
            println("   ")
            println("*****  Warning  *****")
            println("   ")
            println("*****    *****")
            println("   ")
            println(" Iteration breaked because  ------>>> Reach to infisibility  1")
            ############
            #########   update
            ############

            println("    ")
            println("    ")
            println("    ")
            Str_iter_optimization=string(iter_optimization)

                for n in Selected_home
                    for a in A
                        Applience_DetailsFor_home[n][a]["Iter_"*Str_iter_optimization*"_Selected_Percent_LoadReduction"]= value(Percentage_Reduction_Appliences_Scheduled_total_PeakTime_Eng_consump[n,a])*-100
                        Applience_DetailsFor_home[n][a]["Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction"]= value(Percentage_Reduction_Appliences_Scheduled_total_PeakTime_Eng_consump[n,a])*-100
                        ##
                        UpdateHelper2=Applience_DetailsFor_home[n][a]["Appliences_Scheduled_total_PeakTime_Eng_consump_Refrence"]
                        Applience_DetailsFor_home[n][a]["Iter_"*Str_iter_optimization*"_Appliences_total_PeakTime_Eng_cons_updated"]= UpdateHelper2 + UpdateHelper2 * Applience_DetailsFor_home[n][a]["Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction"]/-100
                        Applience_DetailsFor_home[n][a]["Appliences_Scheduled_total_PeakTime_Eng_consump_updated"]= UpdateHelper2 + UpdateHelper2 * Applience_DetailsFor_home[n][a]["Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction"]/-100
                        #Applience_DetailsFor_home[n][a]["Appliences_Scheduled_total_PeakTime_Eng_consump_updated"]= UpdateHelper2 + UpdateHelper2 * Applience_DetailsFor_home[n][a]["Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction"]/-100
                    end
                end
            println(" Iteration breaked because  ------>>> Reach to infisibility  2")

            global Error=true
            break
        end

        global period=time2-time1
        global SecPeriod=Dates.value(period)/1000
        if SecPeriod >= 300#### 5 min
            println("   ")
            println("*****    *****")
            println("   ")
            println("*****  Warning  *****")
            println("   ")
            println("*****    *****")
            println("   ")
            println(" Iteration breaked because ---- time_limit -->>> Reach to  time_limitaion of Optimization problem")
            global Error=true
            break
        end


        if (Error==true)###### global is not required here
            break
        end

        #######
        ####### Updating X_n according to the new solution
        ####### According to algorithem ln is input, hence
        #######
        for n in Selected_home
            for h in H
                         Temp_Hourly_Enrgy_ForSubscriber=0
                         for a in A
                            Hourly_Applience_DetailsFor_home[n][a][h]=value(Schedule_Eng_consump[n,a,h])
                            Temp_Hourly_Enrgy_ForSubscriber=Temp_Hourly_Enrgy_ForSubscriber+Hourly_Applience_DetailsFor_home[n][a][h]
                         end
                         Hourly_loads_ForSubscriber[n][h]["Optimized_Hourly_ControlAble_load_ForSubscriber"]=Temp_Hourly_Enrgy_ForSubscriber
            end
        end




        #######
        #######             UPDATE          #######     UPDATE
        #######

        ##### Compare Hourly_Enrgy_ForSubscriber in each iteration
        #### in Eeach iteration only update Selected home

        for n in Selected_home
            Temp_1=0
            Temp_2=0
            Temp_3=0
            for h in H
                Temp_1=Hourly_loads_ForSubscriber[n][h]["Hourly_ControlAble_load_ForSubscriber"]
                Temp_2=Hourly_loads_ForSubscriber[n][h]["Optimized_Hourly_ControlAble_load_ForSubscriber"]
                if (Temp_1==Temp_2)
                    continue
                else
                    Hourly_loads_ForSubscriber[n][h]["Hourly_ControlAble_load_ForSubscriber"] =Temp_2
                    Temp_3=Hourly_loads_ForSubscriber[n][h]["Hourly_UnControlAble_load_ForSubscriber"]
                    #Hourly_loads_ForSubscriber[n][h]["Hourly_Net_load_ForSubscriber"]=Temp_2+Temp_3
                    Hourly_loads_ForSubscriber[n][h]["Optimized_Hourly_Net_load_ForSubscriber"]=Temp_2+Temp_3

                end
            end
        end



        ############
        #########   update
        ############

        println("    ")
        println("    ")
        println("    ")
        Str_iter_optimization=string(iter_optimization)
        if termination_status(pm) == OPTIMAL
            for n in Selected_home
                for a in A
                    Applience_DetailsFor_home[n][a]["Iter_"*Str_iter_optimization*"_Selected_Percent_LoadReduction"]= value(Percentage_Reduction_Appliences_Scheduled_total_PeakTime_Eng_consump[n,a])*-100
                    Applience_DetailsFor_home[n][a]["Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction"]= value(Percentage_Reduction_Appliences_Scheduled_total_PeakTime_Eng_consump[n,a])*-100
                    ##
                    UpdateHelper2=Applience_DetailsFor_home[n][a]["Appliences_Scheduled_total_PeakTime_Eng_consump_Refrence"]
                    Applience_DetailsFor_home[n][a]["Iter_"*Str_iter_optimization*"_Appliences_total_PeakTime_Eng_cons_updated"]= UpdateHelper2 + UpdateHelper2 * Applience_DetailsFor_home[n][a]["Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction"]/-100
                    Applience_DetailsFor_home[n][a]["Appliences_Scheduled_total_PeakTime_Eng_consump_updated"]= UpdateHelper2 + UpdateHelper2 * Applience_DetailsFor_home[n][a]["Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction"]/-100
                    #Applience_DetailsFor_home[n][a]["Appliences_Scheduled_total_PeakTime_Eng_consump_updated"]= UpdateHelper2 + UpdateHelper2 * Applience_DetailsFor_home[n][a]["Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction"]/-100
                end
            end
        end

        println("*****Finish*****Iteration Number")
        println(iter_optimization)

        println("    ")
        println("    ")
        println("    ")

     #######final end Hoemes negotionsion
     #### This is for iteration.
    end


    if (Error==true)###### global is not required here


        println("    ")
        println("    ")
        println("Diuration of Code Running  =    ", SecPeriod)
        println("  ")
        println("  ")
        println("  ")
        println("Number of iteration passed through  =    ",iter_optimization)
        println("  ")
        println("  ")
        println("  ")
        println("  ")
        println("Convegences list  =    ",ConverRates)
        println("  ")
        println("  ")
        println("  ")

        break
    end

    ##### final end for iter_optimization
end


#####termination_status(pm)=
#####termination_status_Code=MOI.LOCALLY_SOLVED
#####MOI.LOCALLY_SOLVED

## Plot Objective
NN=[1,5,6,7,8,9,10,11,12,13,14,15] ## list of subcribers(homes)

x_plot_objec = 1:iter_optimization# These are the plotting data

objective=plot(x_plot_objec, Objectives, xlabel="Number of iter_optimization ", xticks=0:1:iter_optimization,ylabel="Cost of Energy kWh",title="Objectives" , size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
savefig(objective,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Objective_Optimization.png")


### x_plot_objec_Necessery = 1:NecesseryItertionNumber# These are the plotting data
### Objectives_Necessery=[]
### for i in 1:NecesseryItertionNumber
###    append!(Objectives_Necessery,Objectives[i])
### end
### objective_Necessery=plot(x_plot_objec_Necessery, Objectives_Necessery, xlabel="Number of iter_optimization ", xticks=0:1:NecesseryItertionNumber,ylabel="Cost of Energy kWh", yticks=0:500:40000,title="Objectives" , size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
### savefig(objective_Necessery,"objective_Necessery_Optimization.png")



##
# Getting new information after optimization, etting new information after optimization, etting new information after optimization

Day_Control_Able_PeakTime_Load_Optimized=Dict()
for n in N
    temp_1=0
    for a in A
        temp_1=temp_1+Applience_DetailsFor_home[n][a]["Appliences_Scheduled_total_PeakTime_Eng_consump_updated"]
    end
    Day_Control_Able_PeakTime_Load_Optimized[n]=temp_1
end


## Add optimized information

for n in N
        for a in A
            for h in H
                Hourly_loads_ForSubscriber[n][h]["Hourly_HVAC_load_ForSubscriber_Optimized"]=0.0
                if a==1
                    Hourly_loads_ForSubscriber[n][h]["Hourly_HVAC_load_ForSubscriber_Optimized"]= Hourly_Applience_DetailsFor_home[n][1][h]+Hourly_loads_ForSubscriber[n][h]["Hourly_HVAC_load_ForSubscriber_Optimized"]
                elseif a==2
                    Hourly_loads_ForSubscriber[n][h]["Hourly_WaterHeter_load_ForSubscriber_Optimized"]=Hourly_Applience_DetailsFor_home[n][2][h]
                elseif a==3
                    Hourly_loads_ForSubscriber[n][h]["Hourly_DISHWASHER_load_ForSubscriber_Optimized"]=Hourly_Applience_DetailsFor_home[n][3][h]
                end
            end
        end
        Day_load_ForSubscriber[n]["Day_Control_Able_PeakTime_Load_Optimized"]=Day_Control_Able_PeakTime_Load_Optimized[n]
end


##### update information
for n in N
    Temp_1=0
    Temp_2=0
    Temp_3=0
    for h in H
        #Temp_1=Hourly_loads_ForSubscriber[n][h]["Optimized_Hourly_ControlAble_load_ForSubscriber"]
        #Temp_2=Hourly_loads_ForSubscriber[n][h]["Hourly_UnControlAble_load_ForSubscriber"]
        #Hourly_loads_ForSubscriber[n][h]["Hourly_Net_load_ForSubscriber_Optimized"]=Temp_1+Temp_2
        Hourly_loads_ForSubscriber[n][h]["Hourly_Net_load_ForSubscriber_Optimized"]=Hourly_loads_ForSubscriber[n][h]["Optimized_Hourly_Net_load_ForSubscriber"]
        ##
        Temp_3=Temp_3+Hourly_loads_ForSubscriber[n][h]["Hourly_Net_load_ForSubscriber_Optimized"]
    end
    Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber_Optimized"]=Temp_3
    Day_load_ForSubscriber[n]["Day_ControlAble_load_ForSubscriber_Optimized"]=Day_Control_Able_NoT_PeakTime_Load[n]+Day_Control_Able_PeakTime_Load_Optimized[n]
end


Day_load_ForSubscriber_Control_Able_PeakTime_Optimized_list=zeros(length(NN))
Day_load_ForSubscriber_ControlAble_load_Optimized_list=zeros(length(NN))
Day_load_ForSubscriber_Net_load_Optimized_list=zeros(length(NN))



iter_Day_load_ForSubscriber=0
for n in N
    global iter_Day_load_ForSubscriber=iter_Day_load_ForSubscriber+1
    Day_load_ForSubscriber_Control_Able_PeakTime_Optimized_list[iter_Day_load_ForSubscriber]=Day_load_ForSubscriber[n]["Day_Control_Able_PeakTime_Load_Optimized"]
    Day_load_ForSubscriber_ControlAble_load_Optimized_list[iter_Day_load_ForSubscriber]=Day_load_ForSubscriber[n]["Day_ControlAble_load_ForSubscriber_Optimized"]
    Day_load_ForSubscriber_Net_load_Optimized_list[iter_Day_load_ForSubscriber]=Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber_Optimized"]
end
#Plot_Day_load_ForSubscriber_Control_Able_PeakTime=plot(scatter(NN,[210,210,210,210], color=0:3,mode="markers"),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh", yticks=0:10:800,title=" Day_ControlAble_PeakTime", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
Plot_Day_load_ForSubscriber_Control_Able_PeakTime_Optimized=plot(scatter(NN, Day_load_ForSubscriber_Control_Able_PeakTime_Optimized_list,  color=cols,mode="markers",markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh", title=" ControlAble_PeakTime_Optimized", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
Plot_Day_load_ForSubscriber_ControlAble_load_Optimized=plot(scatter(NN, Day_load_ForSubscriber_ControlAble_load_Optimized_list,  color=cols,mode="markers",markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh", title="Day_ControlAble_load_Optimized", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
Plot_Day_load_ForSubscriber_Net_load_Optimized_Optimized=plot(scatter(NN, Day_load_ForSubscriber_Net_load_Optimized_list, color=cols,mode="markers",markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh", title=" Day Net_load_Optimized ", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)

Load_AfterApplyCode=plot(Plot_Day_load_ForSubscriber_Control_Able_PeakTime_Optimized,Plot_Day_load_ForSubscriber_Control_Able_NoT_PeakTime)
#savefig(Load_AfterApplyCode,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_Load_AfterApply_Optimization.png")


##
Hourly_Net_load_Optimized=Dict()
Hourly_ControlAble_load_Optimized=Dict()
Hourly_HVAC_load_Optimized=Dict()
Hourly_WaterHeter_load_Optimized=Dict()
Hourly_DISHWASHER_load_Optimized=Dict()
Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction=Dict()

for n in N
    Hourly_Net_load_Optimized[n]=[]
    Hourly_ControlAble_load_Optimized[n]=[]
    Hourly_HVAC_load_Optimized[n]=[]
    Hourly_WaterHeter_load_Optimized[n]=[]
    Hourly_DISHWASHER_load_Optimized[n]=[]
    Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction[n]=Dict()
    for h in H
        append!(Hourly_Net_load_Optimized[n],Hourly_loads_ForSubscriber[n][h]["Hourly_Net_load_ForSubscriber_Optimized"])
        append!(Hourly_ControlAble_load_Optimized[n],Hourly_loads_ForSubscriber[n][h]["Optimized_Hourly_ControlAble_load_ForSubscriber"])
        append!(Hourly_HVAC_load_Optimized[n],Hourly_loads_ForSubscriber[n][h]["Hourly_ControlAble_load_ForSubscriber"])
        #append!(Hourly_WaterHeter_load_Optimized[n],Hourly_loads_ForSubscriber[n][h]["Hourly_WaterHeter_load_ForSubscriber_Optimized"])
        #append!(Hourly_DISHWASHER_load_Optimized[n],Hourly_loads_ForSubscriber[n][h]["Hourly_DISHWASHER_load_ForSubscriber_Optimized"])

    end
    for a in A
        Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction[n][a]=Applience_DetailsFor_home[n][a]["Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction"]
        Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction[n,a]=Applience_DetailsFor_home[n][a]["Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction"]
    end
    Day_load_ForSubscriber[n]["Day_Net_load_Reduction_After_Optimization"]=Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber"]- Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber_Optimized"]
    Day_load_ForSubscriber[n]["Percent_Day_Control_Able_PeakTime_Reduction"]=(1-(Day_load_ForSubscriber[n]["Day_Control_Able_PeakTime_Load_Optimized"]/Day_load_ForSubscriber[n]["Day_Control_Able_PeakTime_Load"]))*100
    Day_load_ForSubscriber[n]["Percent_Day_ControlAble_load_ForSubscriber_Reduction"]=(1-(Day_load_ForSubscriber[n]["Day_ControlAble_load_ForSubscriber_Optimized"]/Day_load_ForSubscriber[n]["Day_ControlAble_load_ForSubscriber"]))*100
    Day_load_ForSubscriber[n]["Percent_Day_Net_load_ForSubscriber_Reduction"]=(1-(Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber_Optimized"]/Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber"]))*100

end

Plot_Hourly_ControlAble_load_Optimized_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for
Plot_Hourly_Net_load_Optimized_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for

iter_load_Optimized_list=0
Hourly_Aggregate_Net_load_Optimized=zeros(length(NH))
for n in N
    global iter_load_Optimized_list=iter_load_Optimized_list+1
    global Hourly_Aggregate_Net_load_Optimized=Hourly_Aggregate_Net_load_Optimized+Hourly_Net_load_Optimized[n]
    Plot_Hourly_ControlAble_load_Optimized_list[iter_load_Optimized_list]=Hourly_ControlAble_load_Optimized[n]
    Plot_Hourly_Net_load_Optimized_list[iter_load_Optimized_list]=Hourly_Net_load_Optimized[n]
end

Plot_Hourly_ControlAble_load_Optimized=plot(NH, [Plot_Hourly_ControlAble_load_Optimized_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh", title="ControlAble loads Optimized", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
Plot_Hourly_Net_load_Optimized=plot(NH, [Plot_Hourly_Net_load_Optimized_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="Optimized Net loads", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
Plot_Hourly_Aggregate_Net_load_Optimized=plot(NH, [Hourly_Aggregate_Net_load_Optimized],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="Hourly_Aggregate_Net_load loads", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)

VPP_Net_load_Max=maximum(Hourly_Aggregate_Net_load)
VPP_Net_load_Mean=mean(Hourly_Aggregate_Net_load)
VPP_PAR=VPP_Net_load_Max/VPP_Net_load_Mean
#
VPP_Net_load_Optimized_Max=maximum(Hourly_Aggregate_Net_load_Optimized)
VPP_Net_load_Optimized_Mean=mean(Hourly_Aggregate_Net_load_Optimized)
VPP_PAR_Optimized=VPP_Net_load_Optimized_Max/VPP_Net_load_Optimized_Mean

Day_Percent_Control_Able_total_PeakTimeLoad_Reduction_for_Each_Applience_list=zeros(length(NN))
Day_Percent_ControlAble_load_ForSubscriber_Reduction_list=zeros(length(NN))
Day_Percent_Net_load_ForSubscriber_Reduction_list=zeros(length(NN))

iter_Day_load_ForSubscriber=0
for n in N
    global iter_Day_load_ForSubscriber=iter_Day_load_ForSubscriber+1
    Day_Percent_Control_Able_total_PeakTimeLoad_Reduction_for_Each_Applience_list[iter_Day_load_ForSubscriber]=Day_load_ForSubscriber[n]["Percent_Day_Control_Able_PeakTime_Reduction"]
    Day_Percent_ControlAble_load_ForSubscriber_Reduction_list[iter_Day_load_ForSubscriber]=Day_load_ForSubscriber[n]["Percent_Day_ControlAble_load_ForSubscriber_Reduction"]
    Day_Percent_Net_load_ForSubscriber_Reduction_list[iter_Day_load_ForSubscriber]=Day_load_ForSubscriber[n]["Percent_Day_Net_load_ForSubscriber_Reduction"]
end
#Plot_Day_load_ForSubscriber_Control_Able_PeakTime=plot(scatter(NN,[210,210,210,210], color=0:3,mode="markers"),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh", yticks=0:10:800,title=" Day_ControlAble_PeakTime", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
Plot_Day_Percent_Control_Able_total_PeakTimeLoad_Reduction_for_Each_Applience_Optimized=plot(scatter(NN, Day_Percent_Control_Able_total_PeakTimeLoad_Reduction_for_Each_Applience_list, color=cols,mode="markers",markersize = 20),xlabel="Homes", xticks=0:1:24,ylabel="Percent [%]", size=(2000,1000),lw=6, legend = false, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm,gridlinewidth = 3)
Plot_Day_Percent_ControlAble_load_ForSubscriber_Reduction_Optimized=plot(scatter(NN, Day_Percent_ControlAble_load_ForSubscriber_Reduction_list,  color=cols,mode="markers",markersize = 20),xlabel="Homes", xticks=0:1:24,ylabel="Percent [%]", size=(2000,1000),lw=6, legend = false, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm,gridlinewidth = 3)
Plot_Day_Percent_Net_load_ForSubscriber_Reduction_Optimized=plot(scatter(NN, Day_Percent_Net_load_ForSubscriber_Reduction_list,  color=cols,mode="markers",markersize = 20),xlabel="Homes", xticks=0:1:24,ylabel="Percent [%]", size=(2000,1000),lw=6, legend = false, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm,gridlinewidth = 3)


## create  CSV   ControlAble_load_Optimized, this version is eqaul to HVAC
Hourly_ControlAble_load_Optimized_df = DataFrame()
for (key, value) in Hourly_ControlAble_load_Optimized
       Str_n=string(key)
       Hourly_ControlAble_load_Optimized_df[!,"House_"*Str_n*""] = value
end
if 1==verbose_Figs  println(Hourly_ControlAble_load_Optimized_df) end
CSV.write(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/HVAC_HouseS_EnergyUse_Optimized.csv",Hourly_ControlAble_load_Optimized_df)




## comperation      comperation         comperation

Hourly_ControlAble_load_Comperation=plot(Plot_Hourly_ControlAble_load,Plot_Hourly_ControlAble_load_Optimized)
savefig(Hourly_ControlAble_load_Comperation,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Hourly_Comperation_ControlAble_load_AfterAndBefore_Optimization.png")

Hourly_Net_load_Comperation=plot(Plot_Hourly_Net_load,Plot_Hourly_Net_load_Optimized)
savefig(Hourly_Net_load_Comperation,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Hourly_Comperation_Net_load_AfterAndBefore_Optimization.png")


Hourly_NetAndControlAble_load_load_Comperation=plot(Plot_Hourly_ControlAble_load_Optimized,Plot_Hourly_Net_load_Optimized)
savefig(Hourly_NetAndControlAble_load_load_Comperation,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Hourly_Comperation_ControlAble_&Netloads_AfterAndBefore_Optimization.png")

#Hourly_Aggregate_Net_loads_Optimized_Comperation=plot(NH, [Hourly_Aggregate_Net_load, Hourly_Aggregate_Net_load_Optimized],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="Hourly_Aggregate_Net_load loads", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
Hourly_Aggregate_Net_loads_Optimized_Comperation=plot(NH, [Hourly_Aggregate_Net_load, Hourly_Aggregate_Net_load_Optimized] , color=[:red :black], linewidth=[16 10],linestyle = [:dot :solid], label=["Predicted" "Optimized"],xlabel="24 Hours [h]", xticks=0:2:24,yticks=0:5:43,ylabel="Energy Use [kWh]",legend=:bottom, size=(2000,1000), titlefontsize=35, legendfontsize=35, guidefontsize=35, legendtitlefontsize=35,tickfontsize=35,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm,gridlinewidth = 3)
savefig(Hourly_Aggregate_Net_loads_Optimized_Comperation,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Hourly_Comperation_Aggregate_loads_AfterAndBefore_Optimization.png")

Day_load_Control_Able_PeakTime_Comperation=plot(Plot_Day_load_ForSubscriber_Control_Able_PeakTime,Plot_Day_load_ForSubscriber_Control_Able_PeakTime_Optimized)
savefig(Day_load_Control_Able_PeakTime_Comperation,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_load_Control_Able_PeakTime_Comperation_Optimization.png")

Day_load_ControlAble_load_Comperation=plot(Plot_Day_load_ForSubscriber_ControlAble_load,Plot_Day_load_ForSubscriber_ControlAble_load_Optimized)
savefig(Day_load_ControlAble_load_Comperation,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_load_ControlAble_load_Comperation_Optimization.png")

Day_Percent_Control_Able_total_PeakTimeLoad_Reduction_for_Each_Applience=(Plot_Day_Percent_Control_Able_total_PeakTimeLoad_Reduction_for_Each_Applience_Optimized)
savefig(Day_Percent_Control_Able_total_PeakTimeLoad_Reduction_for_Each_Applience,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_Percent_Control_Able_total_PeakTimeLoad_Reduction_for_Each_Applience_Optimization.png")

#Day_Percent_ControlAble_load_ForSubscriber_Reduction_for_Each_Applience=(Plot_Day_Percent_ControlAble_load_ForSubscriber_Reduction_Optimized)
#savefig(Day_Percent_ControlAble_load_ForSubscriber_Reduction_for_Each_Applience,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_Percent_ControlAble_load_ForSubscriber_Reduction_for_Each_Applience_Optimization.png")

#Day_Percent_Net_load_ForSubscriber_Reduction_for_Each_Applience=(Plot_Day_Percent_Net_load_ForSubscriber_Reduction_Optimized)
#savefig(Day_Percent_Net_load_ForSubscriber_Reduction_for_Each_Applience,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_Percent_Net_load_ForSubscriber_Reduction_for_Each_Applience_Optimization.png")

#sum(HondaHome_Net_load)
##



Day_Net_load_ForSubscriber=zeros(length(NN))
Day_Net_load_ForSubscriber_After_Optimization=zeros(length(NN))
Day_Percent_Net_load_AllHouses_Reduction_After_Optimization=zeros(length(NN))
#
Day_ControlAble_load_ForSubscriber=zeros(length(NN))
Day_ControlAble_load_ForSubscriber_After_Optimization=zeros(length(NN))
Day_Percent_ControlAble_load_AllHouses_Reduction_After_Optimization=zeros(length(NN))
############
Day_Net_load_ForSubscriber_AllHouses=0
Day_Net_load_ForSubscriber_After_Optimization_AllHouses=0

Day_ControlAble_load_ForSubscriber_AllHouses=0
Day_ControlAble_load_ForSubscriber_After_Optimization_AllHouses=0
iter_Day_load_ForSubscriber_AllHouses=0

for n in N
    global iter_Day_load_ForSubscriber_AllHouses=iter_Day_load_ForSubscriber_AllHouses+1
    global Day_Net_load_ForSubscriber_AllHouses=Day_Net_load_ForSubscriber_AllHouses
    global Day_Net_load_ForSubscriber_After_Optimization_AllHouses=Day_Net_load_ForSubscriber_After_Optimization_AllHouses
    global Day_ControlAble_load_ForSubscriber_AllHouses=Day_ControlAble_load_ForSubscriber_AllHouses
    global Day_ControlAble_load_ForSubscriber_After_Optimization_AllHouses=Day_ControlAble_load_ForSubscriber_After_Optimization_AllHouses
    Day_Net_load_ForSubscriber[iter_Day_load_ForSubscriber_AllHouses]=Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber"]
    Day_Net_load_ForSubscriber_AllHouses=Day_Net_load_ForSubscriber_AllHouses+Day_Net_load_ForSubscriber[iter_Day_load_ForSubscriber_AllHouses]
    Day_Net_load_ForSubscriber_After_Optimization[iter_Day_load_ForSubscriber_AllHouses]=Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber_Optimized"]
    Day_Net_load_ForSubscriber_After_Optimization_AllHouses=Day_Net_load_ForSubscriber_After_Optimization_AllHouses+Day_Net_load_ForSubscriber_After_Optimization[iter_Day_load_ForSubscriber_AllHouses]
    Day_Percent_Net_load_AllHouses_Reduction_After_Optimization[iter_Day_load_ForSubscriber_AllHouses]=((Day_Net_load_ForSubscriber[iter_Day_load_ForSubscriber_AllHouses]-Day_Net_load_ForSubscriber_After_Optimization[iter_Day_load_ForSubscriber_AllHouses])/Day_Net_load_ForSubscriber[iter_Day_load_ForSubscriber_AllHouses])*100
    #
    Day_ControlAble_load_ForSubscriber[iter_Day_load_ForSubscriber_AllHouses]=Day_load_ForSubscriber[n]["Day_ControlAble_load_ForSubscriber"]
    Day_ControlAble_load_ForSubscriber_AllHouses=Day_ControlAble_load_ForSubscriber_AllHouses+Day_ControlAble_load_ForSubscriber[iter_Day_load_ForSubscriber_AllHouses]
    Day_ControlAble_load_ForSubscriber_After_Optimization[iter_Day_load_ForSubscriber_AllHouses]=Day_load_ForSubscriber[n]["Day_ControlAble_load_ForSubscriber_Optimized"]
    Day_ControlAble_load_ForSubscriber_After_Optimization_AllHouses=Day_ControlAble_load_ForSubscriber_After_Optimization_AllHouses+Day_ControlAble_load_ForSubscriber_After_Optimization[iter_Day_load_ForSubscriber_AllHouses]
    Day_Percent_ControlAble_load_AllHouses_Reduction_After_Optimization[iter_Day_load_ForSubscriber_AllHouses]=((Day_ControlAble_load_ForSubscriber[iter_Day_load_ForSubscriber_AllHouses]-Day_ControlAble_load_ForSubscriber_After_Optimization[iter_Day_load_ForSubscriber_AllHouses])/Day_ControlAble_load_ForSubscriber[iter_Day_load_ForSubscriber_AllHouses])*100
end


###############
Plot_Day_Percent_Net_load_AllHouses_Reduction_After_Optimization=plot(scatter(NN, Day_Percent_Net_load_AllHouses_Reduction_After_Optimization, color=cols,mode="markers",markersize = 20),xlabel="Homes", xticks=0:1:24,ylabel="Percent [%]", size=(2000,1000),lw=6, legend = false, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm,gridlinewidth = 3)
savefig(Plot_Day_Percent_Net_load_AllHouses_Reduction_After_Optimization,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_Percent_Net_load_Reduction_After_Optimization.png")

Plot_Day_Percent_ControlAble_load_AllHouses_Reduction_After_Optimization=plot(scatter(NN, Day_Percent_ControlAble_load_AllHouses_Reduction_After_Optimization, color=cols,mode="markers",markersize = 20),xlabel="Homes", xticks=0:1:24,ylabel="Percent [%]", size=(2000,1000),lw=6, legend = false, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm,gridlinewidth = 3)
savefig(Plot_Day_Percent_ControlAble_load_AllHouses_Reduction_After_Optimization,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_Percent_ControlAble_load_Reduction_After_Optimization.png")




for n in N
    Str_n=string(n)

    Day_ControlAble_load_Cost_temp=0
    Day_ControlAble_load_ForSubscriber_Cost_After_Optimization_temp=0

    Day_Net_load_Cost_temp=0
    Day_Net_load_ForSubscriber_Cost_After_Optimization_temp=0
    for h in H
        Hourly_ControlAble_load_Cost_temp=0
        Hourly_ControlAble_load_Cost_After_Optimization_temp=0
        #
        Hourly_Net_load_Cost_temp=0
        Hourly_Net_load_Cost_After_Optimization_temp=0
        ################
        Hourly_ControlAble_load_Cost_temp=(CostFunctionParameters[h]["a_h"]*(ControlAble_load[n][h])^2 )
        Hourly_loads_ForSubscriber[n][h]["Hourly_ControlAble_load_Cost_ForSubscriber"]=Hourly_ControlAble_load_Cost_temp
        Day_ControlAble_load_Cost_temp=Day_ControlAble_load_Cost_temp+Hourly_ControlAble_load_Cost_temp
        ##
        Hourly_ControlAble_load_Cost_After_Optimization_temp=(CostFunctionParameters[h]["a_h"]*(Hourly_ControlAble_load_Optimized[n][h])^2 )
        Hourly_loads_ForSubscriber[n][h]["Hourly_ControlAble_load_Cost_ForSubscriber_After_Optimization"]=Hourly_ControlAble_load_Cost_After_Optimization_temp
        Day_ControlAble_load_ForSubscriber_Cost_After_Optimization_temp=Day_ControlAble_load_ForSubscriber_Cost_After_Optimization_temp+Hourly_ControlAble_load_Cost_After_Optimization_temp
        ################
        Hourly_Net_load_Cost_temp=(CostFunctionParameters[h]["a_h"]*(Net_load[n][h])^2 )
        Hourly_loads_ForSubscriber[n][h]["Hourly_Net_load_Cost_ForSubscriber"]=Hourly_Net_load_Cost_temp
        Day_Net_load_Cost_temp=Day_Net_load_Cost_temp+Hourly_Net_load_Cost_temp
        ##
        Hourly_Net_load_Cost_After_Optimization_temp=(CostFunctionParameters[h]["a_h"]*(Hourly_Net_load_Optimized[n][h])^2 )
        Hourly_loads_ForSubscriber[n][h]["Hourly_Net_load_Cost_ForSubscriber_After_Optimization"]=Hourly_Net_load_Cost_After_Optimization_temp
        Day_Net_load_ForSubscriber_Cost_After_Optimization_temp=Day_Net_load_ForSubscriber_Cost_After_Optimization_temp+Hourly_Net_load_Cost_After_Optimization_temp
    end
    #println("House_"*Str_n*" Cost_initial = ",Day_Net_load_Cost_temp)
    Day_load_ForSubscriber[n]["Day_Net_load_Cost"]=Day_Net_load_Cost_temp
    #println("House_"*Str_n*" Cost_After_Optimization = ",Day_Net_load_ForSubscriber_Cost_After_Optimization_temp)
    Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber_Cost_After_Optimization"]=Day_Net_load_ForSubscriber_Cost_After_Optimization_temp
    #
    Day_load_ForSubscriber[n]["Day_ControlAble_load_Cost"]=Day_ControlAble_load_Cost_temp
    Day_load_ForSubscriber[n]["Day_ControlAble_load_ForSubscriber_Cost_After_Optimization"]=Day_ControlAble_load_ForSubscriber_Cost_After_Optimization_temp
end



Day_Net_load_ForSubscriber_Cost=zeros(length(NN))
Day_Net_load_ForSubscriber_Cost_After_Optimization=zeros(length(NN))
Day_Percent_Net_load_Cost_Reduction_After_Optimization=zeros(length(NN))
#
Day_ControlAble_load_ForSubscriber_Cost=zeros(length(NN))
Day_ControlAble_load_ForSubscriber_Cost_After_Optimization=zeros(length(NN))
Day_Percent_ControlAble_load_Cost_Reduction_After_Optimization=zeros(length(NN))
############
Day_Net_load_ForSubscriber_Cost_AllHouses=0
Day_Net_load_ForSubscriber_Cost_After_Optimization_AllHouses=0

Day_ControlAble_load_ForSubscriber_Cost_AllHouses=0
Day_ControlAble_load_ForSubscriber_Cost_After_Optimization_AllHouses=0

iter_Day_load_ForSubscriber_Cost=0
for n in N
    global iter_Day_load_ForSubscriber_Cost=iter_Day_load_ForSubscriber_Cost+1
    global Day_Net_load_ForSubscriber_Cost_AllHouses=Day_Net_load_ForSubscriber_Cost_AllHouses
    global Day_Net_load_ForSubscriber_Cost_After_Optimization_AllHouses=Day_Net_load_ForSubscriber_Cost_After_Optimization_AllHouses
    global Day_ControlAble_load_ForSubscriber_Cost_AllHouses=Day_ControlAble_load_ForSubscriber_Cost_AllHouses
    global Day_ControlAble_load_ForSubscriber_Cost_After_Optimization_AllHouses=Day_ControlAble_load_ForSubscriber_Cost_After_Optimization_AllHouses
    Day_Net_load_ForSubscriber_Cost[iter_Day_load_ForSubscriber_Cost]=Day_load_ForSubscriber[n]["Day_Net_load_Cost"]
    Day_Net_load_ForSubscriber_Cost_AllHouses=Day_Net_load_ForSubscriber_Cost_AllHouses+Day_Net_load_ForSubscriber_Cost[iter_Day_load_ForSubscriber_Cost]
    Day_Net_load_ForSubscriber_Cost_After_Optimization[iter_Day_load_ForSubscriber_Cost]=Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber_Cost_After_Optimization"]
    Day_Net_load_ForSubscriber_Cost_After_Optimization_AllHouses=Day_Net_load_ForSubscriber_Cost_After_Optimization_AllHouses+Day_Net_load_ForSubscriber_Cost_After_Optimization[iter_Day_load_ForSubscriber_Cost]
    Day_Percent_Net_load_Cost_Reduction_After_Optimization[iter_Day_load_ForSubscriber_Cost]=((Day_Net_load_ForSubscriber_Cost[iter_Day_load_ForSubscriber_Cost]-Day_Net_load_ForSubscriber_Cost_After_Optimization[iter_Day_load_ForSubscriber_Cost])/Day_Net_load_ForSubscriber_Cost[iter_Day_load_ForSubscriber_Cost])*100
    #
    Day_ControlAble_load_ForSubscriber_Cost[iter_Day_load_ForSubscriber_Cost]=Day_load_ForSubscriber[n]["Day_ControlAble_load_Cost"]
    Day_ControlAble_load_ForSubscriber_Cost_AllHouses=Day_ControlAble_load_ForSubscriber_Cost_AllHouses+Day_ControlAble_load_ForSubscriber_Cost[iter_Day_load_ForSubscriber_Cost]
    Day_ControlAble_load_ForSubscriber_Cost_After_Optimization[iter_Day_load_ForSubscriber_Cost]=Day_load_ForSubscriber[n]["Day_ControlAble_load_ForSubscriber_Cost_After_Optimization"]
    Day_ControlAble_load_ForSubscriber_Cost_After_Optimization_AllHouses=Day_ControlAble_load_ForSubscriber_Cost_After_Optimization_AllHouses+Day_ControlAble_load_ForSubscriber_Cost_After_Optimization[iter_Day_load_ForSubscriber_Cost]
    Day_Percent_ControlAble_load_Cost_Reduction_After_Optimization[iter_Day_load_ForSubscriber_Cost]=((Day_ControlAble_load_ForSubscriber_Cost[iter_Day_load_ForSubscriber_Cost]-Day_ControlAble_load_ForSubscriber_Cost_After_Optimization[iter_Day_load_ForSubscriber_Cost])/Day_ControlAble_load_ForSubscriber_Cost[iter_Day_load_ForSubscriber_Cost])*100
end



###############
Plot_Day_Percent_Net_load_Cost_Reduction_After_Optimization=plot(scatter(NN, Day_Percent_Net_load_Cost_Reduction_After_Optimization, color=cols,mode="markers",markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel=" % Cost Reduction",title=" Day_Percent_Net_load_Cost_Reduction_Optimization", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
savefig(Plot_Day_Percent_Net_load_Cost_Reduction_After_Optimization,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Cost_Day_Percent_Net_load_Reduction_After_Optimization.png")

Plot_Day_Percent_ControlAble_load_Cost_Reduction_After_Optimization=plot(scatter(NN, Day_Percent_ControlAble_load_Cost_Reduction_After_Optimization, color=cols,mode="markers",markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel=" % Cost Reduction",title=" Day_Percent_ControlAble_load_Cost_Reduction_Optimization", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm)
savefig(Plot_Day_Percent_ControlAble_load_Cost_Reduction_After_Optimization,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Cost_Day_Percent_ControlAble_load_Reduction_After_Optimization.png")


#####
###################
###################
#####
#####
Hourly_Net_load_Cost_=Dict()
Hourly_Net_load_Cost_After_Optimization_=Dict()
for n in N
    Hourly_Net_load_Cost_[n]=[]
    Hourly_Net_load_Cost_After_Optimization_[n]=[]
    for h in H
        append!(Hourly_Net_load_Cost_[n],Hourly_loads_ForSubscriber[n][h]["Hourly_Net_load_Cost_ForSubscriber"])
        append!(Hourly_Net_load_Cost_After_Optimization_[n],Hourly_loads_ForSubscriber[n][h]["Hourly_Net_load_Cost_ForSubscriber_After_Optimization"])
    end
end


Plot_Hourly_Net_load_Cost_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for
Plot_Hourly_Net_load_Cost_After_Optimization_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for

iter_Hourly_make_net_load_Cost=0
for n in N
    global iter_Hourly_make_net_load_Cost=iter_Hourly_make_net_load_Cost+1
    #
    Plot_Hourly_Net_load_Cost_list[iter_Hourly_make_net_load_Cost]=Hourly_Net_load_Cost_[n]
    Plot_Hourly_Net_load_Cost_After_Optimization_list[iter_Hourly_make_net_load_Cost]=Hourly_Net_load_Cost_After_Optimization_[n]
end

Plot_Hourly_Net_load_Cost_initial=plot(NH, [Plot_Hourly_Net_load_Cost_list],xlabel="Hours", xticks=0:1:24,ylabel="Cost \$Dollar/kWh",title="Net loads", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm, label="")
Plot_Hourly_Net_load_Cost_After_Optimization=plot(NH, [Plot_Hourly_Net_load_Cost_After_Optimization_list],xlabel="Hours", xticks=0:1:24,ylabel="Cost \$Dollar/kWh",title="Net_load_Optimization", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=40, legendtitlefontsize=40,tickfontsize=40,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 20Plots.mm, left_margin= 20Plots.mm, right_margin= 12Plots.mm, label="")
Hourly_Net_load_Cost_Comperation_AfterAndBefore_Optimization=plot(Plot_Hourly_Net_load_Cost_initial,Plot_Hourly_Net_load_Cost_After_Optimization)
savefig(Hourly_Net_load_Cost_Comperation_AfterAndBefore_Optimization,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Cost_Hourly_Comperation_Net_load_AfterAndBefore_Optimization.png")




## new codes ar by Optimization. However, old codes are by Optimized


#=
for n in N
    Str_n=string(n)
    if 1==verbose_Figs  println("House_"*Str_n*"") end
    using PyPlot
    pygui(true)
    fig = figure(figsize=(20,10))
    # use x = linspace(0,2*pi,1000) in Julia 0.6
    NH_PyPlot = range(0; stop=length(NH), length=24)
    PyPlot.plot(NH_PyPlot, Net_load[n], color="red", linewidth=4.0, label ="Net Initial")
    #PyPlot.plot(NH_PyPlot, UnControlAble_load[n], color="green", linewidth=4.0, label ="Uncontroled Initial")
    PyPlot.plot(NH_PyPlot, ControlAble_load[n], color="blue", linewidth=4.0, label ="HVAC Initial")
    #
    PyPlot.plot(NH_PyPlot, Hourly_Net_load_Optimized[n], color="black", linewidth=6.0, label ="Net After_Optimization",linestyle="--")
    #PyPlot.plot(NH_PyPlot, UnControlAble_load_After_Optimization[n], color="magenta", linewidth=6.0, label ="Uncontroled After_Optimization",linestyle=":")
    PyPlot.plot(NH_PyPlot, Hourly_ControlAble_load_Optimized[n], color="purple", linewidth=6.0, label ="HVAC After_Optimization",linestyle="-.")
    #plot( NH, PyPlot_HVAC_Optimization, color='k', label ="HVAC After_Optimization")#cols
    PyPlot.title("Energy Usage [kWh] House_"*Str_n*"_Optimization",fontsize=25)
    #title("Energy Usage [kWh]",fontsize=25)
    PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
    #######PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
    PyPlot.xticks(0:1:24,fontsize=25)
    PyPlot.yticks(fontsize=25)
    PyPlot.grid()
    PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Hourly_Comperation_House_"*Str_n*"_AfterAndBefore_Optimization.png")  ## optional command to save results.
    PyPlot.close(fig)
end
=#

for n in N
    Str_n=string(n)
    if 1==verbose_Figs  println("House_"*Str_n*"") end
    using PyPlot
    pygui(true)
    fig = figure(figsize=(20,10))
    # use x = linspace(0,2*pi,1000) in Julia 0.6
    NH_PyPlot = range(0; stop=length(NH), length=24)
    PyPlot.plot(NH_PyPlot, Net_load[n], color="red", linewidth=6.5, label ="net Predicted")
    #PyPlot.plot(NH_PyPlot, UnControlAble_load[n], color="green", linewidth=4.0, label ="Uncontroled Initial")
    PyPlot.plot(NH_PyPlot, ControlAble_load[n], color="blue", linewidth=6.5, label ="HVAC Predicted")
    #
    PyPlot.plot(NH_PyPlot, Hourly_Net_load_Optimized[n], color="black", linewidth=7.5, label ="net Optimized",linestyle="--")
    #PyPlot.plot(NH_PyPlot, UnControlAble_load_After_Optimization[n], color="magenta", linewidth=6.0, label ="Uncontroled After_Optimization",linestyle=":")
    PyPlot.plot(NH_PyPlot, Hourly_ControlAble_load_Optimized[n], color="purple", linewidth=7.5, label ="HVAC Optimized",linestyle="-.")
    #plot( NH, PyPlot_HVAC_Optimization, color='k', label ="HVAC After_Optimization")#cols
    xlabel("24 Hours [h]",fontsize=35)
    ylabel("Energy Use [kWh]",fontsize=35)
    #PyPlot.title("Energy Use [kWh] House_"*Str_n*"_Optimization",fontsize=25)
    #title("Energy Usage [kWh]",fontsize=25)
    PyPlot.legend(loc="best",fontsize=35, handlelength= 3)
    #######PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
    PyPlot.xticks(0:2:24,fontsize=35)
    PyPlot.yticks(fontsize=35)
    PyPlot.grid()
    PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Hourly_Comperation_House_"*Str_n*"_AfterAndBefore_Optimization.png")  ## optional command to save results.
    PyPlot.close(fig)
end

##################
##################
##################
fig = figure(figsize=(20,10))
title("Day_Comperation_load_Net_AfterAndBefore_Optimization",fontsize=25)
R_PyPlot = PyPlot.scatter(NN,Day_load_ForSubscriber_Net_load_list,color="red",marker="o", label = "Energy Usage Initial [kWh] ",s=500)
B_PyPlot = PyPlot.scatter(NN,Day_load_ForSubscriber_Net_load_Optimized_list,color="blue",marker="x", label = "Energy Usage After_Optimization [kWh] ", s=700)
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(0:1:15,fontsize=40)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_Comperation_load_Net_AfterAndBefore_Optimization.png")  ## optional command to save results.
##################
##################
fig = figure(figsize=(20,10))
title("Day_Comperation_load_Control_Able_PeakTime_AfterAndBefore_Optimization",fontsize=25)
R_PyPlot = PyPlot.scatter(NN,Day_load_ForSubscriber_Control_Able_PeakTime_list,color="red",marker="o", label = "Energy Usage Initial [kWh] ",s=500)
B_PyPlot = PyPlot.scatter(NN,Day_load_ForSubscriber_Control_Able_PeakTime_Optimized_list,color="blue",marker="x", label = "Energy Usage After_Optimization [kWh] ", s=700)
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(0:1:15,fontsize=40)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_Comperation_load_Control_Able_PeakTime_AfterAndBefore_Optimization.png")  ## optional command to save results.
##################
##################
fig = figure(figsize=(20,10))
title("Day_Comperation_load_ControlAble_load_AfterAndBefore_Optimization",fontsize=25)
R_PyPlot = PyPlot.scatter(NN,Day_load_ForSubscriber_ControlAble_load_list,color="red",marker="o", label = "Energy Usage Initial [kWh] ",s=500)
B_PyPlot = PyPlot.scatter(NN,Day_load_ForSubscriber_ControlAble_load_Optimized_list,color="blue",marker="x", label = "Energy Usage After_Optimization [kWh] ", s=700)
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(0:1:15,fontsize=40)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_Comperation_load_ControlAble_load_AfterAndBefore_Optimization.png")  ## optional command to save results.
##################
##################
fig = figure(figsize=(20,10))
title("Cost A Day_Net_load 12 Houses",fontsize=25)
R_PyPlot = PyPlot.scatter(NN,Day_Net_load_ForSubscriber_Cost,color="red",marker="o", label = "Cost Initial [\$ ] ",s=500)
B_PyPlot = PyPlot.scatter(NN,Day_Net_load_ForSubscriber_Cost_After_Optimization,color="blue",marker="x", label = "Cost After_Optimization [\$ ] ", s=700)
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(0:1:15,fontsize=40)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Cost_Day_Comperation_Net_load_AfterAndBefore_Optimization.png")  ## optional command to save results.
################
###############
fig = figure(figsize=(20,10))
title("Cost A Day_ControlAble_load 12 Houses",fontsize=25)
R_PyPlot = PyPlot.scatter(NN,Day_ControlAble_load_ForSubscriber_Cost,color="red",marker="o", label = "Cost Initial [\$ ] ",s=500)
B_PyPlot = PyPlot.scatter(NN,Day_ControlAble_load_ForSubscriber_Cost_After_Optimization,color="blue",marker="x", label = "Cost After_Optimization [\$ ] ", s=700)
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(0:1:15,fontsize=40)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Cost_Day_Comperation_ControlAble_load_AfterAndBefore_Optimization.png")  ## optional command to save results.
##################
####################################
####################################
####################################
####################################
##################
NN_AllHouses=[1]
fig = figure(figsize=(20,10))
title("Cost A Day_Net_load_AllHouses",fontsize=25)
R_PyPlot = PyPlot.scatter(NN_AllHouses,Day_Net_load_ForSubscriber_Cost_AllHouses,color="red",marker="o", label = "Cost Initial [\$ ] ",s=500)
B_PyPlot = PyPlot.scatter(NN_AllHouses,Day_Net_load_ForSubscriber_Cost_After_Optimization_AllHouses,color="blue",marker="x", label = "Cost After_Optimization [\$ ] ", s=700)
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(fontsize=25)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Cost_Day_Net_load_AllHouses_Comperation_AfterAndBefore_Optimization.png")  ## optional command to save results.
##################
##################
fig = figure(figsize=(20,10))
title("Cost A Day_ControlAble_load_AllHouses",fontsize=25)
R_PyPlot = PyPlot.scatter(NN_AllHouses,Day_ControlAble_load_ForSubscriber_Cost_AllHouses,color="red",marker="o", label = "Cost Initial [\$ ] ",s=500)
B_PyPlot = PyPlot.scatter(NN_AllHouses,Day_ControlAble_load_ForSubscriber_Cost_After_Optimization_AllHouses,color="blue",marker="x", label = "Cost After_Optimization [\$ ] ", s=700)
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(fontsize=25)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Cost_Day_ControlAble_load_AllHouses_Comperation_AfterAndBefore_Optimization.png")  ## optional command to save results.
##################
##################
fig = figure(figsize=(20,10))
title("Cost A Day_load_AllHouses",fontsize=25)
R1_PyPlot = PyPlot.scatter(NN_AllHouses,Day_Net_load_ForSubscriber_Cost_AllHouses,color="red",marker="o", label = "Net Cost Initial [\$ ] ",s=500)
B2_PyPlot = PyPlot.scatter(NN_AllHouses,Day_Net_load_ForSubscriber_Cost_After_Optimization_AllHouses,color="g",marker="x", label = "Net Cost After_Optimization [\$ ] ", s=700)
R2_PyPlot = PyPlot.scatter(NN_AllHouses,Day_ControlAble_load_ForSubscriber_Cost_AllHouses,color="b",marker="v", label = "ControlAble Cost Initial [\$ ] ",s=500)
B2_PyPlot = PyPlot.scatter(NN_AllHouses,Day_ControlAble_load_ForSubscriber_Cost_After_Optimization_AllHouses,color="c",marker="<", label = "ControlAble Cost After_Optimization [\$ ] ", s=700)
#markers = ["." , "," , "o" , "v" , "^" , "<", ">"]
#colors = ['r','g','b','c','m', 'y', 'k']
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(fontsize=25)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Cost_Day_load_AllHouses_Comperation_AfterAndBefore_Optimization.png")  ## optional

############
############
################################################
################################################
############
############


##################
####################################
####################################
####################################
####################################
##################
NN_AllHouses=[1]
fig = figure(figsize=(20,10))
title("Total Day_load_AllHouses",fontsize=25)
R1_PyPlot = PyPlot.scatter(NN_AllHouses,Day_Net_load_ForSubscriber_AllHouses,color="red",marker="o", label = "Net Energy Usage Initial [kWh] ",s=500)
B2_PyPlot = PyPlot.scatter(NN_AllHouses,Day_Net_load_ForSubscriber_After_Optimization_AllHouses,color="g",marker="x", label = "Net Energy Usage After_Optimization [kWh] ", s=700)
R2_PyPlot = PyPlot.scatter(NN_AllHouses,Day_ControlAble_load_ForSubscriber_AllHouses,color="b",marker="v", label = "ControlAble Energy Usage Initial [kWh] ",s=500)
B2_PyPlot = PyPlot.scatter(NN_AllHouses,Day_ControlAble_load_ForSubscriber_After_Optimization_AllHouses,color="c",marker="<", label = "ControlAble Energy Usage After_Optimization [kWh] ", s=700)
#markers = ["." , "," , "o" , "v" , "^" , "<", ">"]
#colors = ['r','g','b','c','m', 'y', 'k']
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(fontsize=25)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Total_Day_load_AllHouses_Comperation_AfterAndBefore_Optimization.png")  ## optional
PyPlot.close(fig)
############
############
fig_1 = figure(figsize=(20,10))
title("Total Day_Net_load_AllHouses",fontsize=25)
R1_PyPlot = PyPlot.scatter(NN_AllHouses,Day_Net_load_ForSubscriber_AllHouses,color="red",marker="o", label = "Net Energy Usage Initial [kWh] ",s=500)
B2_PyPlot = PyPlot.scatter(NN_AllHouses,Day_Net_load_ForSubscriber_After_Optimization_AllHouses,color="g",marker="x", label = "Net Energy Usage After_Optimization [kWh] ", s=700)
#markers = ["." , "," , "o" , "v" , "^" , "<", ">"]
#colors = ['r','g','b','c','m', 'y', 'k']
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(fontsize=25)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Total_Day_Net_load_AllHouses_Comperation_AfterAndBefore_Optimization.png")  ## optional command to save results.
PyPlot.close(fig_1)
##################
##################
fig_2 = figure(figsize=(20,10))
title("Total Day_ControlAble_load_AllHouses",fontsize=25)
R2_PyPlot = PyPlot.scatter(NN_AllHouses,Day_ControlAble_load_ForSubscriber_AllHouses,color="b",marker="o", label = "ControlAble Energy Usage Initial [kWh] ",s=500)
B2_PyPlot = PyPlot.scatter(NN_AllHouses,Day_ControlAble_load_ForSubscriber_After_Optimization_AllHouses,color="c",marker="x", label = "ControlAble Energy Usage After_Optimization [kWh] ", s=700)
#markers = ["." , "," , "o" , "v" , "^" , "<", ">"]
#colors = ['r','g','b','c','m', 'y', 'k']
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(fontsize=25)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Total_Day_ControlAble_load_AllHouses_Comperation_AfterAndBefore_Optimization.png")  ## optional command to save results.
PyPlot.close(fig_2)
##################
##################


#####     PAR                                    PAR
#####
fig = figure(figsize=(20,10))
title("PAR_load_AllHouses",fontsize=25)
R_PyPlot = PyPlot.scatter(NN_AllHouses,VPP_PAR,color="red",marker="o", label = "PAR Initial  ",s=500)
B_PyPlot = PyPlot.scatter(NN_AllHouses,VPP_PAR_Optimized,color="blue",marker="x", label = "PAR After_Optimization", s=700)
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(fontsize=25)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/PAR_Comperation_AfterAndBefore_Optimization.png")  ## optional command to save results.
#####
#####


println("Total Day_Net_load__initial_AllHouses = ",Day_Net_load_ForSubscriber_AllHouses)
println("Total Day_Net_load_After_Optimization_AllHouses = ",Day_Net_load_ForSubscriber_After_Optimization_AllHouses)
println("Total Day_ControlAble_load_initial_AllHouses = ",Day_ControlAble_load_ForSubscriber_AllHouses)
println("Total Day_ControlAble_load_After_Optimization_AllHouses = ",Day_ControlAble_load_ForSubscriber_After_Optimization_AllHouses)


######
println("Day_Net_load_ForSubscriber_Cost_AllHouses = ",Day_Net_load_ForSubscriber_Cost_AllHouses)
println("Day_Net_load_ForSubscriber_Cost_After_Optimization_AllHouses = ",Day_Net_load_ForSubscriber_Cost_After_Optimization_AllHouses)
println("Day_ControlAble_load_ForSubscriber_Cost_AllHouses = ",Day_ControlAble_load_ForSubscriber_Cost_AllHouses)
println("Day_ControlAble_load_ForSubscriber_Cost_After_Optimization_AllHouses = ",Day_ControlAble_load_ForSubscriber_Cost_After_Optimization_AllHouses)
######

CostProfile_mean=mean(CostProfile)
println("CostProfile_mean = ",CostProfile_mean)
# objective is only base on ControlAble load
println("Cost base on (CostProfile_mean) for  Total Day_ControlAble_load_initial_AllHouses   = ",Day_ControlAble_load_ForSubscriber_AllHouses*CostProfile_mean)
println("Cost base on (CostProfile_mean) for  Total Day_ControlAble_load_After_Optimization_AllHouses  = ",Day_ControlAble_load_ForSubscriber_After_Optimization_AllHouses*CostProfile_mean)
