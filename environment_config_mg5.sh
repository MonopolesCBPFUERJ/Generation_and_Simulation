#!/bin/bash

# 1. Download the Release
cmsrel CMSSW_10_6_22

# 2. Access the `src` Directory
cd CMSSW_10_6_22/src

# 3. Download MadGraph5
wget https://launchpad.net/mg5amcnlo/lts/2.9.x/+download/MG5_aMC_v2.9.16.tar.gz

# 4. Unzip the file
tar -xzvf MG5_aMC_v2.9.16.tar.gz
cd MG5_aMC_v2_9_16

# 5. Enter in virtual environment with python3
source /afs/cern.ch/work/g/gcorreia/public/hepenv_setup.sh

# Automatically install the packages and exit the MadGraph5 environment
echo -e "install MadAnalysis5\ninstall lhapdf6\nexit" | ./bin/mg5_aMC

# 6. Check for lhapdf-config
LHAPDF_CONFIG_PATH=$(which lhapdf-config)
if [ -z "$LHAPDF_CONFIG_PATH" ]; then
    echo "LHAPDF6 is not installed correctly or lhapdf-config is not in your PATH."
    # Handle error or install lhapdf6 here, if needed
else
    # Use the path in MadGraph
    echo -e "set lhapdf /cvmfs/sft.cern.ch/lcg/views/LCG_100/x86_64-centos7-gcc9-opt/bin/lhapdf-config\nsave options\nexit" | ./bin/mg5_aMC
fi

# 7. Set LHAPDF_DATA_PATH (You need to modify this path /afs/cern.ch/user/m/matheus/ to your directory)
export LHAPDF_DATA_PATH=/afs/cern.ch/user/m/matheus/CMSSW_10_6_22/src/MG5_aMC_v2_9_16/HEPTools/lhapdf6_py3/share/LHAPDF

# 8. Add the export command to ~/.bashrc (You need to modify this path /afs/cern.ch/user/m/matheus/ to your directory)
echo "export LHAPDF_DATA_PATH=/afs/cern.ch/user/m/matheus/CMSSW_10_6_23/src/MG5_aMC_v2_9_16/HEPTools/lhapdf6_py3/share/LHAPDF" >> ~/.bashrc
