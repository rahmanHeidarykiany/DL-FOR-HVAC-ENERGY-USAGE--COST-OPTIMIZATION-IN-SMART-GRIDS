##version
version="_1"
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
#=
import Pkg;
Pkg.add("Conda")
import Conda
Conda.update()
Pkg.build("PyPlot")
=#


import DataFrames.DataFrame

using DataFrames
using CSV
using Test
using JLD,HDF5,FileIO
#### declaration of utilized packages
using CSV
using JuMP
using Gurobi # need to install Gurobi on your machine!
using Ipopt
using Statistics
using Dates
using Distributions
using StatsPlots
using Plots

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

Net_load_After_DR_Signal=Dict()
UnControlAble_load_After_DR_Signal=Dict()
ControlAble_load_After_DR_Signal=Dict()
HVAC_load_After_DR_Signal=Dict()
WaterHeter_load_After_DR_Signal=Dict()
DISHWASHER_load_After_DR_Signal=Dict()

for n in N
    Net_load[n]=zeros(length(NH))
    UnControlAble_load[n]=zeros(length(NH))### initialization
    ControlAble_load[n]=zeros(length(NH))### initialization
    HVAC_load[n]=zeros(length(NH))###
    WaterHeter_load[n]=zeros(length(NH))
    DISHWASHER_load[n]=zeros(length(NH))

    Net_load_After_DR_Signal[n]=zeros(length(NH))
    UnControlAble_load_After_DR_Signal[n]=zeros(length(NH))### initialization
    ControlAble_load_After_DR_Signal[n]=zeros(length(NH))### initialization
    HVAC_load_After_DR_Signal[n]=zeros(length(NH))###
    WaterHeter_load_After_DR_Signal[n]=zeros(length(NH))
    DISHWASHER_load_After_DR_Signal[n]=zeros(length(NH))
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
    UnControlAble_load_After_DR_Signal[n]=House_loads.UnControlAble_load
    ControlAble_load[n]=House_loads.ControlAble_load
    HVAC_load[n]=House_loads.HVAC
    WaterHeter_load[n]=House_loads.WaterHeter
    DISHWASHER_load[n]=House_loads.Dishwasher########DISHWASHER_load
end

for n in N
    Str_n=string(n)
    if 1==verbose_Figs
        println("House_"*Str_n*"")
    end
    House_loads=CSV.read(""*OrginalFilesAddress*"Py_Files/OutPut_of_py/House_"*Str_n*"/R_House_"*Str_n*"_EnergyUse_H_AfterRunWith_DR_Signal.csv", DataFrame)
    Net_load_After_DR_Signal[n]=House_loads.Net_Total
    #UnControlAble_load_After_DR_Signal[n]=House_loads.UnControlAble_load
    ControlAble_load_After_DR_Signal[n]=House_loads.ControlAble_load
    HVAC_load_After_DR_Signal[n]=House_loads.HVAC
    WaterHeter_load_After_DR_Signal[n]=House_loads.WaterHeter
    DISHWASHER_load_After_DR_Signal[n]=House_loads.Dishwasher########DISHWASHER_load
end


## UnControlAble_load

Plot_Hourly_UnControlAble_load_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for
Plot_Hourly_UnControlAble_load_After_DR_Signal_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for


iter_UnControlAble_load_list=0
for n in N
    global iter_UnControlAble_load_list=iter_UnControlAble_load_list+1
    Plot_Hourly_UnControlAble_load_list[iter_UnControlAble_load_list]=UnControlAble_load[n]
    Plot_Hourly_UnControlAble_load_After_DR_Signal_list[iter_UnControlAble_load_list]=UnControlAble_load_After_DR_Signal[n]
end

