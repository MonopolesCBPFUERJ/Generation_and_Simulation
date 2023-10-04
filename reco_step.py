import subprocess
import argparse
import os

# Function to execute shell commands
def run_command(command_str, description, file):
    try:
        result = subprocess.run(command_str, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
        print(f"{description} successfully completed for file: {file}")
        print("Standard Output:", result.stdout)
        print("Standard Error:", result.stderr)
        return 0
    except subprocess.CalledProcessError as e:
        print(f"{description} command failed for file: {file}")
        print("Standard Output:", e.stdout)
        print("Standard Error:", e.stderr)
        return 1

# Function to execute the RECO step
def run_reco(input_file):
    base_name = os.path.basename(input_file)
    base_name_without_ext = os.path.splitext(base_name)[0]
    
    output_path = "/eos/home-m/matheus/magnetic_monopole_output_AOD"  # change that path for your
    base_name_without_hlt = base_name_without_ext.replace("_HLT", "")
    reco_output_file = f"{output_path}/{base_name_without_hlt}_RECO.root"
    reco_python_file = f"{base_name_without_hlt}_RECO_cfg.py"

    command_str = f"""cmsDriver.py step3 --filein file:{input_file} --fileout file:{reco_output_file} --mc --eventcontent AODSIM --datatier AODSIM --conditions 106X_upgrade2018_realistic_v16_L1v1 --step RAW2DIGI,L1Reco,RECO,RECOSIM --nThreads 8 --runUnscheduled --geometry DB:Extended --era Run2_2018 --customise=Configuration/DataProcessing/Utils.addMonitoring --customise_commands "process.AODSIMoutput.outputCommands.append('keep *_generatorSmeared_*_*'); process.AODSIMoutput.outputCommands.append('keep *_hybridSuperClusters_*_*'); process.AODSIMoutput.outputCommands.append('keep *_multi5x5SuperClusters_multi5x5EndcapSuperClusters_*'); process.AODSIMoutput.outputCommands.append('keep *_multi5x5SuperClusters_uncleanOnlyMulti5x5EndcapBasicClusters_*'); process.AODSIMoutput.outputCommands.append('keep *_multi5x5SuperClusters_uncleanOnlyMulti5x5EndcapSuperClusters_*'); process.AODSIMoutput.outputCommands.append('keep *_siStripClusters_*_*'); process.AODSIMoutput.outputCommands.append('keep *_siPixelClusters_*_*'); process.AODSIMoutput.outputCommands.append('drop *_generalTracks_*_*'); process.AODSIMoutput.outputCommands.append('keep *_generalTracks_*_*'); process.AODSIMoutput.outputCommands.append('drop *_generalTracks_QualityMasks_*'); process.AODSIMoutput.outputCommands.append('keep *_ecalRecHit_EcalRecHitsEB_*'); process.AODSIMoutput.outputCommands.append('keep *_ecalRecHit_EcalRecHitsEE_*'); process.AODSIMoutput.outputCommands.append('keep *_hbhereco_*_*'); process.Timing.summaryOnly = cms.untracked.bool(True); process.Timing.excessiveTimeThreshold = cms.untracked.double(30.0);" --python_filename {reco_python_file} --no_exec -n -1"""
    return run_command(command_str, "RECO processing", input_file)

# Function to run cmsRun
def run_cmsRun(cfg_file):
    command_str = f"cmsRun {cfg_file}"
    return run_command(command_str, "cmsRun execution", cfg_file)

# Main entry point
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Executes the RECO step of the detector passage simulation.")
    parser.add_argument("input_file", help=".root file to be processed in the RECO step.")
    
    args = parser.parse_args()
    
    exit_code = run_reco(args.input_file)
    if exit_code == 0:
        base_name = os.path.basename(args.input_file)
        base_name_without_ext = os.path.splitext(base_name)[0]
        base_name_without_hlt = base_name_without_ext.replace("_HLT", "")
        cfg_file = f"{base_name_without_hlt}_RECO_cfg.py"  
        exit_code = run_cmsRun(cfg_file)
    exit(exit_code)
