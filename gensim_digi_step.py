import argparse
import subprocess
import os
import re

# ------------------ Run this comands before execute alls codes ------------------
# voms-proxy-init --rfc --voms cms -valid 192:00 -out $HOME/x509up_u130329
# cmsenv
# scram b -j 4

def extract_mass_from_filename(filename):
    match = re.search(r'_mass_([0-9]+)_events', filename)
    return match.group(1) if match else None

def run_command(command, description, file):
    try:
        result = subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
        print(f"{description} successfully completed for file: {file}")
        print("Standard Output:")
        print(result.stdout)
        print("Standard Error:")
        print(result.stderr)
        return 0
    except subprocess.CalledProcessError as e:
        print(f"{description} command failed for file: {file}")
        print("Standard Output:")
        print(e.stdout)
        print("Standard Error:")
        print(e.stderr)
        return 1

def run_pipeline(input_file):
    base_name = os.path.basename(input_file)
    base_name_without_ext = os.path.splitext(base_name)[0]
    
    output_path = "/eos/home-m/matheus/magnetic_monopole_output_AOD" #change that path for your
    
    # First step: LHE
    lhe_output_file = f"{output_path}/{base_name_without_ext}_LHE.root"
    lhe_python_file = f"{base_name_without_ext}_LHE_cfg.py"

    
    lhe_command = [
    "cmsDriver.py", "step1",
    "--filein", f"file:{input_file}",
    "--fileout", f"file:{lhe_output_file}",
    "--mc",
    "--eventcontent", "LHE",
    "--datatier", "LHE",
    "--conditions", "106X_upgrade2018_realistic_v16_L1v1",
    "--step", "NONE",
    "--python_filename", lhe_python_file,
    "--no_exec",
    "-n", "-1",
    "--customise_commands", "process.source.firstLuminosityBlock = cms.untracked.uint32(3)"
    ]   
    
    # Run the cmsDriver.py for LHE step
    if run_command(lhe_command, "cmsDriver.py for LHE", input_file) != 0:
        return 1

    # Run the cmsRun for LHE step
    cmsrun_lhe_command = ["cmsRun", lhe_python_file]
    if run_command(cmsrun_lhe_command, "cmsRun for LHE", input_file) != 0:
        return 1
        
    print('Step LHE completed successfully')    
    # Second step: GENSIM
    mass = extract_mass_from_filename(base_name)
    gensim_output_file = f"{output_path}/{base_name_without_ext}_GENSIM.root"
    gensim_python_file = f"{base_name_without_ext}_GENSIM_cfg.py"
    
    gensim_command = [
    "cmsDriver.py", "Configuration/GenProduction/python/Hadronizer_TuneCP5_13TeV_generic_LHE_pythia8_cff.py",
    "--filein", f"file:{lhe_output_file}",
    "--fileout", f"file:{gensim_output_file}",
    "--mc",
    "--eventcontent", "RAWSIM",
    "--datatier", "GEN-SIM",
    "--conditions", "106X_upgrade2018_realistic_v16_L1v1",
    "--step", "GEN,SIM",
    "--beamspot", "Realistic25ns13TeVEarly2018Collision",
    "--geometry", "DB:Extended",
    "--era", "Run2_2018",
    "--python_filename", gensim_python_file,
    "--customise_commands", f"from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper ; randSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService) ; randSvc.populate(); process.g4SimHits.Physics.MonopoleMass = {mass}",
    "--no_exec",
    "--nThreads", "8",
    "-n", "-1"
    ]
    
    # Retry logic for GENSIM
    max_retries = 2
    retry_count = 0
    
    while retry_count <= max_retries:
        if run_command(gensim_command, "GENSIM", input_file) == 0:
            break
        print(f"GENSIM failed for file: {input_file}. Retry count: {retry_count}")
        retry_count += 1
    
    if retry_count > max_retries:
        print("Max retries reached for GENSIM. Exiting.")
        return 1

    # Run the cmsRun for GENSIM Step
    cmsrun_gensim_command = ["cmsRun", gensim_python_file]
    if run_command(cmsrun_gensim_command, "cmsRun for GENSIM", input_file) != 0:
        return 1

    print('GENSIM Step successfully completed')        
    
    # Third step: DIGI
    digi_output_file = f"{output_path}/{base_name_without_ext}_DIGI.root"
    digi_python_file = f"{base_name_without_ext}_DIGI_cfg.py"
    
    digi_command = [
        "cmsDriver.py", "step1",
        "--filein", f"file:{gensim_output_file}",
        "--fileout", f"file:{digi_output_file}",
        "--pileup_input", "dbs:/Neutrino_E-10_gun/RunIISummer20ULPrePremix-UL18_106X_upgrade2018_realistic_v11_L1v1-v2/PREMIX",
        "--mc",
        "--eventcontent", "PREMIXRAW",
        "--runUnscheduled",
        "--datatier", "GEN-SIM-DIGI",
        "--conditions", "106X_upgrade2018_realistic_v16_L1v1",
        "--step", "DIGI,DATAMIX,L1,DIGI2RAW",
        "--procModifiers", "premix_stage2",
        "--nThreads", "8",
        "--geometry", "DB:Extended",
        "--datamix", "PreMix",
        "--era", "Run2_2018",
        "--python_filename", digi_python_file,
        "--no_exec",
        "-n", "1000",
        "--customise_commands", "from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper ; randSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService) ; randSvc.populate()"
    ]
    
    # Running cmsDriver.py for the DIGI step
    if run_command(digi_command, "cmsDriver.py for DIGI", input_file) != 0:
        return 1

    # Running cmsRun for the DIGI step
    cmsrun_digi_command = ["cmsRun", digi_python_file]
    if run_command(cmsrun_digi_command, "cmsRun for DIGI", input_file) != 0:
        return 1

    print(f"Processing for DIGI file {input_file} completed successfully")
    return 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Runs a simulation pipeline of the detector pass.")
    parser.add_argument("input_file", help=".lhe file to be processed.")
    
    args = parser.parse_args()
    
    exit_code = run_pipeline(args.input_file)
    exit(exit_code)
