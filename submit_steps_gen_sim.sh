#!/bin/bash

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

# If necessary, initialize the proxy certificate
# voms-proxy-init --rfc --voms cms -valid 192:00 -out $HOME/x509up_u130329

source /cvmfs/cms.cern.ch/cmsset_default.sh

# Set up the CMS environment
cmsenv
# Compile all the classes necessary with 8 jobs in parallel
scram b -j 8

#voms-proxy-info --all
#if [ $? -ne 0 ]; then
#    echo "Failed to access proxy"
#    exit 1
#fi

# .lhe file to be processed
file=$1
#file=/eos/home-m/matheus/magnetic_monopole_output/SpinHalf_PF_10_mass_3600_events_10000.lhe

# Get the base name of the file without the path
base=$(basename "$file")

echo "Processing file: $file"

# Check if the file can be opened
if ! [ -r "$file" ]; then
    echo "Could not open file: $file"
    exit 1
fi

# You need create this directory in your EOS
output_path="/eos/home-m/matheus/magnetic_monopole_output_AOD"

# Create the cmsDriver.py command with the specific file
cmsDriver.py step1 --filein "file:$file" --fileout "file:$output_path/${base%.lhe}_LHE.root" --mc --eventcontent LHE --datatier LHE --conditions 106X_upgrade2018_realistic_v16_L1v1 --step NONE --python_filename "${base%.lhe}_LHE_cfg.py" --no_exec -n -1 --customise_commands "process.source.firstLuminosityBlock = cms.untracked.uint32(3)"

if [ $? -ne 0 ]; then
    echo "cmsDriver.py command failed for file: $file"
    exit 1
fi

# Execute the cmsRun command and redirect the output to the created directory
cmsRun "${base%.lhe}_LHE_cfg.py"

if [ $? -ne 0 ]; then
    echo "cmsRun command failed for file: $file"
    exit 1
fi

echo "Processing for file $file completed successfully"

# Second step: GENSIM
echo "Processing GENSIM for file: $file"

mass=$(echo $base | sed -n 's/.*_mass_\([0-9]*\)_events.*/\1/p')
cmsDriver.py Configuration/GenProduction/python/Hadronizer_TuneCP5_13TeV_generic_LHE_pythia8_cff.py --filein "file:$output_path/${base%.lhe}_LHE.root"  --fileout "file:$output_path/${base%.lhe}_GENSIM.root" --mc --eventcontent RAWSIM --datatier GEN-SIM --conditions 106X_upgrade2018_realistic_v16_L1v1 --step GEN,SIM --beamspot Realistic25ns13TeVEarly2018Collision --geometry DB:Extended --era Run2_2018 --python_filename "${base%.lhe}_GENSIM_cfg.py" --customise_commands "from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper ; randSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService) ; randSvc.populate()\n process.g4SimHits.Physics.MonopoleMass = $mass" --no_exec --nThreads 8 -n -1

#cmsDriver.py Configuration/GenProduction/python/Hadronizer_TuneCP5_13TeV_generic_LHE_pythia8_cff.py --filein "file:$output_path/${base%.lhe}_LHE.root"  --fileout "file:$output_path/${base%.lhe}_GENSIM.root" --mc --eventcontent RAWSIM --datatier GEN-SIM --conditions 106X_upgrade2018_realistic_v16_L1v1 --step GEN,SIM --beamspot Realistic25ns13TeVEarly2018Collision --geometry DB:Extended --era Run2_2018 --python_filename "${base%.lhe}_GENSIM_cfg.py" --customise_commands "from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper ; randSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService) ; randSvc.populate()\n process.g4SimHits.Physics.MonopoleMass = 3000" --no_exec --nThreads 8 -n -1

if [ $? -ne 0 ]; then
    echo "GENSIM command failed for file: $file"
    exit 1
fi

# Execute the cmsRun command for the GENSIM step and redirect the output to the created directory
cmsRun "${base%.lhe}_GENSIM_cfg.py"

if [ $? -ne 0 ]; then
    echo "cmsRun command for GENSIM failed for file: $file"
    exit 1
fi

echo "Processing for GENSIM file $file completed successfully"

# Third step: DIGI
echo "Processing DIGI for file: $file"

cmsDriver.py step1 --filein "file:$output_path/${base%.lhe}_GENSIM.root" --fileout "file:$output_path/${base%.lhe}_DIGI.root"  --pileup_input "dbs:/Neutrino_E-10_gun/RunIISummer20ULPrePremix-UL18_106X_upgrade2018_realistic_v11_L1v1-v2/PREMIX" --mc --eventcontent PREMIXRAW --runUnscheduled --datatier GEN-SIM-DIGI --conditions 106X_upgrade2018_realistic_v16_L1v1 --step DIGI,DATAMIX,L1,DIGI2RAW --procModifiers premix_stage2 --nThreads 8 --geometry DB:Extended --datamix PreMix --era Run2_2018 --python_filename "${base%.lhe}_DIGI_cfg.py" --no_exec -n -1 --customise_commands "from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper ; randSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService) ; randSvc.populate()"

# Execute the cmsRun command for the DIGI step and redirect the output to the created directory
cmsRun "${base%.lhe}_DIGI_cfg.py" 

