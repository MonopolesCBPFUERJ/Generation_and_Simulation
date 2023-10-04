: '

This Bash script is used to process simulated magnetic monopole event files. The script performs various steps of data processing, from checking the existence of the input file to generating output files in various steps of processing particle physics data.

The script starts by defining the directory that contains the input .lhe files and the specific file that will be processed. It then creates a directory for the configuration files, determines the file name without the path, checks that the input file can be opened, and creates a directory for the output files.

The script then performs various processing steps using the cmsDriver.py command, which is a CMSSW (CMS Computing Software) tool used to create Python configurations for simulations and data analysis. The script performs various processing steps including LHE, GENSIM, DIGI, HLT and RECO, each generating corresponding output files.

The script then runs the cmsRun command for each step, which runs the Python configuration created in the previous step. If any of these commands fail, the script will print an error message and exit.

Finally, the script executes a final cmsRun command with a different configuration file, removes the temporary files generated during processing, and prints a message indicating that the processing completed successfully.

Each step of data processing is detailed below:

1) LHE: The first step is to process the input .lhe file to create an output file containing LHE (Les Houches Event) events.

2) GENSIM: The second step is to process the output file from the LHE step to create a GENSIM file, which contains simulated events in GEN-SIM format.

3) DIGI: The third step is to process the GENSIM file to create a DIGI file, which contains events in GEN-SIM-DIGI format.

4) HLT: The fourth step is to process the DIGI file to create an HLT file, which contains events in GEN-SIM-RAW format.

5) RECO: The last step is to process the HLT file to create a RECO file, which contains events in AODSIM format.

After all these steps, the script executes a final cmsRun command using a different configuration file to create an AOD file from the RECO file. It then removes the temporary files generated during processing.

The script is designed to run in the CERN environment, as indicated by the file and directory paths used, and assumes that the CMSSW environment is set up correctly.
'
#!/bin/bash

# voms-proxy-init --rfc --voms cms -valid 192:00 -out $HOME/x509up_u130329
cmsenv
scram b -j 4

# Path to main input file
#MAIN_INPUT_FILE="/eos/home-m/matheus/magnetic_monopole_output/SpinHalf_PF_97_mass_3800_events_2000.lhe"
MAIN_INPUT_FILE=$1

# Extract the base name from the main input file for use in output file names
BASE_NAME=$(basename -- "$MAIN_INPUT_FILE")
BASE_NAME_NO_EXT="${BASE_NAME%.*}"

# Path to output directory
OUTPUT_PATH="/eos/home-m/matheus/magnetic_monopole_output_AOD"

# Performs the first step (GENSIM-DIGI)

python3 gensim_digi_step.py "$MAIN_INPUT_FILE"

# Sets the input file for the HLT step
HLT_INPUT_FILE="${OUTPUT_PATH}/${BASE_NAME_NO_EXT}_DIGI.root"

# Performs the second stage (HLT)
cd /afs/cern.ch/user/m/matheus/CMSSW_10_2_16_UL/src
cmsenv
scram b -j 4
python3 /afs/cern.ch/user/m/matheus/CMSSW_10_2_16_UL/src/hlt_step.py "$HLT_INPUT_FILE"

# Defines the input file for the RECO step
RECO_INPUT_FILE="${OUTPUT_PATH}/${BASE_NAME_NO_EXT}_HLT.root"

# Performs the third stage (RECO)
cd /afs/cern.ch/user/m/matheus/CMSSW_10_6_23/src
cmsenv
scram b -j 4
python3 reco_step.py "$RECO_INPUT_FILE"

# Sets the output file for the AOD step
AOD_OUTPUT_FILE="${OUTPUT_PATH}/${BASE_NAME_NO_EXT}_AOD.root"

# Runs the cmsRun command for the AOD step
cmsRun ntuple_mc_2018_cfg.py inputFiles=file:"$RECO_INPUT_FILE" outputFile="$AOD_OUTPUT_FILE"

# Removes the generated .root and .py files except the RECO.root file
for dir in /afs/cern.ch/user/m/matheus/CMSSW_10_6_23/src /afs/cern.ch/user/m/matheus/CMSSW_10_2_16_UL/src; do
    cd "$dir"
    for file in "${BASE_NAME_NO_EXT}"*; do
        if [[ $file == *LHE_cfg.py || $file == *GENSIM_cfg.py || $file == *DIGI_cfg.py || $file == *HLT_cfg.py || $file == *RECO_cfg.py ]]; then
            echo "Removing config file: $file"
            rm -f "$file"
        fi
    done
done

cd "$OUTPUT_PATH"
for file in "${BASE_NAME_NO_EXT}"*; do
    if [[ $file != *"_AOD.root" && $file == *.root ]]; then
        echo "Removing file: $file"
        rm -f "$file"
    fi
done

echo "All steps completed successfully."

cd /afs/cern.ch/user/m/matheus/CMSSW_10_6_23/src