Plot_Hourly_UnControlAble_load=plot(NH, [Plot_Hourly_UnControlAble_load_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh", title="UnControlAble load", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm, label="")
Plot_Hourly_UnControlAble_load_After_DR_Signal=plot(NH, [Plot_Hourly_UnControlAble_load_After_DR_Signal_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh", title="UnControlAble load DR", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm, label="")

##  Making suitable  applienses


Plot_Hourly_HVAC_load_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for
Plot_Hourly_HVAC_load_After_DR_Signal_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for

Plot_Hourly_WaterHeter_load_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for
Plot_Hourly_WaterHeter_load_After_DR_Signal_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for

Plot_Hourly_DISHWASHER_load_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for
Plot_Hourly_DISHWASHER_load_After_DR_Signal_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for


iter_Plot_Hourly_applienses=0
for n in N
    global iter_Plot_Hourly_applienses=iter_Plot_Hourly_applienses+1
    Plot_Hourly_HVAC_load_list[iter_Plot_Hourly_applienses]=HVAC_load[n]
    Plot_Hourly_HVAC_load_After_DR_Signal_list[iter_Plot_Hourly_applienses]=HVAC_load_After_DR_Signal[n]

    Plot_Hourly_WaterHeter_load_list[iter_Plot_Hourly_applienses]=WaterHeter_load[n]
    Plot_Hourly_WaterHeter_load_After_DR_Signal_list[iter_Plot_Hourly_applienses]=WaterHeter_load_After_DR_Signal[n]

    Plot_Hourly_DISHWASHER_load_list[iter_Plot_Hourly_applienses]=DISHWASHER_load[n]
    Plot_Hourly_DISHWASHER_load_After_DR_Signal_list[iter_Plot_Hourly_applienses]=DISHWASHER_load_After_DR_Signal[n]

end


Plot_Hourly_HVAC_load=plot(NH, [Plot_Hourly_HVAC_load_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="HVAC load", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm, label="")
Plot_Hourly_HVAC_load_After_DR_Signal=plot(NH, [Plot_Hourly_HVAC_load_After_DR_Signal_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="HVAC load DR", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm, label="")

Plot_Hourly_WaterHeter_load=plot(NH, [Plot_Hourly_WaterHeter_load_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="WaterHeter load", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm, label="")
Plot_Hourly_WaterHeter_load_After_DR_Signal=plot(NH, [Plot_Hourly_WaterHeter_load_After_DR_Signal_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="WaterHeter load DR", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm, label="")

Plot_Hourly_DISHWASHER_load=plot(NH, [Plot_Hourly_DISHWASHER_load_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="Dishwasher load", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm, label="")
Plot_Hourly_DISHWASHER_load_After_DR_Signal=plot(NH, [Plot_Hourly_DISHWASHER_load_After_DR_Signal_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="Dishwasher load DR", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm, label="")

## make  net load for each home
# # in last version of code we should not have this part, only we should inport them
ControlAble_load=Dict()
ControlAble_load_After_DR_Signal=Dict()

Net_load=Dict()
Net_load_After_DR_Signal=Dict()

for n in N
    ControlAble_load[n]=zeros(length(NH))
    ControlAble_load_After_DR_Signal[n]=zeros(length(NH))
    Net_load[n]=zeros(length(NH))
    Net_load_After_DR_Signal[n]=zeros(length(NH))
    for a in A
        if a == 1
            ControlAble_load[n]=ControlAble_load[n]+HVAC_load[n]
            ControlAble_load_After_DR_Signal[n]=ControlAble_load_After_DR_Signal[n]+HVAC_load_After_DR_Signal[n]
        elseif a == 2
            ControlAble_load[n]=ControlAble_load[n]+WaterHeter_load[n]
            ControlAble_load_After_DR_Signal[n]=ControlAble_load_After_DR_Signal[n]+WaterHeter_load_After_DR_Signal[n]
        elseif a == 3
            ControlAble_load[n]=ControlAble_load[n]+WaterHeter_load[n]
            ControlAble_load_After_DR_Signal[n]=ControlAble_load_After_DR_Signal[n]+WaterHeter_load_After_DR_Signal[n]
        end
    end
    if (IsThere_UncontrolAble_Load)
        global UnControlAble_load[n]=UnControlAble_load[n]
        global UnControlAble_load_After_DR_Signal[n]=UnControlAble_load_After_DR_Signal[n]
    else
        global UnControlAble_load[n]=UnControlAble_load[n]*0.000
        global UnControlAble_load_After_DR_Signal[n]=UnControlAble_load_After_DR_Signal*0.000
    end
    Net_load[n]=ControlAble_load[n]+UnControlAble_load[n]
    Net_load_After_DR_Signal[n]=ControlAble_load_After_DR_Signal[n]+UnControlAble_load_After_DR_Signal[n]
end
Plot_Hourly_ControlAble_load_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for
Plot_Hourly_ControlAble_load_After_DR_Signal_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for

Plot_Hourly_UnControlAble_load_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for
Plot_Hourly_UnControlAble_load_After_DR_Signal_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for

Plot_Hourly_Net_load_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for
Plot_Hourly_Net_load_After_DR_Signal_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for


iter_Hourly_make_net_load=0

Hourly_Aggregate_Net_load=zeros(length(NH))
Hourly_Aggregate_Net_load_After_DR_Signal=zeros(length(NH))


for n in N
    global iter_Hourly_make_net_load=iter_Hourly_make_net_load+1
    global Hourly_Aggregate_Net_load=Hourly_Aggregate_Net_load+Net_load[n]
    global Hourly_Aggregate_Net_load_After_DR_Signal=Hourly_Aggregate_Net_load_After_DR_Signal+Net_load_After_DR_Signal[n]

    Plot_Hourly_ControlAble_load_list[iter_Hourly_make_net_load]=ControlAble_load[n]
    Plot_Hourly_ControlAble_load_After_DR_Signal_list[iter_Hourly_make_net_load]=ControlAble_load_After_DR_Signal[n]

    Plot_Hourly_UnControlAble_load_list[iter_Hourly_make_net_load]=UnControlAble_load[n]
    Plot_Hourly_UnControlAble_load_After_DR_Signal_list[iter_Hourly_make_net_load]=UnControlAble_load_After_DR_Signal[n]

    Plot_Hourly_Net_load_list[iter_Hourly_make_net_load]=Net_load[n]
    Plot_Hourly_Net_load_After_DR_Signal_list[iter_Hourly_make_net_load]=Net_load_After_DR_Signal[n]
end

Plot_Hourly_UnControlAble_load=plot(NH, [Plot_Hourly_UnControlAble_load_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="UnControlAble load", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm, label="")
Plot_Hourly_UnControlAble_load_After_DR_Signal=plot(NH, [Plot_Hourly_UnControlAble_load_After_DR_Signal_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="UnControlAble_load_DR_", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm, label="")

Plot_Hourly_ControlAble_load=plot(NH, [Plot_Hourly_ControlAble_load_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="ControlAble loads", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm, label="")
Plot_Hourly_ControlAble_load_After_DR_Signal=plot(NH, [Plot_Hourly_ControlAble_load_After_DR_Signal_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="ControlAble_load_DR", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm, label="")

Plot_Hourly_Net_load=plot(NH, [Plot_Hourly_Net_load_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="Net loads", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm, label="")
Plot_Hourly_Net_load_After_DR_Signal=plot(NH, [Plot_Hourly_Net_load_After_DR_Signal_list],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="Net_load_DR", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm, label="")

Plot_Hourly_Aggregate_Net_load=plot(NH, [Hourly_Aggregate_Net_load],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="Hourly_Aggregate_Net_load loads", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm, label="")
Plot_Hourly_Aggregate_Net_load_After_DR_Signal=plot(NH, [Hourly_Aggregate_Net_load_After_DR_Signal],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="Hourly_Aggregate_Net_load_DR", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm, label="")


VPP_Net_load_Max=maximum(Hourly_Aggregate_Net_load)
VPP_Net_load_Mean=mean(Hourly_Aggregate_Net_load)
VPP_PAR=VPP_Net_load_Max/VPP_Net_load_Mean
VPP_Net_load_After_DR_Signal_Max=maximum(Hourly_Aggregate_Net_load_After_DR_Signal)
VPP_Net_load_After_DR_Signal_Mean=mean(Hourly_Aggregate_Net_load_After_DR_Signal)
VPP_PAR_After_DR_Signal=VPP_Net_load_After_DR_Signal_Max/VPP_Net_load_After_DR_Signal_Mean

##plot Net load and UnControlAble_load load and HVAC
###check
AllHouses_loadsSeperately=plot(Plot_Hourly_Net_load,Plot_Hourly_UnControlAble_load, Plot_Hourly_HVAC_load)
AllHouses_load_After_DR_SignalSeperately=plot(Plot_Hourly_Net_load_After_DR_Signal,Plot_Hourly_UnControlAble_load_After_DR_Signal, Plot_Hourly_HVAC_load_After_DR_Signal)

#savefig(AllHouses_loadsSeperately,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Hourly_House_All.png")
#savefig(AllHouses_load_After_DR_SignalSeperately,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Hourly_House_All_After_DR.png")

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

Hourly_Applience_DetailsFor_home_After_DR_Signal=Dict()
for n in N
    Hourly_Applience_DetailsFor_home_After_DR_Signal[n]=Dict()
            for a in A
                if a==1
                    Hourly_Applience_DetailsFor_home_After_DR_Signal[n][a]=HVAC_load_After_DR_Signal[n]
                elseif a==2
                    Hourly_Applience_DetailsFor_home_After_DR_Signal[n][a]=WaterHeter_load_After_DR_Signal[n]
                elseif a==3
                    Hourly_Applience_DetailsFor_home_After_DR_Signal[n][a]=DISHWASHER_load_After_DR_Signal[n]
                end
            end
end

## Find out about details of appienes before starting the
#### Statistics on Appliences Parameters
#### Make Dict for each Parameter will be needed on our code

E_MiN_After_DR_Signal=Dict()
E_MaX_After_DR_Signal=Dict()
E_MaX_hour_After_DR_Signal=Dict()
E_Mean_After_DR_Signal=Dict()
for n in N
    E_MiN_After_DR_Signal[n]=Dict()
    E_MaX_After_DR_Signal[n]=Dict()
    E_MaX_hour_After_DR_Signal[n]=Dict()
    E_Mean_After_DR_Signal[n]=Dict()
    for a in A
        if a==1
            E_MiN_After_DR_Signal[n][a]=minimum(HVAC_load_After_DR_Signal[n])
            E_MaX_After_DR_Signal[n][a]=maximum(HVAC_load_After_DR_Signal[n])
            E_Mean_After_DR_Signal[n][a]=mean(HVAC_load_After_DR_Signal[n])
        elseif a==2
            E_MiN_After_DR_Signal[n][a]=minimum(WaterHeter_load_After_DR_Signal[n])
            E_MaX_After_DR_Signal[n][a]=maximum(WaterHeter_load_After_DR_Signal[n])
            E_Mean_After_DR_Signal[n][a]=mean(WaterHeter_load_After_DR_Signal[n])
        elseif a==3
            E_MiN_After_DR_Signal[n][a]=minimum(DISHWASHER_load_After_DR_Signal[n])
            E_MaX_After_DR_Signal[n][a]=maximum(DISHWASHER_load_After_DR_Signal[n])
            E_Mean_After_DR_Signal[n][a]=mean(DISHWASHER_load_After_DR_Signal[n])
        end

        E_MaX_hour_After_DR_Signal[n][a]=0
        for h in H
                if (Hourly_Applience_DetailsFor_home_After_DR_Signal[n][a][h]==E_MaX_After_DR_Signal[n][a])#find times which is close to peak time
                    E_MaX_hour_After_DR_Signal[n][a]=h
                end
        end

    end
end


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


Appliences_Scheduled_total_PeakTime_Eng_consump_After_DR_Signal=Dict()
Appliences_Scheduled_total_NoT_PeakTime_Eng_consump_After_DR_Signal=Dict()
for n in N
    Appliences_Scheduled_total_PeakTime_Eng_consump_After_DR_Signal[n]=Dict()
    Appliences_Scheduled_total_NoT_PeakTime_Eng_consump_After_DR_Signal[n]=Dict()
    for a in A
        Appliences_Scheduled_total_PeakTime_Eng_consump_After_DR_Signal[n][a]=0
        for h in Applience_Time_Can_be_scheduled[n][a]
            if a==1
                    Appliences_Scheduled_total_PeakTime_Eng_consump_After_DR_Signal[n][a]=Appliences_Scheduled_total_PeakTime_Eng_consump_After_DR_Signal[n][a]+HVAC_load_After_DR_Signal[n][h]
            elseif a==2
                    Appliences_Scheduled_total_PeakTime_Eng_consump_After_DR_Signal[n][a]=Appliences_Scheduled_total_PeakTime_Eng_consump_After_DR_Signal[n][a]+WaterHeter_load_After_DR_Signal[n][h]
            elseif a==3
                    Appliences_Scheduled_total_PeakTime_Eng_consump_After_DR_Signal[n][a]=Appliences_Scheduled_total_PeakTime_Eng_consump_After_DR_Signal[n][a]+DISHWASHER_load_After_DR_Signal[n][h]
            end
        end

        Appliences_Scheduled_total_NoT_PeakTime_Eng_consump_After_DR_Signal[n][a]=0
        for h in Applience_Times_Can_not_be_scheduled[n][a]
            if a==1
                    Appliences_Scheduled_total_NoT_PeakTime_Eng_consump_After_DR_Signal[n][a]=Appliences_Scheduled_total_NoT_PeakTime_Eng_consump_After_DR_Signal[n][a]+HVAC_load_After_DR_Signal[n][h]
            elseif a==2
                    Appliences_Scheduled_total_NoT_PeakTime_Eng_consump_After_DR_Signal[n][a]=Appliences_Scheduled_total_NoT_PeakTime_Eng_consump_After_DR_Signal[n][a]+WaterHeter_load_After_DR_Signal[n][h]
            elseif a==3
                    Appliences_Scheduled_total_NoT_PeakTime_Eng_consump_After_DR_Signal[n][a]=Appliences_Scheduled_total_NoT_PeakTime_Eng_consump_After_DR_Signal[n][a]+DISHWASHER_load_After_DR_Signal[n][h]
            end
        end
    end
end


Appliences_Scheduled_total_PeakTime_Eng_consump_After_DR_Signal=Dict()
Appliences_Scheduled_total_NoT_PeakTime_Eng_consump_After_DR_Signal=Dict()
for n in N
    Appliences_Scheduled_total_PeakTime_Eng_consump_After_DR_Signal[n]=Dict()
    Appliences_Scheduled_total_NoT_PeakTime_Eng_consump_After_DR_Signal[n]=Dict()
    for a in A
        Appliences_Scheduled_total_PeakTime_Eng_consump_After_DR_Signal[n][a]=0
        for h in Applience_Time_Can_be_scheduled[n][a]
            if a==1
                    Appliences_Scheduled_total_PeakTime_Eng_consump_After_DR_Signal[n][a]=Appliences_Scheduled_total_PeakTime_Eng_consump_After_DR_Signal[n][a]+HVAC_load_After_DR_Signal[n][h]
            elseif a==2
                    Appliences_Scheduled_total_PeakTime_Eng_consump_After_DR_Signal[n][a]=Appliences_Scheduled_total_PeakTime_Eng_consump_After_DR_Signal[n][a]+WaterHeter_load_After_DR_Signal[n][h]
            elseif a==3
                    Appliences_Scheduled_total_PeakTime_Eng_consump_After_DR_Signal[n][a]=Appliences_Scheduled_total_PeakTime_Eng_consump_After_DR_Signal[n][a]+DISHWASHER_load_After_DR_Signal[n][h]
            end
        end

        Appliences_Scheduled_total_NoT_PeakTime_Eng_consump_After_DR_Signal[n][a]=0
        for h in Applience_Times_Can_not_be_scheduled[n][a]
            if a==1
                    Appliences_Scheduled_total_NoT_PeakTime_Eng_consump_After_DR_Signal[n][a]=Appliences_Scheduled_total_NoT_PeakTime_Eng_consump_After_DR_Signal[n][a]+HVAC_load_After_DR_Signal[n][h]
            elseif a==2
                    Appliences_Scheduled_total_NoT_PeakTime_Eng_consump_After_DR_Signal[n][a]=Appliences_Scheduled_total_NoT_PeakTime_Eng_consump_After_DR_Signal[n][a]+WaterHeter_load_After_DR_Signal[n][h]
            elseif a==3
                    Appliences_Scheduled_total_NoT_PeakTime_Eng_consump_After_DR_Signal[n][a]=Appliences_Scheduled_total_NoT_PeakTime_Eng_consump_After_DR_Signal[n][a]+DISHWASHER_load_After_DR_Signal[n][h]
            end
        end
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


Day_Control_Able_PeakTime_Load_After_DR_Signal=Dict()
Day_Control_Able_NoT_PeakTime_Load_After_DR_Signal=Dict()
for n in N
    temp_1=0
    temp_2=0
    for a in A
        temp_1=temp_1+Appliences_Scheduled_total_PeakTime_Eng_consump_After_DR_Signal[n][a]
        temp_2=temp_2+Appliences_Scheduled_total_NoT_PeakTime_Eng_consump_After_DR_Signal[n][a]
    end
    Day_Control_Able_PeakTime_Load_After_DR_Signal[n]=temp_1
    Day_Control_Able_NoT_PeakTime_Load_After_DR_Signal[n]=temp_2
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
#Plot_Day_load_ForSubscriber_Control_Able_PeakTime=plot(scatter(NN,[210,210,210,210], color=cols,mode="markers",markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh", yticks=0:10:800,title=" Day_ControlAble_PeakTime", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm)
Plot_Day_load_ForSubscriber_Control_Able_PeakTime=plot(scatter(NN,Day_load_ForSubscriber_Control_Able_PeakTime_list, color=cols,mode="markers",markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh",title=" Day_ControlAble_PeakTime", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm)
Plot_Day_load_ForSubscriber_Control_Able_NoT_PeakTime=plot(scatter(NN,Day_load_ForSubscriber_Control_Able_NoT_PeakTime_list, color=cols,mode="markers",markershape=:star,markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh", title=" Day_Control_Able_NoT_PeakTime", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm)
Plot_Day_load_ForSubscriber_ControlAble_load=plot(scatter(NN,Day_load_ForSubscriber_ControlAble_load_list, color=cols,mode="markers",markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh", title=" Day_Control_Able", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm)
Plot_Day_load_ForSubscriber_UnControlAble_load=plot(scatter(NN,Day_load_ForSubscriber_UnControlAble_load_list, color=cols,mode="markers",markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh", title=" Day_UnControl_Able", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm)
Plot_Day_load_ForSubscriber_Net_load=plot(scatter(NN,Day_load_ForSubscriber_Net_load_list, color=cols,mode="markers",markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh",title=" Day_Net_Load", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm)
Load_BeforeApplyCode=plot(Plot_Day_load_ForSubscriber_Control_Able_PeakTime,Plot_Day_load_ForSubscriber_Control_Able_NoT_PeakTime)
#savefig(Load_BeforeApplyCode,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_LoadS_orginal.png")






Hourly_loads_ForSubscriber_After_DR_Signal=Dict()
Day_load_ForSubscriber_After_DR_Signal=Dict()
for n in N
        Hourly_loads_ForSubscriber_After_DR_Signal[n]=Dict()
        Day_load_ForSubscriber_After_DR_Signal[n]=[]
        Temp_1=0
        Temp_2=0
                for h in H
                    Hourly_loads_ForSubscriber_After_DR_Signal[n][h]=Dict(
                    "Hourly_HVAC_load_ForSubscriber"=>HVAC_load_After_DR_Signal[n][h],
                    "Hourly_WaterHeter_load_ForSubscriber"=>WaterHeter_load_After_DR_Signal[n][h],
                    "Hourly_DISHWASHER_load_ForSubscriber"=>DISHWASHER_load_After_DR_Signal[n][h],
                    "Hourly_ControlAble_load_ForSubscriber"=>ControlAble_load_After_DR_Signal[n][h],
                    "Optimized_Hourly_ControlAble_load_ForSubscriber"=>0.00000000,
                    "Hourly_UnControlAble_load_ForSubscriber"=>UnControlAble_load_After_DR_Signal[n][h],
                    )
                    Temp_2=Temp_2+Hourly_loads_ForSubscriber_After_DR_Signal[n][h]["Hourly_UnControlAble_load_ForSubscriber"]
                end
                Day_load_ForSubscriber_After_DR_Signal[n]=Dict(
                "Day_Control_Able_PeakTime_Load"=>Day_Control_Able_PeakTime_Load_After_DR_Signal[n],
                "Day_Control_Able_NoT_PeakTime_Load"=>Day_Control_Able_NoT_PeakTime_Load_After_DR_Signal[n],
                "Day_UnControl_Able_Load_ForSubscriber"=>Temp_2,
                )
end


##### update information
for n in N
    Temp_1=0
    Temp_2=0
    Temp_3=0
    for h in H
        Temp_1=Hourly_loads_ForSubscriber_After_DR_Signal[n][h]["Hourly_ControlAble_load_ForSubscriber"]
        Temp_2=Hourly_loads_ForSubscriber_After_DR_Signal[n][h]["Hourly_UnControlAble_load_ForSubscriber"]
        Hourly_loads_ForSubscriber_After_DR_Signal[n][h]["Hourly_Net_load_ForSubscriber"]=Temp_1+Temp_2
        ##
        Temp_3=Temp_3+Hourly_loads_ForSubscriber_After_DR_Signal[n][h]["Hourly_Net_load_ForSubscriber"]
    end
    Day_load_ForSubscriber_After_DR_Signal[n]["Day_Net_load_ForSubscriber"]=Temp_3
    Day_load_ForSubscriber_After_DR_Signal[n]["Day_ControlAble_load_ForSubscriber"]=Day_Control_Able_NoT_PeakTime_Load_After_DR_Signal[n]+Day_Control_Able_PeakTime_Load_After_DR_Signal[n]### Make Dict for seeing all of them in one location.
end

Day_load_ForSubscriber_Control_Able_PeakTime_list_After_DR_Signal=zeros(length(NN))
Day_load_ForSubscriber_Control_Able_NoT_PeakTime_list_After_DR_Signal=zeros(length(NN))
Day_load_ForSubscriber_ControlAble_load_list_After_DR_Signal=zeros(length(NN))
Day_load_ForSubscriber_UnControlAble_load_list_After_DR_Signal=zeros(length(NN))
Day_load_ForSubscriber_Net_load_list_After_DR_Signal=zeros(length(NN))

iter_Day_load_ForSubscriber=0
for n in N
    global iter_Day_load_ForSubscriber=iter_Day_load_ForSubscriber+1
    Day_load_ForSubscriber_Control_Able_PeakTime_list_After_DR_Signal[iter_Day_load_ForSubscriber]=Day_load_ForSubscriber_After_DR_Signal[n]["Day_Control_Able_PeakTime_Load"]
    Day_load_ForSubscriber_Control_Able_NoT_PeakTime_list_After_DR_Signal[iter_Day_load_ForSubscriber]=Day_load_ForSubscriber_After_DR_Signal[n]["Day_Control_Able_NoT_PeakTime_Load"]
    Day_load_ForSubscriber_ControlAble_load_list_After_DR_Signal[iter_Day_load_ForSubscriber]=Day_load_ForSubscriber_After_DR_Signal[n]["Day_ControlAble_load_ForSubscriber"]
    Day_load_ForSubscriber_UnControlAble_load_list_After_DR_Signal[iter_Day_load_ForSubscriber]=Day_load_ForSubscriber_After_DR_Signal[n]["Day_UnControl_Able_Load_ForSubscriber"]
    Day_load_ForSubscriber_Net_load_list_After_DR_Signal[iter_Day_load_ForSubscriber]=Day_load_ForSubscriber_After_DR_Signal[n]["Day_Net_load_ForSubscriber"]
end
#Plot_Day_load_ForSubscriber_Control_Able_PeakTime=plot(scatter(NN,[210,210,210,210], color=cols,mode="markers",markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh", yticks=0:10:800,title=" Day_ControlAble_PeakTime", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm)
Plot_Day_load_ForSubscriber_Control_Able_PeakTime_After_DR_Signal=plot(scatter(NN,Day_load_ForSubscriber_Control_Able_PeakTime_list_After_DR_Signal, color=cols,mode="markers",markershape=:star,markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh",title=" Day_ControlAble_PeakTime_DR", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm)
Plot_Day_load_ForSubscriber_Control_Able_NoT_PeakTime_After_DR_Signal=plot(scatter(NN,Day_load_ForSubscriber_Control_Able_NoT_PeakTime_list_After_DR_Signal, color=cols,mode="markers",markershape=:star,markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh", title=" Day_Control_Able_NoT_PeakTime_DR", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm)
Plot_Day_load_ForSubscriber_ControlAble_load_After_DR_Signal=plot(scatter(NN,Day_load_ForSubscriber_ControlAble_load_list_After_DR_Signal, color=cols,mode="markers",markershape=:star,markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh", title=" Day_Control_Able_DR", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm)
Plot_Day_load_ForSubscriber_UnControlAble_load_After_DR_Signal=plot(scatter(NN,Day_load_ForSubscriber_UnControlAble_load_list_After_DR_Signal, color=cols,mode="markers",markershape=:star,markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh", title=" Day_UnControl_Able_DR", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm)
Plot_Day_load_ForSubscriber_Net_load_After_DR_Signal=plot(scatter(NN,Day_load_ForSubscriber_Net_load_list_After_DR_Signal, color=cols,mode="markers",markershape=:star,markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh",title=" Day_Net_Load_DR", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm)
Load_BeforeApplyCod_After_DR_Signal=plot(Plot_Day_load_ForSubscriber_Control_Able_PeakTime_After_DR_Signal,Plot_Day_load_ForSubscriber_Control_Able_NoT_PeakTime_After_DR_Signal)
#savefig(Load_BeforeApplyCod_After_DR_Signal,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_Load_After_DR.png")
##############
Control_Able_PeakTime_Load_BeforeAndAfter_DR_Signal=plot(Plot_Day_load_ForSubscriber_Control_Able_PeakTime,Plot_Day_load_ForSubscriber_Control_Able_PeakTime_After_DR_Signal)
savefig(Control_Able_PeakTime_Load_BeforeAndAfter_DR_Signal,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_Load_ControlAble_PeakTime_BeforeAndAfter_DR.png")
ControlAble_load_BeforeAndAfter_DR_Signal=plot(Plot_Day_load_ForSubscriber_ControlAble_load,Plot_Day_load_ForSubscriber_ControlAble_load_After_DR_Signal)
savefig(ControlAble_load_BeforeAndAfter_DR_Signal,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_Load_ControlAble_BeforeAndAfter_DR.png")
Net_load_BeforeAndAfter_DR_Signal=plot(Plot_Day_load_ForSubscriber_Net_load,Plot_Day_load_ForSubscriber_Net_load_After_DR_Signal)
#savefig(Net_load_BeforeAndAfter_DR_Signal,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_Load_Net_load_BeforeAndAfter_DR.png")



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
                        "Appliences_Scheduled_total_PeakTime_Eng_consump_updated"=>Appliences_Scheduled_total_PeakTime_Eng_consump_After_DR_Signal[n][a]## PRE DETERMIND PARAMETERÍ 3^(1/20)
                        )
            end
end



Applience_DetailsFor_home_After_DR_Signal=Dict()
for n in N
    Applience_DetailsFor_home_After_DR_Signal[n]=Dict()
            for a in A
                Applience_DetailsFor_home_After_DR_Signal[n][a]=Dict( #
                        "Time_Can_be_scheduleds"=>Applience_Time_Can_be_scheduled[n][a],#### suscriber determine( we consieder, these times can be different intervals
                        "Times_Can_not_be_scheduleds"=>Applience_Times_Can_not_be_scheduled[n][a],####
                        "E_MaX"=>E_MaX_After_DR_Signal[n][a],#### According to Cris imagiantion, midnight, this number should be setted by ML to, howevre, We should have Histroy#### Manual determine it. e.x. Max of HVAC Heating set= 70  ---> E_max (since that is kWh) it should come form the gridlabD
                        "E_MiN_ProbablyOffTimeofApplience"=>E_MiN_After_DR_Signal[n][a],#### #### Manual determine it. e.x. Min of HVAC Heating set= 60  ---> E_min (since that is kWh)
                        "E_Mean"=>E_Mean_After_DR_Signal[n][a],#### #### Manual determine it. e.x. Min of HVAC Heating set= 60  ---> E_min (since that is kWh)
                        "Appliences_Scheduled_total_PeakTime_Eng_consump_Refrence"=>Appliences_Scheduled_total_PeakTime_Eng_consump[n][a],## PRE DETERMIND PARAMETERÍ 3^(1/20)
                        "Appliences_Scheduled_total_PeakTime_Eng_consump_After_DR_Signal"=>Appliences_Scheduled_total_PeakTime_Eng_consump_After_DR_Signal[n][a]## PRE DETERMIND PARAMETERÍ 3^(1/20)
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


for n in N
    for a in A
        if a==1
            Applience_DetailsFor_home_After_DR_Signal[n][a]["Hourly_Applience_load"]=HVAC_load_After_DR_Signal[n]
            Applience_DetailsFor_home_After_DR_Signal[n][a]["Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction"]=0

        elseif a==2
            Applience_DetailsFor_home_After_DR_Signal[n][a]["Hourly_Applience_load"]=WaterHeter_load_After_DR_Signal[n]
            Applience_DetailsFor_home_After_DR_Signal[n][a]["Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction"]=0
        elseif a==3
            Applience_DetailsFor_home_After_DR_Signal[n][a]["Hourly_Applience_load"]=DISHWASHER_load_After_DR_Signal[n]
            Applience_DetailsFor_home_After_DR_Signal[n][a]["Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction"]=0

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


# Notice "Net_load"
Homes_E_MaX_After_DR_Signal=Dict()
Homes_E_MaX_hour_After_DR_Signal=Dict()
for n in N
    Homes_E_MaX_After_DR_Signal[n]=maximum(Net_load_After_DR_Signal[n])
    Homes_E_MaX_hour_After_DR_Signal[n]=0
    for h in H
        if (Homes_E_MaX_After_DR_Signal[n]==Net_load_After_DR_Signal[n][h])#
            Homes_E_MaX_hour_After_DR_Signal[n]= h
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
        CostFunctionParameters[h]=Dict("a_h"=>(0.065))
    elseif(h>=8 && h<12)
        CostFunctionParameters[h]=Dict("a_h"=>(0.11))
    elseif(h>=12 && h<18)##18 ---> 6 pm
        CostFunctionParameters[h]=Dict("a_h"=>(0.16))
    elseif(h>=18 && h<22)
        CostFunctionParameters[h]=Dict("a_h"=>(0.11))
    elseif(h>=22)
        CostFunctionParameters[h]=Dict("a_h"=>(0.065))
    end
end

CostProfile=[]
for h in H
    append!(CostProfile,CostFunctionParameters[h]["a_h"])## bring out only number
end

## In oginal file this part is after optimization

##
# Getting new information after optimization, etting new information after optimization, etting new information after optimization

Day_Control_Able_PeakTime_Load_After_DR_Signal=Dict()
for n in N
    temp_1=0
    for a in A
        temp_1=temp_1+Applience_DetailsFor_home[n][a]["Appliences_Scheduled_total_PeakTime_Eng_consump_updated"]
    end
    Day_Control_Able_PeakTime_Load_After_DR_Signal[n]=temp_1
end


## Add optimized information

for n in N
        for a in A
            for h in H
                Hourly_loads_ForSubscriber[n][h]["Hourly_ControlAble_load_ForSubscriber_After_DR_Signal"]=0.0
                if a==1
                    Hourly_loads_ForSubscriber[n][h]["Hourly_HVAC_load_ForSubscriber_After_DR_Signal"]= Hourly_Applience_DetailsFor_home_After_DR_Signal[n][1][h]
                    Hourly_loads_ForSubscriber[n][h]["Hourly_ControlAble_load_ForSubscriber_After_DR_Signal"]=Hourly_Applience_DetailsFor_home_After_DR_Signal[n][1][h]+Hourly_loads_ForSubscriber[n][h]["Hourly_ControlAble_load_ForSubscriber_After_DR_Signal"]
                elseif a==2
                    Hourly_loads_ForSubscriber[n][h]["Hourly_WaterHeter_load_ForSubscriber_After_DR_Signal"]=Hourly_Applience_DetailsFor_home_After_DR_Signal[n][2][h]
                    Hourly_loads_ForSubscriber[n][h]["Hourly_ControlAble_load_ForSubscriber_After_DR_Signal"]=Hourly_Applience_DetailsFor_home_After_DR_Signal[n][2][h]+Hourly_loads_ForSubscriber[n][h]["Hourly_ControlAble_load_ForSubscriber_After_DR_Signal"]
                elseif a==3
                    Hourly_loads_ForSubscriber[n][h]["Hourly_DISHWASHER_load_ForSubscriber_After_DR_Signal"]=Hourly_Applience_DetailsFor_home_After_DR_Signal[n][3][h]
                    Hourly_loads_ForSubscriber[n][h]["Hourly_ControlAble_load_ForSubscriber_After_DR_Signal"]=Hourly_Applience_DetailsFor_home_After_DR_Signal[n][3][h]+Hourly_loads_ForSubscriber[n][h]["Hourly_ControlAble_load_ForSubscriber_After_DR_Signal"]
                end
            end
        end
        Day_load_ForSubscriber[n]["Day_Control_Able_PeakTime_Load_After_DR_Signal"]=Day_Control_Able_PeakTime_Load_After_DR_Signal[n]
end


##### update information
for n in N
    Temp_1=0
    Temp_2=0
    Temp_3=0
    for h in H
        Temp_1=Hourly_loads_ForSubscriber[n][h]["Hourly_ControlAble_load_ForSubscriber_After_DR_Signal"]
        Temp_2=Hourly_loads_ForSubscriber[n][h]["Hourly_UnControlAble_load_ForSubscriber"]
        Hourly_loads_ForSubscriber[n][h]["Hourly_Net_load_ForSubscriber_After_DR_Signal"]=Temp_1+Temp_2
        ##
        Temp_3=Temp_3+Hourly_loads_ForSubscriber[n][h]["Hourly_Net_load_ForSubscriber_After_DR_Signal"]
    end
    Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber_After_DR_Signal"]=Temp_3
    Day_load_ForSubscriber[n]["Day_ControlAble_load_ForSubscriber_After_DR_Signal"]=Day_Control_Able_NoT_PeakTime_Load[n]+Day_load_ForSubscriber[n]["Day_Control_Able_PeakTime_Load_After_DR_Signal"]
end


Day_load_ForSubscriber_Control_Able_PeakTime_After_DR_Signal_list=zeros(length(NN))
Day_load_ForSubscriber_ControlAble_load_After_DR_Signal_list=zeros(length(NN))
Day_load_ForSubscriber_Net_load_After_DR_Signal_list=zeros(length(NN))


iter_Day_load_ForSubscriber=0
for n in N
    global iter_Day_load_ForSubscriber=iter_Day_load_ForSubscriber+1
    Day_load_ForSubscriber_Control_Able_PeakTime_After_DR_Signal_list[iter_Day_load_ForSubscriber]=Day_load_ForSubscriber[n]["Day_Control_Able_PeakTime_Load_After_DR_Signal"]
    Day_load_ForSubscriber_ControlAble_load_After_DR_Signal_list[iter_Day_load_ForSubscriber]=Day_load_ForSubscriber[n]["Day_ControlAble_load_ForSubscriber_After_DR_Signal"]
    Day_load_ForSubscriber_Net_load_After_DR_Signal_list[iter_Day_load_ForSubscriber]=Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber_After_DR_Signal"]
end



##
Hourly_Net_load_After_DR_Signal=Dict()
Hourly_ControlAble_load_After_DR_Signal=Dict()
Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction=Dict()

for n in N
    Hourly_Net_load_After_DR_Signal[n]=[]
    Hourly_ControlAble_load_After_DR_Signal[n]=[]
    Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction[n]=Dict()
    for h in H
        append!(Hourly_Net_load_After_DR_Signal[n],Hourly_loads_ForSubscriber[n][h]["Hourly_Net_load_ForSubscriber_After_DR_Signal"])
        append!(Hourly_ControlAble_load_After_DR_Signal[n],Hourly_loads_ForSubscriber[n][h]["Hourly_ControlAble_load_ForSubscriber_After_DR_Signal"])
    end
    for a in A
        Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction[n][a]=Applience_DetailsFor_home[n][a]["Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction"]
        Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction[n,a]=Applience_DetailsFor_home[n][a]["Selected_Percent_Control_Able_total_PeakTimeLoad_Reduction"]
    end
    Day_load_ForSubscriber[n]["Day_Net_load_Reduction_After_After_DR_Signal"]=Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber"]- Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber_After_DR_Signal"]
    Day_load_ForSubscriber[n]["Percent_Day_Control_Able_PeakTime_Reduction_After_DR_Signal"]=((Day_load_ForSubscriber[n]["Day_Control_Able_PeakTime_Load"]-Day_load_ForSubscriber[n]["Day_Control_Able_PeakTime_Load_After_DR_Signal"])/Day_load_ForSubscriber[n]["Day_Control_Able_PeakTime_Load"])*100
    Day_load_ForSubscriber[n]["Percent_Day_ControlAble_load_ForSubscriber_Reduction_After_DR_Signal"]=((Day_load_ForSubscriber[n]["Day_ControlAble_load_ForSubscriber"]-Day_load_ForSubscriber[n]["Day_ControlAble_load_ForSubscriber_After_DR_Signal"])/Day_load_ForSubscriber[n]["Day_ControlAble_load_ForSubscriber"])*100
    Day_load_ForSubscriber[n]["Percent_Day_Net_load_ForSubscriber_Reduction_After_DR_Signal"]=((Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber"]-Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber_After_DR_Signal"])/Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber"])*100

end







iter_load_After_DR_Signal_list=0
Hourly_Aggregate_Net_load_After_DR_Signal=zeros(length(NH))


for n in N
    global iter_load_After_DR_Signal_list=iter_load_After_DR_Signal_list+1
    global Hourly_Aggregate_Net_load_After_DR_Signal=Hourly_Aggregate_Net_load_After_DR_Signal+Hourly_Net_load_After_DR_Signal[n]
end

Plot_Hourly_Aggregate_Net_load_After_DR_Signal=plot(NH, [Hourly_Aggregate_Net_load_After_DR_Signal],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="Hourly_Aggregate_Net_load loads", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm, label="")




Day_Percent_Control_Able_total_PeakTimeLoad_Reduction_for_Each_Applience_list_After_DR_Signal=zeros(length(NN))
Day_Percent_ControlAble_load_ForSubscriber_Reduction_list_After_DR_Signal=zeros(length(NN))
Day_Percent_Net_load_ForSubscriber_Reduction_list_After_DR_Signal=zeros(length(NN))

iter_Day_load_ForSubscriber=0
for n in N
    global iter_Day_load_ForSubscriber=iter_Day_load_ForSubscriber+1
    Day_Percent_Control_Able_total_PeakTimeLoad_Reduction_for_Each_Applience_list_After_DR_Signal[iter_Day_load_ForSubscriber]=Day_load_ForSubscriber[n]["Percent_Day_Control_Able_PeakTime_Reduction_After_DR_Signal"]
    Day_Percent_ControlAble_load_ForSubscriber_Reduction_list_After_DR_Signal[iter_Day_load_ForSubscriber]=Day_load_ForSubscriber[n]["Percent_Day_ControlAble_load_ForSubscriber_Reduction_After_DR_Signal"]
    Day_Percent_Net_load_ForSubscriber_Reduction_list_After_DR_Signal[iter_Day_load_ForSubscriber]=Day_load_ForSubscriber[n]["Percent_Day_Net_load_ForSubscriber_Reduction_After_DR_Signal"]
end
#Plot_Day_load_ForSubscriber_Control_Able_PeakTime=plot(scatter(NN,[210,210,210,210], color=cols,mode="markers",markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Total Energy kWh", yticks=0:10:800,title=" Day_ControlAble_PeakTime", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm)
Plot_Day_Percent_Control_Able_total_PeakTimeLoad_Reduction_for_Each_Applience_After_DR_Signal=plot(scatter(NN, Day_Percent_Control_Able_total_PeakTimeLoad_Reduction_for_Each_Applience_list_After_DR_Signal, color=cols,mode="markers",markershape=:star,markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Percent Reduction",title="Day Percent_Control_Able_total_PeakTimeLoad_Reduction %", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm)
Plot_Day_Percent_ControlAble_load_ForSubscriber_Reduction_After_DR_Signal=plot(scatter(NN, Day_Percent_ControlAble_load_ForSubscriber_Reduction_list_After_DR_Signal, color=cols,mode="markers",markershape=:star,markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Percent Reduction",title="Day Percent_ControlAble_load_ForSubscriber_Reduction %", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm)
Plot_Day_Percent_Net_load_ForSubscriber_Reduction_After_DR_Signal=plot(scatter(NN, Day_Percent_Net_load_ForSubscriber_Reduction_list_After_DR_Signal, color=cols,mode="markers",markershape=:star,markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel="Percent Reduction",title="Day Percent_Net_load_ForSubscriber_Reduction %", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm)


## comperation      comperation         comperation

Hourly_ControlAble_load_Comperation_AfterAndBefore_DR_Signal=plot(Plot_Hourly_ControlAble_load,Plot_Hourly_ControlAble_load_After_DR_Signal)
savefig(Hourly_ControlAble_load_Comperation_AfterAndBefore_DR_Signal,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Hourly_Comperation_ControlAble_load_AfterAndBefore_DR_Signal.png")

Hourly_Net_load_Comperation_AfterAndBefore_DR_Signal=plot(Plot_Hourly_Net_load,Plot_Hourly_Net_load_After_DR_Signal)
savefig(Hourly_Net_load_Comperation_AfterAndBefore_DR_Signal,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Hourly_Comperation_Net_load_AfterAndBefore_DR_Signal.png")

Hourly_NetAndControlAble_load_load_Comperation_AfterAndBefore_DR_Signal=plot(Plot_Hourly_ControlAble_load_After_DR_Signal,Plot_Hourly_Net_load_After_DR_Signal)
savefig(Hourly_NetAndControlAble_load_load_Comperation_AfterAndBefore_DR_Signal,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Hourly_Comperation_ControlAble_&Netloads_AfterAndBefore_DR_Signal.png")

Hourly_Aggregate_Net_loads_After_DR_Signal_Comperation_AfterAndBefore_DR_Signal=plot(NH, [Hourly_Aggregate_Net_load, Hourly_Aggregate_Net_load_After_DR_Signal],xlabel="Hours", xticks=0:1:24,ylabel="Energy kWh",title="Hourly_Aggregate_Net_load loads", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm)
savefig(Hourly_Aggregate_Net_loads_After_DR_Signal_Comperation_AfterAndBefore_DR_Signal,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Hourly_Comperation_Aggregate_loads_AfterAndBefore_DR_Signal.png")

Day_Percent_Control_Able_total_PeakTimeLoad_Reduction_for_Each_Applience_AfterAndBefore_DR_Signal=(Plot_Day_Percent_Control_Able_total_PeakTimeLoad_Reduction_for_Each_Applience_After_DR_Signal)
savefig(Day_Percent_Control_Able_total_PeakTimeLoad_Reduction_for_Each_Applience_AfterAndBefore_DR_Signal,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_Percent_Control_Able_total_PeakTimeLoad_Reduction_for_Each_Applience_AfterAndBefore_DR_Signal.png")

#Day_Percent_ControlAble_load_ForSubscriber_Reduction_for_Each_Applience_AfterAndBefore_DR_Signal=(Plot_Day_Percent_ControlAble_load_ForSubscriber_Reduction_After_DR_Signal)
#savefig(Day_Percent_ControlAble_load_ForSubscriber_Reduction_for_Each_Applience_AfterAndBefore_DR_Signal,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_Percent_ControlAble_load_ForSubscriber_Reduction_for_Each_Applience_AfterAndBefore_DR_Signal.png")

#Day_Percent_Net_load_ForSubscriber_Reduction_for_Each_Applience_AfterAndBefore_DR_Signal=(Plot_Day_Percent_Net_load_ForSubscriber_Reduction_After_DR_Signal)
#savefig(Day_Percent_Net_load_ForSubscriber_Reduction_for_Each_Applience_AfterAndBefore_DR_Signal,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_Percent_Net_load_ForSubscriber_Reduction_for_Each_Applience_AfterAndBefore_DR_Signal.png")



##
Day_Net_load_ForSubscriber=zeros(length(NN))
Day_Net_load_ForSubscriber_After_DR_Signal=zeros(length(NN))
Day_Percent_Net_load_AllHouses_Reduction_After_DR_Signal=zeros(length(NN))
#
Day_ControlAble_load_ForSubscriber=zeros(length(NN))
Day_ControlAble_load_ForSubscriber_After_DR_Signal=zeros(length(NN))
Day_Percent_ControlAble_load_AllHouses_Reduction_After_DR_Signal=zeros(length(NN))
############
Day_Net_load_ForSubscriber_AllHouses=0
Day_Net_load_ForSubscriber_After_DR_Signal_AllHouses=0

Day_ControlAble_load_ForSubscriber_AllHouses=0
Day_ControlAble_load_ForSubscriber_After_DR_Signal_AllHouses=0
iter_Day_load_ForSubscriber_AllHouses=0

for n in N
    global iter_Day_load_ForSubscriber_AllHouses=iter_Day_load_ForSubscriber_AllHouses+1
    global Day_Net_load_ForSubscriber_AllHouses=Day_Net_load_ForSubscriber_AllHouses
    global Day_Net_load_ForSubscriber_After_DR_Signal_AllHouses=Day_Net_load_ForSubscriber_After_DR_Signal_AllHouses
    global Day_ControlAble_load_ForSubscriber_AllHouses=Day_ControlAble_load_ForSubscriber_AllHouses
    global Day_ControlAble_load_ForSubscriber_After_DR_Signal_AllHouses=Day_ControlAble_load_ForSubscriber_After_DR_Signal_AllHouses
    Day_Net_load_ForSubscriber[iter_Day_load_ForSubscriber_AllHouses]=Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber"]
    Day_Net_load_ForSubscriber_AllHouses=Day_Net_load_ForSubscriber_AllHouses+Day_Net_load_ForSubscriber[iter_Day_load_ForSubscriber_AllHouses]
    Day_Net_load_ForSubscriber_After_DR_Signal[iter_Day_load_ForSubscriber_AllHouses]=Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber_After_DR_Signal"]
    Day_Net_load_ForSubscriber_After_DR_Signal_AllHouses=Day_Net_load_ForSubscriber_After_DR_Signal_AllHouses+Day_Net_load_ForSubscriber_After_DR_Signal[iter_Day_load_ForSubscriber_AllHouses]
    Day_Percent_Net_load_AllHouses_Reduction_After_DR_Signal[iter_Day_load_ForSubscriber_AllHouses]=((Day_Net_load_ForSubscriber[iter_Day_load_ForSubscriber_AllHouses]-Day_Net_load_ForSubscriber_After_DR_Signal[iter_Day_load_ForSubscriber_AllHouses])/Day_Net_load_ForSubscriber[iter_Day_load_ForSubscriber_AllHouses])*100
    #
    Day_ControlAble_load_ForSubscriber[iter_Day_load_ForSubscriber_AllHouses]=Day_load_ForSubscriber[n]["Day_ControlAble_load_ForSubscriber"]
    Day_ControlAble_load_ForSubscriber_AllHouses=Day_ControlAble_load_ForSubscriber_AllHouses+Day_ControlAble_load_ForSubscriber[iter_Day_load_ForSubscriber_AllHouses]
    Day_ControlAble_load_ForSubscriber_After_DR_Signal[iter_Day_load_ForSubscriber_AllHouses]=Day_load_ForSubscriber[n]["Day_ControlAble_load_ForSubscriber_After_DR_Signal"]
    Day_ControlAble_load_ForSubscriber_After_DR_Signal_AllHouses=Day_ControlAble_load_ForSubscriber_After_DR_Signal_AllHouses+Day_ControlAble_load_ForSubscriber_After_DR_Signal[iter_Day_load_ForSubscriber_AllHouses]
    Day_Percent_ControlAble_load_AllHouses_Reduction_After_DR_Signal[iter_Day_load_ForSubscriber_AllHouses]=((Day_ControlAble_load_ForSubscriber[iter_Day_load_ForSubscriber_AllHouses]-Day_ControlAble_load_ForSubscriber_After_DR_Signal[iter_Day_load_ForSubscriber_AllHouses])/Day_ControlAble_load_ForSubscriber[iter_Day_load_ForSubscriber_AllHouses])*100
end


###############
Plot_Day_Percent_Net_load_AllHouses_Reduction_After_DR_Signal=plot(scatter(NN, Day_Percent_Net_load_AllHouses_Reduction_After_DR_Signal, color=cols,mode="markers",markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel=" % Energy Usage Reduction",title=" Day_Percent_Net_load_AllHouses_Reduction_After_DR_Signal", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm)
savefig(Plot_Day_Percent_Net_load_AllHouses_Reduction_After_DR_Signal,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_Percent_Net_load_Reduction_After_DR_Signal.png")

Plot_Day_Percent_ControlAble_load_AllHouses_Reduction_After_DR_Signal=plot(scatter(NN, Day_Percent_ControlAble_load_AllHouses_Reduction_After_DR_Signal, color=cols,mode="markers",markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel=" % Energy Usage Reduction",title=" Day_Percent_ControlAble_load_Reduction_DR_Signal", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm)
savefig(Plot_Day_Percent_ControlAble_load_AllHouses_Reduction_After_DR_Signal,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_Percent_ControlAble_load_Reduction_After_DR_Signal.png")




#####
#####

for n in N
    Str_n=string(n)

    Day_ControlAble_load_Cost_temp=0
    Day_ControlAble_load_ForSubscriber_Cost_After_DR_Signal_temp=0

    Day_Net_load_Cost_temp=0
    Day_Net_load_ForSubscriber_Cost_After_DR_Signal_temp=0
    for h in H
        Hourly_ControlAble_load_Cost_temp=0
        Hourly_ControlAble_load_Cost_After_DR_Signal_temp=0
        #
        Hourly_Net_load_Cost_temp=0
        Hourly_Net_load_Cost_After_DR_Signal_temp=0
        ################
        Hourly_ControlAble_load_Cost_temp=(CostFunctionParameters[h]["a_h"]*(Hourly_loads_ForSubscriber[n][h]["Hourly_ControlAble_load_ForSubscriber"])^2 )
        Hourly_loads_ForSubscriber[n][h]["Hourly_ControlAble_load_Cost_ForSubscriber"]=Hourly_ControlAble_load_Cost_temp
        Day_ControlAble_load_Cost_temp=Day_ControlAble_load_Cost_temp+Hourly_ControlAble_load_Cost_temp
        ##
        Hourly_ControlAble_load_Cost_After_DR_Signal_temp=(CostFunctionParameters[h]["a_h"]*(Hourly_loads_ForSubscriber[n][h]["Hourly_ControlAble_load_ForSubscriber_After_DR_Signal"])^2 )
        Hourly_loads_ForSubscriber[n][h]["Hourly_ControlAble_load_Cost_ForSubscriber_After_DR_Signal"]=Hourly_ControlAble_load_Cost_After_DR_Signal_temp
        Day_ControlAble_load_ForSubscriber_Cost_After_DR_Signal_temp=Day_ControlAble_load_ForSubscriber_Cost_After_DR_Signal_temp+Hourly_ControlAble_load_Cost_After_DR_Signal_temp
        ################
        Hourly_Net_load_Cost_temp=(CostFunctionParameters[h]["a_h"]*(Hourly_loads_ForSubscriber[n][h]["Hourly_Net_load_ForSubscriber"])^2 )
        Hourly_loads_ForSubscriber[n][h]["Hourly_Net_load_Cost_ForSubscriber"]=Hourly_Net_load_Cost_temp
        Day_Net_load_Cost_temp=Day_Net_load_Cost_temp+Hourly_Net_load_Cost_temp
        ##
        Hourly_Net_load_Cost_After_DR_Signal_temp=(CostFunctionParameters[h]["a_h"]*(Hourly_loads_ForSubscriber[n][h]["Hourly_Net_load_ForSubscriber_After_DR_Signal"])^2 )
        Hourly_loads_ForSubscriber[n][h]["Hourly_Net_load_Cost_ForSubscriber_After_DR_Signal"]=Hourly_Net_load_Cost_After_DR_Signal_temp
        Day_Net_load_ForSubscriber_Cost_After_DR_Signal_temp=Day_Net_load_ForSubscriber_Cost_After_DR_Signal_temp+Hourly_Net_load_Cost_After_DR_Signal_temp
    end
    #println("House_"*Str_n*" Cost_initial = ",Day_Net_load_Cost_temp)
    Day_load_ForSubscriber[n]["Day_Net_load_Cost"]=Day_Net_load_Cost_temp
    #println("House_"*Str_n*" Cost_After_DR_Signal = ",Day_Net_load_ForSubscriber_Cost_After_DR_Signal_temp)
    Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber_Cost_After_DR_Signal"]=Day_Net_load_ForSubscriber_Cost_After_DR_Signal_temp
    #
    Day_load_ForSubscriber[n]["Day_ControlAble_load_Cost"]=Day_ControlAble_load_Cost_temp
    Day_load_ForSubscriber[n]["Day_ControlAble_load_ForSubscriber_Cost_After_DR_Signal"]=Day_ControlAble_load_ForSubscriber_Cost_After_DR_Signal_temp
end



Day_Net_load_ForSubscriber_Cost=zeros(length(NN))
Day_Net_load_ForSubscriber_Cost_After_DR_Signal=zeros(length(NN))
Day_Percent_Net_load_Cost_Reduction_After_DR_Signal=zeros(length(NN))
#
Day_ControlAble_load_ForSubscriber_Cost=zeros(length(NN))
Day_ControlAble_load_ForSubscriber_Cost_After_DR_Signal=zeros(length(NN))
Day_Percent_ControlAble_load_Cost_Reduction_After_DR_Signal=zeros(length(NN))
############
Day_Net_load_ForSubscriber_Cost_AllHouses=0
Day_Net_load_ForSubscriber_Cost_After_DR_Signal_AllHouses=0

Day_ControlAble_load_ForSubscriber_Cost_AllHouses=0
Day_ControlAble_load_ForSubscriber_Cost_After_DR_Signal_AllHouses=0

iter_Day_load_ForSubscriber_Cost=0
for n in N
    global iter_Day_load_ForSubscriber_Cost=iter_Day_load_ForSubscriber_Cost+1
    global Day_Net_load_ForSubscriber_Cost_AllHouses=Day_Net_load_ForSubscriber_Cost_AllHouses
    global Day_Net_load_ForSubscriber_Cost_After_DR_Signal_AllHouses=Day_Net_load_ForSubscriber_Cost_After_DR_Signal_AllHouses
    global Day_ControlAble_load_ForSubscriber_Cost_AllHouses=Day_ControlAble_load_ForSubscriber_Cost_AllHouses
    global Day_ControlAble_load_ForSubscriber_Cost_After_DR_Signal_AllHouses=Day_ControlAble_load_ForSubscriber_Cost_After_DR_Signal_AllHouses
    Day_Net_load_ForSubscriber_Cost[iter_Day_load_ForSubscriber_Cost]=Day_load_ForSubscriber[n]["Day_Net_load_Cost"]
    Day_Net_load_ForSubscriber_Cost_AllHouses=Day_Net_load_ForSubscriber_Cost_AllHouses+Day_Net_load_ForSubscriber_Cost[iter_Day_load_ForSubscriber_Cost]
    Day_Net_load_ForSubscriber_Cost_After_DR_Signal[iter_Day_load_ForSubscriber_Cost]=Day_load_ForSubscriber[n]["Day_Net_load_ForSubscriber_Cost_After_DR_Signal"]
    Day_Net_load_ForSubscriber_Cost_After_DR_Signal_AllHouses=Day_Net_load_ForSubscriber_Cost_After_DR_Signal_AllHouses+Day_Net_load_ForSubscriber_Cost_After_DR_Signal[iter_Day_load_ForSubscriber_Cost]
    Day_Percent_Net_load_Cost_Reduction_After_DR_Signal[iter_Day_load_ForSubscriber_Cost]=((Day_Net_load_ForSubscriber_Cost[iter_Day_load_ForSubscriber_Cost]-Day_Net_load_ForSubscriber_Cost_After_DR_Signal[iter_Day_load_ForSubscriber_Cost])/Day_Net_load_ForSubscriber_Cost[iter_Day_load_ForSubscriber_Cost])*100
    #
    Day_ControlAble_load_ForSubscriber_Cost[iter_Day_load_ForSubscriber_Cost]=Day_load_ForSubscriber[n]["Day_ControlAble_load_Cost"]
    Day_ControlAble_load_ForSubscriber_Cost_AllHouses=Day_ControlAble_load_ForSubscriber_Cost_AllHouses+Day_ControlAble_load_ForSubscriber_Cost[iter_Day_load_ForSubscriber_Cost]
    Day_ControlAble_load_ForSubscriber_Cost_After_DR_Signal[iter_Day_load_ForSubscriber_Cost]=Day_load_ForSubscriber[n]["Day_ControlAble_load_ForSubscriber_Cost_After_DR_Signal"]
    Day_ControlAble_load_ForSubscriber_Cost_After_DR_Signal_AllHouses=Day_ControlAble_load_ForSubscriber_Cost_After_DR_Signal_AllHouses+Day_ControlAble_load_ForSubscriber_Cost_After_DR_Signal[iter_Day_load_ForSubscriber_Cost]
    Day_Percent_ControlAble_load_Cost_Reduction_After_DR_Signal[iter_Day_load_ForSubscriber_Cost]=((Day_ControlAble_load_ForSubscriber_Cost[iter_Day_load_ForSubscriber_Cost]-Day_ControlAble_load_ForSubscriber_Cost_After_DR_Signal[iter_Day_load_ForSubscriber_Cost])/Day_ControlAble_load_ForSubscriber_Cost[iter_Day_load_ForSubscriber_Cost])*100
end



###############

Plot_Day_Percent_Net_load_Cost_Reduction_After_DR_Signal=plot(scatter(NN, Day_Percent_Net_load_Cost_Reduction_After_DR_Signal, color=cols,mode="markers",markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel=" % Cost Reduction",title=" Day_Percent_Net_load_Cost_Reduction_DR", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm)
savefig(Plot_Day_Percent_Net_load_Cost_Reduction_After_DR_Signal,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Cost_Day_Percent_Net_load_Reduction_After_DR.png")

Plot_Day_Percent_ControlAble_load_Cost_Reduction_After_DR_Signal=plot(scatter(NN, Day_Percent_ControlAble_load_Cost_Reduction_After_DR_Signal, color=cols,mode="markers",markersize = 12),xlabel="Homes", xticks=0:1:24,ylabel=" % Cost Reduction",title=" Day_Percent_ControlAble_load_Cost_Reduction_DR", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm)
savefig(Plot_Day_Percent_ControlAble_load_Cost_Reduction_After_DR_Signal,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Cost_Day_Percent_ControlAble_load_Reduction_After_DR.png")


#####
###################
###################
#####
#####
Hourly_Net_load_Cost_=Dict()
Hourly_Net_load_Cost_After_DR_Signal_=Dict()
for n in N
    Hourly_Net_load_Cost_[n]=[]
    Hourly_Net_load_Cost_After_DR_Signal_[n]=[]
    for h in H
        append!(Hourly_Net_load_Cost_[n],Hourly_loads_ForSubscriber[n][h]["Hourly_Net_load_Cost_ForSubscriber"])
        append!(Hourly_Net_load_Cost_After_DR_Signal_[n],Hourly_loads_ForSubscriber[n][h]["Hourly_Net_load_Cost_ForSubscriber_After_DR_Signal"])
    end
end


Plot_Hourly_Net_load_Cost_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for
Plot_Hourly_Net_load_Cost_After_DR_Signal_list=[zeros(length(NH)) for _ in 1:length(NN)]## Make list for

iter_Hourly_make_net_load_Cost=0
for n in N
    global iter_Hourly_make_net_load_Cost=iter_Hourly_make_net_load_Cost+1
    #
    Plot_Hourly_Net_load_Cost_list[iter_Hourly_make_net_load_Cost]=Hourly_Net_load_Cost_[n]
    Plot_Hourly_Net_load_Cost_After_DR_Signal_list[iter_Hourly_make_net_load_Cost]=Hourly_Net_load_Cost_After_DR_Signal_[n]
end

Plot_Hourly_Net_load_Cost_initial=plot(NH, [Plot_Hourly_Net_load_Cost_list],xlabel="Hours", xticks=0:1:24,ylabel="Cost \$Dollar/kWh",title="Net loads", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm, label="")
Plot_Hourly_Net_load_Cost_After_DR_Signal=plot(NH, [Plot_Hourly_Net_load_Cost_After_DR_Signal_list],xlabel="Hours", xticks=0:1:24,ylabel="Cost \$Dollar/kWh",title="Net_load_DR", size=(2000,1000),lw=6, titlefontsize=40, legendfontsize=40, guidefontsize=20, legendtitlefontsize=40,tickfontsize=17,margin= 20Plots.mm, top_margin= 12Plots.mm, bottom_margin= 12Plots.mm, left_margin= 12Plots.mm, right_margin= 12Plots.mm, label="")
Hourly_Net_load_Cost_Comperation_AfterAndBefore_DR_Signal=plot(Plot_Hourly_Net_load_Cost_initial,Plot_Hourly_Net_load_Cost_After_DR_Signal)
savefig(Hourly_Net_load_Cost_Comperation_AfterAndBefore_DR_Signal,""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Cost_Hourly_Comperation_Net_load_AfterAndBefore_DR_Signal.png")



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
    PyPlot.plot(NH_PyPlot, HVAC_load[n], color="blue", linewidth=4.0, label ="HVAC Initial")
    PyPlot.plot(NH_PyPlot, Net_load_After_DR_Signal[n], color="black", linewidth=6.0, label ="Net After_DR",linestyle="--")
    #PyPlot.plot(NH_PyPlot, UnControlAble_load_After_DR_Signal[n], color="magenta", linewidth=6.0, label ="Uncontroled After_DR",linestyle=":")
    PyPlot.plot(NH_PyPlot, HVAC_load_After_DR_Signal[n], color="purple", linewidth=6.0, label ="HVAC After_DR",linestyle="-.")
    #plot( NH, PyPlot_HVAC_DR, color='k', label ="HVAC After_DR")#cols
    PyPlot.title("Energy Usage [kWh] House_"*Str_n*"_DR_Signal",fontsize=25)
    #title("Energy Usage [kWh]",fontsize=25)
    PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
    #######PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
    PyPlot.xticks(0:1:24,fontsize=25)
    PyPlot.yticks(fontsize=25)
    PyPlot.grid()
    PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Hourly_Comperation_House_"*Str_n*"_AfterAndBefore_DR_Signal.png")  ## optional command to save results.
    PyPlot.close(fig)
end





fig = figure(figsize=(20,10))
title("Day_Comperation_load_Net_AfterAndBefore_DR_Signal",fontsize=25)
R_PyPlot = PyPlot.scatter(NN,Day_load_ForSubscriber_Net_load_list,color="red",marker="o", label = "Energy Usage Initial [kWh] ",s=500)
B_PyPlot = PyPlot.scatter(NN,Day_load_ForSubscriber_Net_load_list_After_DR_Signal,color="blue",marker="x", label = "Energy Usage After_DR [kWh] ", s=700)
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(0:1:15,fontsize=40)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_Comperation_load_Net_AfterAndBefore_DR_Signal.png")  ## optional command to save results.
#####
fig = figure(figsize=(20,10))
title("Day_Comperation_load_Control_Able_PeakTime_AfterAndBefore_DR_Signal",fontsize=25)
R_PyPlot = PyPlot.scatter(NN,Day_load_ForSubscriber_Control_Able_PeakTime_list,color="red",marker="o", label = "Energy Usage Initial [kWh] ",s=500)
B_PyPlot = PyPlot.scatter(NN,Day_load_ForSubscriber_Control_Able_PeakTime_list_After_DR_Signal,color="blue",marker="x", label = "Energy Usage After_DR [kWh] ", s=700)
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(0:1:15,fontsize=40)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_Comperation_load_Control_Able_PeakTime_AfterAndBefore_DR_Signal.png")  ## optional command to save results.

###
fig = figure(figsize=(20,10))
title("Day_Comperation_load_ControlAble_load_AfterAndBefore_DR_Signal",fontsize=25)
R_PyPlot = PyPlot.scatter(NN,Day_load_ForSubscriber_ControlAble_load_list,color="red",marker="o", label = "Energy Usage Initial [kWh] ",s=500)
B_PyPlot = PyPlot.scatter(NN,Day_load_ForSubscriber_ControlAble_load_list_After_DR_Signal,color="blue",marker="x", label = "Energy Usage After_DR [kWh] ", s=700)
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(0:1:15,fontsize=40)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Day_Comperation_load_ControlAble_load_AfterAndBefore_DR_Signal.png")  ## optional command to save results.



fig = figure(figsize=(20,10))
title("Cost A Day_Net_load 12 Houses",fontsize=25)
R_PyPlot = PyPlot.scatter(NN,Day_Net_load_ForSubscriber_Cost,color="red",marker="o", label = "Cost Initial [\$ ] ",s=500)
B_PyPlot = PyPlot.scatter(NN,Day_Net_load_ForSubscriber_Cost_After_DR_Signal,color="blue",marker="x", label = "Cost After_DR [\$ ] ", s=700)
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(0:1:15,fontsize=40)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Cost_Day_Comperation_Net_load_AfterAndBefore_DR_Signal.png")  ## optional command to save results.
################
###############
fig = figure(figsize=(20,10))
title("Cost A Day_ControlAble_load 12 Houses",fontsize=25)
R_PyPlot = PyPlot.scatter(NN,Day_ControlAble_load_ForSubscriber_Cost,color="red",marker="o", label = "Cost Initial [\$ ] ",s=500)
B_PyPlot = PyPlot.scatter(NN,Day_ControlAble_load_ForSubscriber_Cost_After_DR_Signal,color="blue",marker="x", label = "Cost After_DR [\$ ] ", s=700)
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(0:1:15,fontsize=40)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Cost_Day_Comperation_ControlAble_load_AfterAndBefore_DR_Signal.png")  ## optional command to save results.
##################
NN_AllHouses=[1]
fig = figure(figsize=(20,10))
title("Cost A Day_Net_load_AllHouses",fontsize=25)
R_PyPlot = PyPlot.scatter(NN_AllHouses,Day_Net_load_ForSubscriber_Cost_AllHouses,color="red",marker="o", label = "Cost Initial [\$ ] ",s=500)
B_PyPlot = PyPlot.scatter(NN_AllHouses,Day_Net_load_ForSubscriber_Cost_After_DR_Signal_AllHouses,color="blue",marker="x", label = "Cost After_DR [\$ ] ", s=700)
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(fontsize=25)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Cost_Day_Net_load_AllHouses_Comperation_AfterAndBefore_DR_Signal.png")  ## optional command to save results.
#####

#####
fig = figure(figsize=(20,10))
title("Cost A Day_ControlAble_load_AllHouses",fontsize=25)
R_PyPlot = PyPlot.scatter(NN_AllHouses,Day_ControlAble_load_ForSubscriber_Cost_AllHouses,color="red",marker="o", label = "Cost Initial [\$ ] ",s=500)
B_PyPlot = PyPlot.scatter(NN_AllHouses,Day_ControlAble_load_ForSubscriber_Cost_After_DR_Signal_AllHouses,color="blue",marker="x", label = "Cost After_DR [\$ ] ", s=700)
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(fontsize=25)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Cost_Day_ControlAble_load_AllHouses_Comperation_AfterAndBefore_DR_Signal.png")  ## optional command to save results.
#####
#####
fig = figure(figsize=(20,10))
title("Cost A Day_load_AllHouses",fontsize=25)
R1_PyPlot = PyPlot.scatter(NN_AllHouses,Day_Net_load_ForSubscriber_Cost_AllHouses,color="red",marker="o", label = "Net Cost Initial [\$ ] ",s=500)
B2_PyPlot = PyPlot.scatter(NN_AllHouses,Day_Net_load_ForSubscriber_Cost_After_DR_Signal_AllHouses,color="g",marker="x", label = "Net Cost After_DR [\$ ] ", s=700)
R2_PyPlot = PyPlot.scatter(NN_AllHouses,Day_ControlAble_load_ForSubscriber_Cost_AllHouses,color="b",marker="v", label = "ControlAble Cost Initial [\$ ] ",s=500)
B2_PyPlot = PyPlot.scatter(NN_AllHouses,Day_ControlAble_load_ForSubscriber_Cost_After_DR_Signal_AllHouses,color="c",marker="<", label = "ControlAble Cost After_DR [\$ ] ", s=700)
#markers = ["." , "," , "o" , "v" , "^" , "<", ">"]
#colors = ['r','g','b','c','m', 'y', 'k']
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(fontsize=25)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Cost_Day_load_AllHouses_Comperation_AfterAndBefore_DR_Signal.png")  ## optional
#####

## today




NN_AllHouses=[1]
fig = figure(figsize=(20,10))
title("Total Day_Net_load_AllHouses",fontsize=25)
R_PyPlot = PyPlot.scatter(NN_AllHouses,Day_Net_load_ForSubscriber_AllHouses,color="red",marker="o", label = "Energy Usage Initial [kWh] ",s=500)
B_PyPlot = PyPlot.scatter(NN_AllHouses,Day_Net_load_ForSubscriber_After_DR_Signal_AllHouses,color="blue",marker="x", label = "Energy Usage After_DR_Signal [kWh] ", s=700)
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(fontsize=25)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Total_Day_Net_load_AllHouses_Comperation_AfterAndBefore_DR_Signal.png")  ## optional command to save results.
PyPlot.close(fig)
##################
##################
fig = figure(figsize=(20,10))
title("Total Day_ControlAble_load_AllHouses",fontsize=25)
R_PyPlot = PyPlot.scatter(NN_AllHouses,Day_ControlAble_load_ForSubscriber_AllHouses,color="red",marker="o", label = "Energy Usage Initial [kWh] ",s=500)
B_PyPlot = PyPlot.scatter(NN_AllHouses,Day_ControlAble_load_ForSubscriber_After_DR_Signal_AllHouses,color="blue",marker="x", label = "Energy Usage After_DR_Signal [kWh] ", s=700)
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(fontsize=25)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Total_Day_ControlAble_load_AllHouses_Comperation_AfterAndBefore_DR_Signal.png")  ## optional command to save results.
PyPlot.close(fig)
##################
##################
fig = figure(figsize=(20,10))
title("Total Day_load_AllHouses",fontsize=25)
R1_PyPlot = PyPlot.scatter(NN_AllHouses,Day_Net_load_ForSubscriber_AllHouses,color="red",marker="o", label = "Net Energy Usage Initial [kWh] ",s=500)
B2_PyPlot = PyPlot.scatter(NN_AllHouses,Day_Net_load_ForSubscriber_After_DR_Signal_AllHouses,color="g",marker="x", label = "Net Energy Usage After_DR_Signal [kWh] ", s=700)
R2_PyPlot = PyPlot.scatter(NN_AllHouses,Day_ControlAble_load_ForSubscriber_AllHouses,color="b",marker="v", label = "ControlAble Energy Usage Initial [kWh] ",s=500)
B2_PyPlot = PyPlot.scatter(NN_AllHouses,Day_ControlAble_load_ForSubscriber_After_DR_Signal_AllHouses,color="c",marker="<", label = "ControlAble Energy Usage After_DR_Signal [kWh] ", s=700)
#markers = ["." , "," , "o" , "v" , "^" , "<", ">"]
#colors = ['r','g','b','c','m', 'y', 'k']
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(fontsize=25)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/Total_Day_load_AllHouses_Comperation_AfterAndBefore_DR_Signal.png")  ## optional
PyPlot.close(fig)
############
############


#####     PAR                                    PAR

#####
fig = figure(figsize=(20,10))
title("PAR_load_AllHouses",fontsize=25)
R_PyPlot = PyPlot.scatter(NN_AllHouses,VPP_PAR,color="red",marker="o", label = "PAR Initial  ",s=500)
B_PyPlot = PyPlot.scatter(NN_AllHouses,VPP_PAR_After_DR_Signal,color="blue",marker="x", label = "PAR After_DR", s=700)
PyPlot.legend(loc="best",fontsize=25, handlelength= 3)
#PyPlot.legend(bbox_to_anchor =(0.60, 0.20), ncol = 4,fontsize=14, handlelength= 3)
PyPlot.xticks(fontsize=25)
PyPlot.yticks(fontsize=25)
PyPlot.grid()
PyPlot.savefig(""*OrginalFilesAddress*"jl_files/OutPut_of_jl/PAR_Comperation_AfterAndBefore_DR_Signal.png")  ## optional command to save results.
#####
#####

println("Total Day_Net_load__initial_AllHouses = ",Day_Net_load_ForSubscriber_AllHouses)
println("Total Day_Net_load_After_DR_Signal_AllHouses = ",Day_Net_load_ForSubscriber_After_DR_Signal_AllHouses)
println("Total Day_ControlAble_load_initial_AllHouses = ",Day_ControlAble_load_ForSubscriber_AllHouses)
println("Total Day_ControlAble_load_After_DR_Signal_AllHouses = ",Day_ControlAble_load_ForSubscriber_After_DR_Signal_AllHouses)


######
println("Day_Net_load_ForSubscriber_Cost_AllHouses = ",Day_Net_load_ForSubscriber_Cost_AllHouses)
println("Day_Net_load_ForSubscriber_Cost_After_DR_Signal_AllHouses = ",Day_Net_load_ForSubscriber_Cost_After_DR_Signal_AllHouses)
println("Day_ControlAble_load_ForSubscriber_Cost_AllHouses = ",Day_ControlAble_load_ForSubscriber_Cost_AllHouses)
println("Day_ControlAble_load_ForSubscriber_Cost_After_DR_Signal_AllHouses = ",Day_ControlAble_load_ForSubscriber_Cost_After_DR_Signal_AllHouses)
######

CostProfile_mean=mean(CostProfile)
println("CostProfile_mean = ",CostProfile_mean)
# objective is only base on ControlAble load
println("Cost base on (CostProfile_mean) for Total Day_ControlAble_load_initial_AllHouses = ",Day_ControlAble_load_ForSubscriber_AllHouses*CostProfile_mean)
println("Cost base on (CostProfile_mean) for Total Day_ControlAble_load_After_DR_Signal_AllHouses = ",Day_ControlAble_load_ForSubscriber_After_DR_Signal_AllHouses*CostProfile_mean)