if [ $? -ne 0 ]; then
    echo "cmsRun command for DIGI failed for file: $file"
    exit 1
fi

echo "Processing for DIGI file $file completed successfully"

# Fourth Step - HLT

# Store the current directory path
CURRENT_DIR=$(pwd)

# Change to the specified directory
cd /afs/cern.ch/user/m/matheus/CMSSW_10_2_16_UL/src

cmsenv
scram b clean
scram b -j 8

# Processar a etapa HLT no novo diretório
echo "Processing HLT for file: $file"
cmsDriver.py step2 --filein "file:$output_path/${base%.lhe}_DIGI.root" --fileout "file:$output_path/${base%.lhe}_HLT.root" --mc --eventcontent RAWSIM --datatier GEN-SIM-RAW --conditions 102X_upgrade2018_realistic_v15 --customise_commands 'process.source.bypassVersionCheck = cms.untracked.bool(True)' --step HLT:2018v32 --nThreads 8 --geometry DB:Extended --era Run2_2018 --python_filename "${CURRENT_DIR}/${base%.lhe}_HLT_cfg.py" --no_exec -n -1

if [ $? -ne 0 ]; then
    echo "HLT command failed for file: $file"
    exit 1
fi

# Execute the cmsRun command using the absolute path to the configuration file
cmsRun "${CURRENT_DIR}/${base%.lhe}_HLT_cfg.py" 

if [ $? -ne 0 ]; then
    echo "cmsRun command for HLT failed for file: $file"
    exit 1
fi

echo "Processing for HLT file $file completed successfully"

# Return to the original directory

cd /afs/cern.ch/user/m/matheus/CMSSW_10_6_23/src

source /cvmfs/cms.cern.ch/cmsset_default.sh

cmsenv
scram b clean
scram b -j 8

# Última etapa: RECO
echo "Processing RECO for file: $file"

cmsDriver.py step3 --filein "file:$output_path/${base%.lhe}_HLT.root" --fileout "file:$output_path/${base%.lhe}_RECO.root" --mc --eventcontent AODSIM --datatier AODSIM --conditions 106X_upgrade2018_realistic_v16_L1v1 --step RAW2DIGI,L1Reco,RECO,RECOSIM --nThreads 8 --runUnscheduled --geometry DB:Extended --era Run2_2018 --customise=Configuration/DataProcessing/Utils.addMonitoring --customise_commands "process.AODSIMoutput.outputCommands.append('keep *_generatorSmeared_*_*') \n process.AODSIMoutput.outputCommands.append('keep *_hybridSuperClusters_*_*') \n process.AODSIMoutput.outputCommands.append('keep *_multi5x5SuperClusters_multi5x5EndcapSuperClusters_*') \n process.AODSIMoutput.outputCommands.append('keep *_multi5x5SuperClusters_uncleanOnlyMulti5x5EndcapBasicClusters_*') \n process.AODSIMoutput.outputCommands.append('keep *_multi5x5SuperClusters_uncleanOnlyMulti5x5EndcapSuperClusters_*') \n process.AODSIMoutput.outputCommands.append('keep *_siStripClusters_*_*') \n process.AODSIMoutput.outputCommands.append('keep *_siPixelClusters_*_*') \n process.AODSIMoutput.outputCommands.append('drop *_generalTracks_*_*') \n process.AODSIMoutput.outputCommands.append('keep *_generalTracks_*_*') \n process.AODSIMoutput.outputCommands.append('drop *_generalTracks_QualityMasks_*') \n process.AODSIMoutput.outputCommands.append('keep *_ecalRecHit_EcalRecHitsEB_*') \n process.AODSIMoutput.outputCommands.append('keep *_ecalRecHit_EcalRecHitsEE_*') \n process.AODSIMoutput.outputCommands.append('keep *_hbhereco_*_*') \n process.Timing.summaryOnly = cms.untracked.bool(True) \n process.Timing.excessiveTimeThreshold = cms.untracked.double(30.0) \n" --python_filename "${base%.lhe}_RECO_cfg.py" --no_exec -n -1
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
if [ $? -ne 0 ]; then
    echo "RECO command failed for file: $file"
    exit 1
fi

# Executar o comando cmsRun para a etapa RECO e redirecionar o output para o diretório criado
cmsRun "/afs/cern.ch/user/m/matheus/CMSSW_10_6_23/src/${base%.lhe}_RECO_cfg.py" 

if [ $? -ne 0 ]; then
    echo "cmsRun command for RECO failed for file: $file"
    exit 1
fi

echo "Processing for RECO file $file completed successfully"

cmsenv
scram b clean
scram b -j 8

cmsRun /afs/cern.ch/user/m/matheus/CMSSW_10_6_23/src/ntuple_mc_2018_cfg_new.py inputFiles="file:$output_path/${base%.lhe}_RECO.root" outputFile="file:$output_path/${base%.lhe}_AOD.root"

rm $output_path/*_LHE.root
rm $output_path/*_DIGI.root 
rm $output_path/*_GENSIM.root 
rm $output_path/*_HLT.root 
#rm $output_path/*_RECO.root 

rm *_LHE_cfg.py 
rm *_DIGI_cfg.py 
rm *_GENSIM_cfg.py 
rm *_HLT_cfg.py 
rm *_RECO_cfg.py 
