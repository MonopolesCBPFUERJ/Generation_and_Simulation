# Generation and Simulation

## Instructions for Generating Events with MadGraph

First, you must configure the environment. Inside the repository you can see the executable `environment_config_mg5.sh`.
Edit this script fallowing the steps:
* Choice the CMSSW release in the line 4 and modified the line 7 too.
* The line 33 and 36, change the path to you path until `$YOUPATH/src/MG5_aMC_v2_9_16/HEPTools/lhapdf6_py3/share/LHAPDF`
* Run this code with `./environment_config_mg5.sh`
* Open the new terminal
* Enter inside the CMSSW release that you create, for exemple `cd CMSSW_10_6_22/src/MG5_aMC_v2_9_16`
* Run this command to have acess the python 3.8 `source /afs/cern.ch/work/g/gcorreia/public/hepenv_setup.sh`
   
With MadGraph5 configured, inside the directory execute the commands:

    
     voms-proxy-init --rfc --voms cms -valid 192:00
     cmsenv

Now you may be able to run the code for generating the events.
The `Generation_Monopolo_MG5.py` file is responsible for the entire generation process. On lines 39 and 40 you should change the paths to the absolute path of the madgraph(`MADGRAPH_PATH_RUN`) and the output in your `eos` where the generation will be saved (`OUTPUT_DIR`).

    
     MADGRAPH_PATH_RUN = '/afs/cern.ch/user/m/matheus/CMSSW_10_6_24/src/MG5_aMC_v2_9_15/bin/mg5_aMC'
     OUTPUT_DIR = '/eos/home-m/matheus/magnetic_monopole_output'

The shell code `submit_mg5_condor.sh` is the executable that will be allocated to the condor (`condor_sub_mg5.sub`)

If you want to generate local code, just run it locally using

   ```
   python3 Generation_Monopolo_MG5.py -mass 1000 -events 100 -itera 10 -process photon_fusion -spin half

   -mass 1000 --> Monopole mass
   -events 100 --> How many events do you want to generate
   -itera 10 --> Number of times you want to generate the same code
   -process photon_fusion --> Which process do you want to run: Drell Yan or Photon Fusion
   -spin half --> Which spin do you want: Spin 0 or Spin 1/2
