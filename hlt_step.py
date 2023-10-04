import subprocess
import argparse
import os

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

def run_hlt(input_file):
    base_name = os.path.basename(input_file)
    base_name_without_ext = os.path.splitext(base_name)[0]
    base_name_without_suffix = base_name_without_ext.replace('_DIGI', '')
    output_path = "/eos/home-m/matheus/magnetic_monopole_output_AOD"  # change that path for your
    
    base_name_without_suffix = base_name_without_ext.replace('_DIGI', '')
    hlt_output_file = f"{output_path}/{base_name_without_suffix}_HLT.root"
    hlt_python_file = f"{base_name_without_ext}_HLT_cfg.py"
    
    hlt_command = [
        "cmsDriver.py", "step2",
        "--filein", f"file:{input_file}",
        "--fileout", f"file:{hlt_output_file}",
        "--mc",
        "--eventcontent", "RAWSIM",
        "--datatier", "GEN-SIM-RAW",
        "--conditions", "102X_upgrade2018_realistic_v15",
        "--customise_commands", "process.source.bypassVersionCheck = cms.untracked.bool(True)",
        "--step", "HLT:2018v32",
        "--nThreads", "8",
        "--geometry", "DB:Extended",
        "--era", "Run2_2018",
        "--python_filename", hlt_python_file,
        "--no_exec",
        "-n", "-1"
    ]
    
    if run_command(hlt_command, "HLT", input_file) != 0:
        return 1
    
    cmsrun_hlt_command = ["cmsRun", hlt_python_file]
    if run_command(cmsrun_hlt_command, "cmsRun for HLT", input_file) != 0:
        return 1
    
    print(f"Processing for HLT file {input_file} completed successfully")
    return 0

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run the HLT step")
    parser.add_argument("input_file", help="DIGI file to be process")
    
    args = parser.parse_args()
    
    exit_code = run_hlt(args.input_file)
    exit(exit_code)
