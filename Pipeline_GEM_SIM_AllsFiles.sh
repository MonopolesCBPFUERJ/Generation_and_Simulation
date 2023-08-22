#!/bin/bash

#voms-proxy-init --rfc --voms cms -valid 192:00
cmsenv
scram b -j 8

# Lista dos diretórios onde estão os datasets
DIRS=(
    "/eos/home-m/matheus/root_monopolos/SpinHalf_DY_root"
    "/eos/home-m/matheus/root_monopolos/SpinHalf_PF_root"
    "/eos/home-m/matheus/root_monopolos/SpinZero_DY_root"
    "/eos/home-m/matheus/root_monopolos/SpinZero_PF_root"
)

# Cria um diretório para os arquivos de configuracão

mkdir -p "SpinHalf_PF_configs"

for dir in "${DIRS[@]}"; do
    # Lista de arquivos lhe em um diretório específico
    LHE_FILES=$(ls $dir | grep '.lhe$')
    
    for file in $LHE_FILES; do
        full_path="${dir}/${file}"

        # Resto do seu código...
        
        base=$(basename "$full_path")
        echo "Processing file: $full_path"

        if ! [ -r "$full_path" ]; then
            echo "Could not open file: $full_path"
            continue
        fi
        
        mkdir -p "${dir}/${base%.lhe}_AOD"
        
        #Criar o comando cmsDriver.py com o arquivo específico
        cmsDriver.py step1 --filein "file:$full_path" --fileout "file:${dir}/${base%.lhe}_AOD/${base%.lhe}_LHE.root" --mc --eventcontent LHE --datatier LHE --conditions 106X_upgrade2018_realistic_v16_L1v1 --step NONE --python_filename "SpinHalf_PF_configs/${base%.root}_LHE_cfg.py" --no_exec -n 10 --customise_commands "process.source.firstLuminosityBlock = cms.untracked.uint32(3)"


        if [ $? -ne 0 ]; then
            echo "cmsDriver.py command failed for file: $file"
            exit 1
        fi

        # Substituir a linha fileNames no arquivo de configuração
        #sed -i "s#fileNames = cms.untracked.vstring('file:/eos/home-m/matheus/root_monopolos/SpinHalf_PF_1000GeV_50000.lhe')#fileNames = cms.untracked.vstring('file:${file}')#g" "SpinHalf_PF_configs/${base%.lhe}_cfg.py"

        # Executar o comando cmsRun e redirecionar o output para o diretório criado
        cmsRun "SpinHalf_PF_configs/${base%.root}_LHE_cfg.py" #> "${dir}/${base%.lhe}_AOD/output.txt"

        if [ $? -ne 0 ]; then
            echo "cmsRun command failed for file: $file"
            exit 1
        fi

        echo "Processing for file $file completed successfully"

        # Segunda etapa: GENSIM
        echo "Processing GENSIM for file: $file"
        cmsDriver.py Configuration/GenProduction/python/Hadronizer_TuneCP5_13TeV_generic_LHE_pythia8_cff.py --filein "file:${dir}/${base%.lhe}_AOD/${base%.lhe}_LHE.root"  --fileout "file:${dir}/${base%.lhe}_AOD/${base%.lhe}_GENSIM.root" --mc --eventcontent RAWSIM --datatier GEN-SIM --conditions 106X_upgrade2018_realistic_v16_L1v1 --step GEN,SIM --beamspot Realistic25ns13TeVEarly2018Collision --geometry DB:Extended --era Run2_2018 --python_filename "SpinHalf_PF_configs/${base%.lhe}_GENSIM_cfg.py" --customise_commands "from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper ; randSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService) ; randSvc.populate()\n process.g4SimHits.Physics.MonopoleMass = 3000" --no_exec --nThreads 8 -n -1

        if [ $? -ne 0 ]; then
            echo "GENSIM command failed for file: $file"
            exit 1
        fi

        # Executar o comando cmsRun para a etapa GENSIM e redirecionar o output para o diretório criado
        cmsRun "SpinHalf_PF_configs/${base%.lhe}_GENSIM_cfg.py" #> "${dir}/${base%.lhe}_AOD/GENSIM_output.txt"

        if [ $? -ne 0 ]; then
            echo "cmsRun command for GENSIM failed for file: $file"
            exit 1
        fi

        echo "Processing for GENSIM file $file completed successfully"

        # Terceira etapa: DIGI
        echo "Processing DIGI for file: $file"

        cmsDriver.py step1 --filein "file:${dir}/${base%.lhe}_AOD/${base%.lhe}_GENSIM.root" --fileout "file:${dir}/${base%.lhe}_AOD/${base%.lhe}_DIGI.root"  --pileup_input "dbs:/Neutrino_E-10_gun/RunIISummer20ULPrePremix-UL18_106X_upgrade2018_realistic_v11_L1v1-v2/PREMIX" --mc --eventcontent PREMIXRAW --runUnscheduled --datatier GEN-SIM-DIGI --conditions 106X_upgrade2018_realistic_v16_L1v1 --step DIGI,DATAMIX,L1,DIGI2RAW --procModifiers premix_stage2 --nThreads 8 --geometry DB:Extended --datamix PreMix --era Run2_2018 --python_filename "SpinHalf_PF_configs/${base%.lhe}_DIGI_cfg.py" --no_exec -n -1 --customise_commands "from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper ; randSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService) ; randSvc.populate()"

        # Executar o comando cmsRun para a etapa DIGI e redirecionar o output para o diretório criado
        cmsRun "SpinHalf_PF_configs/${base%.lhe}_DIGI_cfg.py" #> "${dir}/${base%.lhe}_AOD/DIGI_output.txt"

        if [ $? -ne 0 ]; then
            echo "cmsRun command for DIGI failed for file: $file"
            exit 1
        fi

        echo "Processing for DIGI file $file completed successfully"

        # Quarta Etapa - HLT

        # Store the current directory path
        CURRENT_DIR=$(pwd)

        # Change to the specified directory
        cd /afs/cern.ch/user/m/matheus/CMSSW_10_2_16_UL/src

        cmsenv
        scram b clean
        scram b -j 8

        # Processar a etapa HLT no novo diretório
        echo "Processing HLT for file: $file"
        cmsDriver.py step2 --filein "file:${dir}/${base%.lhe}_AOD/${base%.lhe}_DIGI.root" --fileout "file:${dir}/${base%.lhe}_AOD/${base%.lhe}_HLT.root" --mc --eventcontent RAWSIM --datatier GEN-SIM-RAW --conditions 102X_upgrade2018_realistic_v15 --customise_commands 'process.source.bypassVersionCheck = cms.untracked.bool(True)' --step HLT:2018v32 --nThreads 8 --geometry DB:Extended --era Run2_2018 --python_filename "${CURRENT_DIR}/SpinHalf_PF_configs/${base%.lhe}_HLT_cfg.py" --no_exec -n -1

        if [ $? -ne 0 ]; then
            echo "HLT command failed for file: $file"
            exit 1
        fi

        # Execute the cmsRun command using the absolute path to the configuration file
        cmsRun "${CURRENT_DIR}/SpinHalf_PF_configs/${base%.lhe}_HLT_cfg.py" #> "${dir}/${base%.lhe}_AOD/HLT_output.txt"

        if [ $? -ne 0 ]; then
            echo "cmsRun command for HLT failed for file: $file"
            exit 1
        fi

        echo "Processing for HLT file $file completed successfully"

        # Return to the original directory

        cd /afs/cern.ch/user/m/matheus/CMSSW_10_6_23/src

        cmsenv
        scram b clean
        scram b -j 8

        # Última etapa: RECO
        echo "Processing RECO for file: $file"

        RECO_output="file:${dir}/${base%.lhe}_AOD/${base%.lhe}_RECO.root"

        cmsDriver.py step3 --filein "file:${dir}/${base%.lhe}_AOD/${base%.lhe}_HLT.root" --fileout "$RECO_output" --mc --eventcontent AODSIM --datatier AODSIM --conditions 106X_upgrade2018_realistic_v16_L1v1 --step RAW2DIGI,L1Reco,RECO,RECOSIM --nThreads 8 --runUnscheduled --geometry DB:Extended --era Run2_2018 --customise=Configuration/DataProcessing/Utils.addMonitoring --customise_commands "process.AODSIMoutput.outputCommands.append('keep *_generatorSmeared_*_*') \n process.AODSIMoutput.outputCommands.append('keep *_hybridSuperClusters_*_*') \n process.AODSIMoutput.outputCommands.append('keep *_multi5x5SuperClusters_multi5x5EndcapSuperClusters_*') \n process.AODSIMoutput.outputCommands.append('keep *_multi5x5SuperClusters_uncleanOnlyMulti5x5EndcapBasicClusters_*') \n process.AODSIMoutput.outputCommands.append('keep *_multi5x5SuperClusters_uncleanOnlyMulti5x5EndcapSuperClusters_*') \n process.AODSIMoutput.outputCommands.append('keep *_siStripClusters_*_*') \n process.AODSIMoutput.outputCommands.append('keep *_siPixelClusters_*_*') \n process.AODSIMoutput.outputCommands.append('drop *_generalTracks_*_*') \n process.AODSIMoutput.outputCommands.append('keep *_generalTracks_*_*') \n process.AODSIMoutput.outputCommands.append('drop *_generalTracks_QualityMasks_*') \n process.AODSIMoutput.outputCommands.append('keep *_ecalRecHit_EcalRecHitsEB_*') \n process.AODSIMoutput.outputCommands.append('keep *_ecalRecHit_EcalRecHitsEE_*') \n process.AODSIMoutput.outputCommands.append('keep *_hbhereco_*_*') \n process.Timing.summaryOnly = cms.untracked.bool(True) \n process.Timing.excessiveTimeThreshold = cms.untracked.double(30.0) \n" --python_filename "SpinHalf_PF_configs/${base%.lhe}_RECO_cfg.py" --no_exec -n -1

        if [ $? -ne 0 ]; then
            echo "RECO command failed for file: $file"
            exit 1
        fi

        # Executar o comando cmsRun para a etapa RECO e redirecionar o output para o diretório criado
        cmsRun "SpinHalf_PF_configs/${base%.lhe}_RECO_cfg.py" #> "${dir}/${base%.lhe}_AOD/RECO_output.txt"

        if [ $? -ne 0 ]; then
            echo "cmsRun command for RECO failed for file: $file"
            exit 1
        fi

        echo "Processing for RECO file $file completed successfully"
   
        AOD_output="${dir}/${base%.lhe}_AOD/${base%.lhe}_AOD.root"
    
        cmsRun /afs/cern.ch/user/m/matheus/CMSSW_10_6_23/src/ntuple_mc_2018_cfg.py inputFileName=$RECO_output outputFile=$AOD_output

    done
done
